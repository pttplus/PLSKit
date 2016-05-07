//
//  PLSGridMenu.m
//  PLSGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "PLSGridMenu.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

CGFloat const kPLSGridMenuDefaultDuration = 0.25f;
CGFloat const kPLSGridMenuDefaultBlur = 0.3f;
CGFloat const kPLSGridMenuDefaultWidth = 280;

#pragma mark - Functions

CGPoint RNCentroidOfTouchesInView(NSSet *touches, UIView *view) {
    CGFloat sumX = 0.f;
    CGFloat sumY = 0.f;

    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:view];
        sumX += location.x;
        sumY += location.y;
    }

    return CGPointMake((CGFloat)round(sumX / touches.count), (CGFloat)round(sumY / touches.count));
}

#pragma mark - RNMenuItemView

@interface RNMenuItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger itemIndex;

@end


@implementation RNMenuItemView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];


        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.bounds;
    CGFloat inset = floorf(CGRectGetHeight(frame) * 0.1f);

    BOOL hasImage = self.imageView.image != nil;
    BOOL hasText = [self.titleLabel.text length] > 0;

    if (hasImage) {
        CGFloat y = 0;
        CGFloat height = CGRectGetHeight(frame);
        if (hasText) {
            y = inset / 2;
            height = floorf(CGRectGetHeight(frame) * 2/3.f);
        }
        self.imageView.frame = CGRectInset(CGRectMake(0, y, CGRectGetWidth(frame), height), inset, inset);
    }
    else {
        self.imageView.frame = CGRectZero;
    }

    if (hasText) {
        CGFloat y = 0;
        CGFloat height = CGRectGetHeight(frame);
        CGFloat left = 0;
        if (hasImage) {
            y = floorf(CGRectGetHeight(frame) * 2/3.f) - inset / 2;
            height = floorf(CGRectGetHeight(frame) / 3.f);
        }
        if (self.titleLabel.textAlignment == NSTextAlignmentLeft) {
            left = 10;
        }
        self.titleLabel.frame = CGRectMake(left, y, CGRectGetWidth(frame), height);
    }
    else {
        self.titleLabel.frame = CGRectZero;
    }
}

@end

#pragma mark - PLSGridMenuItem

@implementation PLSGridMenuItem

+ (instancetype)emptyItem {
    static PLSGridMenuItem *emptyItem = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyItem = [[PLSGridMenuItem alloc] initWithImage:nil title:nil action:nil];
    });

    return emptyItem;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title action:(dispatch_block_t)action {
    if ((self = [super init])) {
        _image = image;
        _title = [title copy];
        _action = [action copy];
    }

    return self;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    return [self initWithImage:image title:title action:nil];
}

- (instancetype)initWithImage:(UIImage *)image {
    return [self initWithImage:image title:nil action:nil];
}

- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithImage:nil title:title action:nil];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PLSGridMenuItem class]]) {
        return NO;
    }

    return ((self.title == [object title] || [self.title isEqualToString:[object title]]) &&
            (self.image == [object image]));
}

- (NSUInteger)hash {
    return self.title.hash;
}

- (BOOL)isEmpty {
    return [self isEqual:[[self class] emptyItem]];
}

@end

#pragma mark - PLSGridMenu

@interface PLSGridMenu ()

@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) RNMenuItemView *selectedItemView;
@property (nonatomic, assign) BOOL parentViewCouldScroll;

@end

static PLSGridMenu *rn_visibleGridMenu;

@implementation PLSGridMenu

#pragma mark - Lifecycle

+ (instancetype)visibleGridMenu {
    return rn_visibleGridMenu;
}

