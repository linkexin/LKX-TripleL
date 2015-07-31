//
//  XTSideMenu.m
//  NewXTNews
//
//  Created by XT on 14-8-9.
//  Copyright (c) 2014年 XT. All rights reserved.
//

#import "XTSideMenu.h"
#import "MessageViewController.h"
#import "MenuViewController.h"

static XTSideMenu *sideMenu = nil;

typedef NS_ENUM(NSUInteger, XTSideMenuVisibleType) {
    XTSideMenuVisibleTypeContent = 0,
    XTSideMenuVisibleTypeLeft = 1,
    XTSideMenuVisibleTypeMoving = 3,
};

typedef NS_ENUM(NSUInteger, XTSideMenuShowType) {
    XTSideMenuShowTypeNone = 0,
    XTSideMenuShowTypeLeft = 1,
};

typedef NS_ENUM(NSUInteger, XTSideMenuDelegateType) {
    XTSideMenuDelegateTypeDidRecognizePanGesture,
    
    XTSideMenuDelegateTypeWillShowLeftMenuViewController,
    XTSideMenuDelegateTypeDidShowLeftMenuViewController,
    XTSideMenuDelegateTypeWillHideLeftMenuViewController,
    XTSideMenuDelegateTypeDidHideLeftMenuViewController,
};


@interface XTSideMenu ()<UIGestureRecognizerDelegate>

@property (nonatomic) XTSideMenuVisibleType visibleType;
@property (nonatomic) XTSideMenuShowType showType;
@property (nonatomic) CGPoint originalPoint;
@property (nonatomic, strong) UIView *menuViewContainer;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIView *menuOpacityView;
@property (nonatomic, strong) UIView *contentViewContainer;
@property (nonatomic, strong) XTBlurView *contentBlurView;

@end

@implementation XTSideMenu

+ (XTSideMenu *) shareInstance
{
    if (sideMenu == nil) {
        sideMenu = [[XTSideMenu alloc] init];
    }
    return sideMenu;
}

- (id)init
{
    if (self = [super init]) {
        _visibleType = XTSideMenuVisibleTypeContent;
        _menuViewContainer = [[UIView alloc] init];
        _contentViewContainer = [[UIView alloc] init];
        _contentBlurViewTintColor = [UIColor colorWithWhite:0.7 alpha:0.73];
        _contentBlurViewMinAlpha = 0;
        _contentBlurViewMaxAlpha = 1.0;
        _leftMenuViewVisibleWidth = [UIScreen mainScreen].bounds.size.width * 0.6;
        _animationDuration = 0.35;
        _panGestureEnabled = YES;
        _contentBlur = NO;
        _menuOpacityViewLeftMinAlpha = 0.75;
        _menuOpacityViewLeftMaxAlpha = 0.8;
        _menuOpacityViewLeftBackgroundColor = [UIColor grayColor];
    }
    return self;
}


- (void) setContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController
{
    _contentViewController = contentViewController;
    _leftMenuViewController = menuViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.menuButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectNull;
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    self.menuOpacityView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectNull];
        view;
    });
    
    self.contentBlurView = ({
        XTBlurView *imageView = [[XTBlurView alloc] initWithFrame:CGRectNull];
        [self updateContentBlurViewImage];
        imageView;
    });
    
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.leftMenuViewController) {
        [self addChildViewController:self.leftMenuViewController];
        self.leftMenuViewController.view.frame = CGRectMake(0, 0, self.leftMenuViewVisibleWidth, CGRectGetHeight(self.view.bounds));
        self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
        [self.menuViewContainer addSubview:self.leftMenuViewController.view];
        [self.leftMenuViewController didMoveToParentViewController:self];
        self.leftMenuViewController.view.hidden = YES;
    }
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    self.menuViewContainer.alpha = 0;
    
    self.view.multipleTouchEnabled = NO;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    panGestureRecognizer.delegate = self;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [self addCenterKVO];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.panGestureEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orientChange:(NSNotification *)noti
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
       
        self.leftMenuViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 0.6, CGRectGetWidth(self.view.bounds));
    }
    else {
        self.leftMenuViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 0.4, CGRectGetWidth(self.view.bounds));
    }
}



