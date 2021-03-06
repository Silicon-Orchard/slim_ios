//
//  MessageHandler.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "MessageHandler.h"
#import <UIKit/UIKit.h>
#import "Constants.h"

@implementation MessageHandler

+(MessageHandler*)sharedHandler{
    
    static MessageHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[MessageHandler alloc] init];
        // Do any other initialisation stuff here
    });
    
    return mySharedHandler;
}


-(instancetype)init{
    if(self = [super init]){
        
        self.statusArray = @[
                             @"Ping Pong",
                             @"Chess",
                             @"Lunch",
                             @"Coffee",
                             @"Pool",
                             @"Football",
                             @"Board Games",
                             @"Hangout",
                             @"Walk",
                             @"Run"
                             ];
        
        self.statusImageArray = @[
                                  @"Ping Pong",
                                  @"Chess",
                                  @"Lunch",
                                  @"Coffee",
                                  @"Pool",
                                  @"Football",
                                  @"Board Games",
                                  @"Hangout",
                                  @"Walk",
                                  @"Run"
                                  ];
    }
    return  self;
}

#pragma mark - Helpers


- (NSString *)getIPAddress {
    
#warning TODO: Remove this code
#if TARGET_OS_SIMULATOR
    
    //Simulator
    
    return @"192.168.2.129";
    
#else
    
    // Device
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
#endif
}

-(BOOL)isValidIPAddress:(NSString *)ipAddress{
    
    const char *utf8 = [ipAddress UTF8String];
    int success;
    
    struct in_addr dst;
    success = inet_pton(AF_INET, utf8, &dst);
    if (success != 1) {
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    
    return success == 1;
}




-(NSString *)requestInfoAtStartMessage{
    
    NSString *base64Image;
    NSString *imageName = [UserHandler sharedInstance].mySelf.profileImageName;
    
    if(imageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:imageName OfType:kFileTypePhoto];
        UIImage *imageToSend = [UIImage imageWithContentsOfFile:imagePath];
        
        if(imageToSend != nil){
            
            base64Image =  [[FileHandler sharedHandler] encodeToBase64String:imageToSend];
        }else{
            base64Image = @"";
        }
        
    }else{
       base64Image = @"";
    }

    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_REQUEST_INFO],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_PROFILE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_PROFILE_STATUS: [UserHandler sharedInstance].mySelf.profileStatus,
                                      JSON_KEY_PROFILE_STATUS_CHANNEL: @([UserHandler sharedInstance].mySelf.statusChannel),
                                      JSON_KEY_PROFILE_IMAGE: base64Image
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}

-(NSString *)acknowledgeDeviceInNetwork{
    
    NSString *base64Image;
    NSString *imageName = [UserHandler sharedInstance].mySelf.profileImageName;
    

    if(imageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:imageName OfType:kFileTypePhoto];
        UIImage *imageToSend = [UIImage imageWithContentsOfFile:imagePath];
        
        if(imageToSend != nil){
            
            base64Image =  [[FileHandler sharedHandler] encodeToBase64String:imageToSend];
        }else{
            base64Image = @"";
        }
        
    }else{
        base64Image = @"";
    }

    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_RECEIVE_INFO],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_PROFILE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_PROFILE_STATUS: [UserHandler sharedInstance].mySelf.profileStatus,
                                      JSON_KEY_PROFILE_STATUS_CHANNEL: @([UserHandler sharedInstance].mySelf.statusChannel),
                                      JSON_KEY_PROFILE_IMAGE: base64Image
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}

-(NSString *)postMessage{
    
    NSString *base64Image;
    NSString *imageName = [UserHandler sharedInstance].mySelf.profileImageName;
    
    if(imageName.length){
        
        NSString *imagePath = [[FileHandler sharedHandler] pathToFileWithFileName:imageName OfType:kFileTypePhoto];
        UIImage *imageToSend = [UIImage imageWithContentsOfFile:imagePath];
        
        if(imageToSend != nil){
            
            base64Image =  [[FileHandler sharedHandler] encodeToBase64String:imageToSend];
        }else{
            base64Image = @"";
        }
        
    }else{
        base64Image = @"";
    }

    //base64Image = @"";
    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_POST_INFO],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_PROFILE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_PROFILE_STATUS: [UserHandler sharedInstance].mySelf.profileStatus,
                                      JSON_KEY_PROFILE_STATUS_CHANNEL: @([UserHandler sharedInstance].mySelf.statusChannel),
                                      JSON_KEY_PROFILE_IMAGE: base64Image
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}



