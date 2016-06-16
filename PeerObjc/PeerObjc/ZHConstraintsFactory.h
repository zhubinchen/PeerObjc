//
//  ZHConstraintsFactory.h
//  PeerObjc
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RTCMediaConstraints;

@interface ZHConstraintsFactory : NSObject

+ (RTCMediaConstraints*)constraintsForDataConnection;

+ (RTCMediaConstraints*)constraintsForMediaConnection;

+ (RTCMediaConstraints*)constraintsForAnswer;

+ (RTCMediaConstraints*)constraintsForOffer;

+ (RTCMediaConstraints*)constraintsForMediaStream;

@end
