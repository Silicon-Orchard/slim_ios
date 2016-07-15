//
//  AppDelegate.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NewDeviceNotificationDelegate <NSObject>
-(void) newDeviceJoined:(User*)user;
-(void) newDeviceConfirmed:(User*)user;
@end


@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
    id myAppDelegate;
}

@property (strong, nonatomic) UIWindow *window;


@end

