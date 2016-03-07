//
//  Negotiator.h
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "WebRTC.h"

/**
 *  负责处理各种SDP,为两个Peer建立起连接
 */
@interface Negotiator : NSObject

@property (nonatomic,strong)RTCMediaStream *stream;

- (instancetype)initWithConnection:(Connection*)connection;

- (RTCPeerConnection*)startPeerConnectionWithOptions:(NSDictionary*)options;

- (instancetype)init __attribute__((unavailable("not avaliable")));

- (void)handleCandidate:(RTCICECandidate*)candidate;

- (void)handelSdp:(NSDictionary*)sdpDic withType:(NSString*)type;

@end
