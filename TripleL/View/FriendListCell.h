//
//  FriendListCell.h
//  TripleL
//
//  Created by h1r0 on 15/4/22.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@class TLUser;

@interface FriendListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *moodLabel;
@property (nonatomic, strong) UILabel *statusAndDistanceLabel;

@property (nonatomic, strong) UILabel *ageLabel;
@property (nonatomic, strong) UIImageView *genderImageView;
@property (nonatomic, strong) UILabel *fadeLabel;

- (void) setFriendInfo: (TLUser *) info;


@end
