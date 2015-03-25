//
//  MediaConnection.m
//  PeerObjectiveC
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

- (instancetype)initWithDstPeerId:(NSString *)dstId AndPeer:(Peer *)peer Options:(NSDictionary *)options
{
    if (self = [super initWithDstPeerId:dstId AndPeer:peer Options:options]) {
        self.type = @"media";
        self.id = self.id == nil ? @"mc_phks5x29u9885mi" : self.id;
        NSDictionary *config = options[@"_payload"] ? options[@"_payload"] : @{@"originator": @"true"} ;
        _remoteVideoView = [[VideoView alloc]initWithFrame:CGRectMake(0, 0, 400, 300) AspectRatio:CGSizeMake(4, 3)];
        _localVideoView = [[VideoView alloc]initWithFrame:CGRectMake(0, 0, 400, 300) AspectRatio:CGSizeMake(4, 3)];
        negotiator = [[Negotiator alloc]initWithConnection:self];
        
        pc = [negotiator startPeerConnectionWithOptions:config];
        
        localStream = [_localVideoView renderVideoWithCamera:2];
        [pc addStream:localStream];
    }
    
    return self;
}

- (void)recievedRemoteVideoTrack:(RTCVideoTrack *)track
{
    [_remoteVideoView renderVideoWithTrack:track];
}

- (void)close
{
    [super close];

    [pc close];
    
    if ([self.delegate respondsToSelector:@selector(mediaConnectionDidClosed:)]) {
        [self.delegate mediaConnectionDidClosed:self];
    }
}

@end
