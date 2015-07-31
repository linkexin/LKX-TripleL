//
//  AppSetingViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/5.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MenuAppSetingViewController.h"
#import "MyHeader.h"
#import "SCLAlertView.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "CommonTableViewCell.h"

#import "MapViewController.h"
#import "AcountMangerViewController.h"
#import "AppSecurityViewController.h"
#import "IndividuationViewController.h"
#import "NotificationViewController.h"
#import "RootViewController.h"

@interface MenuAppSetingViewController ()
{
    NSMutableArray *data;
}

@property (nonatomic, strong) AcountMangerViewController *accountMangerVC;
@property (nonatomic, strong) AppSecurityViewController *appSecrityVC;
@property (nonatomic, strong) NotificationViewController *notificationVC;
@property (nonatomic, strong) IndividuationViewController *individuationVC;

@end

@implementation MenuAppSetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"应用设置"];
 
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    [self.tableView setBackgroundColor:[AppConfig getBGColor]];
   
    NSString *path = [[NSBundle mainBundle] pathForResource:@"setting" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return data.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    if ([type isEqualToString:@"normal"]) {
        cell.textLabel.text = [dic objectForKey:@"title"];
        [cell setUserInteractionEnabled:YES];
    }
    else if([type isEqualToString:@"empty"]){
        cell.textLabel.text = @"";
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    if ([dic objectForKey:@"withDetail"] != nil){
        if ([[dic objectForKey:@"title"] isEqualToString:@"账号管理"]) {
            UIImageView *imageVC = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 6, 33, 33)];
            imageVC.layer.cornerRadius = 33 / 5.0;
            imageVC.layer.masksToBounds = YES;
            [imageVC sd_setImageWithURL:[NSURL URLWithString:[[MyServer getServer] getSelfAccountInfo].avatar] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
            [cell addSubview:imageVC];
        }
       
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        if ([[dic objectForKey:@"title"] isEqualToString:@"清空缓存"]) {
            float space = [[SDImageCache sharedImageCache] getSize] / 1024.0 / 1024.0;
            [cell.detailTextLabel setText:[NSString stringWithFormat:@"%.2f MB", space]];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"normal"]){
        return 45;
    }
    else if ([type isEqualToString:@"empty"]){
        return 20;
    }
    
    return 30;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:@"账号管理"]) {
        if (_accountMangerVC == nil) {
            _accountMangerVC = [[AcountMangerViewController alloc] init];
        }
        
        [self.navigationController pushViewController:_accountMangerVC animated:YES];
    }
    else if ([title isEqualToString:@"通知设置"]){
        if (_notificationVC == nil) {
            _notificationVC = [[NotificationViewController alloc] init];
        }
        [self.navigationController pushViewController:_notificationVC animated:YES];
    }
    else if ([title isEqualToString:@"安全设置"]){
        if (_appSecrityVC == nil) {
            _appSecrityVC = [[AppSecurityViewController alloc] init];
        }
        [self.navigationController pushViewController:_appSecrityVC animated:YES];
    }
    else if ([title isEqualToString:@"个性化设置"]){
        if (_individuationVC == nil) {
            _individuationVC = [[IndividuationViewController alloc] init];
        }
        [self.navigationController pushViewController:_individuationVC animated:YES];
    }
    else if ([title isEqualToString:@"清空消息列表"]) {
        [self cleanMsgRec];
    }
    else if ([title isEqualToString:@"清空聊天记录"]) {
        [self cleanChatRec];
    }
    else if ([title isEqual:@"清空缓存"]){
        [self cleanCache];
    }
    [self.tableView reloadData];
}

#pragma mark - Menu Item Func

