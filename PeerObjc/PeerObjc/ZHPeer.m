//
//  ZHPeer.m
//  PeerObjc
//
//  Created by zhubch on 15-3-6.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "ZHPeer.h"
#import "WebRTC.h"
#import "ZHPrivate.h"

#define kDefaultHost @"0.peerjs.com"
#define kDefaultPath @"/"
#define kDefaultKey @"lwjd5qra8257b9"

#define kDefaultSTUNServerUrl @"stun:stun.l.google.com:19302"

@interface ZHPeer () <SRWebSocketDelegate>

@property(nonatomic, strong) NSString   *key;
@property(nonatomic, strong) NSString   *host;
@property(nonatomic, strong) NSString   *path;
@property(nonatomic, assign) BOOL       secure;
@property(nonatomic, strong) NSString   *port;

@property(nonatomic, strong) NSArray    *iceServers;
@property(nonatomic, strong) SRWebSocket *webSock;

@end

@implementation ZHPeer
{
    RTCPeerConnectionFactory *factory;
    NSMutableArray *messageQueue;
    NSMutableDictionary *connections;
}

- (instancetype)init{
    return [self initWithPeerId:nil options:nil];
}

- (instancetype)initWithPeerId:(NSString *)peerId options:(NSDictionary *)options
{
    if (options == nil){
        options = [self defaultOptions];
    }
    if (self = [super init]) {
        _peerId = peerId;
        _path = options[@"path"];
        _host = options[@"host"];
        _key  = options[@"key"];
        _port = options[@"port"];
        
        _secure = [options[@"secure"] boolValue];
        _iceServers = [self getIceServersWithUrls:[options[@"config"] objectForKey:@"iceServers"]];

        if (_port.length == 0) {
            _port = _secure ? @"443" : @"9000";
        }
        
        if ([@"/" isEqualToString:_path]) {
            _path = @"";
        }
        _open = NO;
        
        connections = [[NSMutableDictionary alloc]init];
        
        [RTCPeerConnectionFactory initializeSSL];
        factory = [[RTCPeerConnectionFactory alloc]init];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        dispatch_async(queue, ^{
            if (_peerId == nil) {
                [self retrievedID];
            }
            [self initializeServerConnection];
        });
    }
    
    return self;
}

- (NSDictionary*)defaultOptions
{
    return @{
             @"host":kDefaultHost,
             @"path":kDefaultPath,
             @"key":kDefaultKey,
             @"secure":@(NO),
             @"config":@{
                     @"iceServers":@[
                             @{
                                 @"url":kDefaultSTUNServerUrl,
                                 @"username":@"",
                                 @"credential":@""
                                 }
                             ]
                     }
             };
}

- (NSArray*)getIceServersWithUrls:(NSArray*)iceServerUrls
{
    NSMutableArray *servers = [[NSMutableArray alloc] init];
    for (NSDictionary *ice in iceServerUrls) {
        NSString *urlStr = [ice objectForKey:@"url"];
        NSString *user = [ice objectForKey:@"username"];
        NSString *password = [ice objectForKey:@"credential"];
        
        NSURL *stunURL = [NSURL URLWithString:urlStr];
        RTCICEServer *iceServer = [[RTCICEServer alloc] initWithURI:stunURL
                                                           username:user password:password];
        [servers addObject:iceServer];
    }
    
    return servers;
}

#pragma mark 必要的初始化准备

- (void)initializeServerConnection
{
    NSString *proto = _secure ? @"wss" : @"ws";
    NSString *token = [self randStringWithMaxLenght:34];
    NSString *urlStr = [NSString stringWithFormat:@"%@://%@:%@%@/peerjs?key=%@&id=%@&token=%@",
                        proto, _host,  _port, _path, _key, _peerId, token];
    NSLog(@"%@",urlStr);
    
    _webSock = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlStr]];
    _webSock.delegate = self;
    [_webSock open];
}

- (void)retrievedID
{
    NSString *proto = _secure ? @"https" : @"http";
    NSString *urlStr = [[NSString alloc] initWithFormat:@"%@://%@:%@%@/%@/id", proto, _host, _port, _path, _key];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    _peerId = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"peerId: %@", _peerId);
}

#pragma mark 发起连接

- (ZHDataConnection*)connectToPeer:(NSString *)peerId options:(NSDictionary *)options
{
    if (!_open && !_webSock) {
        [self initializeServerConnection];
    }
    ZHDataConnection *d = [[ZHDataConnection alloc]initWithPeer:self destPeerId:peerId options:options];
    [self addConnection:d];
    return d;
}

