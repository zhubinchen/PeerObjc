//
//  MediaConnection.h
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "Connection.h"
#import "RTCMediaStream.h"
#import "RTCVideoTrack.h"
#import "VideoView.h"

@class MediaConnection;

@protocol MediaConnectionDelegate <NSObject>

- (void)mediaConnectionDidOpen:(MediaConnection*)connection;

- (void)mediaConnectionDidClosed:(MediaConnection*)connection;

@end

@interface MediaConnection : Connection

@property (nonatomic,assign) id<MediaConnectionDelegate> delegate;

@property (nonatomic,strong) VideoView *remoteVideoView;

@property (nonatomic,strong) VideoView *localVideoView;

- (void)recievedRemoteVideoTrack:(RTCVideoTrack*)track;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

@end
