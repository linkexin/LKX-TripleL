//
//  CommonGameViewController.m
//  TripleL
//
//  Created by h1r0 on 15/5/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "CommonGameViewController.h"
#import "MyHeader.h"

@interface CommonGameViewController ()

@end

@implementation CommonGameViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void) startGame
{

}

- (void) setNavTitle: (NSString *) title
{
    [self.navigationItem setTitle:title];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [AppConfig getBarTitleColor], NSFontAttributeName: [UIFont fontWithName:[AppConfig getTitleFont] size:18]}];
}

@end
