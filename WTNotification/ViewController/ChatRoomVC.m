//
//  ChatRoomVC.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/28/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ChatRoomVC.h"
#import "ChatRoomTVC.h"
#import "ChatVC.h"

@interface ChatRoomVC (){
    
    NSArray *StatusList;
    NSArray *statusImageList;
}

@end

@implementation ChatRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    StatusList = [MessageHandler sharedHandler].statusArray;
    statusImageList = [MessageHandler sharedHandler].statusImageArray;
    
    self.statusTableView.dataSource = self;
    self.statusTableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return StatusList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = @"chatRoomCellID";
    
    ChatRoomTVC *cell =  (ChatRoomTVC *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    
    NSString *statusStr = StatusList[indexPath.row];
    
    cell.statusLabel.text =statusStr;
    cell.statusImageView.image = [UIImage imageNamed:statusImageList[indexPath.row]];
    return cell;
}



#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"channelID: %ld", indexPath.row);
    
    int channelID = (int)indexPath.row;
    Channel *channel = [[Channel alloc] initChannelWithID:channelID];
    
    [[ChannelManager sharedInstance] setCurrentChannel:channel];
    [ChannelManager sharedInstance].isChannelOpen = YES;
    
    //send then notification
    [[MessageHandler sharedHandler] sendChanneljoiningMessageOf:channelID];
    
    //navigate to chatview controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChatVC *chatVC = (ChatVC *)[storyboard instantiateViewControllerWithIdentifier:@"ChatVCID"];
    
    chatVC.currentActiveChannel = [ChannelManager sharedInstance].currentChannel;
    [self.navigationController pushViewController:chatVC animated:YES];
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
