//
//  ChatVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/26/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ChatVC.h"
#import <QuartzCore/QuartzCore.h>

#import "MessageView.h"
#import "MessageData.h"
#import "IPChangeNotifier.h"

#define MESSAGE_SENDER_ME           @(0)
#define MESSAGE_SENDER_OTHER        @(1)

#define MESSAGE_TYPE_TEXT           ((int) 0)


@interface ChatVC (){
    
    
    NSMutableArray *chatRoomMemberList;
    NSMutableArray * messageDataList;
}

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    messageDataList = [[NSMutableArray alloc] init];
    chatRoomMemberList = [[NSMutableArray alloc] init];
    
    self.chatTextField.delegate = self;
    self.memberTextView.delegate = self;

    
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    
    [self initWithNotification];
    [self initWithUISetup];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    aTap.cancelsTouchesInView = NO;
    aTap.delegate = self;
    [self.view addGestureRecognizer:aTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated {
    

    
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Helpers

-(void)initWithNotification {
    
    //UDP Response Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageReceived:) name:NOTIFICATIONKEY_CHAT_MESSAGE_RECEIVED object:nil];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinChannelRequestReceived:) NOTIFICATIONKEY_CHANNEL_JOINED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChannelLeftMessageReceieved:) name:NOTIFICATIONKEY_CHANNEL_LEFT object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceJoined:) name:NOTIFICATIONKEY_NEW_DEVICE_JOINED_APPDELEGATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newDeviceConfirmed:) name:NOTIFICATIONKEY_NEW_DEVICE_CONFIRMED_APPDELEGATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileInfoNotification:) name:NOTIFICATIONKEY_UPDATE_PROFILE_INFO_APPDELEGATE object:nil];
}

-(void)initWithUISetup {
    
    
    self.chatTableView.separatorColor = [UIColor clearColor];
    
    self.backBtn.layer.cornerRadius = 5;
    self.backBtn.clipsToBounds = YES;

    self.memberTextView.editable = NO;
    self.sendBtn.enabled = NO;
    
    self.channelNameLabel.text = [UserHandler sharedInstance].mySelf.profileStatus;
    
    NSMutableString *memberListStr = [[NSMutableString alloc] init];
    
    NSArray *channelMembers = [self.currentActiveChannel getMembers];
    for (User *member in channelMembers) {
        
        [memberListStr appendFormat:@"%@ | ", member.profileName];
    }
    [memberListStr deleteCharactersInRange:NSMakeRange([memberListStr length]-3, 3)];
    
    self.memberTextView.text = memberListStr;
    
}


#pragma mark - IBAction

- (IBAction)sendBtnPress:(id)sender {
    
    NSString * deviceName = [UserHandler sharedInstance].mySelf.profileName;
    
    
    NSString *chatMessageToSend = [[MessageHandler sharedHandler] createChatMessageWithChannelID:self.currentActiveChannel.channelID deviceName:deviceName chatmessage:self.chatTextField.text];
    
    
    NSArray *channelMembers = [self.currentActiveChannel getMembers];
    
    for (User *member in channelMembers) {
        
        
        [[ConnectionHandler sharedHandler] sendMessage:chatMessageToSend toIPAddress:member.deviceIP];
    }
    
    MessageData * messageData = [[MessageData alloc] initWithSender:@"Me"  type:MESSAGE_TYPE_TEXT message:self.chatTextField.text direction:MESSAGE_DIRECTION_SEND];
    [self updateUIForChatMessage:messageData];
    
    self.chatTextField.text = @"";
    self.sendBtn.enabled = NO;
}

- (IBAction)backBtnPress:(id)sender {
    
    //[[ChannelManager sharedInstance] setCurrentChannel:nil];
    [ChannelManager sharedInstance].isChannelOpen = NO;
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Helper

-(void)updateUIForChatMessage:(MessageData *)messagedData {
    
    [messageDataList addObject:messagedData];
    
    NSIndexPath * indexPathOfYourCell = [NSIndexPath indexPathForRow:([messageDataList count] - 1) inSection:0];
    
    [self.chatTableView beginUpdates];
    [self.chatTableView insertRowsAtIndexPaths:@[indexPathOfYourCell] withRowAnimation:UITableViewRowAnimationFade];
    [self.chatTableView endUpdates];
    
    // Scroll to the bottom so we focus on the latest message
    NSUInteger numberOfRows = [self.chatTableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [self.chatTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark - Noticfication
#pragma mark Observer

-(void) chatMessageReceived:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    
    NSString *senderName = [jsonDict objectForKey:JSON_KEY_DEVICE_NAME];
    NSString *message = [jsonDict objectForKey:JSON_KEY_MESSAGE];
    
    MessageData *messageData = [[MessageData alloc] initWithSender:senderName type:MESSAGE_TYPE_TEXT message:message direction:MESSAGE_DIRECTION_RECEIVE];
    [self updateUIForChatMessage:messageData];
}


-(void) joinChannelRequestReceived:(NSNotification*)notification{
    

        
//    NSDictionary* userInfo = notification.userInfo;
//    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
//    NSLog (@"Successfully received native Channel joined notification! %@", [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]);
//    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
//    
//    int requestChannelID = [[jsonDict objectForKey:JSON_KEY_CHANNEL] intValue];
//    
//    if(self.currentActiveChannel.channelID == requestChannelID) {
//        
//        //sendJoiningChannelConfirmationMessage
//        
//        User *requestMember = [[User alloc] initWithIP:jsonDict[JSON_KEY_IP_ADDRESS] deviceID:jsonDict[JSON_KEY_DEVICE_ID] name:jsonDict[JSON_KEY_DEVICE_NAME] andActive:YES];
//        [self.currentActiveChannel addMember:requestMember];
//        [self.currentActiveChannel setActive:YES toUser:requestMember];
//        
//        NSString *myChannelName = [UserHandler sharedInstance].mySelf.deviceName;
//        NSString *confirmationMessageForJoiningChannel = [[MessageHandler sharedHandler] joiningChannelConfirmationMessageOf:requestChannelID channelName:myChannelName];
//        
//        
//        
//        //Send
//        [[asyncUDPConnectionHandler sharedHandler] sendMessage:confirmationMessageForJoiningChannel toIPAddress:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]];
//        
//        
//        
//        //Update updateChannelMemberTable
//        [self updateChannelMemberTable];
//    }
    
}


-(void) ChannelLeftMessageReceieved:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
//    User * leftMember = [[User alloc] initWithDictionary:jsonDict];
//    [self.currentActiveChannel setActive:NO toUser:leftMember];
    
    //Update the Chat member TextView
    //[self updateChannelMemberTable];
    
}


-(void) newDeviceJoined:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User
    User *newUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [self addChannelMember:newUser];
}

-(void) newDeviceConfirmed:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User
    User *newUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [self addChannelMember:newUser];
}

-(void) updateProfileInfoNotification:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User
    User *newUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [self addChannelMember:newUser];
}


-(void)addChannelMember:(User *)newUser{
    
        
    NSArray *statusAry = [MessageHandler sharedHandler].statusArray;
    
    if(newUser.statusChannel != -1 && newUser.statusChannel < statusAry.count && newUser.statusChannel == [UserHandler sharedInstance].mySelf.statusChannel){
        //add member
        
        [self.currentActiveChannel addMember:newUser];
    }
    
}

#pragma mark UITableViewDataSource



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return messageDataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Get the transcript for this row
    MessageData *messageData = [messageDataList objectAtIndex:indexPath.row];

    UITableViewCell *cell;
    //if (messageData.type == kFileTypeAudio)

    cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCellID" forIndexPath:indexPath];
    MessageView *messageView = (MessageView *)[cell viewWithTag:MESSAGE_VIEW_TAG];
    messageView.messageData = messageData;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = cell.contentView.backgroundColor;
    
    return cell;

}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    MessageData *messageData = [messageDataList objectAtIndex:indexPath.row];
    
    CGFloat rowHeight = [MessageView viewHeightForTranscript:messageData];
    
    return rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageData *messageData = [messageDataList objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isDescendantOfView:self.sendBtn] || [touch.view isDescendantOfView:self.backBtn]) {//change it to your condition
        return NO;
    }
    
    return YES;
}



