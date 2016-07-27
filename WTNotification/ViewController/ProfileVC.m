//
//  ProfileVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/22/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ProfileVC.h"
#import "SelectTVC.h"
#import "ChatVC.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <QuartzCore/QuartzCore.h>

#define kDescriptionPlaceholder @"Write your status ..."

typedef void(^myCompletion)(BOOL);

typedef enum ActiveField : NSUInteger {
    kActiveTextField,
    kActiveTextView
} ActiveField;

@interface ProfileVC (){
    
    UIImage *uploadedResizedImage;
    
    
    ActiveField activeField;
    UITextField *activeTextField;
    UITextView * activeTextView;

    BOOL isWriting;
    
    int statusChannel;
    
    NSArray *statusAry;
    
    UILabel *placeholderLabel;
}

@end

@implementation ProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNumber *profileStatusChannel = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_KEY_STATUS_CHANNEL];
    statusChannel = profileStatusChannel.intValue;
    self.usernameTF.delegate = self;
    self.statusTF.delegate = self;
    self.writeStatusTextView.delegate = self;
    
    self.selectStatusTableView.dataSource = self;
    self.selectStatusTableView.delegate = self;
    
    
    //Initialise
    // Chess, Lunch, Coffee, Pool, Football, Board Games, Hangout, Walk, Run
    statusAry = [MessageHandler sharedHandler].statusArray;
    
    User *mySelf = [UserHandler sharedInstance].mySelf;
    
    self.usernameTF.text = mySelf.profileName;
    self.statusTF.text = mySelf.profileStatus;
    
    
    
    
    
    if(mySelf.profileImageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:mySelf.profileImageName OfType:kFileTypePhoto];
        UIImage *proImage = [UIImage imageWithContentsOfFile:imagePath];
        
        if(proImage != nil){
            self.profileImageView.image = proImage;
        }else{
            self.profileImageView.image = [UIImage imageNamed: @"no-profile.png"];
            
        }
        
    }else{
        self.profileImageView.image = [UIImage imageNamed: @"no-profile.png"];
    }
    
    
    
    [self configUI];
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *aTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ScreenTapped)];
    aTap.cancelsTouchesInView = NO;
    aTap.delegate = self;
    [self.view addGestureRecognizer:aTap];

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnProfileImage)];
    singleTap.numberOfTapsRequired = 1;
    self.profileImageView.userInteractionEnabled = YES;
    [self.profileImageView addGestureRecognizer:singleTap];
    
}


-(void) configUI {
    
    self.popupView.hidden = YES;
    
    //Adjust The view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    CGFloat AdjustMiddleHeight = screenHeight - 488;
    
    if(AdjustMiddleHeight < 40){
        AdjustMiddleHeight = 40;
    }
    
    self.middleConstraint.constant = AdjustMiddleHeight;
    [self.view layoutIfNeeded];
    
    
    //
    
    self.postBtn.layer.cornerRadius = 5;
    self.postBtn.clipsToBounds = YES;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    
    self.profileImageView.layer.borderWidth = 2.0f;
    UIColor *defaultColor = UIColorFromRGB(0x00a651);
    self.profileImageView.layer.borderColor = defaultColor.CGColor;
    
    
    self.popupView.layer.cornerRadius = 5;
    self.popupView.clipsToBounds = YES;
    
    self.statusPopupView.layer.cornerRadius = 5;
    self.statusPopupView.clipsToBounds = YES;
    
    
    [[self.writeStatusTextView layer] setBorderColor:[[UIColor whiteColor] CGColor]];
    [[self.writeStatusTextView layer] setBorderWidth:2];
    [[self.writeStatusTextView layer] setCornerRadius:10];
    
    
    //Set PlaceHolder
    // you might have to play around a little with numbers in CGRectMake method
    // they work fine with my settings
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.writeStatusTextView.frame.size.width - 20.0, 34.0)];
    [placeholderLabel setText:kDescriptionPlaceholder];
    // placeholderLabel is instance variable retained by view controller
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setFont:self.writeStatusTextView.font];
    [placeholderLabel setTextColor:[UIColor lightGrayColor]];
    

    // textView is UITextView object you want add placeholder text to
    [self.writeStatusTextView addSubview:placeholderLabel];
    
    //self.writeStatusTextView.text = @"Write your status ...";
    //self.writeStatusTextView.textColor = [UIColor lightGrayColor];
    
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    if(activeField == kActiveTextField){
        
        if (!CGRectContainsPoint(aRect, activeTextField.frame.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, activeTextField.frame.origin.y-kbSize.height);
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }else{
        
        if (!CGRectContainsPoint(aRect, activeTextView.frame.origin) ) {
            
            CGPoint scrollPoint = CGPointMake(0.0, activeTextView.frame.origin.y-kbSize.height);
            
            [self.scrollView setContentOffset:scrollPoint animated:YES];
        }
    }
    

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}




