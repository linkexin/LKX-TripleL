//
//  StartViewController.m
//  toFace
//
//  Created by charles on 4/10/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RootViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "MenuViewController.h"
#import "XTSideMenu.h"
#import "MyHeader.h"
#import "UIBadgeView.h"
#import "SCLAlertView.h"
#import "PromptView.h"

#import "MessageViewController.h"

static NSTimeInterval updata_time = 5;
#define HEIGHT_TEXTFIELD self.view.frame.size.height * 0.09

static RootViewController *rootVC = nil;

@interface RootViewController () <PromptViewDelegate>
{
    SCLAlertView *alertView;
    NSTimer *timer;
}
@property (strong, nonatomic) UIBadgeView *badgeView;
@property (strong, nonatomic) UIImageView *bgView;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) RegisterViewController *registerViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) PromptView *promptView;
@end


@implementation RootViewController

+ (RootViewController *) getRootViewController
{
    if (rootVC == nil) {
        rootVC = [[RootViewController alloc] init];
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];//先得到故事版，记住这是故事板的名字
        UIViewController *modalViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"TabBarController"];
        MenuViewController *menuVC = [[MenuViewController alloc] init];
        
        XTSideMenu *root = [XTSideMenu shareInstance];
        [root setContentViewController:modalViewController menuViewController:menuVC];

    }
    return rootVC;
}

- (void) reloadVC
{
    [[RootViewController getRootViewController].navigationController popToRootViewControllerAnimated:NO];
}

- (void) logout
{
    [self setMsgCountInTabBar:0];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[RootViewController getRootViewController].navigationController popToRootViewControllerAnimated:NO];
}

- (void) setMsgCountInTabBar:(int)count
{
    if (_badgeView == nil){
        float width = [UIScreen mainScreen].bounds.size.width;
        _badgeView = [[UIBadgeView alloc] initWithFrame:CGRectMake(width / 7 - 1, 0, 50, 50)];
        _badgeView.badgeColor = [UIColor redColor];
        _badgeView.badgeString = @"0";
    }
    _badgeView.badgeString = [NSString stringWithFormat:@"%d", count];
    if (count == 1) {
        UITabBarController *modalViewController = (UITabBarController *)([XTSideMenu shareInstance].contentViewController);
        UINavigationController *navVC = modalViewController.viewControllers.firstObject;
        UIViewController *tabVC = navVC.viewControllers.firstObject;
        
        [tabVC.tabBarController.tabBar addSubview:_badgeView];
    }
    else if (count <= 0){
        [_badgeView removeFromSuperview];
    }
}

- (void) changeMsgCountInTabBar: (int) count
{
    if (_badgeView == nil){
        float width = [UIScreen mainScreen].bounds.size.width;
        _badgeView = [[UIBadgeView alloc] initWithFrame:CGRectMake(width / 7 - 1, 0, 50, 50)];
        _badgeView.badgeColor = [UIColor redColor];
        _badgeView.badgeString = @"0";
    }
    int t = _badgeView.badgeString.intValue + count;
    _badgeView.badgeString = [NSString stringWithFormat:@"%d", t];
    if (t == 1) {
        UITabBarController *modalViewController = (UITabBarController *)([XTSideMenu shareInstance].contentViewController);
        UINavigationController *navVC = modalViewController.viewControllers.firstObject;
        UIViewController *tabVC = navVC.viewControllers.firstObject;

        [tabVC.tabBarController.tabBar addSubview:_badgeView];
    }
    else if (t <= 0){
        [_badgeView removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _bgView = [[UIImageView alloc]init];
    
    [_bgView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _bgView.userInteractionEnabled = YES;
    [self.view addSubview: _bgView];
    
    
    _registerButton = [[UIButton alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - HEIGHT_TEXTFIELD, self.view.frame.size.width * 0.5, HEIGHT_TEXTFIELD)];
    [_registerButton addTarget:self action:@selector(registerButtonDown) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _registerButton.userInteractionEnabled = YES;
    [_bgView addSubview:_registerButton];
    
    
    _loginButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width * 0.5 + 1, self.view.frame.size.height - HEIGHT_TEXTFIELD, self.view.frame.size.width * 0.5, HEIGHT_TEXTFIELD)];
    
    [_loginButton addTarget:self action:@selector(loginButtonDown) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _loginButton.userInteractionEnabled = YES;
    [_bgView addSubview:_loginButton];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessful) name:INFO_LOGINSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:INFO_LOGINFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedNetInfo:) name:INFO_RECIEVEDNETNOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authFailed) name:INFO_AUTHFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if (username != nil && ![username isEqualToString:@""]) {
        MyServer *server = [MyServer getServer];
        NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"psword"];
        NSLog(@"username = %@， password = %@", username, password);
        [server loginWithUsername:username andPassword:password];
        
        XTSideMenu *root = [XTSideMenu shareInstance];
        [self.navigationController pushViewController:root animated:NO];

        return;
    }
    if([UIDevice deviceVerType] == DeviceVer4)
        _bgView.image =[UIImage imageNamed:@"background4S.jpg"];
    else
        _bgView.image =[UIImage imageNamed:@"background2.jpg"];
    
    _loginButton.backgroundColor = [UIColor whiteColor];
    _loginButton.alpha = 0.5;
    [_loginButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_loginButton setTitle:@"登陆" forState: UIControlStateNormal];
    
    _registerButton.backgroundColor = [UIColor blackColor];
    _registerButton.alpha = 0.5;
    [_registerButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_registerButton setTitle:@"注册" forState: UIControlStateNormal];
    
}

