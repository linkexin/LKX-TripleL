//
//  AboutCell.m
//  TripleL
//
//  Created by h1r0 on 15/5/27.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "AboutCell.h"
#import "MyHeader.h"

#define     FREESIZE        5
#define     TIMESIZE        200

@implementation AboutCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[AppConfig getFGColor]];
        
        RECT = frame;
        _avatarImageView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:17]];
        [_nameLabel setTextColor:[AppConfig getTitleColor]];
        _majorLabel = [[UILabel alloc] init];
        [_majorLabel setTextColor:[UIColor grayColor]];
        [_majorLabel setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:14.5]];
        _respLabel = [[UILabel alloc] init];
        [_respLabel setFont:[UIFont systemFontOfSize:12]];
        [_respLabel setTextColor:[UIColor grayColor]];
        [_respLabel setTextAlignment:NSTextAlignmentRight];

        
        [self addSubview:_avatarImageView];
        [self addSubview:_nameLabel];
        [self addSubview:_majorLabel];
        [self addSubview:_respLabel];
        
        float x = FREESIZE * 2.2;
        float h = frame.size.height - FREESIZE * 2;
        [_avatarImageView setFrame:CGRectMake(x, FREESIZE, h, h)];
        _avatarImageView.layer.cornerRadius = h / 2.0;
        _avatarImageView.layer.masksToBounds = YES;
        
        x += h + FREESIZE * 1.5;
        float w = frame.size.width - TIMESIZE - x;
        
        [_nameLabel setText:@" "];
        CGSize size = CGSizeMake(self.frame.size.width, MAXFLOAT);
        size = [_nameLabel sizeThatFits:size];
        h = frame.size.height * 0.5;
        
        [_majorLabel setText:@" "];
        CGSize mSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
        mSize = [_majorLabel sizeThatFits:mSize];
        
        w = frame.size.width - x - FREESIZE * 3;
        [_nameLabel setFrame:CGRectMake(x, frame.size.height / 2.0 - size.height * 1.1, w - FREESIZE * 4, size.height)];
        [_majorLabel setFrame:CGRectMake(x, frame.size.height / 2.0 * 1.15, w, mSize.height)];
        
        
        int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
        if (choose == 1) {
            [_nameLabel setFrame:CGRectMake(x, frame.size.height / 2.0 - size.height * 0.85, w - FREESIZE * 4, size.height)];
            [_majorLabel setFrame:CGRectMake(x, frame.size.height / 2.0 * 1.02, w, mSize.height)];
        }
        
        [_respLabel setText:@" "];
        [_respLabel setTextAlignment:NSTextAlignmentRight];
        size = [_respLabel sizeThatFits:CGSizeMake(self.frame.size.width, MAXFLOAT)];
        x = frame.size.width - FREESIZE * 2 - TIMESIZE;
        [_respLabel setFrame:CGRectMake(x, FREESIZE, TIMESIZE, size.height)];
        
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_majorLabel setBackgroundColor:[UIColor clearColor]];
        [_respLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (void) setAvatar: (NSString *) avatar name: (NSString *) name responsibility: (NSString *) response major: (NSString *) major
{
    [_avatarImageView setImage:[UIImage imageNamed:avatar]];
    [_nameLabel setText:name];
    [_respLabel setText:response];
    [_majorLabel setText: major];
}


@end
