//
//  MenuViewController.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/4.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MenuPersonPrivilegesViewController.h"
#import "MenuAppSetingViewController.h"
#import "MenuFeedbackViewController.h"
#import "MenuAboutViewController.h"

@protocol MenuViewDelegate <NSObject>

- (void) chooseItemInMenu: (NSString *) itemName;

@end

@interface MenuViewController : UIViewController

@property (nonatomic, strong) id<MenuViewDelegate>delegate;

@end
