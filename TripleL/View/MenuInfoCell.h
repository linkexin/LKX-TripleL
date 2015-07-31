//
//  MenuInfoCell.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/4.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuInfoCell : UITableViewCell
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nicknameLabel;

- (void) setAvatar: (NSString *) path nickname: (NSString *) nickname;

@end