- (void) cleanMsgRec
{
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确认清空" actionBlock:^{
        BOOL ok = [[DataCenter getDataCenter] removeAllMessageListItemsFromUser:[[MyServer getServer] getSelfAccountInfo].username];
        ok = [[DataCenter getDataCenter] removeAllChatRecordFromUser:[[MyServer getServer] getSelfAccountInfo].username];
        [[RootViewController getRootViewController] setMsgCountInTabBar:0];
        if (ok) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showSuccess:self.tabBarController title:@"提示" subTitle:@"操作成功，已清除消息列表！" closeButtonTitle:@"确定" duration:0.0f];
        }
        else{
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self.tabBarController title:@"提示" subTitle:@"清空消息列表失败！" closeButtonTitle:@"确定" duration:0.0f];
        }
    }];
    [alertView showNotice:self.tabBarController title:@"确认操作" subTitle:@"确认清空所有消息列表吗？这将无法恢复，请谨慎操作！" closeButtonTitle:@"取消" duration:0.0f];
}

- (void) cleanChatRec
{
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确认清空" actionBlock:^{
        BOOL ok;
        
        // 删除聊天中的视频、图片、语音
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@%@", FILE_DOC, FILE_IMAGE];
        if ([fileManager isExecutableFileAtPath:path]) {
            ok = [fileManager removeItemAtPath:path error:&error];
            if (!ok) {
                NSLog(@"remove file error: %@", error);
            }
            
            ok = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (!ok) {
                NSLog(@"create file error: %@", error);
            }
        }
        
        path = [NSString stringWithFormat:@"%@%@", FILE_DOC, FILE_VOICE];
        if ([fileManager isExecutableFileAtPath:path]) {
            ok = [fileManager removeItemAtPath:path error:&error];
            if (!ok) {
                NSLog(@"remove file error: %@", error);
            }
            
            ok = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (!ok) {
                NSLog(@"create file error: %@", error);
            }
        }
        
        path = [NSString stringWithFormat:@"%@%@", FILE_DOC, FILE_VIDEO];
        if ([fileManager isExecutableFileAtPath:path]) {
            ok = [fileManager removeItemAtPath:path error:&error];
            if (!ok) {
                NSLog(@"remove file error: %@", error);
            }
            
            ok = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
            if (!ok) {
                NSLog(@"create file error: %@", error);
            }
        }
        
        // 删除数据库中的聊天记录信息
        ok = [[DataCenter getDataCenter] removeAllMessageListItemsFromUser:[[MyServer getServer] getSelfAccountInfo].username];
        ok = [[DataCenter getDataCenter] removeAllChatRecordFromUser:[[MyServer getServer] getSelfAccountInfo].username];
        [[RootViewController getRootViewController] setMsgCountInTabBar:0];
        
        if (ok) {
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showSuccess:self.tabBarController title:@"提示" subTitle:@"操作成功，已清除所有聊天记录！" closeButtonTitle:@"确定" duration:0.0f];
        }
        else{
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            [alert showError:self.tabBarController title:@"提示" subTitle:@"清空聊天记录失败！" closeButtonTitle:@"确定" duration:0.0f];
        }
    }];
    [alertView showNotice:self.tabBarController title:@"确认操作" subTitle:@"确认清空所有聊天记录吗？这将一并清空消息列表，请谨慎操作！" closeButtonTitle:@"取消" duration:0.0f];
}

- (void) cleanCache
{
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确认清空" actionBlock:^{
        float space = [[SDImageCache sharedImageCache] getSize] / 1024.0 / 1024.0;
        [[SDImageCache sharedImageCache] cleanDisk];
        [[SDImageCache sharedImageCache] clearDisk];
              
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert addButton:@"确定" actionBlock:^{
            [self.tableView reloadData];
        }];
        [alert showSuccess:self.tabBarController title:@"提示" subTitle:[NSString stringWithFormat: @"操作成功，已释放 %.2fM 空间！", space]closeButtonTitle:nil duration:0.0f];
    }];
    [alertView showNotice:self.tabBarController title:@"确认操作" subTitle:@"确认清空缓存吗？" closeButtonTitle:@"取消" duration:0.0f];
}

@end