#pragma mark KVO Method

- (void)addCenterKVO
{
    [self.leftMenuViewController.view addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"center"])
    {
        UIView *view = object;
        if (view == self.leftMenuViewController.view)
        {
            if (CGRectGetMinX(view.frame) > 0)
            {
                view.left = 0;
            }
        }
    }
}

#pragma mark -
#pragma mark - PublicMethod

/*!
 *  显示leftMenu
 */

- (void)presentLeftViewController
{
    if (self.leftMenuViewController)
    {
        [self dealDelegateWithType:XTSideMenuDelegateTypeWillShowLeftMenuViewController object:self.leftMenuViewController];
        
        [self _presentLeftViewController];
    }
    else
    {
         NSAssert(false,@"NONE LEFTMENU!");
    }
}

/*!
 *  隐藏menu
 */

- (void)hideMenuViewController
{
    if (self.visibleType == XTSideMenuVisibleTypeLeft) {
        [self dealDelegateWithType:XTSideMenuDelegateTypeWillHideLeftMenuViewController object:self.leftMenuViewController];
    }
    
    XTSideMenuVisibleType type = self.visibleType;
    [self.menuButton removeFromSuperview];
    self.visibleType = XTSideMenuVisibleTypeMoving;
    
    switch (type)
    {
        case XTSideMenuVisibleTypeLeft:
        {
            CGPoint center = self.leftMenuViewController.view.center;
            CGPoint endCenter = CGPointMake(center.x - CGRectGetWidth(self.leftMenuViewController.view.bounds), center.y);
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 self.leftMenuViewController.view.center = endCenter;
                                 self.menuOpacityView.center = endCenter;
                                 self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
                                 self.contentBlurView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 self.menuViewContainer.alpha = 0;
                                 self.leftMenuViewController.view.center = center;
                                 self.leftMenuViewController.view.hidden = YES;
                                 self.visibleType = XTSideMenuVisibleTypeContent;
                                 [self.contentBlurView removeFromSuperview];
                                 [self dealDelegateWithType:XTSideMenuDelegateTypeDidHideLeftMenuViewController object:self.leftMenuViewController];
                             }];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark - Private Method

- (CGPoint)leftMenuViewCenter:(XTSideMenuShowType)type
{
    switch (type)
    {
        case XTSideMenuShowTypeNone:
            return CGPointMake(-1 * self.leftMenuViewVisibleWidth / 2.0, CGRectGetHeight(self.leftMenuViewController.view.bounds) / 2.0);
            break;
        case XTSideMenuShowTypeLeft:
            return CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetHeight(self.leftMenuViewController.view.bounds) / 2.0);
            break;
        default:
            break;
    }
}

- (void)prepareForPresentMenuViewController
{
    [self.view bringSubviewToFront:self.menuViewContainer];

    [self.view.window endEditing:YES];
    
    [self addContentBlurView];
    
    [self addMenuButton];
    
    self.menuButton.enabled = NO;
    
    self.menuViewContainer.alpha = 1;
    
    self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
}

- (void)prepareForPresentLeftViewController
{
    [self prepareForPresentMenuViewController];
    
    self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
    
    [self addMenuOpacityView:XTSideMenuShowTypeLeft];
    
    [self updateMenuOperateViewBackgroundColor:XTSideMenuShowTypeLeft];
    
    self.leftMenuViewController.view.hidden = NO;
    
    self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
    
    self.menuOpacityView.center = self.leftMenuViewController.view.center;
}

