//
//  Private.h
//  Example
//
//  Created by zhubch on 1/11/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#ifndef Private_h
#define Private_h

#import "SRWebSocket.h"
#import "Peer.h"

@interface Peer (project)

@property(nonatomic, strong, readonly) SRWebSocket *webSock;

@property(nonatomic, strong, readonly) NSArray     *iceServers;

@end

@interface DataConnection (project)

- (void)initializeDataChannel:(RTCDataChannel*)dataChannel;

@end

@interface MediaConnection (project)

- (void)recievedRemoteVideoTrack:(RTCVideoTrack*)track;

@end

#endif /* Private_h */
