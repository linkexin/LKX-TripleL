//
//  SearchFriendResultViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/23.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "SearchFriendResultViewController.h"

#import "SearchResultCell.h"
#import "UIImageView+WebCache.h"
#import "MyHeader.h"
#import "BriefUserInfo.h"
#import "MapFriendsInfo.h"

#define         CELL_HEIGHT             55
#define         CELL_IDENTIFY           @"re_search_result_cell"

@interface SearchFriendResultViewController ()<BriefUserInfoDelegate>
{
    CGRect shortCutViewRect;
    TLUser *userinfo;
}
@property (strong, nonatomic) BriefUserInfo *briefInfoView;
@property (strong, nonatomic) UIButton *btnNextPage;

@end

@implementation SearchFriendResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"搜索结果"];

    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - _data.count * CELL_HEIGHT - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height + 20);
    [view setBackgroundColor:[UIColor clearColor]];
    
    _btnNextPage = [[UIButton alloc]init];
    [_btnNextPage addTarget:self action:@selector(hideOrShow) forControlEvents:UIControlEventTouchUpInside];
    _btnNextPage.backgroundColor = [UIColor clearColor];
    _btnNextPage.userInteractionEnabled = YES;
    _btnNextPage.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [view addSubview:_btnNextPage];
    [self.tableView setTableFooterView:view];
    
    
    [[MapFriendsInfo getMapFriendsInfo] initself];
    [MapFriendsInfo getMapFriendsInfo].callOutHeight = self.view.frame.size.height * 0.6;
    [MapFriendsInfo getMapFriendsInfo].callOutWidth = [MapFriendsInfo getMapFriendsInfo].callOutHeight * 0.55;
    
    _briefInfoView = [[BriefUserInfo alloc]init];
    _briefInfoView.delegate = self;
    float w = self.view.frame.size.height * 0.6 * 0.55;
    float h = self.view.frame.size.height * 0.6;
    float x = (self.view.frame.size.width - w) / 2.0;
    float y = (self.view.frame.size.height - h) / 2.0;
    shortCutViewRect = CGRectMake(x, y, w, h);

    [self.tabBarController.tabBar setHidden:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tabBarController.tabBar setHidden:YES];
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_briefInfoView setHidden:YES];
}


#pragma mark - tableview

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFY];
    if (cell == nil) {
        cell = [[SearchResultCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
    }
    TLUser *user = [_data objectAtIndex:indexPath.row];
    [cell setAvatar:[NSURL URLWithString:user.avatar] name:user.username nikename:user.nickname mood:user.mood];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLUser *user = [_data objectAtIndex:indexPath.row];
    userinfo = user;
    int index = user.gameInfo.gameID.intValue;
    NSDictionary *dic = [[GameCenter getGameCenter].infoArr objectAtIndex:index];
    
    int x = user.gameInfo.gameDiff.intValue;
    [_briefInfoView setInfoWithPhoto:user.avatar userName:user.username islock:user.gameInfo.lockDetailInfo gameName:[dic objectForKey:@"name"] gameLevel:[[dic objectForKey:@"level"]objectAtIndex:x] gamenamepicture:[dic objectForKey:@"gameAvater"] gamelevelpicture:[dic objectForKey:@"levelAvater"]];
    
    [_briefInfoView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 4, 0, shortCutViewRect.size.width, shortCutViewRect.size.height)];
    [UIView animateWithDuration:0.3 animations:^{
        [_briefInfoView setHidden:NO];
        //[_briefInfoView setHidden:YES];
        [self.navigationController.view addSubview:_briefInfoView];
        [_briefInfoView setFrame:shortCutViewRect];
    } completion:^(BOOL finished) {}];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

-(void)hideOrShow
{
    if(![_briefInfoView isHidden])
    {
        [UIView animateWithDuration:0.3 animations:^{
            [_briefInfoView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 4, [UIScreen mainScreen].bounds.size.height, shortCutViewRect.size.width, shortCutViewRect.size.height)];
            [_briefInfoView setHidden:YES];
        } completion:^(BOOL finished) {}];
    }
}

-(void)toGame:(TLUser*)user
{
    [[GameCenter getGameCenter]jump:userinfo from:self];
}

@end
