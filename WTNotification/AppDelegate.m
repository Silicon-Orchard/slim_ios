//
//  AppDelegate.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Create Socket
    [[ConnectionHandler sharedHandler] createSocketWithPort:WTNOTIFICATION_PORT_NORMAL];
    [[ConnectionHandler sharedHandler] createSocketWithPort:WTNOTIFICATION_PORT_FILE];
    
    
    NSString *ipAddress = [[MessageHandler sharedHandler] getIPAddress];
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
        [[NSUserDefaults standardUserDefaults] setObject:profileImage forKey:USERDEFAULTS_KEY_STATUS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    [UserHandler sharedInstance].mySelf = [[User alloc]
                                           initWithIP:ipAddress
                                           deviceID:deviceUUID
                                           name:profileName
                                           status:profileStatus
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
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User
    User *newUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [[UserHandler sharedInstance] addUser:newUser];
    
    
    NSString *acknowledgeDeviceInNetWorkMessage = [[MessageHandler sharedHandler] acknowledgeDeviceInNetwork];
    [[ConnectionHandler sharedHandler] sendMessage:acknowledgeDeviceInNetWorkMessage toIPAddress:newUser.deviceIP];
    
    //send notification to main page

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONKEY_NEW_DEVICE_JOINED_APPDELEGATE object:nil userInfo:userInfo];

}

-(void) newDeviceConfirmed:(NSNotification*)notification{
    
    NSDictionary* userInfo = notification.userInfo;
    NSData* receivedData = (NSData*)userInfo[@"receievedData"];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:receivedData options:0 error:nil];
    
    //Save The User
    User *confirmerUser = [[User alloc] initWithDictionary:jsonDict andActive:YES];
    [[UserHandler sharedInstance] addUser:confirmerUser];
    
    //send notification to main page
     [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONKEY_NEW_DEVICE_CONFIRMED_APPDELEGATE object:nil userInfo:userInfo];
}

#pragma mark - Private Methods

-(void)notifySelfPresenceToNetwork{
    
    NSString *requestInfoMessage = [[MessageHandler sharedHandler] requestInfoAtStartMessage];
    
    NSString *myIP = [UserHandler sharedInstance].mySelf.deviceIP;
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

@end
