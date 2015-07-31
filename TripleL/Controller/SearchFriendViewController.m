//
//  AddFriendSearchViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/23.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "CommonTableViewCell.h"
#import "SearchFriendResultViewController.h"
#import "MyHeader.h"

@interface SearchFriendViewController ()
{
    UITextField *keywordTextField;
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) SearchFriendResultViewController *searchResultVC;
@end

@implementation SearchFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"搜索好友"];
    keywordTextField = [[UITextField alloc] init];
    progressHUD = [[MBProgressHUD alloc] init];
    [self.tabBarController.view addSubview:progressHUD];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];

    [self.tabBarController.tabBar setHidden:YES];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStyleDone target:self action:@selector(searchButtonDown)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFriendSuccessful:) name:INFO_SEARCHFRIENDSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFriendFailed:) name:INFO_SEARCHFRIENDFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [progressHUD hide:YES];
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

- (void) searchButtonDown
{
    if (keywordTextField.text.length > 0) {
        [[MyServer getServer] searchFriendByKeyword:keywordTextField.text];
        [progressHUD setLabelText:@"请稍候"];
        [progressHUD setDetailsLabelText:@"正在请求数据"];
        [progressHUD show:YES];
    }
    else{
        SCLAlertView *alertView = [[SCLAlertView alloc] init];
        [alertView showInfo:self.tabBarController title:@"提示" subTitle:@"请输入搜索关键词～" closeButtonTitle:@"确定" duration:0];
    }
}

- (void) searchFriendSuccessful: (NSNotification *) noti
{
    [progressHUD hide:YES];
    NSArray *data = noti.object;
    if (data.count == 0) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert showInfo:self.tabBarController title:@"提示" subTitle:@"未找到相关好友～" closeButtonTitle:@"确定" duration:0];
        return;
    }
    
    if (_searchResultVC == nil) {
        _searchResultVC = [[SearchFriendResultViewController alloc] init];
    }
    _searchResultVC.data = data;
    
    UINavigationController *nv = self.navigationController;
    [self.navigationController popViewControllerAnimated:NO];
    [nv pushViewController:_searchResultVC animated:YES];
}

- (void) searchFriendFailed: (NSNotification *) noti
{
    [progressHUD hide:YES];
    NSString *error = noti.object;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showError:self.tabBarController title:@"出错啦。。" subTitle:error closeButtonTitle:@"确定" duration:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    if (indexPath.row == 0) {
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setUserInteractionEnabled:NO];
    }
    else if (indexPath.row == 1){
        [cell setBackgroundColor:[AppConfig getFGColor]];
        [keywordTextField setPlaceholder:@"输入用户名或昵称"];
        [keywordTextField setFrame:CGRectMake(20, 0, self.view.frame.size.width - 40, 45)];
        [cell addSubview:keywordTextField];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 25;
    }
    return 45;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
}

@end
