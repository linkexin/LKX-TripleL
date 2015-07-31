//
//  AcountMangerViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/16.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "AcountMangerViewController.h"
#import "MyHeader.h"
#import "UIImageView+WebCache.h"
#import "SCLAlertView.h"
#import "RootViewController.h"
#import "LTHPasscodeViewController.h"
#import "CommonTableViewCell.h"
#import "MBProgressHUD.h"

#define     FREE_WIDTH          16
#define     AVATAR_WIDTH        37

@interface AcountMangerViewController ()
{
    TLUser *loginUser;
    NSMutableArray *data;
    BOOL addAccount;
    MBProgressHUD *prgressHud;
}

@property (nonatomic, strong) UIBarButtonItem *item;

@end

@implementation AcountMangerViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"账号设置"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    _item = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStyleDone target:self action:@selector(addButtonDown)];
    [self.navigationItem setRightBarButtonItem:_item animated:YES];
    
    prgressHud = [[MBProgressHUD alloc] init];
    [prgressHud setLabelText:@"请稍候"];
    [prgressHud setDetailsLabelText:@"正在切换账号"];
    [self.tabBarController.view addSubview:prgressHud];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    addAccount = NO;
    data = [[DataCenter getDataCenter] getUsers];
    [self.tableView reloadData];
}

#pragma mark - tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count + 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    if (indexPath.row == 0) {
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    else if (indexPath.row == data.count + 1){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.view.frame.size.width - 40, 45)];
        label.text = @"左滑可删除账号信息。";
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:13];
        [cell addSubview:label];
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0,0, self.view.frame.size.width / 2.0)];
        return cell;
    }
    TLUser *user = [data objectAtIndex:indexPath.row - 1];
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(FREE_WIDTH, 4, AVATAR_WIDTH, AVATAR_WIDTH)];
    [imageV sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    imageV.layer.cornerRadius = 37 / 5.0;
    imageV.layer.masksToBounds = YES;
    [cell addSubview:imageV];

    float x = FREE_WIDTH + AVATAR_WIDTH + 10;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 4, self.view.frame.size.width - x - AVATAR_WIDTH, 37)];
    [label setTextColor:[AppConfig getTitleColor]];
    [label setText:user.username];
    [cell addSubview:label];
    
    if ([user.username isEqualToString:[[MyServer getServer] getSelfAccountInfo].username]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 20;
    }
    return 45;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    loginUser = [data objectAtIndex:indexPath.row - 1];
    if (![loginUser.username isEqualToString:[[MyServer getServer] getSelfAccountInfo].username]) {
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        UITextField *psTextField = [alertView addTextField:@"请输入密码"];
        [psTextField setSecureTextEntry:YES];
        [alertView addButton:@"登陆" actionBlock:^{
            loginUser.password = psTextField.text;
            if (loginUser.password == nil || loginUser.password.length == 0) {
                SCLAlertView *alertView = [[SCLAlertView alloc] init];
                [alertView showError:self.tabBarController title:@"错误" subTitle:@"密码格式不正确" closeButtonTitle:@"确定" duration:0];
                return;
            }
            [prgressHud show:YES];
            [[MyServer getServer] logout];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessful:) name:INFO_LOGINSUCCESSFUL object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFaild:) name:INFO_LOGINFAILED object:nil];
            [[MyServer getServer] loginWithUsername:loginUser.username andPassword: loginUser.password];
        }];
        [alertView showEdit:self.tabBarController title:@"切换账号" subTitle:[NSString stringWithFormat: @"请输入 \"%@\" 的登入密码:", loginUser.username] closeButtonTitle:@"取消" duration:0];
    }
    [self.tableView reloadData];
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TLUser *user = [data objectAtIndex:indexPath.row - 1];
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        [alertView addButton:@"确认删除" actionBlock:^{
            if ([[MyServer getServer] getSelfAccountInfo].username != nil && [user.username isEqualToString:[[MyServer getServer] getSelfAccountInfo].username]) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                [alert addButton:@"确认删除" actionBlock:^{
                    [[RootViewController getRootViewController] setMsgCountInTabBar:0];
                    [SFHFKeychainUtils deleteItemForUsername:user.username andServiceName:@"iOS" error:nil];
                    [[DataCenter getDataCenter] removeUser:user];
                    [data removeObjectAtIndex:indexPath.row - 1];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"psword"];
                    [self.navigationController popToRootViewControllerAnimated:NO];
                    [[MyServer getServer] logout];
                    [[RootViewController getRootViewController] logout];
                }];
                [alert showNotice:self.tabBarController title:@"警告" subTitle:@"当前账号处于登陆状态，是否自动注销并删除此账号？" closeButtonTitle: @"取消删除" duration: 0];
                return;
            }
            else{
                [SFHFKeychainUtils deleteItemForUsername:user.username andServiceName:@"iOS" error:nil];
                [[DataCenter getDataCenter] removeUser:user];
                [data removeObjectAtIndex:indexPath.row - 1];
                [self.tableView reloadData];
            }
        }];
        [alertView showInfo:self.tabBarController title:@"确认操作" subTitle:[NSString stringWithFormat: @"确定要删除\"%@\"吗？这将删除其下的所有消息记录。", user.username] closeButtonTitle:@"取消删除" duration:0];
    }
    [self.tableView reloadData];
}


#pragma mark - login

- (void) loginSuccessful: (NSNotification *) noti
{
    [prgressHud hide:YES];
    [[RootViewController getRootViewController] setMsgCountInTabBar:0];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:loginUser.username forKey:@"username"];
    [userDefaults setObject:loginUser.password forKey:@"psword"];
     
    if (addAccount) {
        addAccount = NO;
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        [alertView addButton:@"确定" actionBlock:^{
            data = [[DataCenter getDataCenter] getUsers];       // 添加账户时必须这样
            [self.tableView reloadData];
        }];
        [alertView showSuccess:self.tabBarController title:@"提示" subTitle:@"新用户登陆成功" closeButtonTitle:nil duration:0];
    }

        [self.tableView reloadData];

}

- (void) loginFaild: (NSNotification *) noti
{
    [prgressHud hide:YES];
    NSString *err = noti.object;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] stringForKey:@"psword"];
    [[MyServer getServer] loginWithUsername:username andPassword: password];
    
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView showError:self.tabBarController title:@"登录失败" subTitle:err  closeButtonTitle:@"确定" duration:0];
}

- (void) addButtonDown
{
    addAccount = YES;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UITextField *nameTF = [alert addTextField:@"用户名"];
    UITextField *passTF = [alert addTextField:@"密码"];
    [passTF setSecureTextEntry:YES];
    [alert addButton:@"登陆" actionBlock:^{
        loginUser = [[TLUser alloc] init];
        loginUser.username = nameTF.text;
        loginUser.password = passTF.text;
        if (loginUser.username == nil || loginUser.username.length == 0 || loginUser.password == nil || loginUser.password.length == 0) {
            SCLAlertView *alertView = [[SCLAlertView alloc] init];
            [alertView showError:self.tabBarController title:@"错误" subTitle:@"用户名或密码格式不正确" closeButtonTitle:@"确定" duration:0];
            return;
        }
        [[MyServer getServer] logout];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessful:) name:INFO_LOGINSUCCESSFUL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFaild:) name:INFO_LOGINFAILED object:nil];
        [[MyServer getServer] loginWithUsername:loginUser.username andPassword: loginUser.password];
    }];
    [alert showInfo:self.tabBarController title:@"用户登陆" subTitle:@"请输入用户名和密码：" closeButtonTitle:@"取消" duration:0];
}

@end
