//
//  Connection.h
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Peer;

/**
 *  不要实例化这个类。请用他的子类
 */
@interface Connection : NSObject

@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *id;

@property (nonatomic,assign) BOOL open;

@property (nonatomic,strong) NSString *destId;

@property (nonatomic,strong) Peer *peer;

@property (nonatomic,strong) NSString *label;

@property (nonatomic,strong) NSString *serialization;

@property (nonatomic,assign) BOOL reliable;

@property (nonatomic,strong) NSString *metadata;

@property (nonatomic,strong) NSString *destBrowser;

- (instancetype)initWithPeer:(Peer*)peer destPeerId:(NSString*)destId options:(NSDictionary*)options;

- (void)handelMessage:(NSDictionary*)msg;

- (void)close;

@end