- (instancetype)initWithItems:(NSArray *)items {
    if ((self = [super init])) {
        _itemSize = CGSizeMake(100.f, 100.f);
        _cornerRadius = 8.f;
        _itemTextColor = [UIColor whiteColor];
        _itemFont = [UIFont boldSystemFontOfSize:14.f];
        _highlightColor = [UIColor colorWithRed:.02f green:.549f blue:.961f alpha:1.f];
        _itemTextAlignment = NSTextAlignmentCenter;
        _menuView = [UIView new];
        _backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _items = [items copy];

        [self setupItemViews];
    }

    return self;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = RNCentroidOfTouchesInView(touches, self.view);

    [self selectItemViewAtPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = RNCentroidOfTouchesInView(touches, self.view);

    [self selectItemViewAtPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    id<PLSGridMenuDelegate> delegate = self.delegate;

    if (self.selectedItemView != nil) {
        PLSGridMenuItem *item = self.items[self.selectedItemView.itemIndex];

        if ([delegate respondsToSelector:@selector(gridMenu:willDismissWithSelectedItem:atIndex:)]) {
            [delegate gridMenu:self
   willDismissWithSelectedItem:item
                       atIndex:self.selectedItemView.itemIndex];
        }

        if (item.action != nil) {
            item.action();
        }
    } else {
        if ([delegate respondsToSelector:@selector(gridMenuWillDismiss:)]) {
            [delegate gridMenuWillDismiss:self];
        }
    }

    [self hideMenu];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selectedItemView.backgroundColor = [UIColor clearColor];
    self.selectedItemView = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.menuView.backgroundColor = self.backgroundColor;
    self.menuView.opaque = NO;
    self.menuView.clipsToBounds = YES;
    self.menuView.layer.cornerRadius = self.cornerRadius;
}

#pragma mark - Actions

- (void)setupItemViews {
    self.itemViews = [NSMutableArray array];

    [self.items enumerateObjectsUsingBlock:^(PLSGridMenuItem *item, NSUInteger idx, BOOL *stop) {
        RNMenuItemView *itemView = [[RNMenuItemView alloc] init];
        itemView.imageView.image = item.image;
        itemView.titleLabel.text = item.title;
        itemView.itemIndex = idx;

        [self.menuView addSubview:itemView];
        [self.itemViews addObject:itemView];
    }];
}

#pragma mark - Layout

- (void)styleItemViews {
    [self.itemViews enumerateObjectsUsingBlock:^(RNMenuItemView *itemView, NSUInteger idx, BOOL *stop) {
        itemView.titleLabel.textColor = self.itemTextColor;
        itemView.titleLabel.textAlignment = self.itemTextAlignment;
        itemView.titleLabel.font = self.itemFont;
    }];
}

- (void)layoutAsGrid {
    NSInteger itemCount = self.items.count;
    NSInteger rowCount = ceilf(sqrtf(itemCount));

    CGFloat height = self.itemSize.height * rowCount;
    CGFloat width = self.itemSize.width * ceilf(itemCount / (CGFloat)rowCount);
    CGFloat itemHeight = floorf(height / (CGFloat)rowCount);
    
    for (NSInteger i = 0; i < rowCount; i++) {
        NSInteger rowLength = ceilf(itemCount / (CGFloat)rowCount);
        NSInteger rowStartIndex = i * rowLength;

        if ((i + 1) * rowLength > itemCount) {
            rowLength = itemCount - i * rowLength;
        }
        NSArray *subItems = [self.itemViews subarrayWithRange:NSMakeRange(rowStartIndex, rowLength)];
        CGFloat itemWidth = floorf(width / (CGFloat)rowLength);
        [subItems enumerateObjectsUsingBlock:^(RNMenuItemView *itemView, NSUInteger idx, BOOL *stop) {
            itemView.frame = CGRectMake(idx * itemWidth, i * itemHeight, itemWidth, itemHeight);
        }];
    }
}

- (void)addGridMenuContraints
{
    NSInteger itemCount = self.items.count;
    NSInteger rowCount = ceilf(sqrtf(itemCount));
    CGFloat height = self.itemSize.height * rowCount;
    CGFloat width = self.itemSize.width * ceilf(itemCount / (CGFloat)rowCount);
    
    self.menuView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:self.menuView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *con2 = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:self.menuView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *con3 = [NSLayoutConstraint constraintWithItem:self.menuView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:width];
    NSLayoutConstraint *con4 = [NSLayoutConstraint constraintWithItem:self.menuView attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:height];
    NSArray *constraints = @[con1,con2,con3,con4];
    
    [self.view addConstraints:constraints];
}

- (void)addLayoutContraintsWithParentViewController:(UIViewController *)parentViewContorller {
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:parentViewContorller.view
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:0
                                                                        toItem:self.view
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:parentViewContorller.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:0
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:parentViewContorller.view
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:0
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1
                                                                          constant:0];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:parentViewContorller.view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:0
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:0];
    
    NSArray *constraints = @[topConstraint,
                             bottomConstraint,
                             leadingConstraint,
                             trailingConstraint];
    
    [parentViewContorller.view addConstraints:constraints];
}

