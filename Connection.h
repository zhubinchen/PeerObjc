//
//  Connection.h
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Peer;

@interface Connection : NSObject

@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *id;

@property (nonatomic,assign) BOOL open;

@property (nonatomic,strong) NSString *dstId;

@property (nonatomic,strong) Peer *peer;

@property (nonatomic,strong) NSString *label;

@property (nonatomic,strong) NSString *serialization;

@property (nonatomic,assign) BOOL reliable;

@property (nonatomic,strong) NSString *metadata;

@property (nonatomic,strong) NSString *dstBrowser;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithDstPeerId:(NSString*)dstId AndPeer:(Peer*)peer Options:(NSDictionary*)options;

- (void)handelMessage:(NSDictionary*)msg;

- (void)close;

@end
