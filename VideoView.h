//
//  VideoView.h
//  QinXin
//
//  Created by zhubch on 15-3-12.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTCVideoTrack;
@class RTCMediaStream;

typedef enum : NSUInteger {
    DefaultCamera,
    FrontCamera,
    BackCamera
} CameraPostion;

@interface VideoView : UIView

@property (nonatomic,assign,readonly) CameraPostion *cameraPostion;

- (instancetype)initWithFrame:(CGRect)frame AspectRatio:(CGSize)ratio;

- (void)renderVideoWithTrack:(RTCVideoTrack*)track;

- (RTCMediaStream*)renderVideoWithCamera:(CameraPostion)camera;

@end