- (void) loginSuccessful
{
    vis = 0;
    [timer invalidate];
    [_promptView hidden];
}

- (void) loginFailed
{
    if (!_promptView.show && vis) {
        [_promptView showMessage:@"网络环境异常，连接已断开..." buttonTitle:@"重试"];
        timer = [NSTimer scheduledTimerWithTimeInterval:updata_time target:self selector:@selector(reUpload) userInfo:nil repeats:YES];
    }
}


static int vis = 0;
- (void) networkAnomaly
{
    NSLog(@"网络环境异常");
    if (_promptView == nil) {
        float y = [UIScreen mainScreen].bounds.size.height - ((UITabBarController *)([XTSideMenu shareInstance].contentViewController)).tabBar.frame.size.height - 30;
        _promptView = [[PromptView alloc] initWithFrame:CGRectMake(0, y, [UIScreen mainScreen].bounds.size.width, 30)];
        _promptView.delegate = self;
         [[XTSideMenu shareInstance].contentViewController.view addSubview:_promptView];
    }
    
    if (!_promptView.show) {
        vis = 1;
        [self reUpload];
    };
}

- (void) authFailed
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"确定" actionBlock:^{
        [self logout];
    }];
    [alert showError: [XTSideMenu shareInstance].contentViewController title:@"警告" subTitle:@"账号验证失败，请确认账号安全后重新登陆！" closeButtonTitle:nil duration:0];
}

- (void) recievedNetInfo: (NSNotification *) noti
{
    if (alertView == nil) {
        alertView = [[SCLAlertView alloc] init];
    }
    
    
    TLNotification *info = noti.object;
    if (info.type == TLNotificationTypeFriendRequest) {
        [alertView addButton:@"接收并添加" actionBlock:^{
            [[MyServer getServer] sendFriendRequestReplayWithId:info.notiID accept:YES];
        }];
        [alertView addButton:@"拒绝" actionBlock:^{
            [[MyServer getServer] sendFriendRequestReplayWithId:info.notiID accept:NO];
        }];
        [alertView showInfo:[XTSideMenu shareInstance].contentViewController title:@"好友添加请求" subTitle:[NSString stringWithFormat: @"验证消息: %@", info.message] closeButtonTitle:@"忽略" duration:0];
    }
    else if (info.type == TLNotificationTypeFriendAdded){
        [alertView showSuccess:[XTSideMenu shareInstance].contentViewController title:@"消息" subTitle:info.message closeButtonTitle:@"确定" duration:0];
    }
    else if (info.type == TLNotificationTypeFriendRejected) {
        [alertView showInfo:[XTSideMenu shareInstance].contentViewController title:@"消息" subTitle:info.message closeButtonTitle:@"确定" duration:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_ADDFRIENDSUCCESSFUL object:nil];
    }
}


#pragma mark -
-(void)registerButtonDown
{
    //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];//先得到故事版，记住这是故事板的名字
   //UIViewController *modalViewController = [mainStoryboard instantiateViewControllerWithIdentifier: @"register"];
                                             //这里才使用modalview得到modalview类的一个视图
    //[self presentViewController:_registerViewController animated:YES completion:^{}];
    if(_registerViewController == nil)
        _registerViewController = [[RegisterViewController alloc]init];
    [_registerViewController.view setFrame:self.view.frame];
    
    [self.navigationController pushViewController:_registerViewController animated:YES];
}

-(void)loginButtonDown
{
    if(_loginViewController == nil)
        _loginViewController = [[LoginViewController alloc]init];
    [_loginViewController.view setFrame:self.view.frame];
    [self.navigationController pushViewController: _loginViewController animated:YES];
    //[self presentViewController:_loginViewController animated:YES completion:nil];
}


#pragma mark - propmptViewDelegate
- (void) promptViewButtonDown:(PromptView *) sender
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"psword"];
    [[MyServer getServer] loginWithUsername:username andPassword: password];
    [sender hidden];
}

- (void) reUpload
{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"psword"];
    [[MyServer getServer] loginWithUsername:username andPassword: password];
}


@end
