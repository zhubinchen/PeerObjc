//
//  Utils.m
//  GolfPKiOS
//
//  Created by zhubch on 15/7/28.
//  Copyright (c) 2015年 Robusoft. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "Utils.h"

@implementation NSData (Utils)

- (NSDictionary *)toDictionay
{
//    NSString *s = [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self options:0 error:nil];
    return dic;
}

- (NSString*)toString
{
    NSString *s = [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
    return s;
}

@end

@implementation UIView (Utils)

@dynamic borderColor;
@dynamic borderRadius;
@dynamic borderWidth;

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.masksToBounds = YES;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderRadius:(CGFloat)borderRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = borderRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = borderWidth;
}

- (void)showBorderWithColor:(UIColor *)color radius:(CGFloat)radius width:(CGFloat)width
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = width;
    self.layer.borderColor = color.CGColor;
}

- (void)makeRound:(float)radius
{
    [self showBorderWithColor:[UIColor clearColor] radius:radius width:1.0];
}

- (void)showShadowWithColor:(UIColor *)color offset:(CGSize)offset
{
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowColor = color.CGColor;
    self.clipsToBounds = NO;
}

@end

@implementation UIViewController (Utils)

- (void)showToast:(NSString *)message
{
    UIWindow *window=[[[UIApplication sharedApplication] delegate] window];

    UIView *oldView = [self.view viewWithTag:52684653];

    [oldView removeFromSuperview];

    if (message.length < 1) {
        return;
    }
    
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:message
     attributes:attributes];
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(kScreenWidth - 20, 40)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil].size;
    CGFloat w = size.width + 20;
    CGFloat h = size.height + 10;

    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake((kScreenWidth - w) * 0.5,kScreenHeight - 60 - h, w, h)];
    l.numberOfLines = 0;
    l.text = message;
    l.textColor = [UIColor whiteColor];
    l.backgroundColor = [UIColor darkGrayColor];
    l.font = [UIFont systemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    l.tag = 52684653;
    [l makeRound:5];
    l.alpha = 0.5;
    
    [window addSubview:l];
    
    [UIView animateWithDuration:0.15 animations:^{
        l.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.5 animations:^{
                    l.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [l removeFromSuperview];
                }];
            });
        }
    }];
}

- (void)beginLoadingAnimation:(NSString*)message
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;

    UIView *oldView = [window viewWithTag:52684654];
    if (oldView) {
        [oldView removeFromSuperview];
    }
    
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    v.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [v makeRound:5];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.center = CGPointMake(40, 30);
    [activity startAnimating];
    [v addSubview:activity];
    
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, 86, 20)];
    l.textAlignment = NSTextAlignmentCenter;
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:12];
    l.text = message;
    [v addSubview:l];
    
    UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    bg.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.1];
    bg.tag = 52684654;
    
    v.center = bg.center;
    [bg addSubview:v];

    [window addSubview:bg];
}

- (void)stopLoadingAnimation
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;

    UIView *v = [window viewWithTag:52684654];
    [v removeFromSuperview];
}

@end

static void (^block)(NSInteger,UIAlertView*) = nil;

@implementation UIAlertView (Utils)

@dynamic clickedButton;

- (void)setClickedButton:(void (^)(NSInteger buttonIndex,UIAlertView* alertView))clickedButton
{
    block = clickedButton;
    self.delegate = self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (block) {
        block(buttonIndex,alertView);
    }
}

- (void)releaseBlock
{
//    Block_release(block); 
    block = nil;
}

@end


