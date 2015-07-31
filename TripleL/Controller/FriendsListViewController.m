//
//  FriendListViewController.m
//  RripleL
//
//  Created by 李伯坤 on 15/4/13.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "FriendsListViewController.h"
#import "FriendListSearchViewController.h"
#import "FriendListCell.h"
#import "MyHeader.h"
#import "DetailInfoViewController.h"
#import "SearchFriendViewController.h"
#import "SCLAlertView.h"

#define     HEARDER_HEIGHT          20
#define     CELL_HEIGHT             65
#define     RE_FRIENDLIST_CELL      @"friendlistcell"

@interface FriendsListViewController () <UISearchBarDelegate, FriendListSearchVCDelegate>
{
    NSMutableArray *friendData;
    NSMutableArray *listData;
    NSMutableArray *sectionData;
}

@property (nonatomic, strong) UITextView *friendsCountView;
@property (nonatomic, strong) DetailInfoViewController *detailController;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) FriendListSearchViewController *friendListSearchViewController;
@property (nonatomic, strong) SearchFriendViewController *SearchFriendVC;

@end

@implementation FriendsListViewController

- (void) viewDidLoad
{
    [[MyServer getServer] getTravelData];
    [super viewDidLoad];
    [self setNavTitle:@"通讯录"];
    {
        [self.navigationController.navigationBar setBackgroundImage:[AppConfig getNavBarBgImage] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTintColor:[AppConfig getBarTitleColor]];
    }
    
    friendData = [[DataCenter getDataCenter] getFriendListFromUser:[[MyServer getServer] getSelfAccountInfo].username];
    NSDictionary *dic = [DataProcessCenter transformFriendList:friendData];
    listData = [dic objectForKey:@"data"];
    sectionData = [dic objectForKey:@"section"];
    
    // friendList
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    view.backgroundColor = [UIColor clearColor];
    _friendsCountView = [[UITextView alloc] initWithFrame:CGRectMake(0, 3, self.view.frame.size.width, 40)];
    [_friendsCountView setTextColor:[UIColor grayColor]];
    [_friendsCountView setFont:[UIFont systemFontOfSize:12]];
    [_friendsCountView setTextAlignment:NSTextAlignmentCenter];
    [_friendsCountView setBackgroundColor:[UIColor clearColor]];
    [_friendsCountView setUserInteractionEnabled:NO];
    if (friendData.count != 0){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        
        [_friendsCountView setText:[NSString stringWithFormat:@"%@\n好友总数：%lu", [formatter stringFromDate:[NSDate date]],(unsigned long)friendData.count]];
    }
    else{
        [_friendsCountView setText:@"暂无好友数据"];
    }
    [view addSubview:_friendsCountView];
    [self.tableView setTableFooterView:view];
    // 下拉刷新
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"刷新好友列表"];
    refreshControl.tintColor = [AppConfig getBarButtonColor];
    [refreshControl addTarget:self action:@selector(refreshFriendList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor]; // 导航设置

    // 详细信息页面
    _detailController = [DetailInfoViewController getDetailVC];
    
    // searchBar
    self.friendListSearchViewController = [[FriendListSearchViewController alloc] init];
    self.friendListSearchViewController.delegate = self;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.friendListSearchViewController];
    _searchController.searchResultsUpdater = self.friendListSearchViewController;
    [_searchController.searchBar sizeToFit];
    _searchController.searchBar.delegate = self;
    [self.tableView setTableHeaderView:_searchController.searchBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedFriendList:) name:INFO_GETMYFRIENDLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendList) name:INFO_MODIFYREMARKNAMESUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendList) name:INFO_DELETEFRIENDSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendList) name:INFO_ADDFRIENDSUCCESSFUL object:nil];
    [[MyServer getServer] getMyFriendList];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
    
    [self.navigationController.navigationBar setHidden:NO];
    [self.tabBarController.tabBar setHidden:NO];
    
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:INFO_NETWORKANOMALY object:nil];
}

- (void) networkAnomaly
{
    [self.refreshControl endRefreshing];
}

- (void) refreshFriendList
{
    [[MyServer getServer] getMyFriendList];
}

- (void) receivedFriendList: (NSNotification *) notification
{
    friendData = notification.object;
    NSDictionary *dic = [DataProcessCenter transformFriendList:friendData];
    listData = [dic objectForKey:@"data"];
    sectionData = [dic objectForKey:@"section"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm";
    [_friendsCountView setText:[NSString stringWithFormat:@"%@\n好友总数：%lu", [formatter stringFromDate:[NSDate date]],(unsigned long)friendData.count]];
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)orientChange:(NSNotification *)noti
{
    [_friendsCountView setFrame:CGRectMake(0, 3, [UIScreen mainScreen].bounds.size.width, 40)];
}

- (IBAction)addFriendButtonDown:(id)sender {
    if (_SearchFriendVC == nil) {
        _SearchFriendVC = [[SearchFriendViewController alloc] init];
    }
    
    [self.navigationController pushViewController:_SearchFriendVC animated:YES];
}

#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return listData.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *array = [listData objectAtIndex:section];
    return array.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEARDER_HEIGHT)];
    [view setBackgroundColor:DEFAULT_WHITE_COLOR];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, HEARDER_HEIGHT - 2)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextColor:[UIColor grayColor]];
    [view addSubview:label];
    [label setText: [sectionData objectAtIndex:section]];
    return view;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:RE_FRIENDLIST_CELL];
    if (cell == nil) {
        cell = [[FriendListCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
    }
    
    NSMutableArray *array = [listData objectAtIndex:indexPath.section];
    TLUser *user = [array objectAtIndex:indexPath.row];
    if (indexPath.row == array.count - 1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0,0, self.view.frame.size.width / 2.0)];
    }
    else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width, 0, self.view.frame.size.width)];
    }

    [cell setFriendInfo:user];
    
    return cell;
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return sectionData;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEARDER_HEIGHT;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [listData objectAtIndex:indexPath.section];
    TLUser *user = [array objectAtIndex:indexPath.row];
    //NSLog(@"name = %@, avar = %@, gender = %@, mood = %@", user.username, user.avatar, user.gender, user.mood);
    _detailController.friendInfo = user;
    _detailController.type = FromList;
    [self.navigationController pushViewController:_detailController animated:YES];
}

#pragma mark - friendListDelegate

- (NSArray *)friendListSearchData
{
    return friendData;
}

- (void) didChooseUserItem:(TLUser *)user
{
    _detailController.friendInfo = user;
     _detailController.type = FromList;
    
    [self.navigationController pushViewController:_detailController animated:YES];
    [self.searchController.searchBar setText:@""];
    [self.searchController.searchBar resignFirstResponder];
    self.searchController.searchBar.showsCancelButton = NO;
    [self.searchController resignFirstResponder];
    [self.searchController dismissViewControllerAnimated:NO completion:^{
        
    }];
}

#pragma mark - searchBar
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.tabBarController.tabBar setHidden:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tabBarController.tabBar setHidden:NO];
}

@end