-(NSString *)leftApplicationMessage {
    
    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_LEFT_APPLICATION],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_PROFILE_NAME: [UserHandler sharedInstance].mySelf.profileName
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}



#pragma mark - TYPE_MESSAGE

-(NSString *)createChatMessageWithChannelID:(int)channelID chatmessage:(NSString *)message{
    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_MESSAGE],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_DEVICE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_CHANNEL:@(channelID),
                                      JSON_KEY_MESSAGE:message
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
}

-(NSString *)joiningChannelMessageOf:(int) channelID{
    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_JOIN_CHANNEL],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_DEVICE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_CHANNEL:@(channelID)
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
    
}


-(NSString *)joiningChannelConfirmationMessageOf:(int)channelID{

    
//    Channel * currentChannel = [[ChannelManager sharedInstance] currentChannel];
//    NSArray *channelMemberUsers = [currentChannel getMembers];
//    
//    
//    NSMutableArray *channelMembers = [[NSMutableArray alloc] init];
//    for (User *member in channelMemberUsers) {
//        
//        if(member.isActive){
//            
//            NSDictionary * channelMember = @{
//                                              JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
//                                              JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
//                                              JSON_KEY_DEVICE_NAME: [UserHandler sharedInstance].mySelf.profileName,
//                                              };
//            [channelMembers addObject:channelMember];
//        }
//    }
    
    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_JOIN_CHANNEL_CONFIRM],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_DEVICE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_CHANNEL:@(channelID)
                                      };
    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}


-(NSString *)leaveChannelMessageOf:(int)channelID{
    
    NSDictionary * postDictionary = @{
                                      JSON_KEY_TYPE: [NSNumber numberWithInt:TYPE_LEFT_CHANNEL],
                                      JSON_KEY_DEVICE_ID : [UserHandler sharedInstance].mySelf.deviceID,
                                      JSON_KEY_IP_ADDRESS : [UserHandler sharedInstance].mySelf.deviceIP,
                                      JSON_KEY_DEVICE_NAME: [UserHandler sharedInstance].mySelf.profileName,
                                      JSON_KEY_CHANNEL:@(channelID)
                                      };

    
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return resultAsString;
}


#pragma mark - File Message

- (NSArray *)jsonStringArrayWithFile:(NSString *)fileName OfType:(int)type{
    
    NSMutableArray *JSONStringArray = [[NSMutableArray alloc] init];
    NSArray *encodedStringChunksArray = [[FileHandler sharedHandler] encodedStringChunksWithFile:fileName OfType:type];
    
    
    NSUInteger chunkCount = encodedStringChunksArray.count;

    
    for (int i = 0; i < encodedStringChunksArray.count; i++) {
        
        NSError * error = nil;
        
        NSDictionary * postDictionary = @{
                                          JSON_KEY_TYPE : @(TYPE_FILE_MESSAGE),
                                          JSON_KEY_DEVICE_NAME : [UserHandler sharedInstance].mySelf.profileName,
                                          JSON_KEY_IP_ADDRESS: [UserHandler sharedInstance].mySelf.deviceIP,
                                          JSON_KEY_FILE_TYPE: @(type),
                                          JSON_KEY_FILE_NAME: fileName,
                                          JSON_KEY_FILE_MESSAGE: [encodedStringChunksArray objectAtIndex:i],
                                          JSON_KEY_FILE_CHUNK_COUNT: @(chunkCount),
                                          JSON_KEY_FILE_CURRENT_CHUNK: @(i+1)
                                          };
        
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:postDictionary options:NSJSONWritingPrettyPrinted error:&error];
        NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [JSONStringArray addObject:resultAsString];
    }
    
    return JSONStringArray;
}


#pragma mark - Send Message


-(void)sendChanneljoiningMessageOf:(int)channelID{
    
    NSString *channelJoinNotificationMessage = [self joiningChannelMessageOf:channelID];
    
    [[ConnectionHandler sharedHandler] enableBroadCast];
    
    NSArray *allIPs = [[UserHandler sharedInstance] getAllUserIPs];
    for (NSString *ipAddress in allIPs) {
        
        [[ConnectionHandler sharedHandler] sendMessage:channelJoinNotificationMessage toIPAddress:ipAddress];
    }
}

-(void)sendSelfPresenceMessageToNetwork{
    
    NSString *requestInfoMessage = [self requestInfoAtStartMessage];
    
    NSString *myIP = [UserHandler sharedInstance].mySelf.deviceIP;
    BOOL successfullIP = [self isValidIPAddress:myIP];
    
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


@end
