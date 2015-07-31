//
//  FriendListCell.m
//  TripleL
//
//  Created by h1r0 on 15/4/14.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MapFriendListCell.h"
#import "MyHeader.h"
#import "UIImageView+WebCache.h"


@implementation MapFriendListCell

- (void) setUsername:(NSString *)username avatar:(NSURL *)avatarURL
{
 
    [_usernameLabel setText:username];

    [_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width / 8;
}


@end
