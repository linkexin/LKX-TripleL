//
//  MenuViewController.m
//  TripleL
//
//  Created by 李伯坤 on 15/5/4.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuInfoCell.h"
#import "MyHeader.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *menuData;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.6, self.view.frame.size.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.6, 30)];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setShowsHorizontalScrollIndicator:NO];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    menuData = [self getMenuData];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoChange) name:INFO_REFRESHUSERINFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height * 0.6, [UIScreen mainScreen].bounds.size.height)];
    }
    else {
        [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.6, [UIScreen mainScreen].bounds.size.height)];
    }

    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientChange:(NSNotification *)noti
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height * 0.6, [UIScreen mainScreen].bounds.size.height)];
    }
    else {
        [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width * 0.6, [UIScreen mainScreen].bounds.size.height)];
    }

    [self.tableView reloadData];
}

- (void) infoChange
{
    [self.tableView reloadData];
}


- (NSMutableArray *) getMenuData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"plist"];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile: path];
    return data;
}

#pragma mark - uitableview

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuData.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [menuData objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"avatar"]) {
        MenuInfoCell *cell = [[MenuInfoCell alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.width * 0.8)];
        TLUser *user = [[MyServer getServer] getSelfAccountInfo];
        [cell setAvatar:user.avatar nickname:user.nickname];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    else if ([type isEqualToString:@"mood"]){
        TLUser *user = [[MyServer getServer] getSelfAccountInfo];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.text = [NSString stringWithFormat:@"“%@”", user.mood];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setUserInteractionEnabled:YES];
        return cell;
    }
    else if ([type isEqualToString:@"normal"]){
        NSString *title = [dic objectForKey:@"title"];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.text = title;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setUserInteractionEnabled:YES];
        return cell;
    }
    else if ([type isEqualToString:@"order"]){
        NSString *title = [dic objectForKey:@"title"];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.text = title;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setUserInteractionEnabled:YES];
        return cell;
    }
    else if ([type isEqualToString:@"empty"]){
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.6, 20)];
    [view setBackgroundColor:[UIColor clearColor]];
    return view;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [menuData objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"avatar"]) {
        return tableView.frame.size.width * 0.8;
    }
    else if([type isEqualToString:@"mood"]){
        return 40;
    }
    else if([type isEqualToString:@"normal"]){
        return 40;
    }
    else if([type isEqualToString:@"order"]){
        return 40;
    }
    else if([type isEqualToString:@"empty"]){
        return 20;
    }
    
    return 50;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        [self.delegate chooseItemInMenu:@"mood"];
        return;
    }
    NSDictionary *dic = [menuData objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    [self.delegate chooseItemInMenu:title];
}

@end
