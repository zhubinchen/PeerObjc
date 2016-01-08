//
//  TextChatViewController.m
//  Example
//
//  Created by zhubch on 1/8/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "TextChatViewController.h"

@interface TextChatViewController () <UITableViewDataSource,UITableViewDelegate,DataConnectionDelegate>

@property (nonatomic,weak) IBOutlet UITableView *messageTableView;
@property (nonatomic,weak) IBOutlet UITextField *messageInput;

@end

@implementation TextChatViewController
{
    NSMutableArray *messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    messages = [NSMutableArray array];
    _conn.delegate = self;
}

- (void)dataConnection:(DataConnection *)connection didRecievedMessage:(NSString *)msg
{
    [messages addObject:_messageInput.text];
    [_messageTableView reloadData];
}

- (IBAction)sendMessage:(id)sender
{
    if (_messageInput.text.length) {
        [_conn sendMessage:_messageInput.text];
        [messages addObject:_messageInput.text];
        _messageInput.text = @"";
        [_messageTableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messages.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"message" forIndexPath:indexPath];
    cell.textLabel.text = messages[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
