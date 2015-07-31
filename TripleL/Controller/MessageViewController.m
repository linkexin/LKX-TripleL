//
//  MessageViewController.m
//  RripleL
//
//  Created by 李伯坤 on 15/4/13.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "MessageViewController.h"
#import "MyHeader.h"
#import "MapViewController.h"
#import "MessageCell.h"
#import "MsgRecordItem.h"
#import "ChatViewController.h"
#import "UIViewController+XTSideMenu.h"
#import "XTSideMenu.h"
#import "SCLAlertView.h"

#import "UIButton+WebCache.h"
#import "MenuViewController.h"
#import "RootViewController.h"
#import "DetailInfoViewController.h"
#import "LTHPasscodeViewController.h"
#import "ModifyMoodViewController.h"

#define     CELL_HEIGHT                     60
#define     RE_MESSAGECALL_IDENTIFY         @"message_cell"

@interface MessageViewController () <MenuViewDelegate, XTSideMenuDelegate>
{
    NSMutableArray *msgRecArray;
}

@property (nonatomic, strong) UIButton *selfCenterButton;

@end


@implementation MessageViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"消息"];
    {
        [self.navigationController.navigationBar setBackgroundImage:[AppConfig getNavBarBgImage] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTintColor:[AppConfig getBarTitleColor]];
        [self.tabBarController.tabBar setBackgroundImage:[AppConfig getTabBarBgImage]];
        [self.tabBarController.tabBar setTintColor:[AppConfig getBarItemColor]];
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    // 个人中心按钮
    _selfCenterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    [_selfCenterButton sd_setBackgroundImageWithURL:[NSURL URLWithString:@""] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    _selfCenterButton.layer.cornerRadius = _selfCenterButton.frame.size.width / 2.0;
    _selfCenterButton.layer.masksToBounds = YES;
    [_selfCenterButton addTarget:self action:@selector(personalButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: _selfCenterButton];
    [self.navigationItem setLeftBarButtonItem:item];

    ((MenuViewController *)(self.sideMenuViewController.leftMenuViewController)).delegate = self;
    self.sideMenuViewController.delegate = self;

    [self userLoginSuccessfully];           // 由于注册成功时，次vc尚未初始化，所以接受不到登陆成功的回调，只能手动调用检查
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginSuccessfully) name:INFO_LOGINSUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showChatVC) name:INFO_SHOWCHATVC object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshList:) name:INFO_REFRESHMESSAGELIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifySelfCenterInfo) name:INFO_REFRESHUSERINFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList:) name:INFO_GETMYFRIENDLIST object:nil];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    chooseItemName = nil;
    [self.tabBarController.tabBar setHidden:NO];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ChatViewController getChatViewController].friendUser = nil;
}

- (void) userLoginSuccessfully
{
    TLUser *user = [[MyServer getServer] getSelfAccountInfo];
    if (user == nil) {
        return;
    }
   
    [_selfCenterButton sd_setBackgroundImageWithURL:[NSURL URLWithString:user.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    msgRecArray = [[DataCenter getDataCenter] getMessageListFromUser:user.username];
    [self.tableView reloadData];
}

- (void) modifySelfCenterInfo
{
    TLUser *user = [[MyServer getServer] getSelfAccountInfo];
    [_selfCenterButton sd_setBackgroundImageWithURL:[NSURL URLWithString:user.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    msgRecArray = [[DataCenter getDataCenter] getMessageListFromUser:user.username];
}

- (void) reloadList: (NSNotification *) noti
{
    msgRecArray = [[DataCenter getDataCenter] getMessageListFromUser:[[MyServer getServer] getSelfAccountInfo].username];
    [self.tableView reloadData];
}

- (void) refreshList: (NSNotification *) noti
{
    [self.tableView reloadData];
}

- (void) personalButtonDown:(id)sender {
    [self.sideMenuViewController presentLeftViewController];
}

- (void) showChatVC
{
    ChatViewController *chatVC = [ChatViewController getChatViewController];
    // 推送特判
    for (id item in self.navigationController.viewControllers) {
        if ([item class] == [chatVC class]) {
            return;
        }
    }
    [self.tabBarController setSelectedIndex:0];
    [self.tabBarController.tabBar setHidden:YES];
    [self.navigationController pushViewController:chatVC animated:YES];
}


#pragma mark - tableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(msgRecArray.count == 0)
        return 1;
    else
        return msgRecArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(msgRecArray.count == 0)
    {
        UITableViewCell *bgcell = [self.tableView dequeueReusableCellWithIdentifier:@"bgCell"];
        if (bgcell == nil) {
            bgcell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"bgCell"];
        }
        bgcell.backgroundColor = [AppConfig getBGColor];
        UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 25, [UIScreen mainScreen].bounds.size.height / 2 - 120, 50, 50)];
        bg.image = [UIImage imageNamed:@"chat1.png"];
        bg.alpha = 0.05;
        bgcell.userInteractionEnabled = NO;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, [UIScreen mainScreen].bounds.size.height / 2 - 70, 100, 50)];
        label.text = @"暂无会话";
        label.backgroundColor = [UIColor clearColor];
        label.alpha = 0.05;
        label.textAlignment = NSTextAlignmentCenter;
        [bgcell addSubview:bg];
        [bgcell addSubview:label];
        return bgcell;
    }
    
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:RE_MESSAGECALL_IDENTIFY];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CELL_HEIGHT)];
    }
    MsgRecordItem *item = [msgRecArray objectAtIndex:indexPath.row];
    [cell setAvatar:[NSURL URLWithString:item.avatar] name:item.remarkName time:item.time message:item.message number:item.count];
    if (indexPath.row == msgRecArray.count - 1) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0, 0, self.view.frame.size.width / 2.0)];
    }
    else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width, 0, self.view.frame.size.width)];
    }
    
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(msgRecArray.count == 0)
        return self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - 20 - self.tabBarController.tabBar.frame.size.height;
    return CELL_HEIGHT;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MsgRecordItem *item = [msgRecArray objectAtIndex:indexPath.row];
        [[DataCenter getDataCenter] removeMessageListItemByFriendName:item.username fromUser:[[MyServer getServer] getSelfAccountInfo].username];
        [msgRecArray removeObjectAtIndex: indexPath.row];
        
        if (msgRecArray.count > 1) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        }
        else {
            [self.tableView reloadData];
        }
    }
}

