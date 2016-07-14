//
//  ConnectionHandler.h
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface ConnectionHandler : NSObject <GCDAsyncUdpSocketDelegate>


@property (nonatomic, strong) GCDAsyncUdpSocket *asyncUdpSocket;


+(ConnectionHandler*)sharedHandler;

-(void)createSocketWithPort:(uint16_t) port;
-(void)sendMessage:(NSString *)message toIPAddress:(NSString *)IPAddress;


-(void)enableBroadCast;
-(void)disableBroadCast;

@end
