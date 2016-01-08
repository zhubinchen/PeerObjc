//
//  ViewController.m
//  Example
//
//  Created by zhubch on 1/8/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "ViewController.h"
#import "Peer.h"
#import "DataConnection.h"
#import "MediaConnection.h"
#import "Utils.h"
#import "TextChatViewController.h"

@interface ViewController ()
@property (nonatomic,weak) IBOutlet UITextField *myPeerIdText;
@property (nonatomic,weak) IBOutlet UITextField *otherPeerIdText;
@property (nonatomic,strong) DataConnection *dataConnection;
@property (nonatomic,strong) MediaConnection *mediaConnection;

@end

@implementation ViewController
{
    Peer *p;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    p = [[Peer alloc]initWithPeerId:@"123qweqq" options:nil];
    
    __weak ViewController *__self = self;
    p.onOpen = ^(NSString *peerId){
        __self.myPeerIdText.text = peerId;
        NSLog(@"%@",peerId);
    };
    
    p.onConnection = ^(Connection *conn){
        if ([conn isKindOfClass:[DataConnection class]]) {
            __self.dataConnection = (DataConnection*)conn;
        }else{
            __self.mediaConnection = (MediaConnection*)conn;
        }
        NSString *msg =  [NSString stringWithFormat:@"%@%@",conn.destId,[conn isKindOfClass:[DataConnection class]] ? @"":@""];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.clickedButton = ^(NSInteger buttonIndex,UIAlertView *alertView){
            if (buttonIndex == 0) {
                [__self performSegueWithIdentifier:@"text" sender:nil];
            }else {
                [conn close];
            }
            [alertView releaseBlock];
        };
        [alert show];
    };
}

- (IBAction)textChat:(id)sender
{
    if (_otherPeerIdText.text.length) {
        _dataConnection = [p connectToPeer:_otherPeerIdText.text options:@{@"label":@"text",@"serialization":@"none",@"metadata":@{@"message":@"12345"}}];
        [self performSegueWithIdentifier:@"text" sender:nil];
        return;
    }
    [self showToast:@"请输入对方的peerID"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"text"]) {
        TextChatViewController *vc = segue.destinationViewController;
        vc.conn = _dataConnection;
    }
}

@end
