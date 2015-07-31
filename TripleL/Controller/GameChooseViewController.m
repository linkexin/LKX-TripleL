//
//  GameChooseViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/17.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "GameChooseViewController.h"
#import "CommonTableViewCell.h"
#import "SCLAlertView.h"
#import "MyHeader.h"
#import "MBProgressHUD.h"
#import "GameCenter.h"

@interface GameChooseViewController ()
{
    NSMutableArray *data;
    TLInfo *setting;
}

@property (nonatomic, strong) MBProgressHUD *mbProgressHUD;

@end

@implementation GameChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"解锁游戏"];

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"game" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    _mbProgressHUD = [[MBProgressHUD alloc] init];
    [self.tabBarController.view addSubview:_mbProgressHUD];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_mbProgressHUD setLabelText:@"请稍候"];
    [_mbProgressHUD setDetailsLabelText:@"正在获取用户信息"];
    [_mbProgressHUD show:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getInfoSuccessful:) name:INFO_GETPERMISSTIONINFOSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getInfoFailed:) name:INFO_GETPERMISSTIONINFOFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyInfoSuccessful:) name:INFO_MODIFYPERMISSTIONINFOSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyInfoFailed:) name:INFO_MODIFYPERMISSTIONINFOFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
    [[MyServer getServer] getUserPermisstionByUsername:[[MyServer getServer] getSelfAccountInfo].username];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mbProgressHUD hide:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) getInfoSuccessful: (NSNotification *) noti
{
    [_mbProgressHUD hide:YES];
    setting = noti.object;
    [self.tableView reloadData];
}

- (void) getInfoFailed: (NSNotification *) noti
{
    [_mbProgressHUD hide:YES];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"获取解锁信息失败" closeButtonTitle:nil duration:0];
}

- (void) modifyInfoSuccessful: (NSNotification *) noti
{
    
}

- (void) modifyInfoFailed: (NSNotification *) noti
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"修改解锁信息失败" closeButtonTitle:nil duration:0];
}

#pragma mark - UITableView
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (! setting.lockDetailInfo.boolValue)
        return 1;
    return data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [data objectAtIndex:section];
    return array.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [data objectAtIndex:indexPath.section];
    NSDictionary *dic = [array objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if ([type isEqualToString:@"normal"]) {
        cell.textLabel.text = [dic objectForKey:@"title"];
        [cell setUserInteractionEnabled:YES];
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
    
    if ([dic objectForKey:@"withDetail"] != nil){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if ([dic objectForKey:@"withoutLine"] != nil){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0,0, self.view.frame.size.width / 2.0)];
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 6.5, 60, 37)];
            sw.on = setting.lockDetailInfo.boolValue;
            [sw addTarget:self action:@selector(switchButtonDown:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:sw];
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == setting.gameID.intValue + 1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.section == 2){
        if (indexPath.row == setting.gameDiff.intValue + 1) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [data objectAtIndex:indexPath.section];
    NSDictionary *dic = [array objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"normal"]){
        return 45;
    }
    else if ([type isEqualToString:@"empty"]){
        if ([dic objectForKey:@"withoutLine"] != nil){
            return 10;
        }
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
    if (indexPath.section == 1) {
        setting.gameID = [NSString stringWithFormat:@"%d", (int)(indexPath.row - 1)];
    }
    else if (indexPath.section == 2) {
        setting.gameDiff = [NSString stringWithFormat:@"%d", (int)(indexPath.row - 1)];
    }
    else if (indexPath.section == 3 && indexPath.row == 1){
        [[GameCenter getGameCenter] tryGame:setting from:self];
    }
    [[MyServer getServer] modifySelfPermisstion:setting];
    [self.tableView reloadData];
}

- (void) switchButtonDown: (UISwitch *) sender;
{
    setting.lockDetailInfo = [NSString stringWithFormat:@"%d", sender.on];
    [[MyServer getServer] modifySelfPermisstion:setting];
    [self.tableView reloadData];
}

@end
