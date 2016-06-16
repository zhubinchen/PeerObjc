//
//  ZHDataConnection.h
//  PeerObjc
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHConnection.h"

@class ZHDataConnection,RTCDataChannel;

@protocol ZHDataConnectionDelegate <NSObject>

@optional

- (void)dataConnectionDidOpen:(ZHDataConnection *)connection;

- (void)dataConnectionDidClosed:(ZHDataConnection *)connection;

- (void)dataConnection:(ZHDataConnection *)connection didRecievedData:(NSData *)data;

- (void)dataConnection:(ZHDataConnection *)connection didRecievedMessage:(NSString*)msg;

@end

/**
 *  传输二进制数据和文本消息用的连接
 */
@interface ZHDataConnection : Connection

@property (nonatomic,strong,readonly) NSData *recivedData;

@property (nonatomic,assign) id<ZHDataConnectionDelegate> delegate;

- (BOOL)sendMessage:(NSString*)msg;

- (BOOL)sendData:(NSData *)data;

@end