- (NSString *) tableView: (UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath: (NSIndexPath *)indexPath
{
    return @"删除";
}

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgRecordItem *item = [msgRecArray objectAtIndex:indexPath.row];
    
    ChatViewController *chatVC = [ChatViewController getChatViewController];
    chatVC.selfUser = [[MyServer getServer] getSelfAccountInfo];
    TLUser *f_User = [[TLUser alloc] init];
    f_User.username = item.username;
    f_User.avatar = item.avatar;
    f_User.remarkName = item.remarkName;
    chatVC.friendUser = f_User;
    if (item.count.intValue != 0){
        [[RootViewController getRootViewController] changeMsgCountInTabBar: - item.count.intValue];
        item.count = @"0";
        [[DataCenter getDataCenter] addMessageListItem:item toUser:[[MyServer getServer] getSelfAccountInfo].username];
    }
    
    [self showChatVC];
}

static NSString *chooseItemName = nil;
#pragma mark - menuViewDelegate
- (void) chooseItemInMenu:(NSString *)itemName
{
    chooseItemName = itemName;

    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark - XTSideMenuDelegate
- (void) sideMenu:(XTSideMenu *)sideMenu didHideLeftMenuViewController:(UIViewController *)menuViewController
{
    id vc;
    if([chooseItemName isEqualToString: @"mood"])
    {
        ModifyMoodViewController *modifyMood = [[ModifyMoodViewController alloc]init];
        modifyMood.isFromMenu = YES;
        modifyMood.moodString = [[MyServer getServer] getSelfAccountInfo].mood;
        [self.navigationController pushViewController:modifyMood animated:YES];
    }
    
    else if ([chooseItemName isEqualToString:@"个人资料"]){
        [DetailInfoViewController getDetailVC].type = FromSelf;
        vc = [DetailInfoViewController getDetailVC];
    }
    else if ([chooseItemName isEqualToString:@"账号设置"]) {
        vc = [[MenuPersonPrivilegesViewController alloc] init];
    }
    else if ([chooseItemName isEqualToString:@"应用设置"]) {
        vc = [[MenuAppSetingViewController alloc] init];
    }
    else if ([chooseItemName isEqualToString:@"反馈建议"]) {
        vc = [[MenuFeedbackViewController alloc] init];
    }
    else if ([chooseItemName isEqualToString:@"关于应用"]) {
        vc = [[MenuAboutViewController alloc] init];
    }
    else if ([chooseItemName isEqualToString:@"注销登陆"]) {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addButton:@"确认注销" actionBlock:^{
            [[MyServer getServer] logout];
            [SFHFKeychainUtils deleteItemForUsername:[[MyServer getServer] getSelfAccountInfo].username andServiceName:@"iOS" error:nil];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
            
            [[RootViewController getRootViewController] logout];
        }];
        [alert showNotice:self.tabBarController title:@"注销" subTitle:@"确认要注销当前账号吗？" closeButtonTitle:@"保持登陆" duration:0.0f];
        return;
    }
    else{
        return;
    }
    
    [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:vc animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
}

@end