#pragma mark - IBAction

- (IBAction)tapOnChangeBtnPress:(UIButton *)sender {
    
    [self tapOnProfileImage];
    
}

-(void)tapOnProfileImage{
    NSLog(@"single Tap on imageview");
    
    
    [self togglePopupView];
    
    
    /*
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Select Options" message:@"Either capture an image from the camera or open from the Photo Library." preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Camera button tapped.
        [self dismissViewControllerAnimated:NO completion:NULL];
        
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // Photo Gallery button tapped.
        [self dismissViewControllerAnimated:NO completion:nil];
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    */
    
}

- (IBAction)postBtnPress:(UIButton *)sender {
    
    if(!self.popupView.hidden){
        [self tapOnProfileImage];
    }
    
    if(uploadedResizedImage != nil || self.statusTF.text.length || self.usernameTF.text.length){
        
        [SVProgressHUD showWithStatus:@"Please wait ..."];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // long-running code
            //Name
            if(self.usernameTF.text.length){
                
                NSString * name = self.usernameTF.text;
                [UserHandler sharedInstance].mySelf.profileName = name;
                
                [[NSUserDefaults standardUserDefaults] setObject:name forKey:USERDEFAULTS_KEY_NAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //status
            if(self.statusTF.text.length){
                
                [UserHandler sharedInstance].mySelf.profileStatus = self.statusTF.text;
                
                [[NSUserDefaults standardUserDefaults] setObject:self.statusTF.text forKey:USERDEFAULTS_KEY_STATUS];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            //statusChannel
            [UserHandler sharedInstance].mySelf.statusChannel = statusChannel;
            [[NSUserDefaults standardUserDefaults] setObject:@(statusChannel) forKey:USERDEFAULTS_KEY_STATUS_CHANNEL];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //save the image
            if(!CGSizeEqualToSize(uploadedResizedImage.size, CGSizeZero)){
                
                NSData *imageData = UIImagePNGRepresentation(uploadedResizedImage);
                NSString *fileName = [NSString stringWithFormat:@"%@.png",[UserHandler sharedInstance].mySelf.deviceID];
                NSString *imagePath = [[FileHandler sharedHandler] writeData:imageData toFileName:fileName ofType:kFileTypePhoto];
                
                [UserHandler sharedInstance].mySelf.profileImageName = fileName;
                
                [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:USERDEFAULTS_KEY_IMAGE];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            [self sendPostMessageWithCompletionBlock:^(BOOL finished) {
                
                if(finished){
                    
                    NSLog(@"Successfully finished.");
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Successfully notification send."
                                                                    message: @""
                                                                   delegate: self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    alert.tag = 50;
                    [alert show];
                    
                    
                }
            }];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD dismiss];
            });
        });
        
        
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"All Empty. please update something."
                                                        message: @""
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
    
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 55){
        
        if(buttonIndex == 0){
            
            //Decline, send Reply
            
            
        }else if(buttonIndex == 1){
            
            int channelID = [UserHandler sharedInstance].mySelf.statusChannel;
            Channel *channel = [[Channel alloc] initChannelWithID:channelID];
            
            NSArray *memberOfSameStatus = [[UserHandler sharedInstance] getAllUsersOfSameStatus];
            for (User *member in memberOfSameStatus) {
                [channel addMember:member];
            }
            
            [[ChannelManager sharedInstance] setCurrentChannel:channel];
            
            //navigate to chatview controller
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatVC *chatVC = (ChatVC *)[storyboard instantiateViewControllerWithIdentifier:@"ChatVCID"];
            
            
            chatVC.currentActiveChannel = [[ChannelManager sharedInstance] currentChannel];
            
            //UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            //self.navigationController
            [self.navigationController pushViewController:chatVC animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    
    if(alertView.tag == 50){
        
        NSArray *sameStatusUser = [[UserHandler sharedInstance] getAllUsersOfSameStatus];
        if (buttonIndex == 0 && sameStatusUser.count) {
            //search same status user
            
            NSString * statusStr = [UserHandler sharedInstance].mySelf.profileStatus;
            
            NSString *message =  [NSString stringWithFormat:@"Others have the same \"%@\" status as yours. Would you like to join them?", statusStr];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Chatting Request"
                                                            message: message
                                                           delegate: self
                                                  cancelButtonTitle:@"Decline"
                                                  otherButtonTitles:@"Accept", nil];
            
            alert.tag = 55;
            [alert show];
            
            
        }
    }
}



#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(textField.tag == self.statusTF.tag){
        [textField resignFirstResponder];
        [self toggleStatusPopupView];
        
    }
    
    
    if(!self.popupView.hidden){
        [self tapOnProfileImage];
    }
    
    activeField = kActiveTextField;
    activeTextField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if(textField.tag == self.statusTF.tag){
        return NO;
    }
    
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 128;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if (([touch.view isDescendantOfView:self.popupView])) {//change it to your condition
        return NO;
    }
    
    if (([touch.view isDescendantOfView:self.statusPopupView])) {//change it to your condition
        
        if (!([touch.view isDescendantOfView:self.writeStatusTextView])) {
            [self.view endEditing:YES];
        }
        
        return NO;
    }
    

    return YES;
}

