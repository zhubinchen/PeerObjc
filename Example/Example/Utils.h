//
//  Utils.h
//  GolfPKiOS
//
//  Created by zhubch on 15/7/28.
//  Copyright (c) 2015年 Robusoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define kIsSimulator [[UIDevice currentDevice].model hasSuffix:@"Simulator"]

#define kIsPhone ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)

#define SYSTEM_VERSION   [[UIDevice currentDevice].systemVersion floatValue]

/**
 *  方便调试
 */
@interface NSData (Utils)

- (NSDictionary*)toDictionay;

- (NSString*)toString;

@end

@interface UIView (Utils)

/**
 *  边框颜色，支持可视化修改
 */
@property (nonatomic,strong) IBInspectable UIColor *borderColor;
/**
 *  边框宽度，支持可视化修改
 */
@property (nonatomic,assign) IBInspectable CGFloat borderWidth;
/**
 *  边框半径。支持可视化修改
 */
@property (nonatomic,assign) IBInspectable CGFloat borderRadius;


/**
 *  设置成圆角
 *
 *  @param radius 圆角半径
 */
- (void)makeRound:(float)radius;

/**
 *  设置边框
 *
 *  @param color  边框颜色
 *  @param radius 边框半径
 *  @param width  边框宽度
 */
- (void)showBorderWithColor:(UIColor *)color radius:(CGFloat)radius width:(CGFloat)width;

/**
 *  设置阴影
 *
 *  @param color  阴影颜色
 *  @param offset 阴影偏移
 */
- (void)showShadowWithColor:(UIColor *)color offset:(CGSize)offset;

@end

@interface UIViewController (Utils)

/**
 *  显示一个android风格的toast
 *
 *  @param message 显示的内容
 */
- (void)showToast:(NSString*)message;

/**
 *  显示一个简单的活动指示器
 */
- (void)beginLoadingAnimation:(NSString*)message;

/**
 *  隐藏活动指示器
 */
- (void)stopLoadingAnimation;

@end

@interface UIAlertView (Utils)

/**
 *  代替delegate
 */
@property (nonatomic) void(^clickedButton)(NSInteger,UIAlertView*);

/**
 *  然而这个block并不会被自动释放，所以你需要这个方法
 */
- (void)releaseBlock;

@end


