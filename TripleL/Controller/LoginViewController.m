//
//  LoginViewController.m
//  toFace
//
//  Created by charles on 4/11/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "UITextField+Shake.h"
#import "MyServer.h"
#import "MyHeader.h"
#import "MessageViewController.h"
#import "XTSideMenu.h"
#import "MenuViewController.h"
#import "RootViewController.h"


#define LOCX_SPRITE self.view.frame.size.width * 0.1
#define WIDTH_SPRITE self.view.frame.size.width * 0.8
#define LEFT_PHOTO_RECT CGRectMake(20, 0, 50, 35)

@interface LoginViewController ()
{
    BOOL isUserOrPswordError;
}

@property (strong, nonatomic)UIImageView *bgView;
@property (strong, nonatomic)UILabel *loginLable;
@property (strong, nonatomic)UITextField *usernameField;
@property (strong, nonatomic)UITextField *pswordField;
@property (strong, nonatomic)UIButton *loginButton;
@property (strong, nonatomic)UILabel *errorInfoLabel;
@property (strong, nonatomic)UIVisualEffectView *effectview;
@end

@implementation LoginViewController
@synthesize bgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isUserOrPswordError = NO;
    
    bgView = [[UIImageView alloc]init];
    if([UIDevice deviceVerType] == DeviceVer4)
        bgView.image =[UIImage imageNamed:@"background4S2.jpg"];
    else
        bgView.image =[UIImage imageNamed:@"background2.jpg"];
    //bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background2.jpg"]];
    [bgView setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bgView.contentMode = UIViewContentModeScaleAspectFit;
    bgView.userInteractionEnabled = YES;
    [self.view addSubview: bgView];
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
    _effectview = [[UIVisualEffectView alloc] initWithEffect: blur];
    _effectview.frame =CGRectMake(0,0, bgView.frame.size.width, bgView.frame.size.height);
    [bgView addSubview: _effectview];

    
    _loginLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    _loginLable.text = @"用户登陆";
    _loginLable.font = [UIFont boldSystemFontOfSize:18];
    _loginLable.textAlignment = NSTextAlignmentCenter;
    _loginLable.textColor = [UIColor colorWithRed:0.0/255.0 green:138.0/255.0 blue:255.0/255.0 alpha:1.0];
    _loginLable.textColor = [UIColor blackColor];
    [self.navigationItem setTitleView:_loginLable];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backItem setTintColor:[UIColor grayColor]];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    
    _usernameField = [[UITextField alloc] initWithFrame:CGRectMake(LOCX_SPRITE, self.view.frame.size.height * 0.13, WIDTH_SPRITE, 40)];
    UIImageView *imgv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nickname.png"]];
    [imgv setFrame:LEFT_PHOTO_RECT];
    imgv.alpha= 0.8;
    _usernameField.leftView = imgv;
    _usernameField.backgroundColor = DEFAULT_INPUT_COLOR;
    _usernameField.leftViewMode = UITextFieldViewModeAlways;
    _usernameField.userInteractionEnabled = YES;
    _usernameField.placeholder = @"用户名";
    _usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;

    
    _pswordField = [[UITextField alloc] initWithFrame:CGRectMake(LOCX_SPRITE, _usernameField.frame.origin.y + 42, WIDTH_SPRITE, 40)];
    UIImageView *img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"psword.png"]];
    _pswordField.leftView = img;
    [img setFrame:LEFT_PHOTO_RECT];
    img.alpha = 0.8;
    _pswordField.backgroundColor = DEFAULT_INPUT_COLOR;
    _pswordField.leftViewMode = UITextFieldViewModeAlways;
    _pswordField.userInteractionEnabled = YES;
    _pswordField.placeholder = @"密码";
    _pswordField.secureTextEntry = YES;
    _pswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    _errorInfoLabel = [[UILabel alloc]initWithFrame:CGRectMake(LOCX_SPRITE, _pswordField.frame.origin.y + 42, WIDTH_SPRITE, 35)];
    _errorInfoLabel.text = @"";
    _errorInfoLabel.backgroundColor = [UIColor redColor];
    _errorInfoLabel.alpha = 0.5;
    _errorInfoLabel.font = [UIFont boldSystemFontOfSize:13];
    _errorInfoLabel.textAlignment = NSTextAlignmentCenter;
    _errorInfoLabel.textColor = [UIColor whiteColor];
    
    
    _loginButton = [[UIButton alloc]initWithFrame:CGRectMake(LOCX_SPRITE, _errorInfoLabel.frame.origin.y + 50, WIDTH_SPRITE, 40)];
    _loginButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.3];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_loginButton setTitle:@"登录" forState: UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _loginButton.userInteractionEnabled = YES;
    
    [bgView addSubview:_errorInfoLabel];
    _errorInfoLabel.hidden = YES;
    [bgView addSubview:_usernameField];
    [bgView addSubview:_pswordField];
    [bgView addSubview:_loginButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    bgView.userInteractionEnabled = YES;
    [self.view addSubview: bgView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //接收广播
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (loginSuccess) name:INFO_LOGINSUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (loginFailed:) name:INFO_LOGINFAILED object: nil];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap
{
    [_usernameField resignFirstResponder];
    [_pswordField resignFirstResponder];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-
//响应函数
-(void)usernameOrPswordError
{
    isUserOrPswordError = YES;
    
    if(isUserOrPswordError)
    {
        [_usernameField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        [_pswordField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        _errorInfoLabel.text = @"用户名或密码错误";
        _errorInfoLabel.hidden = NO;
    }
}

-(void)loginSuccess
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_usernameField.text forKey:@"username"];
    [userDefaults setObject:_pswordField.text forKey:@"psword"];
    [userDefaults synchronize];
    
    _usernameField.text = @"";
    _pswordField.text = @"";
    
    XTSideMenu *mainVC = [XTSideMenu shareInstance];
 //   NSLog(@"%lu", ((UITabBarController *)(mainVC.contentViewController)).viewControllers.count);
    [self.navigationController pushViewController:mainVC animated:YES];
}

-(void)loginFailed:(NSNotification *)notification
{
    _errorInfoLabel.text = notification.object;
    [_usernameField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
    [_pswordField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
    _errorInfoLabel.hidden = NO;
}


-(void)buttonDown
{
    _errorInfoLabel.hidden = YES;
    if([_usernameField.text isEqual: @""])
    {
        [_usernameField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
    }
    //震动次数，震动间隙，速度，震动方式（水平 数值）
    if([_pswordField.text isEqual: @""])
    {
        [_pswordField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        return;
    }
    
    [[MyServer getServer] loginWithUsername: _usernameField.text andPassword: _pswordField.text];
    
    //MessageViewController *messageViewcontroller = [[MessageViewController alloc]init];
    //[self presentViewController:messageViewcontroller animated:YES completion:nil]
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
