//
//  TextChatViewController.m
//  Example
//
//  Created by zhubch on 1/8/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "TextChatViewController.h"
#import "Utils.h"

@interface TextChatViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,DataConnectionDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardChanged:(NSNotification*)noti
{
    NSDictionary *info = noti.userInfo;
    
    NSTimeInterval interval = [info[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat height = kScreenHeight - [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;

    [self.view layoutIfNeeded];
    [UIView animateWithDuration:interval animations:^{
        self.bottomSpace.constant = height;
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendMessage:nil];
    return YES;
}

- (void)dataConnectionDidOpen:(DataConnection *)connection
{
    NSLog(@"connection opened");
}

- (void)dataConnection:(DataConnection *)connection didRecievedMessage:(NSString *)msg
{
    [messages addObject:@{@"fromSelf":@(NO),@"message":msg}];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_messageTableView reloadData];
    });
}

- (IBAction)sendMessage:(id)sender
{
    if (_messageInput.text.length) {
        [_conn sendMessage:_messageInput.text];
        [messages addObject:@{@"fromSelf":@(YES),@"message":_messageInput.text}];
        _messageInput.text = @"";
        [_messageTableView reloadData];
        [_messageInput resignFirstResponder];
    }else{
        [self showToast:@"请输入要发送的内容"];
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
    NSDictionary *msg = messages[indexPath.row];
    cell.textLabel.text = msg[@"message"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    if ([msg[@"fromSelf"] boolValue]) {
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.textLabel.textColor = [UIColor colorWithRed:0.1 green:0.8 blue:0.6 alpha:1];
    }else{
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.textColor = [UIColor grayColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *msg = messages[indexPath.row];
    NSString *m = msg[@"message"];
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:m
     attributes:attributes];
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(kScreenWidth - 20, 100)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil].size;
    return size.height + 20;
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
