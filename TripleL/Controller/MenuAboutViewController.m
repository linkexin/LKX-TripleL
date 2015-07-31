//
//  MenuAboutViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/5.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MenuAboutViewController.h"
#import "MyHeader.h"
#import "AboutCell.h"

#define         CELL_HEIGHT         60

@interface MenuAboutViewController ()
{
    NSMutableArray *data;
}


@end

@implementation MenuAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavTitle:@"关于应用"];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setTableFooterView:view];
    [self.tableView setBackgroundColor:[AppConfig getBGColor]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"plist"];
    data = [[NSMutableArray alloc] initWithContentsOfFile:path];

    [self.view setBackgroundColor:[AppConfig getBGColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return data.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [data objectAtIndex:section];
    return array.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        [cell setBackgroundColor:[AppConfig getFGColor]];
        float y = 15;
        UIImageView *nameImageView = [[UIImageView alloc] init];
        [nameImageView setImage:[UIImage imageNamed:@"xunmi.png"]];
        [nameImageView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 128) / 2.0, y, 128, 64)];
        [cell addSubview: nameImageView];
        
        y += 64 + 15;
        UILabel *label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14]];
        [label setTextColor:[UIColor grayColor]];
        [label setText:@"v1.0  于2015年参加中国软件杯作品"];
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        [label setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - size.width) / 2.0, y, size.width, size.height)];
        [cell addSubview:label];
        
        return cell;
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        else{
            NSArray *array = [data objectAtIndex:indexPath.section];
            NSDictionary *dic = [array objectAtIndex:indexPath.row];
            AboutCell *cell = [[AboutCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
            NSString *avatar = [dic objectForKey:@"avatar"];
            NSString *name = [dic objectForKey:@"name"];
            NSString *major = [dic objectForKey:@"major"];
            NSString *responsibility = [dic objectForKey:@"responsibility"];
            [cell setAvatar:avatar name:name responsibility:responsibility major:major];
            return cell;
        }
    }
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setUserInteractionEnabled:NO];
            return cell;
        }
        else {
            NSArray *array = [data objectAtIndex:indexPath.section];
            NSDictionary *dic = [array objectAtIndex:indexPath.row];
            AboutCell *cell = [[AboutCell alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT)];
            NSString *avatar = [dic objectForKey:@"avatar"];
            NSString *name = [dic objectForKey:@"name"];
            NSString *major = [dic objectForKey:@"major"];
            NSString *responsibility = [dic objectForKey:@"responsibility"];
            [cell setAvatar:avatar name:name responsibility:responsibility major:major];
            return cell;
        }
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 120;
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            return 20;
        }
        return CELL_HEIGHT;
    }
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            return 20;
        }
        return CELL_HEIGHT;
    }
    
    return 30;
}

@end
