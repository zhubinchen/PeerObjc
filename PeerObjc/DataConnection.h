//
//  DataConnection.h
//  PeerObjc
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@class DataConnection,RTCDataChannel;

@protocol DataConnectionDelegate <NSObject>

@optional

- (void)dataConnectionDidOpen:(DataConnection *)connection;

- (void)dataConnectionDidClosed:(DataConnection *)connection;

- (void)dataConnection:(DataConnection *)connection didRecievedData:(NSData *)data;

- (void)dataConnection:(DataConnection *)connection didRecievedMessage:(NSDictionary*)msg;

@end

@interface DataConnection : Connection

@property (nonatomic,strong,readonly) NSData *recivedData;

@property (nonatomic,assign) id<DataConnectionDelegate> delegate;

- (void)initializeDataChannel:(RTCDataChannel*)dataChannel;

- (void)sendMessage:(NSDictionary*)msg;

- (BOOL)sendData:(NSData *)data;

@end
