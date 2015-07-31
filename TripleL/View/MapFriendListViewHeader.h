//
//  FriendListViewHeader.h
//  TripleL
//
//  Created by h1r0 on 15/4/15.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFriendListViewHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

- (void) setText: (NSString *)test;


@end
