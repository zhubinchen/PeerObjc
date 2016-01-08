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

- (void)dataConnection:(DataConnection *)connection didRecievedMessage:(NSString*)msg;

@end

/**
 *  传输二进制数据和文本消息用的连接
 */
@interface DataConnection : Connection

@property (nonatomic,strong,readonly) NSData *recivedData;

@property (nonatomic,assign) id<DataConnectionDelegate> delegate;

- (void)initializeDataChannel:(RTCDataChannel*)dataChannel;

- (BOOL)sendMessage:(NSString*)msg;

- (BOOL)sendData:(NSData *)data;

@end
