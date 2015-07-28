//
//  Connection.h
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Peer;


/**
 *  不要试着实例化这个类。请用他的子类
 */
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

- (instancetype)initWithDstPeerId:(NSString*)dstId AndPeer:(Peer*)peer Options:(NSDictionary*)options;

- (void)handelMessage:(NSDictionary*)msg;

- (void)close;

@end
