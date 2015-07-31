//
//  ViewController.h
//  ChatView
//
//  Created by h1r0 on 15/4/26.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "SOMessagingViewController.h"

@class TLUser;

@interface ChatViewController : SOMessagingViewController

@property (nonatomic, strong) TLUser *selfUser;
@property (nonatomic, strong) TLUser *friendUser;
@property (strong, nonatomic) NSMutableArray *dataSource;

+ (ChatViewController *) getChatViewController;

@end

