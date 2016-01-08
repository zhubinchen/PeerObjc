//
//  DataConnection.m
//  PeerObjc
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "DataConnection.h"
#import "RTCPeerConnection.h"
#import "Negotiator.h"
#import "RTCICECandidate.h"
#import "RTCPeerConnection.h"
#import "RTCDataChannel.h"

@interface DataConnection () <RTCDataChannelDelegate>

@property (nonatomic,strong) RTCDataChannel *dataChannel;

@end

@implementation DataConnection
{
    Negotiator *negotiator;
    RTCPeerConnection *pc;
}

- (instancetype)initWithPeer:(Peer *)peer destPeerId:(NSString *)destId options:(NSDictionary *)options
{
    if (self = [super initWithPeer:peer destPeerId:destId options:options]) {
        self.type = @"data";
        NSDictionary *config = options[@"_payload"] ? options[@"_payload"] : @{@"originator": @"true"} ;
        negotiator = [[Negotiator alloc]initWithConnection:self];
        pc = [negotiator startPeerConnectionWithOptions:config];
    }
    
    return self;
}

- (void)handelMessage:(NSDictionary *)msg
{
    NSDictionary *payload = msg[@"payload"];
    if ([msg[@"type"] isEqualToString:@"ANSWER"]) {
        [negotiator handelSdp:payload[@"sdp"] withType:@"answer"];
        
    } else if ([msg[@"type"] isEqualToString:@"CANDIDATE"]) {
        
        NSDictionary *candidateObj = [payload objectForKey:@"candidate"];
        NSString *candidateMessage = [candidateObj objectForKey:@"candidate"];
        NSInteger sdpMLineIndex = [[candidateObj objectForKey:@"sdpMLineIndex"] integerValue];
        NSString *sdpMid = [candidateObj objectForKey:@"sdpMid"];
        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:sdpMid index:sdpMLineIndex sdp:candidateMessage];
        [negotiator handleCandidate:candidate];
    }
}

- (void)initializeDataChannel:(RTCDataChannel *)dataChannel
{
    self.dataChannel = dataChannel;
    dataChannel.delegate = self;
    
    NSLog(@"dataChannel OK");
}

- (BOOL)sendData:(NSData *)data
{
    if (!self.open) {
        return NO;
    }
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc]initWithData:data isBinary:YES];
    return [_dataChannel sendData:buffer];
}

- (BOOL)sendMessage:(NSString *)msg
{
    if (!self.open) {
        return NO;
    }
    
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc]initWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
    return [_dataChannel sendData:buffer];
}

#pragma mark RTCDataChannelDelegate

- (void)channelDidChangeState:(RTCDataChannel *)channel
{
    NSLog(@"datachannel state %u",channel.state);
    if (channel.state == kRTCDataChannelStateOpen) {
        self.open = YES;
        if ([self.delegate respondsToSelector:@selector(dataConnectionDidOpen:)]) {
            [self.delegate dataConnectionDidOpen:self];
        }
        return;
    }
    self.open = NO;
    if (channel.state == kRTCDataChannelStateClosed) {
        if ([self.delegate respondsToSelector:@selector(dataConnectionDidClosed:)]) {
            [self.delegate dataConnectionDidClosed:self];
        }
    }
}

- (void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    if (buffer.isBinary) {
    
        if ([self.delegate respondsToSelector:@selector(dataConnection:didRecievedData:)]) {
            [self.delegate dataConnection:self didRecievedData:buffer.data];
        }
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(dataConnection:didRecievedMessage:)]) {
            NSString *msg = [[NSString alloc]initWithData:buffer.data encoding:NSUTF8StringEncoding];
            [self.delegate dataConnection:self didRecievedMessage:msg];
        }
    }
}

- (void)close
{
    [super close];

    if (_dataChannel.state == kRTCDataChannelStateConnecting || _dataChannel.state == kRTCDataChannelStateOpen) {
        [_dataChannel close];
    }
    [_dataChannel close];

    if ([self.delegate respondsToSelector:@selector(dataConnectionDidClosed:)]) {
        [self.delegate dataConnectionDidClosed:self];
    }
}

@end
