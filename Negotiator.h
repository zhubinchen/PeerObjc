//
//  Negotiator.h
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

@class RTCPeerConnection;
@class RTCICECandidate;

@interface Negotiator : NSObject

- (instancetype)initWithConnection:(Connection*)connection;

- (RTCPeerConnection*)startPeerConnectionWithOptions:(NSDictionary*)options;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (void)handleCandidate:(RTCICECandidate*)candidate;

- (void)handelSdp:(NSDictionary*)sdpDic WithType:(NSString*)type;

@end
