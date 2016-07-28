//
//  AppDelegate.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatVC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Create Socket
    [[ConnectionHandler sharedHandler] createSocketWithPort:WTNOTIFICATION_PORT_ACTIVE];
    //[[ConnectionHandler sharedHandler] createSocketWithPort:WTNOTIFICATION_PORT_FILE];
    
    
    NSString *ipAddress = [[MessageHandler sharedHandler] getIPAddress];
    BOOL success = [[MessageHandler sharedHandler] isValidIPAddress:ipAddress];
    
    if(success){
        
        NSLog(@"Success");
    }else{
        NSLog(@"Fail");
        
        if (!self.alertShowing) {
            
            self.alertView = [[UIAlertView alloc] initWithTitle:@"No Wifi Connection"
                                               message:@"Please Enable Wifi connection & try again."
                                              delegate:self
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil];
            //[alert show];
            self.alertShowing = YES;
            self.alertView.tag= 99;
            [self.alertView performSelector:@selector(show) withObject:nil afterDelay:0.0];
        }
        

    }
    
    NSString *deviceUUID = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_KEY_UUID];
    if (!deviceUUID) {
        deviceUUID = [[NSUUID UUID]  UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:deviceUUID forKey:USERDEFAULTS_KEY_UUID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSString *profileName = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_KEY_NAME];
    if(!profileName.length){
        profileName = [UIDevice currentDevice].name;
        [[NSUserDefaults standardUserDefaults] setObject:profileName forKey:USERDEFAULTS_KEY_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *profileImage = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_KEY_IMAGE];
    if(!profileImage.length){
        
        profileImage = @"";
        [[NSUserDefaults standardUserDefaults] setObject:profileImage forKey:USERDEFAULTS_KEY_IMAGE];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString *profileStatus = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_KEY_STATUS];
    if(!profileStatus.length){
        
        profileStatus = @"";
        [[NSUserDefaults standardUserDefaults] setObject:profileStatus forKey:USERDEFAULTS_KEY_STATUS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSNumber *profileStatusChannel = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULTS_KEY_STATUS_CHANNEL];
    if ([profileStatusChannel isKindOfClass:[NSNull class]]){
        
        profileStatusChannel = @(-1);
        [[NSUserDefaults standardUserDefaults] setObject:profileStatusChannel forKey:USERDEFAULTS_KEY_STATUS_CHANNEL];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [UserHandler sharedInstance].mySelf = [[User alloc]
                                           initWithIP:ipAddress
                                           deviceID:deviceUUID
                                           name:profileName
                                           status:profileStatus
                                           statusChannel:profileStatusChannel.intValue
                                           imageName:profileImage
                                           andActive:YES];
    

    //Notify Self Presence
    [self notifySelfPresenceToNetwork];
    
    //NSNotificationCenter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDeviceJoined:)
                                                 name:NOTIFICATIONKEY_NEW_DEVICE_JOINED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newDeviceConfirmed:)
                                                 name:NOTIFICATIONKEY_NEW_DEVICE_CONFIRMED
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateProfileInfo:)
                                                 name:NOTIFICATIONKEY_UPDATE_PROFILE_INFO
                                               object:nil];
    
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSString *ipAddress = [[MessageHandler sharedHandler] getIPAddress];
    BOOL success = [[MessageHandler sharedHandler] isValidIPAddress:ipAddress];
    
    if(success){
        
        NSLog(@"Success");
        if(self.alertShowing){
            
            [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
        [UserHandler sharedInstance].mySelf.deviceIP = ipAddress;
        [self notifySelfPresenceToNetwork];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    


}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



#pragma mark - NSNotification

-(void) newDeviceJoined:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSMutableDictionary *jsonDict = [[NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil] mutableCopy];
    
    //Save The Image & User
    //Image
    NSString *base64Image = [jsonDict objectForKey:JSON_KEY_PROFILE_IMAGE];
    //NSString *deviceID = [jsonDict objectForKey:JSON_KEY_DEVICE_ID];
    NSString *deviceIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];
    NSString *imageName = [[FileHandler sharedHandler] saveBase64Image:base64Image ofDeviceID:deviceIP];

    [jsonDict setObject:imageName forKey:JSON_KEY_PROFILE_IMAGE];

    //User
    User *newUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [[UserHandler sharedInstance] addUser:newUser];
    
    
    //send confirmartion
    NSString *acknowledgeDeviceInNetWorkMessage = [[MessageHandler sharedHandler] acknowledgeDeviceInNetwork];
    [[ConnectionHandler sharedHandler] sendMessage:acknowledgeDeviceInNetWorkMessage toIPAddress:newUser.deviceIP];
    
    
    //send notification to main page
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONKEY_NEW_DEVICE_JOINED_APPDELEGATE object:nil userInfo:userInfo];
 
    [self showAlertForJoiningChannelWith:newUser];
}

-(void) newDeviceConfirmed:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSMutableDictionary *jsonDict = [[NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil] mutableCopy];

    
    //Save The Image & User
    //Image
    NSString *base64Image = [jsonDict objectForKey:JSON_KEY_PROFILE_IMAGE];
    //NSString *deviceID = [jsonDict objectForKey:JSON_KEY_DEVICE_ID];
    NSString *deviceIP = [jsonDict objectForKey:JSON_KEY_IP_ADDRESS];
    NSString *imageName = [[FileHandler sharedHandler] saveBase64Image:base64Image ofDeviceID:deviceIP];
    
    [jsonDict setObject:imageName forKey:JSON_KEY_PROFILE_IMAGE];
    
    //Save The User
    User *confirmerUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [[UserHandler sharedInstance] addUser:confirmerUser];
    
    //send notification to main page
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONKEY_NEW_DEVICE_CONFIRMED_APPDELEGATE object:nil userInfo:userInfo];
    
    [self showAlertForJoiningChannelWith:confirmerUser];
}

