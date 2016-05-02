//
//  PLSBanner.h
//  PLSBanner
//
//  Created by Wani on 2016/1/27.
//  Copyright © 2016年 Wani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLSBanner : UIView
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *leftIconImageView;
@property (nonatomic, strong) UIImageView *rightIconImageView;
@property (nonatomic, copy) void (^onClickBanner)(PLSBanner *banner);

- (instancetype)initWithNavigationViewController:(UINavigationController *)navigationViewController;
- (instancetype)initWithView:(UIView *)view;

- (instancetype)withTextColor:(UIColor *)color;
- (instancetype)withHeight:(CGFloat)height;
- (instancetype)withBackgroundColor:(UIColor *)backgroundColor;
- (instancetype)withText:(NSString *)text;

// default iconImageView size (28,28)
- (instancetype)withRightIcon:(UIImage *)rightIcon;
- (instancetype)withLeftIcon:(UIImage *)leftIcon;

- (instancetype)withRightIcon:(UIImage *)rightIcon size:(CGSize)size;
- (instancetype)withLeftIcon:(UIImage *)leftIcon size:(CGSize)size;

- (void)show;
- (void)hide;

+ (NSArray<PLSBanner *> *)bannersOnView:(UIView *)view;
+ (BOOL)hasBannersOnNavigationController:(UINavigationController *)navigationController;
+ (BOOL)hasBannersOnView:(UIView *)view;
+ (void)removeFromView:(UIView *)view animated:(BOOL)animated;
+ (void)removeFromNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated;

@end
