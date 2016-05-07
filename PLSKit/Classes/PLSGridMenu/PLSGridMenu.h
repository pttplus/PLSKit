//
//  PLSGridMenu.h
//  PLSGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PLSGridMenu;

@interface PLSGridMenuItem : NSObject

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, copy) dispatch_block_t action;

+ (instancetype)emptyItem;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title action:(dispatch_block_t)action;
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithTitle:(NSString *)title;

- (BOOL)isEmpty;

@end

@protocol PLSGridMenuDelegate <NSObject>
@optional
- (void)gridMenu:(PLSGridMenu *)gridMenu willDismissWithSelectedItem:(PLSGridMenuItem *)item atIndex:(NSInteger)itemIndex;
- (void)gridMenuWillDismiss:(PLSGridMenu *)gridMenu;
@end


@interface PLSGridMenu : UIViewController

+ (instancetype)visibleGridMenu;

@property (nonatomic, readonly) UIView *menuView;

// the menu items. Instances of PLSGridMenuItem
@property (nonatomic, readonly) NSArray *items;

// An optional delegate to receive information about what items were selected
@property (nonatomic, weak) id<PLSGridMenuDelegate> delegate;

// The color that items will be highlighted with on selection.
// default table view selection blue
@property (nonatomic, strong) UIColor *highlightColor;

// The background color of the main view (note this is a UIViewController subclass)
// default black with 0.7 alpha
@property (nonatomic, strong) UIColor *backgroundColor;

// defaults to nil, the path to be applied as a mask to the background image. if this path is set, cornerRadius is ignored
//@property (nonatomic, strong) UIBezierPath *backgroundPath;

// defaults to 8 (only applied if backgroundPath == nil)
@property (nonatomic, assign) CGFloat cornerRadius;

// The size of an item
// default {100, 100}
@property (nonatomic, assign) CGSize itemSize;

// The time in seconds for the show and dismiss animation
// default 0.25f
//@property (nonatomic, assign) CGFloat animationDuration;

// The text color for list items
// default white
@property (nonatomic, strong) UIColor *itemTextColor;

// The font used for list items
// default bold size 14
@property (nonatomic, strong) UIFont *itemFont;

// The text alignment of the item titles
// default center
@property (nonatomic, assign) NSTextAlignment itemTextAlignment;

// An optional block that gets executed before the gridMenu gets dismissed
@property (nonatomic, copy) dispatch_block_t dismissAction;

// Initialize the menu with a list of menu items.
// Note: this changes the view to style PLSGridMenuStyleList if no images are supplied
- (instancetype)initWithItems:(NSArray *)items;

// Show the menu
- (void)showInViewController:(UIViewController *)parentViewController;

// Dismiss the menu
// This is called when the window is tapped. If tapped inside the view an item will be selected.
// If tapped outside the view, the menu is simply dismissed.
- (void)hideMenu;

@end


@interface RNLongPressGestureRecognizer : UILongPressGestureRecognizer

@end