- (void)_presentLeftViewController
{
    if (!_leftMenuViewController) {
        return;
    }
    [_leftMenuViewController viewWillAppear:YES];
    
    [self prepareForPresentLeftViewController];
    
    [self userInteractionEnabled:NO];
    
    [UIView animateWithDuration:self.animationDuration
                     animations:^{
                         self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeLeft];
                         self.menuOpacityView.center = [self leftMenuViewCenter:XTSideMenuShowTypeLeft];
                         self.menuOpacityView.alpha = self.menuOpacityViewLeftMaxAlpha;
                         self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                     }
                     completion:^(BOOL finished) {
                         [self userInteractionEnabled:YES];
                         self.visibleType = XTSideMenuVisibleTypeLeft;
                         self.menuButton.enabled = YES;
                         [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowLeftMenuViewController object:self.leftMenuViewController];
                     }];
}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint Point = [touch locationInView:self.view];
    if (Point.x > 50) {
        return NO;
    }
    else if(((UINavigationController *)(((UITabBarController *)self.contentViewController).selectedViewController)).viewControllers.count > 1){
        return NO;
    }

    return YES;
}


#pragma mark -
#pragma mark PanGestureAction

- (void)prepareForPanPresentLeftViewController
{
    [self prepareForPresentLeftViewController];
    [_leftMenuViewController viewWillAppear:YES];
    self.showType = XTSideMenuShowTypeLeft;
}


