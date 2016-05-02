//
//  PLSBanner.m
//  PLSBanner
//
//  Created by Wani on 2016/1/27.
//  Copyright © 2016年 Wani. All rights reserved.
//

#import "PLSBanner.h"

@interface PLSBanner()
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) NSLayoutConstraint *leftIconWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftIconHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightIconWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightIconHeightConstraint;
@end

@implementation PLSBanner

#pragma mark - Public

#pragma mark - Init

- (instancetype)initWithView:(UIView *)view {
    self = [super init];
    
    if (self) {
        [view addSubview:self];
    
        [self setupSubViews];
        [self setupConstraints];
        [self addTapGesture];
    }
    
    return self;
}

- (instancetype)initWithNavigationViewController:(UINavigationController *)navigationViewController {
    self = [super init];
    
    if (self) {
        _navigationController = navigationViewController;
        [navigationViewController.view insertSubview:self belowSubview:navigationViewController.navigationBar];
        
        [self setupSubViews];
        [self setupConstraints];
        [self addTapGesture];
    }
    
    return self;
}

#pragma mark - Show & Hide

- (void)show {
    [self show:YES completion:nil];
}

- (void)show:(BOOL)animated completion:(void (^)(void))completion  {
    self.isShow = YES;
    
    [self.superview layoutIfNeeded];
    self.topConstraint.constant = [self getTopOffset];
    
    if (!animated) {
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)hide {
    [self hide:YES completion:nil];
}

- (void)hide:(BOOL)animated completion:(void (^)(void))completion {
    
    self.isShow = NO;

    [self.superview layoutIfNeeded];
    self.topConstraint.constant = [self getTopOffset] - self.height;
    
    if (!animated) {
        return;
    }
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Decorators

- (instancetype)withTextColor:(UIColor *)color {
    self.titleLabel.textColor = color;
    return self;
}

- (instancetype)withHeight:(CGFloat)height {
    self.height = height;
    return self;
}

- (instancetype)withBackgroundColor:(UIColor *)backgroundColor {
    self.backgroundColor = backgroundColor;
    return self;
}

- (instancetype)withText:(NSString *)text {
    self.titleLabel.text = text;
    return self;
}

- (instancetype)withRightIcon:(UIImage *)rightIcon {
    self.rightIconImageView.image = rightIcon;
    return self;
}

- (instancetype)withLeftIcon:(UIImage *)leftIcon {
    self.leftIconImageView.image = leftIcon;
    return self;
}

- (instancetype)withRightIcon:(UIImage *)rightIcon size:(CGSize)size {
    self.rightIconImageView.image = rightIcon;
    self.rightIconWidthConstraint.constant = size.width;
    self.rightIconHeightConstraint.constant = size.height;
    return self;
}

- (instancetype)withLeftIcon:(UIImage *)leftIcon size:(CGSize)size {
    self.leftIconImageView.image = leftIcon;
    self.leftIconWidthConstraint.constant = size.width;
    self.leftIconHeightConstraint.constant = size.height;
    return self;
}

#pragma mark - Static

+ (BOOL)hasBannersOnNavigationController:(UINavigationController *)navigationController {
    return [self bannersOnView:navigationController.view].count > 0;
}

+ (BOOL)hasBannersOnView:(UIView *)view {
    return [self bannersOnView:view].count > 0;
}

+ (NSArray<PLSBanner *> *)bannersOnView:(UIView *)view {
    NSMutableArray *banners = [NSMutableArray new];
    
    [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([v isKindOfClass:[PLSBanner class]]) {
            [banners addObject:v];
        }
    }];
    
    return banners;
}

+ (void)removeFromView:(UIView *)view animated:(BOOL)animated {
    NSArray<PLSBanner *> *banners = [PLSBanner bannersOnView:view];
    [banners enumerateObjectsUsingBlock:^(PLSBanner *banner, NSUInteger idx, BOOL * _Nonnull stop) {
        if (animated) {
            [banner hide:YES completion:^{
                [banner removeFromSuperview];
            }];
        }else {
            [banner removeFromSuperview];
        }
    }];
}

+ (void)removeFromNavigationController:(UINavigationController *)navigationController animated:(BOOL)animated {
    [self removeFromView:navigationController.view animated:YES];
}

#pragma mark - Private

- (void)setupSubViews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor lightGrayColor];
    
    _titleLabel = [UILabel new];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:_titleLabel];

    _rightIconImageView = [UIImageView new];
    _rightIconImageView.contentMode = UIViewContentModeScaleToFill;
    _rightIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_rightIconImageView];
    
    _leftIconImageView = [UIImageView new];
    _leftIconImageView.contentMode = UIViewContentModeScaleToFill;
    _leftIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_leftIconImageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChanged:)
                                                 name:UIApplicationWillChangeStatusBarOrientationNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setHeight:(CGFloat)height {
    _height = height;
    _heightConstraint.constant = height;
    _topConstraint.constant = _isShow ? [self getTopOffset] : [self getTopOffset] - _height;
}

- (void)orientationDidChanged:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[[notification userInfo]
                                           objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
    CGFloat topOffset = [self getTopOffsetToOrientation:orientation];
    _topConstraint.constant = self.isShow ? topOffset : topOffset - self.height;
}

- (CGFloat)getTopOffsetToOrientation:(UIInterfaceOrientation)orientation {
    CGFloat topOffset = 0;
    BOOL isIPhone = [[UIDevice currentDevice].model rangeOfString:@"iPhone"].location != NSNotFound;
    if (self.navigationController) {
        if (isIPhone && UIInterfaceOrientationIsLandscape(orientation)) {
            topOffset += 32;
        }
        else {
            topOffset += 64;
        }
    }
    return topOffset;
}

- (CGFloat)getTopOffset {
    if (!_navigationController) {
        return 0;
    }
    
    CGFloat topOffset = 0;
    topOffset += [UIApplication sharedApplication].isStatusBarHidden ? 0 : 20;
    topOffset += CGRectGetHeight(self.navigationController.navigationBar.frame);
    return topOffset;
}

- (void)setupConstraints {
    
    id views = @{@"banner": self,
                 @"leftIconImageView": _leftIconImageView,
                 @"rightIconImageView": _rightIconImageView,
                 @"titleLabel": _titleLabel};
    
    // banner
    _topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1 constant:[self getTopOffset]-(self.height)];
    [self.superview addConstraint:_topConstraint];
    
    _height = _height > 0 ? _height : 32;
    _heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_height];
    [self addConstraint:_heightConstraint];
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[banner]|" options:0 metrics:nil views:views]];
    
    // titleLabel
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    // leftIconImageView
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_leftIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

    _leftIconHeightConstraint = [NSLayoutConstraint constraintWithItem:_leftIconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:28];
    [self addConstraint:_leftIconHeightConstraint];
    
    _leftIconWidthConstraint = [NSLayoutConstraint constraintWithItem:_leftIconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:28];
    [self addConstraint:_leftIconWidthConstraint];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_leftIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[leftIconImageView]" options:0 metrics:nil views:views]];
    
    // rightIconImageView
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    _rightIconHeightConstraint = [NSLayoutConstraint constraintWithItem:_rightIconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:28];
    [self addConstraint:_rightIconHeightConstraint];
    
    _rightIconWidthConstraint = [NSLayoutConstraint constraintWithItem:_rightIconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:28];
    [self addConstraint:_rightIconWidthConstraint];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightIconImageView]-12-|" options:0 metrics:nil views:views]];
}

- (void)addTapGesture {
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)]];
}

- (IBAction)actionTap:(id)sender {
    if (self.onClickBanner) {
        self.onClickBanner(self);
    }
}

@end