-(void)ScreenTapped {
    
    [self.view endEditing:YES];
    self.bottomSpaceForSendContainer.constant = 0;
    [self.view layoutIfNeeded];
}

-(void)keyboardWasShown:(NSNotification*)notification {
    
    CGFloat height = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey ] CGRectValue].size.height;
    
    self.bottomSpaceForSendContainer.constant = height;
    [self.view layoutIfNeeded];
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (textField.text.length > 0)
    {
        self.sendBtn.enabled = YES;
    }
    else
    {
        self.sendBtn.enabled = NO;
    }
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (textField.text.length > 1 || (string.length > 0 && ![string isEqualToString:@""]))
    {
        self.sendBtn.enabled = YES;
    }
    else
    {
        self.sendBtn.enabled = NO;
    }
    
    return YES;
}

#pragma mark - IPChangeNotifier
-(void) IPChangeDetected:(NSString*)newIP previousIP:(NSString*)oldIP {
    // Do what you need
}



#pragma mark - Extra

/*
 
 -(void)sendChannelLeaveMessage{
 
 int channelID = self.isPrivateChannel ? kChannelIDPersonal : self.currentActiveChannel.channelID;
 NSString *deviceName = [UserHandler sharedInstance].mySelf.deviceName;
 
 NSString *leaveMessageToSend = [[MessageHandler sharedHandler] leaveChatMessageWithChannelID:channelID  deviceName:deviceName];
 
 if(self.isPrivateChannel){
 
 [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:self.oponentUser.deviceIP];
 
 }else{
 
 NSArray *channelMembers = [self.currentActiveChannel getMembers];
 
 for (User *member in channelMembers) {
 
 [[asyncUDPConnectionHandler sharedHandler]sendMessage:leaveMessageToSend toIPAddress:member.deviceIP];
 }
 
 }
 }
 
 -(void)updateChannelMemberTable{
 
 chatRoomMemberList = [[NSMutableArray alloc] init];
 
 
 
 User *mySelf = [UserHandler sharedInstance].mySelf;
 //    if([ChannelManager sharedInstance].isHost){
 //
 //        mySelf.deviceName = [NSString stringWithFormat:@"%@ Owner", mySelf.deviceName];
 //    }
 [chatRoomMemberList addObject:mySelf];
 
 NSArray *members =  [self.currentActiveChannel getMembers];
 for(User * member in members){
 
 [chatRoomMemberList addObject:member];
 }
 
 [self.channelMemberTableView reloadData];
 }
 
*/

@end
