//
//  ModifyQGZKViewController.m
//  TripleL
//
//  Created by charles on 5/18/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyQGZKViewController.h"
#import "CommonTableViewCell.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#define INDEX 6

@interface ModifyQGZKViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSArray *array;
}
@property (strong, nonatomic)UITableView *tableView;
@end

@implementation ModifyQGZKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [AppConfig getBGColor];
    array = [NSArray arrayWithObjects:@"保密", @"单身", @"恋爱中",@"已婚", @"同性", nil];
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_tableView setTableFooterView:view];
    
    [self.view addSubview:_tableView];
    [self orientChange:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientChange:(NSNotification *)noti
{
    _tableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
}

#pragma mark - tableview
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [array count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"modifyInfoCell";
    
    CommonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CommonTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [array objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:[array objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
