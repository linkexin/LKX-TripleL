//
//  NotificationViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/17.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "NotificationViewController.h"
#import "CommonTableViewCell.h"
#import "MyHeader.h"

@interface NotificationViewController ()
{
    NSMutableArray *data;
    TLInfo *setting;
}

@end

@implementation NotificationViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:@"通知设置"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"notiSetting" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    setting = [[DataCenter getDataCenter] getSettingInfoFromUser:[[MyServer getServer] getSelfAccountInfo].username];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return data.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [data objectAtIndex:section];
    if (section == 0) {
        if (!setting.recNewMsg) {
            return 2;
        }
    }
    return array.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [data objectAtIndex:indexPath.section];
    NSDictionary *dic = [array objectAtIndex:indexPath.row];
    NSString *type = [dic objectForKey:@"type"];
    
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    if ([type isEqualToString:@"normal"]) {
        NSString *title = [dic objectForKey:@"title"];
        cell.textLabel.text = title;
        [cell setUserInteractionEnabled:YES];
        UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 6.5, 60, 37)];
        [sw addTarget:self action:@selector(switchButtonDown:) forControlEvents:UIControlEventValueChanged];
        sw.tag = indexPath.section * 10 + indexPath.row;
        if ([title isEqualToString:@"接收新消息通知"]) {
            sw.on = setting.recNewMsg;
        }
        else if ([title isEqualToString:@"通知显示消息详情"]){
            sw.on = setting.showMsgDetail;
        }
        else if ([title isEqualToString:@"声音"]) {
            sw.on = setting.audio;
        }
        else if ([title isEqualToString:@"震动"]) {
            sw.on = setting.shock;
        }
        else if ([title isEqualToString:@"夜间防打扰模式"]){
            sw.on = setting.nightModal;
        }
        
        [cell addSubview:sw];
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
        [textView setFrame:CGRectMake(15, 0, self.view.frame.size.width - 30, size.height + 20)];
        textView.textColor = [UIColor grayColor];
        textView.backgroundColor = [UIColor clearColor];
        textView.font = [UIFont systemFontOfSize:13];
        textView.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:textView];
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    if ([dic objectForKey:@"withoutLine"] != nil){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, self.view.frame.size.width / 2.0,0, self.view.frame.size.width / 2.0)];
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = [data objectAtIndex:indexPath.section];
    NSDictionary *dic = [array objectAtIndex:indexPath.row];
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
    [self.tableView reloadData];
}

#pragma mark - switch button down
- (void) switchButtonDown: (UISwitch *) sender
{
    NSArray *array = [data objectAtIndex:sender.tag / 10];
    NSDictionary *dic = [array objectAtIndex:sender.tag % 10];
    NSString *title = [dic valueForKey:@"title"];
    if ([title isEqualToString:@"接收新消息通知"]) {
        setting.recNewMsg = sender.on;
        if (setting.recNewMsg == NO) {
            setting.showMsgDetail = NO;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if ([title isEqualToString:@"通知显示消息详情"]){
        setting.showMsgDetail = sender.on;
    }
    else if ([title isEqualToString:@"声音"]) {
        setting.audio = sender.on;
    }
    else if ([title isEqualToString:@"震动"]) {
        setting.shock = sender.on;
    }
    else if ([title isEqualToString:@"夜间防打扰模式"]){
        setting.nightModal = sender.on;
    }
    [[DataCenter getDataCenter] setSettingInfo:setting toUser:[[MyServer getServer] getSelfAccountInfo].username];
}


@end
