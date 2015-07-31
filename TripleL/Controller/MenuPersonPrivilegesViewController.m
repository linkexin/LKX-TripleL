//
//  MenuPersonPrivilegesViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/5.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MenuPersonPrivilegesViewController.h"
#import "CommonTableViewCell.h"
#import "MyHeader.h"

#import "GameChooseViewController.h"
#import "AddFriendSettingViewController.h"
#import "ChangePasswordViewController.h"

@interface MenuPersonPrivilegesViewController ()
{
    NSMutableArray *data;
}

@property (nonatomic, strong) GameChooseViewController *gameChooseVC;
@property (nonatomic, strong) AddFriendSettingViewController *addFriendSettingVC;
@property (nonatomic, strong) ChangePasswordViewController *changePasswordVC;

@end

@implementation MenuPersonPrivilegesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:@"账号设置"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"authority" ofType:@"plist"];
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
    NSDictionary *dic = [data objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    
    if ([title isEqualToString:@"解锁游戏设置"]) {
        if (_gameChooseVC == nil) {
            _gameChooseVC = [[GameChooseViewController alloc] init];
        }
        [self.navigationController pushViewController:_gameChooseVC animated:YES];
    }
    else if ([title isEqualToString:@"加好友设置"]){
        if (_addFriendSettingVC == nil) {
            _addFriendSettingVC = [[AddFriendSettingViewController alloc] init];
        }
        [self.navigationController pushViewController:_addFriendSettingVC animated:YES];
    }
    else if ([title isEqualToString:@"修改密码"]){
        if (_changePasswordVC == nil) {
            _changePasswordVC = [[ChangePasswordViewController alloc] init];
        }
        [self.navigationController pushViewController:_changePasswordVC animated:YES];
    }
    
    [self.tableView reloadData];
}

@end