-(void)ScreenTapped {
    
    [self.view endEditing:YES];
    
    if(!self.popupView.hidden){
        [self tapOnProfileImage];
    }
    if(!self.statusPopupView.hidden){
        [self toggleStatusPopupView];
    }

}



#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    UIImage *uploadedImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    NSData *imageData = UIImagePNGRepresentation(uploadedImage);
    
    //resize the image
    uploadedResizedImage = [[FileHandler sharedHandler] resizeImage:uploadedImage];
    
    imageData = UIImagePNGRepresentation(uploadedResizedImage);
    
    self.profileImageView.image = uploadedResizedImage;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self togglePopupView];
}


- (void)sendPostMessageWithCompletionBlock:(myCompletion) completionBlock {
    
    
    NSString *postMessage = [[MessageHandler sharedHandler] postMessage];
    
    NSUInteger bytes = [postMessage lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%lu bytes", (unsigned long)bytes);
    
    [[ConnectionHandler sharedHandler] enableBroadCast];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSArray *channelMembers = [[UserHandler sharedInstance] getAllUserIPs];
        
        for (NSString *ipAddress in channelMembers) {
            
            [[ConnectionHandler sharedHandler] sendMessage:postMessage toIPAddress:ipAddress];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionBlock(YES);
        });
    });
    
}



#pragma mark - popup

