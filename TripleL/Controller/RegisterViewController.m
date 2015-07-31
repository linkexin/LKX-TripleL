//
//  RegisterViewController.m
//  toFace
//
//  Created by charles on 4/10/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyHeader.h"
#import "RegisterViewController.h"
#import "UITextField+Shake.h"
#import "ImageUploadViewController.h"

#define LOCX_SPRITE self.view.frame.size.width * 0.1
#define WIDTH_SPRITE self.view.frame.size.width * 0.8
#define HEIGHT_TEXTFIELD self.view.frame.size.width * 0.12
#define HEIGHT_INTERVAL 2 + self.view.frame.size.width * 0.12
#define LEFT_PHOTO_RECT CGRectMake(20, 0, 50, 35)

@interface RegisterViewController ()
{
    NSArray *object;
    BOOL isNameLegal;
    BOOL isNetWorkError;
}
@property (strong, nonatomic)UIImageView *bgView;
@property (strong, nonatomic)UILabel *registerLable;
@property (strong, nonatomic)UITextField *pswordAgainField;
@property (strong, nonatomic)UILabel *infoLable;//提示信息显示
@property (strong, nonatomic)UIButton *registerButton;
@property (strong, nonatomic)UIVisualEffectView *effectview;//高斯效果
@end

@implementation RegisterViewController
@synthesize bgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    isNameLegal = false;
    isNetWorkError = false;
    
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
    _effectview.frame = CGRectMake(0,0, bgView.frame.size.width, bgView.frame.size.height);
    [bgView addSubview: _effectview];
    
    
    _registerLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 35)];
    _registerLable.text = @"新用户注册";
    _registerLable.font = [UIFont boldSystemFontOfSize:18];
    _registerLable.textAlignment = NSTextAlignmentCenter;
    _registerLable.textColor = [UIColor colorWithRed:0.0/255.0 green:138.0/255.0 blue:255.0/255.0 alpha:1.0];
    _registerLable.textColor = [UIColor blackColor];
    [self.navigationItem setTitleView:_registerLable];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [backItem setTintColor:[UIColor grayColor]];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    
    _userNameField = [[UITextField alloc] initWithFrame:CGRectMake(LOCX_SPRITE, self.view.frame.size.height * 0.1, WIDTH_SPRITE, HEIGHT_TEXTFIELD)];
    UIImageView *imgv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"username.png"]];
    [imgv setFrame:LEFT_PHOTO_RECT];
    imgv.alpha = 0.8;
    _userNameField.leftView = imgv;
    _userNameField.backgroundColor = DEFAULT_INPUT_COLOR;
    _userNameField.leftViewMode = UITextFieldViewModeAlways;
    _userNameField.userInteractionEnabled = YES;
    _userNameField.placeholder = @" 用户名";
    _userNameField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_userNameField addTarget:self action:@selector(checkUserName) forControlEvents: UIControlEventEditingDidEnd];//用户名输入结束就判断是否合法
    //[_userNameField addTarget:self action:@selector(checkUserName) forControlEvents:UIControlEventAllTouchEvents];
    
    _nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(LOCX_SPRITE, _userNameField.frame.origin.y + HEIGHT_INTERVAL, WIDTH_SPRITE, HEIGHT_TEXTFIELD)];
    imgv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nickname.png"]];
    [imgv setFrame:LEFT_PHOTO_RECT];
    imgv.alpha = 0.8;
    _nickNameField.leftView = imgv;
    _nickNameField.backgroundColor = DEFAULT_INPUT_COLOR;
    _nickNameField.leftViewMode = UITextFieldViewModeAlways;
    _nickNameField.userInteractionEnabled = YES;
    _nickNameField.placeholder = @" 昵称";
    _nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;

    
    _pswordField = [[UITextField alloc] initWithFrame:CGRectMake(LOCX_SPRITE, _nickNameField.frame.origin.y + HEIGHT_INTERVAL, WIDTH_SPRITE, HEIGHT_TEXTFIELD)];
    UIImageView *img=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"psword.png"]];
    _pswordField.leftView = img;
    [img setFrame:LEFT_PHOTO_RECT];
    img.alpha = 0.8;
    _pswordField.backgroundColor = DEFAULT_INPUT_COLOR;
    _pswordField.leftViewMode = UITextFieldViewModeAlways;
    _pswordField.userInteractionEnabled = YES;
    _pswordField.secureTextEntry = YES;
    _pswordField.placeholder = @" 密码";
    _pswordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    
    _pswordAgainField = [[UITextField alloc] initWithFrame:CGRectMake(LOCX_SPRITE, _pswordField.frame.origin.y + HEIGHT_INTERVAL, WIDTH_SPRITE, HEIGHT_TEXTFIELD)];
    imgv=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pswordagain.png"]];
    [imgv setFrame:LEFT_PHOTO_RECT];
    imgv.alpha = 0.8;
    _pswordAgainField.leftView = imgv;
    _pswordAgainField.backgroundColor = DEFAULT_INPUT_COLOR;
    _pswordAgainField.leftViewMode = UITextFieldViewModeAlways;
    _pswordAgainField.userInteractionEnabled = YES;
    _pswordAgainField.placeholder = @" 重复密码";
    _pswordAgainField.secureTextEntry = YES;
    _pswordAgainField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    _infoLable = [[UILabel alloc]initWithFrame:CGRectMake(LOCX_SPRITE, _pswordAgainField.frame.origin.y + 41, WIDTH_SPRITE, HEIGHT_TEXTFIELD - 5)];
    _infoLable.text = @"";
    _infoLable.backgroundColor = [UIColor redColor];
    _infoLable.alpha = 0.5;
    _infoLable.font = [UIFont boldSystemFontOfSize:13];
    _infoLable.textAlignment = NSTextAlignmentCenter;
    _infoLable.textColor = [UIColor whiteColor];
    
    
    _registerButton = [[UIButton alloc]initWithFrame:CGRectMake(LOCX_SPRITE, _infoLable.frame.origin.y + 50, WIDTH_SPRITE, HEIGHT_TEXTFIELD)];
    _registerButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:128 alpha:0.3];
    [_registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_registerButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_registerButton setTitle:@"下一步" forState: UIControlStateNormal];
    [_registerButton addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchUpInside];
    _registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _registerButton.userInteractionEnabled = YES;
    
    
    object = [[NSArray alloc]initWithObjects: _userNameField, _nickNameField, _pswordField, _pswordAgainField, nil];
    [bgView addSubview:_infoLable];
    _infoLable.hidden = YES;
    [bgView addSubview:_nickNameField];
    [bgView addSubview:_userNameField];
    [bgView addSubview:_pswordField];
    [bgView addSubview:_pswordAgainField];
    [bgView addSubview:_registerButton];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    //NSLog(@"%f", self.navigationController.navigationBar.frame.size.height);
    //接收广播
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector (usernameIsLegal:) name:INFO_USERNAMEISLEGAL object: nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)checkUserName
{
    if([_userNameField.text isEqualToString: @""])
        return;
    [[MyServer getServer] ckeckUsernameIllegal: _userNameField.text];
}

