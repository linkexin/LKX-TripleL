//
//  MenuFeedbackViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/5.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MenuFeedbackViewController.h"
#import "SCLAlertView.h"
#import "MyHeader.h"

@interface MenuFeedbackViewController ()
{
    UITextField *titleField;
    UITextView *textView;
}

@end

@implementation MenuFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"反馈建议"];
    [self.view setBackgroundColor:[AppConfig getBGColor]];
    
    float x = 10;
    float y = 64 + 5;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    [item setTitle:@"提交"];
    [self.navigationItem setRightBarButtonItem:item];
    

    CGRect rect = CGRectMake(x, y, 50, 32);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    [label setText:@"标题:"];
    [self.view addSubview:label];
    
    rect = CGRectMake(x + rect.size.width, y, self.view.frame.size.width - 2 * x - rect.size.width, 32);
    titleField = [[UITextField alloc] initWithFrame:rect];
    [titleField setBackgroundColor:[UIColor whiteColor]];
    titleField.layer.cornerRadius = 8.0;
    titleField.layer.masksToBounds = YES;
    titleField.layer.borderColor = [[UIColor blueColor] CGColor];
    titleField.layer.borderWidth = 0.1f;
    [self.view addSubview:titleField];
    
    
    rect = CGRectMake(x, y + rect.size.height + 6, self.view.frame.size.width - 2 * x, self.view.frame.size.height * 0.4);
    textView = [[UITextView alloc] initWithFrame: rect];
    [textView setShowsHorizontalScrollIndicator:NO];
    [textView setShowsVerticalScrollIndicator:NO];
    [textView setFont:[UIFont systemFontOfSize:16]];
    textView.layer.cornerRadius = 8.0;
    textView.layer.masksToBounds = YES;
    textView.layer.borderColor=[[UIColor blueColor]CGColor];
    textView.layer.borderWidth= 0.1f;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:textView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendFeedbackSuccessful:) name:INFO_SENDFEEDBACKSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendFeedbackFailed:) name:INFO_SENDFEEDBACKFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) networkAnomaly
{
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确定" actionBlock:^{
    }];
    [alertView showError:self.tabBarController title:@"提交失败" subTitle:@"设备网络异常！" closeButtonTitle:nil duration:0];
}

- (void) sendFeedbackSuccessful: (NSNotification *) noti
{
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertView showSuccess:self.tabBarController title:@"提交成功" subTitle:@"感谢您的反馈，我们将尽快处理！" closeButtonTitle:nil duration:0];
}

- (void) sendFeedbackFailed: (NSNotification *) noti
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self.tabBarController title:@"出错了" subTitle:@"提交失败，请稍后重试！" closeButtonTitle:@"确定" duration:0];
}

- (void) submit
{
    if (textView.text.length == 0 || titleField.text.length == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showInfo:self.tabBarController title:@"注意" subTitle:@"信息不完整，请输入标题和正文内容！" closeButtonTitle:@"确定" duration:0];
        return;
    }
    [titleField resignFirstResponder];
    [textView resignFirstResponder];
    [[MyServer getServer] sendFeedbackTitle:titleField.text detail:textView.text];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
