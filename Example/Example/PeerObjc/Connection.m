//
//  Connection.m
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "Connection.h"
#import "WebRTC.h"
#import "Peer.h"

@implementation Connection

- (instancetype)initWithPeer:(Peer *)peer destPeerId:(NSString *)destId options:(NSDictionary *)options
{
    if (self = [super init]) {
        _destId = destId;
        _peer = peer;
        _open = NO;
        _id = options[@"connectionId"];
        _label = options[@"label"] ? options[@"label"] : @"";
        _metadata = options[@"metadata"];
        _serialization = @"binary";
        _reliable = YES;
        self.id = self.id == nil ? [self randStringWithMaxLenght:15] : self.id;
    }
    
    return self;
}

- (void)handelMessage:(NSDictionary *)msg
{
    //子类实现
}

- (void)close
{
    _open = NO;
    NSLog(@"%@ closed",self);
}

- (NSString *)randStringWithMaxLenght:(NSInteger)len
{
    NSInteger length = [self randBetween:len max:len];
    unichar letter[length];
    for (int i = 0; i < length; i++) {
        letter[i] = [self randBetween:65 max:90];
    }
    return [[[NSString alloc] initWithCharacters:letter length:length] lowercaseString];
}

- (NSInteger)randBetween:(NSInteger)min max:(NSInteger)max
{
    return (random() % (max - min + 1)) + min;
}

- (void)dealloc
{
    NSLog(@"%@:dealloc",self);
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"class:%@ <connectionID:%@,srcPeer:%@,dstPeer:%@>",NSStringFromClass([self class]),self.id,self.peer.peerId,self.destId];
}

@end
