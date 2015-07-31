//
//  MenuInfoCell.m
//  TripleL
//
//  Created by 李伯坤 on 15/5/4.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MenuInfoCell.h"
#import "MyHeader.h"
#import "UIImageView+WebCache.h"

@implementation MenuInfoCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.avatarView = [[UIImageView alloc] init];
        self.avatarView.layer.masksToBounds = YES;
        self.nicknameLabel = [[UILabel alloc] init];
        [self.nicknameLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.avatarView];
        [self addSubview:self.nicknameLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self.nicknameLabel setTextColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    float h = frame.size.width * 0.6;
    float x = (frame.size.width - h) * 0.5;
    [self.avatarView setFrame:CGRectMake(x, 5, h, h)];
    self.avatarView.layer.cornerRadius = h * 0.5;
    
    float height = frame.size.height - h - 5;
    float y = h + height * 0.3;
    
    [self.nicknameLabel setFrame:CGRectMake(0, y, frame.size.width, height * 0.6)];
}

- (void) setAvatar:(NSString *)path nickname:(NSString *)nickname
{
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed: DEFAULT_AVATARPATH]];
    [self.nicknameLabel setText:nickname];
}

@end