- (ZHMediaConnection *)callPeer:(NSString *)peerId options:(NSDictionary *)options
{
    if (!_open && !_webSock) {
        [self initializeServerConnection];
    }
    
    ZHMediaConnection *m = [[ZHMediaConnection alloc]initWithPeer:self destPeerId:peerId options:options];
    [self addConnection:m];
    return m;
}

#pragma mark 断开连接

- (void)disconnectAllConnections
{
    [connections enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        for (Connection *conn in obj) {
            [self disconnect:conn];
        }
    }];
}

- (void)disconnect:(Connection *)connection
{
    [connection close];
    [self removeConnection:connection];
}

#pragma mark 从socket接收到消息后的第一步消息处理。连接建立后会把消息转给connection

- (void)handleMessage:(NSString*)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *type = message[@"type"];
    NSDictionary *payload = message[@"payload"];
    NSString *destId = message[@"src"];
    NSString *connectionId = payload[@"connectionId"];
    
    if([@"OPEN" isEqualToString:type]){
        
        [self drainMessages];
        if (_onOpen){
            _open = YES;
            _onOpen(_peerId);
        }
        
    }else if([@"EXPIRE" isEqualToString:type]){
        
        [self drainMessages];
        NSError *err = [NSError errorWithDomain:@"连接超时" code:100 userInfo:nil];
        if (_onError) {
            _onError(err);
        }
        
    }else if ([@"OFFER" isEqualToString:type]) {
                
        Connection *connection = [self getConnectionWithPeerId:destId ConnectionId:connectionId];
       
        if (connection) {
            NSLog(@"Connection is exist");
            return;
        }
        
        if ([payload[@"type"] isEqualToString:@"data"]) {
            connection = [[ZHDataConnection alloc]initWithPeer:self destPeerId:destId options:@{
                                                                                               @"connectionId": connectionId,
                                                                                               @"_payload": payload,
                                                                                               @"metadata": payload[@"metadata"] == nil ? @"" : payload[@"metadata"],
                                                                                               @"label": payload[@"label"],
                                                                                               @"serialization": payload[@"serialization"],
                                                                                               @"reliable": payload[@"reliable"]
                                                                                               }];
            
            [self addConnection:connection];
            
        } else if ([payload[@"type"] isEqualToString:@"media"]) {
            connection = [[ZHMediaConnection alloc]initWithPeer:self destPeerId:destId options:@{
                                                                                               @"connectionId": connectionId,
                                                                                               @"_payload": payload,
                                                                                               @"metadata": payload[@"metadata"] == nil ? @"" : payload[@"metadata"],
                                                                                               @"label": payload[@"label"] == nil ? @"" :payload[@"label"],
                                                                                               }];
            
            [self addConnection:connection];
        }
        
        if (_onConnection){
            _onConnection(connection);
        }
    }
    else {
        Connection *conn = [self getConnectionWithPeerId:destId ConnectionId:payload[@"connectionId"]];
        [conn handelMessage:message];
    }
}

#pragma mark 消息发送

- (void)sendMessage:(NSDictionary *)message
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];

    [messageQueue addObject:data];
    [self drainMessages];
}

- (void)drainMessages
{
    if (!_open) {
        return;
    }
    for (NSDictionary *msg in messageQueue) {
        [_webSock send:msg];
    }
    messageQueue = [[NSMutableArray alloc] initWithCapacity:10];
}

#pragma mark 连接管理

- (void)addConnection:(Connection*)connection
{
    if (connections[connection.destId] == nil) {
        [connections setObject:[NSMutableArray array] forKey:connection.destId];
    }
    [connections[connection.destId] addObject:connection];
}

- (void)removeConnection:(Connection*)connection
{
    [connections[connection.destId] removeObject:connection];
}

- (Connection*)getConnectionWithPeerId:(NSString*)peerId ConnectionId:(NSString*)id
{
    NSArray *connArr = connections[peerId];
    for (Connection *conn in connArr){
        if ([conn.id isEqualToString:id]){
            return conn;
        }
    }
    return nil;
}

#pragma Mark SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"socket open");
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"websocket recieved:%@",message);
    [self handleMessage:message];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"socket error:%@",error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"socket closed reason:%@",reason);
}

#pragma mark 善后

- (void)cleanUp
{
    [self disconnectAllConnections];
    _open = NO;
    [_webSock close];
    _webSock = nil;
}

- (void)dealloc{
    [self cleanUp];
}

#pragma MARK 生成随机数而已

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

@end
