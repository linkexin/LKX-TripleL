//
//  AppSecurityViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/16.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "AppSecurityViewController.h"
#import "MyHeader.h"
#import "LTHPasscodeViewController.h"
#import "SCLAlertView.h"
#import "DataCenter.h"
#import "RootViewController.h"
#import "CommonTableViewCell.h"

typedef NS_ENUM(NSInteger, ShortPassStatus) {
    ShortPassStatusWillOpen = 0,
    ShortPassStatusWillDown = 1,
    ShortPassStatusWillChange = 2,
    ShortPassStatusCheck = 3,
    ShortPassStatusOther
};

@interface AppSecurityViewController () <LTHPasscodeViewControllerDelegate>
{
    NSMutableArray *data;
    BOOL open;
    ShortPassStatus status;
}

@property (nonatomic, strong) UISwitch *switchTool;

@end


@implementation AppSecurityViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"安全设置"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"appSecurity" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    status = ShortPassStatusOther;
    
    [LTHPasscodeViewController sharedUser].delegate = self;
    [LTHPasscodeViewController setUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] andServiceName:@"iOS"];
    [self.tableView reloadData];
}

#pragma mark - tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    if (username != nil && [LTHPasscodeViewController passcodeExistsInKeychain]) {
        return data.count;
    }
    else{
        return 2;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if ([type isEqualToString:@"normal"]) {
        cell.textLabel.text = [dic objectForKey:@"title"];
        [cell setUserInteractionEnabled:YES];
       
        if (indexPath.row == 1) {
            _switchTool = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 6.5, 42, 37)];
            NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
            if (username != nil && [LTHPasscodeViewController passcodeExistsInKeychain]) {
                _switchTool.on = YES;
            }
            else{
                _switchTool.on = NO;
            }
            [_switchTool addTarget:self action:@selector(switchToolChange:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:_switchTool];
        }
    }
    else if([type isEqualToString:@"empty"]){
        cell.textLabel.text = @"";
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else if([type isEqualToString:@"explanation"]){
        UITextView *textView = [[UITextView alloc] init];
        textView.text = [dic objectForKey:@"title"];
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT);
        CGSize size = [textView sizeThatFits:constraintSize];
        [textView setFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, size.height)];
        textView.textColor = [UIColor grayColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.font = [UIFont systemFontOfSize:13];
        textView.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:textView];
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"normal"]){
        return 45;
    }
    else if ([type isEqualToString:@"empty"]){
        return 20;
    }
    else if ([type isEqualToString:@"explanation"]){
        UITextView *textView = [[UITextView alloc] init];
        textView.text = [dic objectForKey:@"title"];
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT);
        CGSize size = [textView sizeThatFits:constraintSize];
        return size.height;
    }
    
    return 30;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    if (title != nil && [title isEqualToString:@"修改短密码"]) {
        status = ShortPassStatusWillChange;
        [[LTHPasscodeViewController sharedUser] showForChangingPasscodeInViewController: self];
    }
    else if (title != nil && [title isEqualToString:@"验证短密码"]){
        status = ShortPassStatusCheck;
        [[LTHPasscodeViewController sharedUser] showLockScreenWithAnimation:YES];
    }
    [self.tableView reloadData];
}

#pragma mark - switch
- (void) switchToolChange: (UISwitch *) sender
{
    if (sender.on) {
        status = ShortPassStatusWillOpen;
        [SFHFKeychainUtils deleteItemForUsername:[[MyServer getServer] getSelfAccountInfo].username andServiceName:@"iOS" error:nil];
        [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController: self];
    }
    else{
        status = ShortPassStatusWillDown;
        [[LTHPasscodeViewController sharedUser] showForTurningOffPasscodeInViewController: self];
    }
}

#pragma mark -

- (void)maxNumberOfFailedAttemptsReached
{
    [[LTHPasscodeViewController sharedUser]dismissMe];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    if (status == ShortPassStatusWillDown || status == ShortPassStatusWillChange) {
        [alert addButton:@"确定" actionBlock:^{
            [SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"usernmae"] andServiceName:@"iOS" error:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"psword"];
            [[MyServer getServer] logout];
            [[RootViewController getRootViewController] logout];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }];
        [alert showError:self.tabBarController title:@"警告" subTitle:@"由于您输错密码次数过多，现在将注销此账号，并清空其短密码！" closeButtonTitle:nil duration:0];
    }
    else if(status == ShortPassStatusCheck){
        [alert showError:self.tabBarController title:@"验证失败" subTitle:@"您输错密码次数过多！" closeButtonTitle:@"确定" duration:0];
    }
}

- (void)passcodeWasEnteredSuccessfully
{
    if (status == ShortPassStatusWillDown) {
        [SFHFKeychainUtils deleteItemForUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"usernmae"] andServiceName:@"iOS" error:nil];
        [self.tableView reloadData];
        [_switchTool setOn:NO];
    }
    else if (status == ShortPassStatusCheck){
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showSuccess:self.tabBarController title:@"验证成功" subTitle:@"密码输入正确！" closeButtonTitle:@"确定" duration:0];
    }
}

- (void)passcodeViewControllerWasDismissed {
    if (status == ShortPassStatusWillOpen) {
        if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
            [self.tableView reloadData];
        }
        else{
            [_switchTool setOn:NO];
        }
    }
}

@end