-(void) updateProfileInfo:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSMutableDictionary *jsonDict = [[NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil] mutableCopy];

    
    //Save The Image & User
    //Image
    NSString *base64Image = [jsonDict objectForKey:JSON_KEY_PROFILE_IMAGE];
    NSString *deviceID = [jsonDict objectForKey:JSON_KEY_DEVICE_ID];
    NSString *imageName = [[FileHandler sharedHandler] saveBase64Image:base64Image ofDeviceID:deviceID];
    
    [jsonDict setObject:imageName forKey:JSON_KEY_PROFILE_IMAGE];
    
    //Save The User
    User *updaterUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [[UserHandler sharedInstance] addUser:updaterUser];

    //send notification to main page
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONKEY_UPDATE_PROFILE_INFO_APPDELEGATE object:nil userInfo:userInfo];
    
    [self showAlertForJoiningChannelWith:updaterUser];
}


#pragma mark - Private Methods

-(void)notifySelfPresenceToNetwork {
    
    NSString *requestInfoMessage = [[MessageHandler sharedHandler] requestInfoAtStartMessage];
    
    NSString *myIP = [UserHandler sharedInstance].mySelf.deviceIP;
    BOOL successfullIP = [[MessageHandler sharedHandler] isValidIPAddress:myIP];
    
    if(successfullIP){
        
        NSArray *ipArray = [myIP componentsSeparatedByString:@"."];
        NSString *ipThreeSegments = [NSString stringWithFormat:@"%@.%@.%@.", [ipArray objectAtIndex:0], [ipArray objectAtIndex:1], [ipArray objectAtIndex:2]];
        
        [[ConnectionHandler sharedHandler] enableBroadCast];
        
        for (int i =1 ; i<=254; i++) {
            
            NSString *ipAddressTosendData = [NSString stringWithFormat:@"%@%d", ipThreeSegments, i];
            
            if (![ipAddressTosendData isEqualToString:myIP]) {
                
                NSLog(@"ip to send %@", ipAddressTosendData);
                [[ConnectionHandler sharedHandler] sendMessage:requestInfoMessage toIPAddress:ipAddressTosendData];
            }
        }
    }

}

-(void)sendChanneljoiningMessage{
    
    int channelID = [UserHandler sharedInstance].mySelf.statusChannel;
    NSString *channelJoinNotificationMessage = [[MessageHandler sharedHandler] joiningChannelMessageOf:channelID];
    
    [[ConnectionHandler sharedHandler] enableBroadCast];
    
    NSArray *memberOfSameStatusIP = [[UserHandler sharedInstance] getAllUserIPsOfSameStatus];
    for (NSString *ipAddress in memberOfSameStatusIP) {
        
        [[ConnectionHandler sharedHandler] sendMessage:channelJoinNotificationMessage toIPAddress:ipAddress];
    }
}

-(void)showAlertForJoiningChannelWith:(User *)newUser{
    
    BOOL channelOpen = [ChannelManager sharedInstance].isChannelOpen;
    
    if(!channelOpen && !self.alertShowing){
        
        NSArray *statusAry = [MessageHandler sharedHandler].statusArray;
        
        //int statusChannel = newUser.statusChannel;
        //int myStatusChannelID = [UserHandler sharedInstance].mySelf.statusChannel;
        //int statusAryCount = statusAry.count;
        
        if(newUser.statusChannel != -1 && newUser.statusChannel < statusAry.count && newUser.statusChannel == [UserHandler sharedInstance].mySelf.statusChannel){
            //show a action to join chat
            
            NSString * statusStr = statusAry[newUser.statusChannel];
            
            NSString *message =  [NSString stringWithFormat:@"%@ & others have the same \"%@\" status as yours. Would you like to join them?", newUser.profileName, statusStr];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Chatting Request"
                                                            message: message
                                                           delegate: self
                                                  cancelButtonTitle:@"Decline"
                                                  otherButtonTitles:@"Accept", nil];
            
            alert.tag = 55;
            [alert show];
            self.alertShowing = YES;
        }
    }

}



#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 55){
        self.alertShowing = NO;
        
        if(buttonIndex == 0){
            
            //Decline, send Reply

            
        }else if(buttonIndex == 1){
            
            int channelID = [UserHandler sharedInstance].mySelf.statusChannel;
            Channel *channel = [[Channel alloc] initChannelWithID:channelID];
            
            [[ChannelManager sharedInstance] setCurrentChannel:channel];
            [ChannelManager sharedInstance].isChannelOpen = YES;
            
            //send then notification
            [self performSelector:@selector(sendChanneljoiningMessage) withObject:nil afterDelay:3.0];
            //[self sendChanneljoiningMessage];
            
            //navigate to chatview controller
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ChatVC *chatVC = (ChatVC *)[storyboard instantiateViewControllerWithIdentifier:@"ChatVCID"];
            
            chatVC.currentActiveChannel = [ChannelManager sharedInstance].currentChannel;
            
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            [navController pushViewController:chatVC animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    
    if(alertView.tag == self.alertView.tag){
        
        if (buttonIndex == 0) {
            
            
            //self.alertShowing = YES;
            //exit(0);
        }
    }
    
}

@end
