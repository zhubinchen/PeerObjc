//
//  MediaViewController.m
//  Example
//
//  Created by zhubch on 1/9/16.
//  Copyright © 2016 zhubch. All rights reserved.
//

#import "MediaViewController.h"

@interface MediaViewController ()

@property (nonatomic,weak) IBOutlet UIView *localView;
@property (nonatomic,weak) IBOutlet UIView *remoteView;

@end

@implementation MediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
//    [_localView addSubview:_conn.localVideoView];
//    [_remoteView addSubview:_conn.remoteVideoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
