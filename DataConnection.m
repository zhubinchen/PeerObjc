//
//  DataConnection.m
//  PeerObjectiveC
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "DataConnection.h"
#import "RTCPeerConnection.h"
#import "Negotiator.h"
#import "RTCICECandidate.h"
#import "RTCPeerConnection.h"
#import "RTCDataChannel.h"

@interface DataConnection () <RTCDataChannelDelegate>

@property (nonatomic,strong) RTCDataChannel *dataChannel;

@end

@implementation DataConnection
{
    Negotiator *negotiator;
    NSMutableData *rData;
    RTCPeerConnection *pc;
}

- (instancetype)initWithDstPeerId:(NSString *)dstId AndPeer:(Peer *)peer Options:(NSDictionary *)options
{
    if (self = [super initWithDstPeerId:dstId AndPeer:peer Options:options]) {
        self.type = @"data";
        self.id = self.id == nil ? @"dc_phks5x29u9885mi" : self.id;
        NSDictionary *config = options[@"_payload"] ? options[@"_payload"] : @{@"originator": @"true"} ;
        negotiator = [[Negotiator alloc]initWithConnection:self];
        pc = [negotiator startPeerConnectionWithOptions:config];
    }
    
    return self;
}

- (void)handelMessage:(NSDictionary *)msg
{
    NSDictionary *payload = msg[@"payload"];
    if ([msg[@"type"] isEqualToString:@"ANSWER"]) {
        [negotiator handelSdp:payload[@"sdp"] WithType:@"answer"];
        
    } else if ([msg[@"type"] isEqualToString:@"CANDIDATE"]) {
        
        NSDictionary *candidateObj = [payload objectForKey:@"candidate"];
        NSString *candidateMessage = [candidateObj objectForKey:@"candidate"];
        NSInteger sdpMLineIndex = [[candidateObj objectForKey:@"sdpMLineIndex"] integerValue];
        NSString *sdpMid = [candidateObj objectForKey:@"sdpMid"];
        RTCICECandidate *candidate = [[RTCICECandidate alloc] initWithMid:sdpMid index:sdpMLineIndex sdp:candidateMessage];
        [negotiator handleCandidate:candidate];
    }
}

- (void)initializeDataChannel:(RTCDataChannel *)dataChannel
{
    self.dataChannel = dataChannel;
    dataChannel.delegate = self;
    
    NSLog(@"dataChannel OK");
}

- (void)sendData:(NSData *)data
{
    NSMutableData *dataToSend = [data mutableCopy];
    NSString *endSuffix = @"zbc";
    NSLog(@"%@",[endSuffix dataUsingEncoding:NSUTF8StringEncoding]);
    [dataToSend appendData:[endSuffix dataUsingEncoding:NSUTF8StringEncoding]];
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc]initWithData:dataToSend isBinary:YES];
    [_dataChannel sendData:buffer];
}

- (void)sendMessage:(NSString *)msg
{
    RTCDataBuffer *buffer = [[RTCDataBuffer alloc]initWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
    [_dataChannel sendData:buffer];
}

#pragma mark RTCDataChannelDelegate

- (void)channelDidChangeState:(RTCDataChannel *)channel
{
    NSLog(@"datachannel state %u",channel.state);
    if (channel.state == kRTCDataChannelStateOpen) {
        if ([self.delegate respondsToSelector:@selector(dataConnectionDidOpen:)]) {
            [self.delegate dataConnectionDidOpen:self];
        }
    } else if (channel.state == kRTCDataChannelStateClosed) {
        if ([self.delegate respondsToSelector:@selector(dataConnectionDidClosed:)]) {
            [self.delegate dataConnectionDidClosed:self];
        }
    }
}

- (void)channel:(RTCDataChannel *)channel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    if (rData == nil) {
        rData = [NSMutableData data];
    }
    
    [rData appendData:buffer.data];
    
    _recivedData = rData;
    
    if (buffer.isBinary) {
    
        if ([self.delegate respondsToSelector:@selector(dataConnection:DidRecievedData:)]) {
            [self.delegate dataConnection:self DidRecievedData:buffer.data];
        }
        
        NSString *endSuffix = [[NSString alloc]initWithData:[buffer.data subdataWithRange:NSMakeRange(buffer.data.length - 3, 3)] encoding:NSUTF8StringEncoding];
        
        NSLog(@"endSuffix:%@",endSuffix);
        
        if ([endSuffix isEqualToString:@"zbc"]) {
            if ([self.delegate respondsToSelector:@selector(dataConnectionRecieveCompleted:)]) {
                [self.delegate dataConnectionRecieveCompleted:self];
            }
        }
        
    } else {
        
        if ([self.delegate respondsToSelector:@selector(dataConnection:DidRecievedMessage:)]) {
            [self.delegate dataConnection:self DidRecievedMessage:[[NSString alloc]initWithData:buffer.data encoding:NSUTF8StringEncoding]];
        }
        
    }
}

#pragma mark 随机数

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


- (void)close
{
    [super close];

    [pc close];
    
    if ([self.delegate respondsToSelector:@selector(dataConnectionDidClosed:)]) {
        [self.delegate dataConnectionDidClosed:self];
    }
}

@end