#pragma mark - Animations

- (void)showInViewController:(UIViewController *)parentViewController {
    NSParameterAssert(parentViewController != nil);

    if (rn_visibleGridMenu != nil) {
        [rn_visibleGridMenu hideMenu];
    }

    [self rn_addToParentViewController:parentViewController];

    [self showMenu];
}

- (void)showMenu {
    rn_visibleGridMenu = self;

    [self.view addSubview:self.menuView];
    [self addGridMenuContraints];
}

- (void)hideMenu {
    if (self.dismissAction != nil) {
        self.dismissAction();
    }

    self.view.hidden = YES;
    [self cleanupGridMenu];
    
    rn_visibleGridMenu = nil;
}

- (void)cleanupGridMenu {
    self.selectedItemView = nil;
    [self rn_removeFromParentViewController];
}

#pragma mark - Private

- (void)rn_addToParentViewController:(UIViewController *)parentViewController {
    if (self.parentViewController != nil) {
        [self rn_removeFromParentViewController];
    }

//    [parentViewController addChildViewController:self];
    
    [parentViewController.view addSubview:self.view];
    
    [self addLayoutContraintsWithParentViewController:parentViewController];
    
    [self didMoveToParentViewController:parentViewController];
    
    if ([parentViewController.view respondsToSelector:@selector(setScrollEnabled:)] && [(UIScrollView *)parentViewController.view isScrollEnabled]) {
        self.parentViewCouldScroll = YES;
        [(UIScrollView *)parentViewController.view setScrollEnabled:NO];
    }
    
    [self styleItemViews];
    [self layoutAsGrid];
}

- (void)rn_removeFromParentViewController {
    if (self.parentViewCouldScroll) {
        [(UIScrollView *)self.parentViewController.view setScrollEnabled:YES];
        self.parentViewCouldScroll = NO;
    }
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (RNMenuItemView *)itemViewAtPoint:(CGPoint)point {
    RNMenuItemView *selectedView = nil;

    if (CGRectContainsPoint(self.menuView.frame, point)) {
        point =  [self.view convertPoint:point toView:self.menuView];
        selectedView = [[self.itemViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RNMenuItemView *itemView, NSDictionary *bindings) {
            return CGRectContainsPoint(itemView.frame, point);
        }]] lastObject];
    }

    return selectedView;
}

- (void)selectItemViewAtPoint:(CGPoint)point {
    RNMenuItemView *selectedItemView = [self itemViewAtPoint:point];
    PLSGridMenuItem *item = self.items[selectedItemView.itemIndex];

    if (selectedItemView != self.selectedItemView) {
        self.selectedItemView.backgroundColor = [UIColor clearColor];
    }

    if (![item isEmpty]) {
        selectedItemView.backgroundColor = self.highlightColor;
        self.selectedItemView = selectedItemView;
    } else {
        self.selectedItemView = nil;
    }
}

@end
