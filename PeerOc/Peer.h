//
//  Peer.h
//  PeerObjc
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "DataConnection.h"
#import "MediaConnection.h"

@interface Peer : NSObject

@property(nonatomic, strong) NSString   *id;

/**
 *  以下是options内容
 */
@property(nonatomic, strong) NSString   *key;
@property(nonatomic, strong) NSString   *host;
@property(nonatomic, strong) NSString   *path;
@property(nonatomic, assign) BOOL       secure;
@property(nonatomic, strong) NSString   *port;
@property(nonatomic, strong) NSArray    *iceServers;

/**
 *  以下是回调block
 */
@property(nonatomic, copy) void(^onOpen)(NSString *id);
@property(nonatomic, copy) void(^onConnection)(Connection *connection);
@property(nonatomic, copy) void(^onClose)();
@property(nonatomic, copy) void(^onError)(NSError *error);

/**
 *  状态标记
 */
@property(nonatomic, assign) BOOL        open;

@property (nonatomic,strong) SRWebSocket *webSock;

- (id)init __attribute__((unavailable("not avaliable")));

- (instancetype)initWithOptions:(NSDictionary*)options AndId:(NSString*)id;

- (DataConnection*)connectToPeer:(NSString*)peerID Options:(NSDictionary*)options;

- (MediaConnection*)callPeer:(NSString*)peerID Options:(NSDictionary*)options;

- (void)disConnectAllConnections;

- (void)disConnect:(Connection*) connection;

- (void)cleanUp;

@end
