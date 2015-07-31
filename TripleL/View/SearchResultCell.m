//
//  SearchResultCell.m
//  TripleL
//
//  Created by 李伯坤 on 15/5/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "SearchResultCell.h"
#import "UIImageView+WebCache.h"
#import "MyHeader.h"

@implementation SearchResultCell

#define     FREESIZE        5

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[AppConfig getFGColor]];
        
        _avatarImageView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:15]];
        [_nameLabel setTextColor:[AppConfig getTitleColor]];
        _moodLabel = [[UILabel alloc] init];
        [_moodLabel setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:13]];
        [_moodLabel setTextColor:[AppConfig getTitleColor]];
        [_moodLabel setAlpha:0.6];
        
        [self addSubview:_avatarImageView];
        [self addSubview:_nameLabel];
        [self addSubview:_moodLabel];
        
        float x = FREESIZE * 2.3;
        float h = frame.size.height - FREESIZE * 3;
        [_avatarImageView setFrame:CGRectMake(x, FREESIZE * 1.5, h, h)];
        _avatarImageView.layer.cornerRadius = h / 2.0;
        _avatarImageView.layer.masksToBounds = YES;
        
        x += h + FREESIZE * 1.8;
        float w = frame.size.width - x;
        h = frame.size.height * 0.5;
        
        [_nameLabel setText:@" "];
        CGSize size = CGSizeMake(self.frame.size.width, MAXFLOAT);
        size = [_nameLabel sizeThatFits:size];
        
        
        [_moodLabel setText:@" "];
        CGSize mSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
        mSize = [_moodLabel sizeThatFits:mSize];
        
        w = frame.size.width - FREESIZE ;
        int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
        if (choose == 0) {
            [_nameLabel setFrame:CGRectMake(x, frame.size.height / 2.0 - size.height * 1.1, w - FREESIZE, size.height)];
            [_moodLabel setFrame:CGRectMake(x, frame.size.height / 2.0 * 1.16, w, mSize.height)];
        }
        else if (choose == 1) {
            [_nameLabel setFrame:CGRectMake(x, frame.size.height / 2.0 - size.height * 0.85, w - FREESIZE, size.height)];
            [_moodLabel setFrame:CGRectMake(x, frame.size.height / 2.0 * 1.05, w, mSize.height)];
        }
    }
    
    return self;
}

- (void) setAvatar: (NSURL *) avatarURL name: (NSString *) name nikename: (NSString *) nikename mood: (NSString *) mood
{    
    [_avatarImageView sd_setImageWithURL:avatarURL placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    [_nameLabel setText:[NSString stringWithFormat:@"%@ (%@)", nikename, name]];
    [_moodLabel setText:mood];
}
@end
