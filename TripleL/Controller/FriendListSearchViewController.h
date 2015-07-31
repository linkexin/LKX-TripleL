//
//  FriendListSearchViewController.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/12.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTableViewController.h"

@class TLUser;

@protocol FriendListSearchVCDelegate <NSObject>

- (void) didChooseUserItem: (TLUser *) user;
- (NSArray *) friendListSearchData;

@end

@interface FriendListSearchViewController : CommonTableViewController<UISearchResultsUpdating>

@property (nonatomic, strong) id<FriendListSearchVCDelegate>delegate;

@end
