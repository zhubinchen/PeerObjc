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
#import "ConstraintsFactory.h"
#import "RTCICECandidate.h"

@interface MediaConnection ()<RTCEAGLVideoViewDelegate>

@end

@implementation MediaConnection
{
    Negotiator *negotiator;
    RTCPeerConnection *pc;
    
    RTCVideoTrack *remoteVideoTrack;
    RTCVideoTrack *localVideoTrack;
    
    RTCMediaStream *localStream;
    
    RTCEAGLVideoView *remoteVideoView;
    RTCEAGLVideoView *localVideoView;
    CGSize radio;
}

@synthesize open = _open;

- (instancetype)initWithPeer:(Peer *)peer destPeerId:(NSString *)destId options:(NSDictionary *)options
{
    if (self = [super initWithPeer:peer destPeerId:destId options:options]) {
        self.type = @"media";
        self.id = self.id == nil ? @"mc_phks5x29u9885mi" : self.id;
        NSDictionary *config = options[@"_payload"] ? options[@"_payload"] : @{@"originator": @"true"} ;

    
        [self renderVideoWithCamera:FrontCamera];
        radio = [UIScreen mainScreen].bounds.size;
        
        negotiator = [[Negotiator alloc]initWithConnection:self];
        negotiator.stream = localStream;
        
        pc = [negotiator startPeerConnectionWithOptions:config];
        
        [pc addStream:localStream];
    }
    
    return self;
}

- (void)renderVideoWithCamera:(CameraPostion)camera
{
    
    RTCPeerConnectionFactory *factory = [[RTCPeerConnectionFactory alloc]init];
    
    localStream = [factory mediaStreamWithLabel:@"ARDAMS"];
    
    NSString *cameraID = nil;
    
    for (AVCaptureDevice *captureDevice in
         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        
        if (captureDevice.position == camera) {
            cameraID = [captureDevice localizedName];
        }
    }
    
    NSAssert(cameraID, @"Unable to get the camera id");
    
    RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
    RTCMediaConstraints *mediaConstraints = [ConstraintsFactory constraintsForMediaStream];
    RTCVideoSource *videoSource = [factory videoSourceWithCapturer:capturer constraints:mediaConstraints];
    localVideoTrack = [factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
    
    if (localVideoTrack) {
        [localStream addVideoTrack:localVideoTrack];
    }
    
    [localStream addAudioTrack:[factory audioTrackWithID:@"ARDAMSa0"]];
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

- (RTCEAGLVideoView*)createRenderViewWithFrame:(CGRect)frame
{
    RTCEAGLVideoView *videoView = [[RTCEAGLVideoView alloc]initWithFrame:frame];
    videoView.delegate = self;
    frame = AVMakeRectWithAspectRatioInsideRect(frame.size, frame);
    videoView.frame = frame;
    return videoView;
}

- (UIView *)renderViewForType:(RenderType)type bounding:(CGRect)bounds
{
    if (type == RenderFromLocalCamera) {
        localVideoView = [self createRenderViewWithFrame:bounds];
        [localVideoTrack addRenderer:localVideoView];
        return localVideoView;
    }else{
        remoteVideoView = [self createRenderViewWithFrame:bounds];
        [remoteVideoTrack addRenderer:remoteVideoView];
        return remoteVideoView;
    }
}

- (void)recievedRemoteVideoTrack:(RTCVideoTrack *)track
{
    remoteVideoTrack = track;
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

- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size
{
    CGRect frame = AVMakeRectWithAspectRatioInsideRect(size, videoView.bounds);
    videoView.frame = frame;
}

- (void)close
{
    [super close];

    [pc close];
    
    self.open = NO;
}

@end
