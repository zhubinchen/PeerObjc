//
//  ViewController.m
//  Example
//
//  Created by zhubch on 1/8/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ViewController.h"
#import "Peer.h"

@interface ViewController ()

@end

@implementation ViewController
{
    Peer *p;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    p = [[Peer alloc]initWithPeerId:@"123" options:nil];
    p.onOpen = ^(NSString *peerId){
        NSLog(@"%@",peerId);
        //        [p connectToPeer:@"g1slnv8jyzrrudi" Options:@{@"label":@"text",@"serialization":@"none",@"metadata":@{@"message":@"12345"}}];
    };
    p.onConnection = ^(Connection *conn){
        NSLog(@"zzz");
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
