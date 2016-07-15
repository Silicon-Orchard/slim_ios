//
//  User.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "User.h"
#import "Constants.h"

@implementation User



-(instancetype)init {
    
    if(self = [super init]) {
        
    }
    
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)jsonDict andActive:(BOOL)active{
    
    return [self initWithIP:[jsonDict objectForKey:JSON_KEY_IP_ADDRESS]
                   deviceID:[jsonDict objectForKey:JSON_KEY_DEVICE_ID]
                       name:[jsonDict objectForKey:JSON_KEY_PROFILE_NAME]
                     status:[jsonDict objectForKey:JSON_KEY_PROFILE_STATUS]
                  imageName:[jsonDict objectForKey:JSON_KEY_PROFILE_IMAGE]
                  andActive:active];
}

-(instancetype)initWithIP:(NSString *)ip deviceID:(NSString* )ID name:(NSString*)name status:(NSString *)status imageName:(NSString *)imageName andActive:(BOOL)active{
    
    if(self = [super init]) {
        
        self.deviceIP = ip;
        self.deviceID = ID;
        
        self.profileName = name;
        self.profileStatus = status;
        self.profileImageName = imageName;
        
        self.isActive = active;
    }
    
    return self;
    
}


@end
