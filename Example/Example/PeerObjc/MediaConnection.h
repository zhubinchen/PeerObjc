//
//  MediaConnection.h
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "Connection.h"
#import <UIKit/UIKit.h>

@class MediaConnection;

typedef enum : NSUInteger {
    RenderFromLocalCamera,
    RenderFromRemoteStream,
} RenderType;

@protocol MediaConnectionDelegate <NSObject>

@optional

- (void)mediaConnectionRecievedStream;

- (void)mediaConnectionDidOpen;

- (void)mediaConnectionDidClosed;

@end

/**
 *  视频通话用的连接
 */
@interface MediaConnection : Connection

@property (nonatomic,assign) id<MediaConnectionDelegate> delegate;

- (UIView*)renderViewForType:(RenderType)type bounding:(CGRect)bounds;

@end
