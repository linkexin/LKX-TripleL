//
//  MakeFriendsViewController.m
//  RripleL
//
//  Created by 李伯坤 on 15/4/13.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "MakeFriendsViewController.h"
#import "CommonTableViewCell.h"
#import "MyHeader.h"
#import "MyServer.h"

#import "MakeFriendCell.h"

#import "SelfTimeLineCenterViewController.h"
#import "FriendTimeLineViewController.h"
#import "ArounderTimeLineViewController.h"
#import "FriendRecommendViewController.h"
#import "LocationRoaming.h"

#define         CELL_HEIGHT                 45
#define         RE_MAKEFRIENDLIST_CELL      @"re_makefriendlist_cell"

@interface MakeFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *mfListArray;
}

@property (nonatomic, strong) FriendTimeLineViewController *friendTimelineVC;
@property (nonatomic, strong) SelfTimeLineCenterViewController *selfTimelineVC;
@property (nonatomic, strong) ArounderTimeLineViewController *arrounderTimerlineVC;
@property (nonatomic, strong) FriendRecommendViewController *friendRecommendVC;

@end

@implementation MakeFriendsViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"交际中心"];
    {
        [self.navigationController.navigationBar setBackgroundImage:[AppConfig getNavBarBgImage] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTintColor:[AppConfig getBarTitleColor]];
    }
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    mfListArray = [self getMakeFriendListData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (NSMutableArray *) getMakeFriendListData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"makeFriendMenu" ofType:@"plist"];
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return data;
}

#pragma mark - tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mfListArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [mfListArray objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    
    MakeFriendCell *cell = [[MakeFriendCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
    
    if ([type isEqualToString:@"normal"]) {
        NSString *title = [dic objectForKey:@"title"];
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"mf_%d.png", (int)indexPath.row]];
        [cell setImage:image andTitle:title];
        [cell setUserInteractionEnabled:YES];
    }
    else if([type isEqualToString:@"empty"]){
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }

    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width, 0, self.view.frame.size.width)];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];
    
    NSDictionary *dic = [mfListArray objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:@"个人中心"]) {
        if (_selfTimelineVC == nil) {
            _selfTimelineVC = [[SelfTimeLineCenterViewController alloc] init];
        }
        [self.navigationController pushViewController:_selfTimelineVC animated:YES];
    }
    else if ([title isEqualToString:@"好友动态"]) {
        if (_friendTimelineVC == nil) {
            _friendTimelineVC = [[FriendTimeLineViewController alloc] init];
        }
        [self.navigationController pushViewController:_friendTimelineVC animated:YES];
    }
    else if ([title isEqualToString:@"周围的人"]){
        if (_arrounderTimerlineVC == nil) {
            _arrounderTimerlineVC = [[ArounderTimeLineViewController alloc] init];
        }
        [self.navigationController pushViewController:_arrounderTimerlineVC animated:YES];
    }
    else if ([title isEqualToString:@"好友推荐"]){
        if (_friendRecommendVC == nil) {
            _friendRecommendVC = [[FriendRecommendViewController alloc] init];
        }
        [self.navigationController pushViewController:_friendRecommendVC animated:YES];
    }
    else if([title isEqualToString:@"地点漫游"])
    {
        LocationRoaming *locationRoaming = [[LocationRoaming alloc]init];
        [self.navigationController pushViewController:locationRoaming animated:YES];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [mfListArray objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"normal"]){
        return CELL_HEIGHT;
    }
    return 20;
}

@end
