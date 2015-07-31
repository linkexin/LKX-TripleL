//
//  ModifyMajorViewController.m
//  TripleL
//
//  Created by charles on 5/18/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyMajorViewController.h"
#import "CommonTableViewCell.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#define INDEX 12

@interface ModifyMajorViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *array;
}
@property (strong, nonatomic)UITableView *tableView;
@end

@implementation ModifyMajorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [AppConfig getBGColor];
    [[DetailInfoCenter getDetailInfoCenter]initMajorData];
    array = [DetailInfoCenter getDetailInfoCenter].majorData;
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
    cell.textLabel.text = [[array objectAtIndex:indexPath.row] objectForKey:@"title"];
    /*
    NSString *text = [[array objectAtIndex:indexPath.row] objectForKey:@"picture"];
    if(text != nil && indexPath.row != 12)
    {
        cell.imageView.image = [UIImage imageNamed:text];
        cell.imageView.frame = CGRectMake(0, 0, 1, 1);
    }
     */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *text = [[array objectAtIndex:indexPath.row] objectForKey:@"title"];
    [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