-(void)usernameIsLegal: (NSNotification *)notification
{
    if([[notification.object objectForKey:@"result"] isEqualToString: @"YES"])
        isNameLegal = YES;
    else if([[notification.object objectForKey:@"result"] isEqualToString: @"NO"])
        isNameLegal = NO;
    else
        isNetWorkError = YES;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap
{
    UITextField *obj;
    for(int i = 0; i < [object count]; i++)
    {
        obj =[object objectAtIndex:i];
        [obj resignFirstResponder];
    }
}

-(void)buttonDown
{
    _infoLable.hidden = YES;
    UITextField *obj, *obj1;
    bool isEmpty = 0;
    for(int i = 0; i < [object count]; i++)
    {
        obj =[object objectAtIndex:i];
        if([obj.text isEqual: @""])
        {
            [[object objectAtIndex:i] shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
            //震动次数，震动间隙，速度，震动方式（水平 数值)
            isEmpty = 1;
        }
    }
    if(isEmpty)
        return;
    
    if(isNetWorkError)
    {
        _infoLable.text = @"网络连接错误!";
        _infoLable.hidden = NO;
        return;

    }
    
    if(!isNameLegal)
    {
        [_userNameField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        _infoLable.text = @"用户名不合法或已存在!";
        _infoLable.hidden = NO;
        return;
    }
    
    if([_pswordField.text length] < 6)
    {
        [_pswordAgainField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        [_pswordField shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        _infoLable.text = @"密码不足六位!";
        _infoLable.hidden = NO;
        return;
    }
    
    obj1 = [object objectAtIndex: 2];
    if(![obj1.text isEqualToString: obj.text])
    {
        [obj shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        [obj1 shake:10 withDelta:8 andSpeed:0.05 shakeDirection:0];
        _infoLable.text = @"输入密码不一致!";
        _infoLable.hidden = NO;
        return;
    }
    
    ImageUploadViewController *imageView = [[ImageUploadViewController alloc]init];
    [imageView getinfowith: _userNameField.text nick:_nickNameField.text psword:_pswordField.text];
    //[self presentViewController:imageView animated:YES completion:^{}];
    [self.navigationController pushViewController:imageView animated:YES];
}

- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
    * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
        return YES;
    else
        return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
