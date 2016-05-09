//
//  FriendListCell.m
//  TripleL
//
//  Created by h1r0 on 15/4/22.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "FriendListCell.h"
#import "MyHeader.h"

#define     FREESIZE        5

@interface FriendListCell ()
{
    CGRect rect;
}

@end

@implementation FriendListCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        rect = frame;
        [self setBackgroundColor:[AppConfig getFGColor]];
        
        _avatarImageView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:16]];
        [_nameLabel setTextColor:[AppConfig getTitleColor]];
        _moodLabel = [[UILabel alloc] init];
        [_moodLabel setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:12]];
        [_moodLabel setTextColor:[AppConfig getTitleColor]];
        [_moodLabel setAlpha:0.6];
        
        _ageLabel = [[UILabel alloc] init];
        [_ageLabel setBackgroundColor:[AppConfig getStatusBarColor]];
        [_ageLabel setTextColor:[UIColor whiteColor]];
        [_ageLabel setTextAlignment:NSTextAlignmentCenter];
        [_ageLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:11]];
        _genderImageView = [[UIImageView alloc] init];
        _fadeLabel = [[UILabel alloc] init];
        [_fadeLabel setTextColor:[UIColor colorWithRed:254.0/ 255.0 green:67.0/255.0 blue:101.0/255.0 alpha:1.0]];
        [_fadeLabel setTextAlignment:NSTextAlignmentCenter];
        [_fadeLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:11]];
        
        _statusAndDistanceLabel = [[UILabel alloc] init];
        [_statusAndDistanceLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:11]];
        [_statusAndDistanceLabel setTextColor:[AppConfig getDetailColor]];
        
        [self addSubview:_avatarImageView];
        [self addSubview:_nameLabel];
        [self addSubview:_moodLabel];
        [self addSubview:_statusAndDistanceLabel];
        
        [self addSubview:_ageLabel];
        [self addSubview:_genderImageView];
        [self addSubview:_fadeLabel];
    }
    
    return self;
}

- (void) setFriendInfo:(TLUser *)info
{
    if([info.status isEqualToString: USER_ONLINE]){
        [_statusAndDistanceLabel setText:[NSString stringWithFormat:@"%@km|在线", info.distance]];
    }
    else if([info.status isEqualToString: USER_OFFLINE]){
        [_statusAndDistanceLabel setText:[NSString stringWithFormat:@"%@km|离线", info.distance]];
    }
    
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:info.avatar] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    
    [_moodLabel setText:info.mood];
    [_nameLabel setText:info.remarkName == nil ? info.nickname : info.remarkName];
    [_ageLabel setText:info.age == nil ? @"" :[NSString stringWithFormat:@"年龄: %@", info.age]];
    
    if (info.credit == nil){
        [_fadeLabel setText: @""];
    }
    else{
        NSString *str = @"";
        for (int i = 0; i < info.credit.intValue; i ++) {
            str = [NSString stringWithFormat:@"%@★", str];
        }
        [_fadeLabel setText:str];
    }
    [_genderImageView setImage: [info.gender isEqualToString:@"m"] ? [UIImage imageNamed:@"male.png"] : [UIImage imageNamed:@"female.png"]];

    float x = FREESIZE * 2.3;
    float h = rect.size.height - FREESIZE * 2;
    [_avatarImageView setFrame:CGRectMake(x, FREESIZE, h, h)];
    _avatarImageView.layer.cornerRadius = h / 2.0;
    _avatarImageView.layer.masksToBounds = YES;
    
    x += h + FREESIZE * 1.8;
    float w = rect.size.width - x;
    float y;
    
    CGSize size = [_statusAndDistanceLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
    [_statusAndDistanceLabel setFrame:CGRectMake(rect.size.width - FREESIZE - size.width, FREESIZE, size.width, size.height)];

    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
    if (choose != 0) {
        // 用户昵称
        size = [_nameLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        y = rect.size.height * 0.125;
        [_nameLabel setFrame:CGRectMake(x, y, size.width, size.height)];
        
        // 用户信息
        float start = x + 1;
        y += size.height + FREESIZE;
        size = [_ageLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        [_ageLabel setFrame:CGRectMake(start, y, size.width + 5, size.height + 1)];
        start += size.width + 5 + 8;
        [_genderImageView setFrame:CGRectMake(start, y + 0.5, size.height - 1, size.height - 1)];
        start += size.height + 3;
        size = [_fadeLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        [_fadeLabel setFrame:CGRectMake(start, y - 0.5 , size.width + 5, size.height + 1)];
        
        // 用户签名
        size = [_moodLabel sizeThatFits: CGSizeMake(rect.size.width, MAXFLOAT)];
        y = rect.size.height - size.height - FREESIZE * 1.7;
        [_moodLabel setFrame:CGRectMake(x - 0.5, y, w, size.height)];
    }
    else {
        // 用户昵称
        size = [_nameLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        y = rect.size.height * 0.06;
        [_nameLabel setFrame:CGRectMake(x, y, size.width, size.height)];
        
        // 用户信息
        float start = x + 1;
        y += size.height + FREESIZE * 0.1;
        size = [_ageLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        [_ageLabel setFrame:CGRectMake(start, y, size.width + 5, size.height)];
        start += size.width + 5 + 8;
        [_genderImageView setFrame:CGRectMake(start, y + 0.5, size.height - 1, size.height)];
        start += size.height + 3;
        size = [_fadeLabel sizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        [_fadeLabel setFrame:CGRectMake(start, y - 0.5 , size.width + 5, size.height)];
        
        // 用户签名
        size = [_moodLabel sizeThatFits: CGSizeMake(rect.size.width, MAXFLOAT)];
        y = rect.size.height - size.height - FREESIZE ;
        [_moodLabel setFrame:CGRectMake(x - 0.5, y, w, size.height)];
    }

}


@end
