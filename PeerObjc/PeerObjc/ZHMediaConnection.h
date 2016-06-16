//
//  ZHMediaConnection.h
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "ZHConnection.h"
#import <UIKit/UIKit.h>

@class ZHMediaConnection;

typedef enum : NSUInteger {
    RenderFromLocalCamera,
    RenderFromRemoteStream,
} RenderType;

@protocol ZHMediaConnectionDelegate <NSObject>

@optional

- (void)mediaConnectionRecievedStream;

- (void)mediaConnectionDidOpen;

- (void)mediaConnectionDidClosed;

@end

/**
 *  视频通话用的连接
 */
@interface ZHMediaConnection : Connection

@property (nonatomic,assign) id<ZHMediaConnectionDelegate> delegate;

- (UIView*)renderViewForType:(RenderType)type bounding:(CGRect)bounds;

@end
