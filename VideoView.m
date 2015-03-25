//
//  VideoView.m
//  QinXin
//
//  Created by zhubch on 15-3-12.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "VideoView.h"
#import "RTCEAGLVideoView.h"
#import "RTCVideoTrack.h"
#import <AVFoundation/AVFoundation.h>
#import "RTCPeerConnectionFactory.h"
#import "RTCVideoCapturer.h"
#import "ConstraintsFactory.h"
#import "RTCMediaStream.h"

@interface VideoView () <RTCEAGLVideoViewDelegate>

@end

@implementation VideoView
{
    RTCEAGLVideoView *_videoView;
    RTCVideoTrack *_track;
    RTCPeerConnectionFactory *_factory;
}

- (instancetype)initWithFrame:(CGRect)frame AspectRatio:(CGSize)ratio
{
    if (self = [super initWithFrame:frame]) {
        _videoView = [[RTCEAGLVideoView alloc]initWithFrame:self.bounds];
        [self addSubview:_videoView];
        _videoView.delegate = self;
        
        if(ratio.height == 0){
            ratio = CGSizeMake(4, 3);
        }
        
        _factory = [[RTCPeerConnectionFactory alloc]init];

        frame = AVMakeRectWithAspectRatioInsideRect(ratio, _videoView.bounds);
        _videoView.frame = frame;
    }
    
    return self;
}

- (void)renderVideoWithTrack:(RTCVideoTrack *)track
{
    _track = track;
    [_track addRenderer:_videoView];
}

- (RTCMediaStream *)renderVideoWithCamera:(CameraPostion)camera
{
    RTCMediaStream* localStream = [_factory mediaStreamWithLabel:@"ARDAMS"];

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
    RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer
                                                       constraints:mediaConstraints];
    RTCVideoTrack* localVideoTrack = [_factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
    
    if (localVideoTrack) {
        [localStream addVideoTrack:localVideoTrack];
        [localVideoTrack addRenderer:_videoView];
    }
    
    [self renderVideoWithTrack:localVideoTrack];
    [localStream addAudioTrack:[_factory audioTrackWithID:@"ARDAMSa0"]];

    return localStream;
}

- (void)videoView:(RTCEAGLVideoView *)videoView didChangeVideoSize:(CGSize)size
{
    CGRect frame = AVMakeRectWithAspectRatioInsideRect(size, videoView.bounds);
    videoView.frame = frame;
}

@end
