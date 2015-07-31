//
//  MessageCell.h
//  TripleL
//
//  Created by 李伯坤 on 15/4/21.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface MessageCell : CommonTableViewCell
{
    CGRect RECT;
}
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *numberBackgroundImageView;
@property (nonatomic, strong) UILabel *numberLabel;

- (void) setAvatar: (NSURL *) avatar name: (NSString *) name time: (NSString *) time message: (NSString *) message number: (NSString *)number;

@end
