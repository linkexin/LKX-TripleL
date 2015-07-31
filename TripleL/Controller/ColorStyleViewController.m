//
//  ColorStyleViewController.m
//  TripleL
//
//  Created by 李伯坤 on 15/5/20.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "ColorStyleViewController.h"
#import "CommonTableViewCell.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "MyHeader.h"

@interface ColorStyleViewController ()
{
    NSArray *data;
}

@end

@implementation ColorStyleViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"颜色方案"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    
    data = [AppConfig getColorStyleArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommonTableViewCell *cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"";
        [cell setUserInteractionEnabled:NO];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    else{
        NSDictionary *dic = [data objectAtIndex:indexPath.row - 1];
        NSString *title = [dic objectForKey:@"title"];
        cell.textLabel.text = title;
        [cell setUserInteractionEnabled:YES];
    }
    
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    if (indexPath.row - 1 == choose) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        return 20;
    }
    
    return 45;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue == indexPath.row - 1) {
        return;
    }
    SCLAlertView *alertView = [[SCLAlertView alloc] init];
    [alertView addButton:@"确定并重启" actionBlock:^{
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", (int)(indexPath.row - 1)] forKey:@"colorStyle"];
        MBProgressHUD *mb = [[MBProgressHUD alloc] init];
        [self.tabBarController.view addSubview:mb];
        [mb setLabelText:@"请稍候"];
        [mb setDetailsLabelText:@"正在保存设置"];
        [mb showAnimated:YES whileExecutingBlock:^{
            
        } completionBlock:^{
            exit(0);
        }];
        [mb hide:YES afterDelay:10];
    }];
    [alertView showInfo:self.tabBarController title:@"重要提示" subTitle:@"修改配色方案需要重启应用哦" closeButtonTitle:@"取消" duration:0];
    [self.tableView reloadData];
}

@end
