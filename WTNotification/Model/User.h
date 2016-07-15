//
//  User.h
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/27/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property BOOL isActive;

@property (nonatomic, strong) NSString *deviceIP;
@property (nonatomic, strong) NSString *deviceID;

@property (nonatomic, strong) NSString *profileName;
@property (nonatomic, strong) NSString *profileStatus;
@property (nonatomic, strong) NSString *profileImageName;



-(instancetype)initWithDictionary:(NSDictionary *)jsonDict andActive:(BOOL)active;
-(instancetype)initWithIP:(NSString *)ip deviceID:(NSString* )ID name:(NSString*)name status:(NSString *)status imageName:(NSString *)imageName andActive:(BOOL)active;


@end
