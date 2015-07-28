//
//  ConstraintsFactory.m
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-9.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "ConstraintsFactory.h"
#import "RTCPair.h"
#import "RTCMediaConstraints.h"

@implementation ConstraintsFactory

+ (RTCMediaConstraints *)constraintsForDataConnection
{
    RTCPair* audio = [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"false"];
    RTCPair* video = [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"];
    NSArray* mandatory = @[ audio, video];
    
    RTCPair *sctpDatachannels = [[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"];
    
    RTCPair *dtlsSrtpKeyAgreeement = [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"];
    
    NSArray *optionalConstraints = @[
                                     sctpDatachannels,dtlsSrtpKeyAgreeement
////                                     [[RTCPair alloc] initWithKey:@"DtlsDataChannels" value:@"true"],
//                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]
                                     ];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatory
     optionalConstraints:optionalConstraints];
    return constraints;
    
}

+ (RTCMediaConstraints *)constraintsForMediaConnection
{
    NSArray *optionalConstraints = @[
                                     [[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]
                                     ];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:optionalConstraints];
    
    return constraints;
}

+ (RTCMediaConstraints *)constraintsForAnswer
{
    NSArray *mandatoryConstraints = @[
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"],
                                      [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]
                                    ];
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:mandatoryConstraints
     optionalConstraints:nil];
    return constraints;
}

+ (RTCMediaConstraints *)constraintsForOffer
{
    return [self constraintsForAnswer];
}

+ (RTCMediaConstraints *)constraintsForMediaStream
{
    RTCMediaConstraints* constraints =
    [[RTCMediaConstraints alloc]
     initWithMandatoryConstraints:nil
     optionalConstraints:nil];
    return constraints;
}

@end
