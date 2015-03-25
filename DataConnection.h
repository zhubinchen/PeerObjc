//
//  DataConnection.h
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@class DataConnection,RTCDataChannel;

@protocol DataConnectionDelegate <NSObject>

@optional

- (void)dataConnectionDidOpen:(DataConnection*)connection;

- (void)dataConnectionDidClosed:(DataConnection*)connection;

- (void)dataConnection:(DataConnection*)connection DidRecievedData:(NSData *)data;

- (void)dataConnection:(DataConnection *)connection DidRecievedMessage:(NSString*)msg;

- (void)dataConnectionRecieveCompleted:(DataConnection *)connection;

@end

@interface DataConnection : Connection

@property (nonatomic,assign) BOOL keepOriginalData; 

@property (nonatomic,strong,readonly) NSData *recivedData;

@property (nonatomic,assign) id<DataConnectionDelegate> delegate;

- (void)initializeDataChannel:(RTCDataChannel*)dataChannel;

- (void)sendMessage:(NSString*)msg;

- (void)sendData:(NSData*)data;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
