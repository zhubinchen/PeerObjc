//
//  Negotiator.m
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "Negotiator.h"
#import "ConstraintsFactory.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCICECandidate.h"
#import "RTCDataChannel.h"
#import "DataConnection.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "Peer.h"

@interface Negotiator () <RTCPeerConnectionDelegate,RTCSessionDescriptionDelegate>

@property (nonatomic,weak)  Connection *connection;

@property (nonatomic,strong) RTCPeerConnectionFactory *factory;

@property (nonatomic,strong) RTCSessionDescription *sdp;

@end

@implementation Negotiator
{
    BOOL shouldOffer;
    RTCPeerConnection *_peerConnection;
    NSString *sdpType;
    NSString *where;
}

- (instancetype)initWithConnection:(Connection *)connection
{
    NSAssert(connection, @"connection should not be nil");
    
    if (self = [super init]) {
        _connection = connection;
        _factory = [[RTCPeerConnectionFactory alloc]init];
    }
    
    return self;
}

- (RTCPeerConnection*)startPeerConnectionWithOptions:(NSDictionary *)options
{
    if (_peerConnection == nil) {
        
        NSLog(@"Creating RTCPeerConnection");
        if ([_connection.type isEqualToString:@"data"]) {
            
            _peerConnection = [_factory peerConnectionWithICEServers:_connection.peer.iceServers constraints:[ConstraintsFactory constraintsForDataConnection] delegate:self];
            
        } else if ([_connection.type isEqualToString:@"media"]){
            
            _peerConnection = [_factory peerConnectionWithICEServers:_connection.peer.iceServers constraints:[ConstraintsFactory constraintsForMediaConnection] delegate:self];
            
            if (![options[@"originator"] isEqualToString:@"true"]) {
                [_peerConnection addStream:_stream];
            }
            
        } else {
            
            NSAssert(0, @"connection type is not valid");
        }
        
    }
    
    if ([options[@"originator"] isEqualToString:@"true"]) {
        
        if ([_connection.type isEqualToString:@"data"]) {
            
            RTCDataChannelInit *config = [[RTCDataChannelInit alloc]init];
            config.isOrdered = YES;
            RTCDataChannel *dc = [_peerConnection createDataChannelWithLabel:_connection.label config:config];
            [(DataConnection*)_connection initializeDataChannel:dc];
            
        } else if ([_connection.type isEqualToString:@"media"]) {
            shouldOffer = YES;
        } else {
            NSAssert(0, @"connection type is not valid");
        }
        
    } else {
        
        [self handelSdp:options[@"sdp"] withType:@"offer"];
    }
    
    return _peerConnection;
}

- (void)sendOfferWithSdp:(NSString*)sdp
{
    NSDictionary *message = @{@"type": @"OFFER",
                              @"src": _connection.peer.peerId,
                              @"dest": _connection.destId,
                              @"payload":
                                  @{@"browser": @"Chrome",
                                    @"serialization": _connection.serialization,
                                    @"reliable":@"true",
                                    @"type": _connection.type,
                                    @"label":_connection.label,
                                    @"connectionId": _connection.id,
                                    @"sdp": @{@"sdp": sdp, @"type": @"offer"}}
                              };
    
    [self sendMessage:message];
}

- (void)sendAnswerWithSdp:(NSString*)sdp
{
    if (sdp == nil) {
        return;
    }
    
    NSLog(@"%@",sdp);
    [self sendMessage:@{@"type": @"ANSWER",
                              @"src": _connection.peer.peerId,
                              @"dest": _connection.destId,
                              @"payload":
                                  @{@"browser": @"Chrome",
                                    @"serialization": @"binary",
                                    @"type": _connection.type,
                                    @"connectionId": _connection.id,
                                    @"sdp": @{@"sdp": sdp, @"type": @"answer"} }
                              }];
}

- (void)makeOffer
{
    sdpType = @"offer";
    
    [_peerConnection createOfferWithDelegate:self constraints:nil];
}

- (void)makeAnswer
{
    sdpType = @"answer";
    
    [_peerConnection createAnswerWithDelegate:self constraints:nil];
}

- (void)handelSdp:(NSDictionary*)sdpDic withType:(NSString*)type
{
    RTCSessionDescription *sdp = [[RTCSessionDescription alloc]initwithType:type sdp:sdpDic[@"sdp"]];
    sdpType = type;
    where = @"remote";
    [_peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
}

- (void)handleCandidate:(RTCICECandidate*)candidate
{
    [_peerConnection addICECandidate:[[RTCICECandidate alloc]initWithMid:candidate.sdpMid index:candidate.sdpMLineIndex sdp:candidate.sdp]];
    NSLog(@"Added ICE candidate");
}

- (void)sendMessage:(NSDictionary*)msg
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:msg options:0 error:nil];

    [_connection.peer.webSock send:data];
}

#pragma mark - RTCSessionDescriptionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didCreateSessionDescription:(RTCSessionDescription *)sdp
                 error:(NSError *)error {
    if (error) {
        NSLog(@"failed to createSDP,error:%@",error);
        return;
    }
    NSLog(@"created Sdp. Type:%@",sdpType);
    where = @"local";
    _sdp = sdp;
    [_peerConnection setLocalDescriptionWithDelegate:self sessionDescription:sdp];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
didSetSessionDescriptionWithError:(NSError *)error {
    if (error) {
        NSLog(@"Failed to set %@Description:%@ Error:%@",where,sdpType,error);
        return;
    }
    
    NSLog(@"Set %@Description:%@",where,sdpType);
    
    if ([sdpType isEqualToString:@"offer"] && [where isEqualToString:@"remote"]) {
        [self makeAnswer];
    } else if ([sdpType isEqualToString:@"answer"] && [where isEqualToString:@"local"]) {
        [self sendAnswerWithSdp:_sdp.description];
    } else if ([sdpType isEqualToString:@"offer"] && [where isEqualToString:@"local"]) {
        [self sendOfferWithSdp:_sdp.description];
    }
}

#pragma Mark RTCPeerConnectionDelegate

- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate
{
    NSDictionary *candidateObj = @{@"sdpMLineIndex": @(candidate.sdpMLineIndex),
                                   @"sdpMid": candidate.sdpMid,
                                   @"candidate": candidate.sdp};
    
    [self sendMessage:@{@"type": @"CANDIDATE",
                                     @"src": _connection.peer.peerId,
                                     @"dest": _connection.destId,
                                     @"payload": @{
                                             @"type": _connection.type,
                                             @"connectionId": _connection.id,
                                             @"candidate": candidateObj}
                                     }];
    NSLog(@"Received ICE candidates");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream
{
    if (stream.videoTracks.count) {
        RTCVideoTrack *videoTrack = stream.videoTracks[0];
        [(MediaConnection*)_connection recievedRemoteVideoTrack:videoTrack];
    }
    NSLog(@"Recieved stream");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream
{
    NSLog(@"Stream was removed");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    NSLog(@"Recieved datachannel");
    [(DataConnection*)_connection initializeDataChannel:dataChannel];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState
{
    NSLog(@"RTCICEGatheringState:%u",newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState
{
    NSLog(@"RTCICEConnectionState:%u",newState);
}

- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection
{
    NSLog(@"negotiationneeded triggered");
    if (peerConnection.signalingState == RTCSignalingStable) {
        if ([_connection.type isEqualToString:@"data"] || shouldOffer) {
            [self makeOffer];
        }
    } else {
        NSLog(@"onnegotiationneeded triggered when not stable. Is another connection being established?");
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged
{
    NSLog(@"signaling changed %u",stateChanged);
}

@end
