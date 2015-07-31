//
//  FriendRecommendViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/26.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "FriendRecommendViewController.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "FriendListCell.h"
#import "MyHeader.h"
#import "BriefUserInfo.h"
#import "MapFriendsInfo.h"

#define     CELL_HEIGHT             65
#define     RE_FRIENDLIST_CELL      @"friend_recommend_list_cell"

@interface FriendRecommendViewController ()<BriefUserInfoDelegate>
{
    NSMutableArray *data;
    MBProgressHUD *progressHUD;
    CGRect shortCutViewRect;
    TLUser *userinfo;
    UIView *view;
}
@property (strong, nonatomic) BriefUserInfo *briefInfoView;
@property (strong, nonatomic) UIButton *btnNextPage;

@end

@implementation FriendRecommendViewController


- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"好友推荐"];
    
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    //view.backgroundColor = [UIColor clearColor];
    
    view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    
    _btnNextPage = [[UIButton alloc]init];
    [_btnNextPage addTarget:self action:@selector(hideOrShow) forControlEvents:UIControlEventTouchUpInside];
    _btnNextPage.backgroundColor = [UIColor clearColor];
    _btnNextPage.userInteractionEnabled = YES;
    [view addSubview:_btnNextPage];
    

    [self.tableView setTableFooterView:[UIView new]];
    
    progressHUD = [[MBProgressHUD alloc] init];
    [self.view addSubview:progressHUD];
    
    
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
 
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
    [progressHUD setLabelText:@"请稍后"];
    [progressHUD setDetailsLabelText:@"正在请求网络数据"];
    [progressHUD show:YES];

    [[MyServer getServer] getFriendRecommend];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendDataSuccessful:) name:INFO_GETFRIENDRECOMMENDSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendDataFailed:) name:INFO_GETFRIENDRECOMMENDFAILED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_briefInfoView setHidden:YES];
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

- (void) getFriendDataSuccessful: (NSNotification *) noti
{
    [progressHUD hide:YES];
    
    data = noti.object;
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - data.count * CELL_HEIGHT - self.navigationController.navigationBar.frame.size.height - self.tabBarController.tabBar.frame.size.height + 20);
    _btnNextPage.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    [self.tableView setTableFooterView:view];
    [self.tableView reloadData];
}

- (void) getFriendDataFailed: (NSNotification *) noti
{
    [progressHUD hide:YES];
    NSString *error = noti.object;
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showError: self.tabBarController title:@"出错了～" subTitle:error closeButtonTitle:nil duration:0];
}



#pragma mark - UITableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:RE_FRIENDLIST_CELL];
    if (cell == nil) {
        cell = [[FriendListCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
    }
    
    TLUser *user = [data objectAtIndex:indexPath.row];
    [cell setFriendInfo:user];
    [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width, 0, self.view.frame.size.width)];
    
    return cell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLUser *user = [data objectAtIndex:indexPath.row];
    
    userinfo = user;
    
    int index = user.gameInfo.gameID.intValue;
    NSDictionary *dic = [[GameCenter getGameCenter].infoArr objectAtIndex:index];
    
    int x = user.gameInfo.gameDiff.intValue;
    [_briefInfoView setInfoWithPhoto:user.avatar userName:user.username islock:user.gameInfo.lockDetailInfo gameName:[dic objectForKey:@"name"] gameLevel:[[dic objectForKey:@"level"]objectAtIndex:x] gamenamepicture:[dic objectForKey:@"gameAvater"] gamelevelpicture:[dic objectForKey:@"levelAvater"]];
    
    
    [_briefInfoView setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 4, 0, shortCutViewRect.size.width, shortCutViewRect.size.height)];
    [UIView animateWithDuration:0.3 animations:^{
        [_briefInfoView setHidden:NO];
        [self.navigationController.view addSubview:_briefInfoView];
        [_briefInfoView setFrame:shortCutViewRect];
    } completion:^(BOOL finished) {}];
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
