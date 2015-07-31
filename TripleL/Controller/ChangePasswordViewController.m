//
//  ChangePasswordViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/17.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "CommonTableViewCell.h"
#import "SCLAlertView.h"
#import "MyHeader.h"
#import "MBProgressHUD.h"

@interface ChangePasswordViewController ()
{
    NSMutableArray *data;
}
@property (nonatomic, strong) MBProgressHUD *mbProgressHUD;
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"修改密码"];

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(submitButtonDown)];
    [self.navigationItem setRightBarButtonItem:submitButton];

    data = [[NSMutableArray alloc] initWithObjects:@{@"title": @"旧密码：", @"textField" : [[UITextField alloc] init], @"placeholder": @"请输入旧密码"},
                                                   @{@"title": @"新密码：", @"textField" : [[UITextField alloc] init], @"placeholder": @"请输入新密码"},
                                                   @{@"title": @"确认密码：", @"textField" : [[UITextField alloc] init], @"placeholder": @"请再输入新密码"}, nil];
    _mbProgressHUD = [[MBProgressHUD alloc] init];
    [self.tabBarController.view addSubview:_mbProgressHUD];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((UITextField *)(data[0][@"textField"])).text = @"";
    ((UITextField *)(data[1][@"textField"])).text = @"";
    ((UITextField *)(data[2][@"textField"])).text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyPasswordSuccessful) name:INFO_MODIFYPASSWORDSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyPasswordFailed:) name:INFO_MODIFYPASSWORDFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
}

- (void) hideKeyboard
{
    for (int i = 0; i < 3; i ++) {
        UITextField *tf = data[i][@"textField"];
        [tf resignFirstResponder];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mbProgressHUD hide:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) networkAnomaly
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"请求数据失败，请检查网络！" closeButtonTitle:nil duration:0.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count + 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if (indexPath.row == 0 || indexPath.row == 2) {
        cell.textLabel.text = @"";
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else if (indexPath.row == 1){
        cell.textLabel.text = @"用户名：";
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 150, 45)];
        [label setTextColor:[UIColor grayColor]];
        [label setText:[[MyServer getServer] getSelfAccountInfo].username];
        [cell addSubview:label];
    }
    else{
        NSDictionary *dic = [data objectAtIndex:indexPath.row - 3];
        cell.textLabel.text = [dic objectForKey:@"title"];
        UITextField *textField = [dic objectForKey:@"textField"];
        [textField setPlaceholder:[dic objectForKey:@"placeholder"]];
        [textField setFrame:CGRectMake(100, 0, self.view.frame.size.width - 150, 45)];
        [textField setSecureTextEntry:YES];
        [cell addSubview:textField];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self hideKeyboard];
    [self.tableView reloadData];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 2) {
        return 20;
    }
    
    return 45;
}

#pragma mark - button and noti

- (void) submitButtonDown
{
    [self hideKeyboard];
    NSString *oldPass = ((UITextField *)(data[0][@"textField"])).text;
    NSString *newPass = ((UITextField *)(data[1][@"textField"])).text;
    NSString *rePass = ((UITextField *)(data[2][@"textField"])).text;
    
    if (oldPass == nil || newPass == nil || rePass == nil) {
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        [alertView addButton:@"确定" actionBlock:^{
            ((UITextField *)(data[0][@"textField"])).text = @"";
            ((UITextField *)(data[1][@"textField"])).text = @"";
            ((UITextField *)(data[2][@"textField"])).text = @"";
        }];
        [alertView showInfo:self.tabBarController title:@"错误" subTitle:@"密码格式不正确，请重新输入。" closeButtonTitle:nil duration:0];
        return;
    }
    if (![newPass isEqualToString:rePass]) {
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        [alertView addButton:@"确定" actionBlock:^{
            ((UITextField *)(data[1][@"textField"])).text = @"";
            ((UITextField *)(data[2][@"textField"])).text = @"";
        }];
        [alertView showInfo:self.tabBarController title:@"错误" subTitle:@"两次密码输入不一致，请重新输入。" closeButtonTitle:nil duration:0];
        return;

    }
    [_mbProgressHUD setLabelText:@"请稍候"];
    [_mbProgressHUD setDetailsLabelText:@"正在进行信息同步"];
    [_mbProgressHUD show:YES];
    [[MyServer getServer] modifyPassword:newPass oldPassword:oldPass];
}

- (void) modifyPasswordSuccessful
{
    [_mbProgressHUD hide:YES];
    [[NSUserDefaults standardUserDefaults] setObject:((UITextField *)(data[1][@"textField"])).text forKey:@"psword"];
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
        [self.view becomeFirstResponder];
        ((UITextField *)(data[0][@"textField"])).text = @"";
        ((UITextField *)(data[1][@"textField"])).text = @"";
        ((UITextField *)(data[2][@"textField"])).text = @"";
    }];
    [alertView showSuccess:self.tabBarController title:@"提示" subTitle:@"修改密码成功" closeButtonTitle:nil duration:0];
}

- (void) modifyPasswordFailed: (NSNotification *) noti
{
    [_mbProgressHUD hide:YES];
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView showInfo:self.tabBarController title:@"修改密码失败" subTitle:noti.object closeButtonTitle:@"确定" duration:0];
}

@end
