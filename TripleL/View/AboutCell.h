//
//  AboutCell.h
//  TripleL
//
//  Created by h1r0 on 15/5/27.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "CommonTableViewCell.h"

@interface AboutCell : CommonTableViewCell
{
    CGRect RECT;
}
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *respLabel;
@property (nonatomic, strong) UILabel *majorLabel;

- (void) setAvatar: (NSString *) avatar name: (NSString *) name responsibility: (NSString *) response major: (NSString *) major;

@end
