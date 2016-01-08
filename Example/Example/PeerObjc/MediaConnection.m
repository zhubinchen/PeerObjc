//
//  MediaConnection.m
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "MediaConnection.h"
#import "Negotiator.h"
#import "RTCEAGLVideoView.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCVideoCapturer.h"
#import <AVFoundation/AVFoundation.h>
#import "RTCPeerConnection.h"
#import "RTCPeerConnection.h"
#import "RTCICECandidate.h"

@interface MediaConnection ()

@end

@implementation MediaConnection
{
    Negotiator *negotiator;
    RTCPeerConnection *pc;
    RTCVideoTrack *remoteTrack;
    RTCVideoTrack *localTrack;
    RTCMediaStream *localStream;
}

@synthesize open = _open;

- (instancetype)initWithPeer:(Peer *)peer destPeerId:(NSString *)destId options:(NSDictionary *)options
{
    if (self = [super initWithPeer:peer destPeerId:destId options:options]) {
        self.type = @"media";
        self.id = self.id == nil ? @"mc_phks5x29u9885mi" : self.id;
        NSDictionary *config = options[@"_payload"] ? options[@"_payload"] : @{@"originator": @"true"} ;
        
        float w = [UIScreen mainScreen].bounds.size.width;
        
        float h = [UIScreen mainScreen].bounds.size.height;
        
        _remoteVideoView = [[VideoView alloc]initWithFrame:CGRectMake(0, 0, w, h) Ratio:CGSizeMake(w, h)];
        _localVideoView = [[VideoView alloc]initWithFrame:CGRectMake(0.8*w, 0.8*h, 0.2*w, 0.2*h) Ratio:CGSizeMake(w, h)];
        
        localStream = [_localVideoView renderVideoWithCamera:2];

        negotiator = [[Negotiator alloc]initWithConnection:self];
        negotiator.stream = localStream;
        
        pc = [negotiator startPeerConnectionWithOptions:config];
        
        [pc addStream:localStream];
    }
    
    return self;
}

- (void)handelMessage:(NSDictionary *)msg
{
    NSDictionary *payload = msg[@"payload"];
    
    if ([msg[@"type"] isEqualToString:@"ANSWER"]) {
        [negotiator handelSdp:payload[@"sdp"] withType:@"answer"];
        self.open = true;
    } else if ([msg[@"type"] isEqualToString:@"CANDIDATE"]) {
        
        NSDictionary *candidateObj = [payload objectForKey:@"candidate"];
        NSString *candidateMessage = [candidateObj objectForKey:@"candidate"];
        NSInteger sdpMLineIndex = [[candidateObj objectForKey:@"sdpMLineIndex"] integerValue];
        NSString *sdpMid = [candidateObj objectForKey:@"sdpMid"];
        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:sdpMid index:sdpMLineIndex sdp:candidateMessage];
        [negotiator handleCandidate:candidate];
    }
}

- (void)recievedRemoteVideoTrack:(RTCVideoTrack *)track
{
    [_remoteVideoView renderVideoWithTrack:track];
}

- (void)setOpen:(BOOL)open
{
    _open = open;
    
    if (_open && [self.delegate respondsToSelector:@selector(mediaConnectionDidOpen:)]) {
        [self.delegate mediaConnectionDidOpen:self];
    }
    
//    if (!_open && [self.delegate respondsToSelector:@selector(mediaConnectionDidClosed:)]) {
//        [self.delegate mediaConnectionDidClosed:self];
//    }
}

- (void)setDelegate:(id<MediaConnectionDelegate>)delegate
{
    _delegate = delegate;
}

- (void)close
{
    [super close];

    [pc close];
    
    self.open = NO;
}

@end
