//
//  FriendListSearchViewController.m
//  TripleL
//
//  Created by 李伯坤 on 15/5/12.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "FriendListSearchViewController.h"
#import "FriendListCell.h"
#import "MyHeader.h"

#define     HEARDER_HEIGHT          20
#define     CELL_HEIGHT             65
#define     RE_FRIENDLIST_CELL      @"friendlistcell"

@interface FriendListSearchViewController ()
{
    NSMutableArray *searchData;
}
@end

@implementation FriendListSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    searchData = [[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect rect = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 164);
    [self.tableView setFrame:rect];
}

#pragma mark - uitableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchData.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEARDER_HEIGHT)];
    [view setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 20, HEARDER_HEIGHT - 2)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [label setTextColor:[UIColor grayColor]];
    [view addSubview:label];
    [label setText: @"你可能要查找的人"];
    return view;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:RE_FRIENDLIST_CELL];
    if (cell == nil) {
        cell = [[FriendListCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
    }
    
    TLUser *user = [searchData objectAtIndex:indexPath.row];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, CELL_HEIGHT, 0, 0)];
    [cell setFriendInfo:user];
    
    return cell;
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
    TLUser *user = [searchData objectAtIndex:indexPath.row];
    
    [self.delegate didChooseUserItem:user];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    [searchData removeAllObjects];
    NSArray *data = [self.delegate friendListSearchData];
    for (TLUser *user in data){
        if ([user.username containsString:searchText] || [user.nickname containsString:searchText] || [user.remarkName containsString:searchText] || [user.pinyin containsString:searchText]) {
            [searchData addObject:user];
        }
    }
    [self.tableView reloadData];
}

@end
