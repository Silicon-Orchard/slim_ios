//
//  ConnectionHandler.m
//  WTNotification
//
//  Created by Mehedi Hasan on 7/14/16.
//  Copyright © 2016 Mehedi Hasan. All rights reserved.
//

#import "ConnectionHandler.h"
#import "Constants.h"

@implementation ConnectionHandler

+(ConnectionHandler*)sharedHandler{
    static ConnectionHandler *mySharedHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySharedHandler = [[ConnectionHandler alloc] init];
        // Do any other initialisation stuff here
        
    });
    
    return mySharedHandler;
}


-(void)createSocketWithPort:(uint16_t) port{
    if (self.asyncUdpSocket) {
        NSLog(@"SocketNotCreated");
        //        self.currentListenerSocket
        //        return;
    }
    NSError *error = nil;
    self.asyncUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    if (![self.asyncUdpSocket bindToPort:WALKIETALKIE_UINT_PORT error:&error]) {
        NSLog(@"bind failed with error %@", [error localizedDescription]);
        //         [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    };
    //    [self.currentListenerSocket enableBroadcast:YES error:&error];
    if (![self.asyncUdpSocket beginReceiving:&error]) {
        NSLog(@"receive failed with error %@", [error localizedDescription]);
        //         [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
    };

}


-(void)sendMessage:(NSString *)message toIPAddress:(NSString *)IPAddress {
    //    NSLog(@"data sent to %@", IPAddress);
    [self.asyncUdpSocket sendData:[message dataUsingEncoding:NSUTF8StringEncoding] toHost:IPAddress port:WALKIETALKIE_UINT_PORT withTimeout:3 tag:0];
}


-(void)enableBroadCast{
    NSError *error =nil;
    [self.asyncUdpSocket enableBroadcast:YES error:&error];
}

-(void)disableBroadCast{
    NSError *error =nil;
    [self.asyncUdpSocket enableBroadcast:NO error:&error];
}


#pragma mark - Delegate Method

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"Datasent");
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"Failed");
    
}

/**
 * Called when the socket has received the requested datagram.
 **/


-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    
    NSString *hostIP;
    uint16_t senderport;
    int senderSocketFamily;
    [GCDAsyncUdpSocket getHost:&hostIP port:&senderport family:&senderSocketFamily fromAddress:address];
    uint16_t receiverPort = sock.localPort;
    
    NSDictionary* userInfo = @{@"receievedData": data};
    [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_RECEIVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
    NSDictionary *jsonDict = [NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
    NSLog(@"received: %@", jsonDict);
    
    
    
    NSNumber *messageType = [jsonDict objectForKey:JSON_KEY_TYPE];
    NSNumber *channelID  = [jsonDict objectForKey:JSON_KEY_CHANNEL];
    int type = [messageType intValue];
    
    if (receiverPort == WALKIETALKIE_VOICE_STREAMER_PORT) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VOICE_STREAM_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
        return;
    }
    else{
        if (!type) {
            [[NSNotificationCenter defaultCenter] postNotificationName:VOICE_MESSAGE_RECEIEVED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            return;
        }
    }
    
    
    switch (type) {
            
        case TYPE_MESSAGE:

            break;
            
        case TYPE_REQUEST_INFO:
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_DEVICE_CONNECTED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        case TYPE_RECEIVE_INFO:
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_DEVICE_CONFIRMED_NOTIFICATIONKEY object:nil userInfo:userInfo];
            break;
            
        default:
            break;
    }
    
    
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
    NSLog(@"SocketClosed with error %@", [error localizedDescription]);
    self.asyncUdpSocket = nil;
    [self createSocketWithPort:WALKIETALKIE_UINT_PORT];
}

@end