-(void)togglePopupView {
    
    if (!self.popupView.hidden) {
        
        [UIView transitionWithView:self.popupView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.popupView.hidden = YES;
                            self.backgroundView.hidden = YES;
                        }
                        completion:NULL];
        
        
    } else {
        
        [UIView transitionWithView:self.popupView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.popupView.hidden = NO;
                            self.backgroundView.hidden = NO;
                        }
                        completion:NULL];
        
    }
}

- (IBAction)cancelBtnPress:(id)sender {
    
    [self togglePopupView];
}

- (IBAction)galleryBtnPress:(id)sender {
    
    [self togglePopupView];
    
    // Photo Gallery button tapped.
    [self dismissViewControllerAnimated:NO completion:nil];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)cameraBtnPress:(id)sender {
    
    [self togglePopupView];
    
    // Camera button tapped.
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - StatusPopup

-(void)toggleStatusPopupView {
    
    if (!self.statusPopupView.hidden) {
        
        
        [UIView transitionWithView:self.statusPopupView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.statusPopupView.hidden = YES;
                            self.backgroundView.hidden = YES;
                            //self.scrollView.backgroundColor = [UIColor whiteColor];
                        }
                        completion:NULL];
        
        
    } else {
        
//        UIView *aView = [[UIView alloc] initWithFrame:self.view.frame];
//        aView.backgroundColor = [UIColor grayColor];
//        [self.view addSubview:aView];
        
        [self.WriteStatusBtn setTitle:@"Write Your Status" forState:UIControlStateNormal];
        self.StatusPopupTitle.text = @"Your Status";
        isWriting = NO;
        
        
        self.selectStatusTableView.hidden=NO;
        self.writeStatusTextView.hidden = YES;
        
        [UIView transitionWithView:self.statusPopupView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.statusPopupView.hidden = NO;
                            self.backgroundView.hidden = NO;
                            //self.scrollView.backgroundColor = [UIColor lightGrayColor];
                        }
                        completion:NULL];
        
    }
}

- (IBAction)statusCancelBtnPress:(id)sender {
    
    [self toggleStatusPopupView];
}

- (IBAction)writeStatusBtnPress:(id)sender {
    
    
    
    if(!isWriting){
        
        isWriting = YES;
        
        self.selectStatusTableView.hidden=YES;
        self.writeStatusTextView.hidden = NO;
        
        [self.WriteStatusBtn setTitle:@"Done" forState:UIControlStateNormal];
        self.StatusPopupTitle.text = @"Write Your Status";
    }else{

        statusChannel = -1;
        self.statusTF.text = self.writeStatusTextView.text;
        [self toggleStatusPopupView];
    }
    
}


#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//    }
    
    return textView.text.length + (text.length - range.length) <= 128;
    
    //return YES;
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    
    //    textView.text = @"";
    //    textView.textColor = [UIColor whiteColor];
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    NSLog(@"Did begin editing");
    activeField = kActiveTextView;
    activeTextView = textView;
}




- (void) textViewDidChange:(UITextView *)textView
{
    if(![textView hasText]) {
        [textView addSubview:placeholderLabel];
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 1.0;
        }];
    } else if ([[textView subviews] containsObject:placeholderLabel]) {
        
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [placeholderLabel removeFromSuperview];
        }];
    }
}


-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    //[textView resignFirstResponder];
//    if (isEditing) {
//        return NO;
//    }else{
//        return YES;
//    }
    
    return YES;
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (![textView hasText]) {
        [textView addSubview:placeholderLabel];
        [UIView animateWithDuration:0.15 animations:^{
            placeholderLabel.alpha = 1.0;
        }];
    }
}


#pragma mark - Table View Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section{
    return [statusAry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"SelectTVCID";
    
    SelectTVC *cell =  (SelectTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc]initWithStyle: UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    
    NSString *statusStr = statusAry[indexPath.row];

    cell.StatusLabel.text =statusStr;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    statusChannel = indexPath.row;
    
    NSString *StatusStr = statusAry[indexPath.row];
    self.statusTF.text = StatusStr;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self toggleStatusPopupView];
}
@end
