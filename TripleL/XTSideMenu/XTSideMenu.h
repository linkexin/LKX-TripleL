//
//  XTSideMenu.h
//  NewXTNews
//
//  Created by XT on 14-8-9.
//  Copyright (c) 2014年 XT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+XTFrame.h"
#import "XTBlurView.h"

@protocol XTSideMenuDelegate;

@interface XTSideMenu : UIViewController

@property (nonatomic, strong) UIViewController *contentViewController;

@property (nonatomic, strong) UIViewController *leftMenuViewController;

@property (nonatomic, weak) id <XTSideMenuDelegate> delegate;

@property (nonatomic) BOOL contentBlur;

@property (nonatomic) BOOL panGestureEnabled;

@property (nonatomic) NSTimeInterval animationDuration;

@property (nonatomic, strong) UIColor *contentBlurViewTintColor;

@property (nonatomic) CGFloat contentBlurViewMinAlpha;

@property (nonatomic) CGFloat contentBlurViewMaxAlpha;

@property (nonatomic) CGFloat leftMenuViewVisibleWidth;

@property (nonatomic) CGFloat leftMenuViewVisibleHeight;

@property (nonatomic, strong) UIColor *menuOpacityViewLeftBackgroundColor;

@property (nonatomic) CGFloat menuOpacityViewLeftMinAlpha;

@property (nonatomic) CGFloat menuOpacityViewLeftMaxAlpha;

+ (XTSideMenu *) shareInstance;
- (void) setContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController;

- (void)presentLeftViewController;
- (void)hideMenuViewController;

@end

@protocol XTSideMenuDelegate <NSObject>

@optional

- (void)sideMenu:(XTSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;

- (void)sideMenu:(XTSideMenu *)sideMenu willShowLeftMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu didShowLeftMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu willHideLeftMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(XTSideMenu *)sideMenu didHideLeftMenuViewController:(UIViewController *)menuViewController;

@end