static bool canMove = NO;

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)sender
{
    [self dealDelegateWithType:XTSideMenuDelegateTypeDidRecognizePanGesture object:sender];
    
    if (self.visibleType == XTSideMenuVisibleTypeContent)
    {
        CGPoint point = [sender locationInView:self.view];
        
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                CGPoint dirPoint = [sender translationInView:self.view];
                
                self.originalPoint = point;
                if (self.originalPoint.x > 50) {
                    canMove = NO;
                    self.panGestureEnabled = NO;
                    return;
                }
                else{
                    if(((UINavigationController *)(((UITabBarController *)self.contentViewController).selectedViewController)).viewControllers.count > 1){
                        canMove = NO;
                        self.panGestureEnabled = NO;
                        return;
                    };
                    
                    canMove = YES;
                }
                
                if (dirPoint.x > 0 && self.leftMenuViewController)
                {
                    [self dealDelegateWithType:XTSideMenuDelegateTypeWillShowLeftMenuViewController object:self.leftMenuViewController];
                    
                    [self prepareForPanPresentLeftViewController];
                }
                else
                {
                    self.showType = XTSideMenuShowTypeNone;
                }
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                if (!canMove) {
                    return;
                }
                if (self.showType == XTSideMenuShowTypeLeft)
                {
                    CGRect rect = self.leftMenuViewController.view.frame;
                    CGFloat maxX = CGRectGetMaxX(rect);
                    CGFloat progress = maxX / self.leftMenuViewVisibleWidth;
                    self.menuOpacityView.alpha = progress * (self.menuOpacityViewLeftMaxAlpha - self.menuOpacityViewLeftMinAlpha) + self.menuOpacityViewLeftMinAlpha;
                    self.contentBlurView.alpha = self.contentBlurViewMinAlpha + progress * (self.contentBlurViewMaxAlpha - self.contentBlurViewMinAlpha);
                    
                    CGPoint center = self.leftMenuViewController.view.center;
                    self.leftMenuViewController.view.center = CGPointMake(center.x + point.x - self.originalPoint.x, center.y);
                    self.menuOpacityView.center = self.leftMenuViewController.view.center;
                    self.originalPoint = point;
                }
                break;
            }
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                if (!canMove) {
                    return;
                }
                if (self.showType == XTSideMenuShowTypeLeft)
                {
                    CGRect rect = self.leftMenuViewController.view.frame;
                    CGFloat maxX = CGRectGetMaxX(rect);
                    CGFloat deltaX = [sender velocityInView:self.view].x;
                    if (maxX == self.leftMenuViewVisibleWidth)
                    {
                        self.menuButton.enabled = YES;
                        self.visibleType = XTSideMenuVisibleTypeLeft;
                        
                        [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowLeftMenuViewController object:self.leftMenuViewController];
                    }
                    else if ((maxX < self.leftMenuViewVisibleWidth && maxX >= self.leftMenuViewVisibleWidth / 2.0) || deltaX > 400)
                    {
                        [self userInteractionEnabled:NO];
                        [UIView animateWithDuration:self.animationDuration
                                         animations:^{
                                             self.leftMenuViewController.view.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                             self.menuOpacityView.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                             self.menuOpacityView.alpha = self.menuOpacityViewLeftMaxAlpha;
                                             self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                                         }
                                         completion:^(BOOL finished) {
                                             [self userInteractionEnabled:YES];
                                             self.menuButton.enabled = YES;
                                             self.visibleType = XTSideMenuVisibleTypeLeft;
                                             [self dealDelegateWithType:XTSideMenuDelegateTypeDidShowLeftMenuViewController object:self.leftMenuViewController];
                                         }];
                    }
                    else
                    {
                        [self userInteractionEnabled:NO];
                        [self.menuButton removeFromSuperview];
                        CGPoint endCenter = CGPointMake(-1 * self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                        CGPoint origionCenter = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                        [UIView animateWithDuration:self.animationDuration
                                         animations:^{
                                             self.leftMenuViewController.view.center = endCenter;
                                             self.menuOpacityView.center = endCenter;
                                             self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
                                             self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
                                         }
                                         completion:^(BOOL finished) {
                                             [self userInteractionEnabled:YES];
                                             self.menuViewContainer.alpha = 0;
                                             self.leftMenuViewController.view.center = origionCenter;
                                             self.leftMenuViewController.view.hidden = YES;
                                             self.visibleType = XTSideMenuVisibleTypeContent;
                                             [self.contentBlurView removeFromSuperview];
                                         }];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
    else if (self.visibleType == XTSideMenuVisibleTypeLeft)
    {
        CGPoint point = [sender locationInView:self.view];
        switch (sender.state) {
            case UIGestureRecognizerStateBegan:
            {
                self.originalPoint = point;
                [self dealDelegateWithType:XTSideMenuDelegateTypeWillHideLeftMenuViewController object:self.leftMenuViewController];
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                CGRect rect = self.leftMenuViewController.view.frame;
                CGFloat maxX = CGRectGetMaxX(rect);
                CGFloat progress = maxX / self.leftMenuViewVisibleWidth;
                self.menuOpacityView.alpha = progress * (self.menuOpacityViewLeftMaxAlpha - self.menuOpacityViewLeftMinAlpha) + self.menuOpacityViewLeftMinAlpha;
                self.contentBlurView.alpha = self.contentBlurViewMinAlpha + progress * (self.contentBlurViewMaxAlpha - self.contentBlurViewMinAlpha);
                CGPoint center = self.leftMenuViewController.view.center;
                self.leftMenuViewController.view.center = CGPointMake(center.x + point.x - self.originalPoint.x, center.y);
                self.menuOpacityView.center = self.leftMenuViewController.view.center;
                self.originalPoint = point;
                break;
            }
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                CGRect rect = self.leftMenuViewController.view.frame;
                CGFloat maxX = CGRectGetMaxX(rect);
                CGFloat delta = [sender velocityInView:self.view].x;
                if (delta < -400 || maxX < self.leftMenuViewVisibleWidth / 2.0)
                {
                    [self userInteractionEnabled:NO];
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
                                         self.menuOpacityView.center = [self leftMenuViewCenter:XTSideMenuShowTypeNone];
                                         self.menuOpacityView.alpha = self.menuOpacityViewLeftMinAlpha;
                                         self.contentBlurView.alpha = self.contentBlurViewMinAlpha;
                                     }
                                     completion:^(BOOL finished) {
                                         [self.menuButton removeFromSuperview];
                                         self.menuViewContainer.alpha = 0;
                                         self.leftMenuViewController.view.center = [self leftMenuViewCenter:XTSideMenuShowTypeLeft];
                                         self.leftMenuViewController.view.hidden = YES;
                                         self.visibleType = XTSideMenuVisibleTypeContent;
                                         [self.contentBlurView removeFromSuperview];
                                         [self userInteractionEnabled:YES];
                                         [self dealDelegateWithType:XTSideMenuDelegateTypeDidHideLeftMenuViewController object:self.leftMenuViewController];
                                     }];
                }
                else
                {
                    [self userInteractionEnabled:NO];
                    [UIView animateWithDuration:self.animationDuration
                                     animations:^{
                                         self.leftMenuViewController.view.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                         self.menuOpacityView.center = CGPointMake(self.leftMenuViewVisibleWidth / 2.0, CGRectGetMidY(rect));
                                         self.menuOpacityView.alpha = self.menuOpacityViewLeftMaxAlpha;
                                         self.contentBlurView.alpha = self.contentBlurViewMaxAlpha;
                                     }
                                     completion:^(BOOL finished) {
                                         [self userInteractionEnabled:YES];
                                         self.menuButton.enabled = YES;
                                         self.visibleType = XTSideMenuVisibleTypeLeft;
                                     }];
                }
                break;
            }
            default:
                break;
        }
        
    }
}

