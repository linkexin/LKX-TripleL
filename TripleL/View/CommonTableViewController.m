//
//  CommonTableViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/21.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "CommonTableViewController.h"
#import "MyHeader.h"

@interface CommonTableViewController ()

@end

@implementation CommonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[AppConfig getLineColor]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView setBackgroundColor:[AppConfig getBGColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) setNavTitle: (NSString *) title
{
    [self.navigationItem setTitle:title];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [AppConfig getBarTitleColor], NSFontAttributeName: [UIFont fontWithName:[AppConfig getTitleFont] size:18]}];
}

@end