- (void)addMenuButton
{
    if (self.menuButton.superview)
    {
        return;
    }
    self.menuButton.autoresizingMask = UIViewAutoresizingNone;
    self.menuButton.frame = self.menuViewContainer.bounds;
    self.menuButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.menuViewContainer insertSubview:self.menuButton atIndex:0];
}

- (void)addMenuOpacityView:(XTSideMenuShowType)type
{
    if (self.menuOpacityView.superview)
    {
        if (type == XTSideMenuShowTypeLeft) {
            self.menuOpacityView.frame = self.leftMenuViewController.view.bounds;
        }        return;
    }
    self.menuOpacityView.autoresizingMask = UIViewAutoresizingNone;
    if (type == XTSideMenuShowTypeLeft) {
        self.menuOpacityView.frame = self.leftMenuViewController.view.bounds;
    }
    self.menuOpacityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.menuViewContainer insertSubview:self.menuOpacityView aboveSubview:self.menuButton];
}

- (void)addContentBlurView
{
    if (self.contentBlurView.superview)
    {
        return;
    }
    self.contentBlurView.autoresizesSubviews = UIViewAutoresizingNone;
    self.contentBlurView.frame = self.contentViewContainer.bounds;
    self.contentBlurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentBlurView.viewToBlur = self.contentViewController.view;
    [self.contentViewContainer insertSubview:self.contentBlurView aboveSubview:self.contentViewController.view];
}

- (void)updateContentBlurViewImage
{
    if (self.contentBlur)
    {
        self.contentBlurView.blur = YES;
        self.contentBlurView.tintColor = self.contentBlurViewTintColor;
    }
    else
    {
        self.contentBlurView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    }
}

- (void)updateMenuOperateViewBackgroundColor:(XTSideMenuShowType)type
{
    if (type == XTSideMenuShowTypeLeft) {
        self.menuOpacityView.backgroundColor = self.menuOpacityViewLeftBackgroundColor;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle
{
 //   UIStatusBarStyle statusBarStyle = UIStatusBarStyleLightContent;
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    return statusBarAnimation;
}

#pragma mark -
#pragma mark UserInteractionEnabled

- (void)userInteractionEnabled:(BOOL)enable
{
    self.view.userInteractionEnabled = enable;
}

#pragma mark -
#pragma mark DelegateMethod


#define XTSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

- (void)dealDelegateWithType:(XTSideMenuDelegateType)type object:(id)object
{
    if (_delegate) {
        SEL action;
        switch (type) {
            case XTSideMenuDelegateTypeDidRecognizePanGesture:
                action = @selector(sideMenu:didRecognizePanGesture:);
                break;
            case XTSideMenuDelegateTypeWillShowLeftMenuViewController:
                action = @selector(sideMenu:willShowLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeDidShowLeftMenuViewController:
                action = @selector(sideMenu:didShowLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeWillHideLeftMenuViewController:
                action = @selector(sideMenu:willHideLeftMenuViewController:);
                break;
            case XTSideMenuDelegateTypeDidHideLeftMenuViewController:
                action = @selector(sideMenu:didHideLeftMenuViewController:);
                break;
            default:
                break;
        }
        if (action && [_delegate respondsToSelector:action] && object) {
            XTSuppressPerformSelectorLeakWarning([_delegate performSelector:action withObject:self withObject:object]);
        }
    }
}


@end
