//
//  MessageCell.m
//  TripleL
//
//  Created by 李伯坤 on 15/4/21.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MessageCell.h"
#import "MyHeader.h"

#define     FREESIZE        5
#define     TIMESIZE        35

@implementation MessageCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[AppConfig getFGColor]];
        
        RECT = frame;
        _avatarImageView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:17]];
        [_nameLabel setTextColor:[AppConfig getTitleColor]];
        _messageLabel = [[UILabel alloc] init];
        [_messageLabel setTextColor:[UIColor grayColor]];
        [_messageLabel setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:14.5]];
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setFont:[UIFont systemFontOfSize:12]];
        [_timeLabel setTextColor:[UIColor grayColor]];
        [_timeLabel setTextAlignment:NSTextAlignmentRight];
        _numberLabel = [[UILabel alloc] init];
        [_numberLabel setTextColor:[UIColor whiteColor]];
        [_numberLabel setTextAlignment:NSTextAlignmentRight];
        _numberBackgroundImageView = [[UIImageView alloc] init];
        
        [self addSubview:_avatarImageView];
        [self addSubview:_nameLabel];
        [self addSubview:_messageLabel];
        [self addSubview:_timeLabel];
        
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
        
        [_messageLabel setText:@" "];
        CGSize mSize = CGSizeMake(self.frame.size.width, MAXFLOAT);
        mSize = [_messageLabel sizeThatFits:mSize];
        
        w = frame.size.width - x - FREESIZE * 3;
        [_nameLabel setFrame:CGRectMake(x, frame.size.height / 2.0 - size.height * 1.1, w - FREESIZE * 4, size.height)];
        [_messageLabel setFrame:CGRectMake(x, frame.size.height / 2.0 * 1.15, w, mSize.height)];

        
        int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
        if (choose == 1) {
            [_nameLabel setFrame:CGRectMake(x, frame.size.height / 2.0 - size.height * 0.85, w - FREESIZE * 4, size.height)];
            [_messageLabel setFrame:CGRectMake(x, frame.size.height / 2.0 * 1.02, w, mSize.height)];
        }
        
        [_timeLabel setText:@" "];
        size = CGSizeMake(self.frame.size.width, MAXFLOAT);
        size = [_timeLabel sizeThatFits:size];
        x = frame.size.width - FREESIZE * 2 - TIMESIZE;
        [_timeLabel setFrame:CGRectMake(x, FREESIZE, TIMESIZE, size.height)];
        
        [_numberLabel setFont:[UIFont systemFontOfSize:14]];
        
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [_messageLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_numberLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void) setAvatar:(NSURL *) avatar name:(NSString *)name time:(NSString *)time message:(NSString *)message number:(NSString *)number
{
    [_avatarImageView sd_setImageWithURL:avatar placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    [_nameLabel setText:name];
    [_timeLabel setText:time];
    [_messageLabel setText:message];
    

    if (number.intValue > 0) {
        if (number.intValue >= 10) {
            [_numberLabel setText:@"+"];
        }
        else{
            [_numberLabel setText:number];
        }
        
        [self addSubview:_numberBackgroundImageView];
        [self addSubview:_numberLabel];
        
        CGSize constraintSize = CGSizeMake(RECT.size.width, MAXFLOAT);
        CGSize size = [_numberLabel sizeThatFits:constraintSize];
        
        float x = RECT.size.width - size.width - 2;
        float y = RECT.size.height / 2.0 - size.height / 2.0;
        
  
        [_numberLabel setFrame:CGRectMake(x, y, size.width, size.height)];
        
        [_numberBackgroundImageView setFrame:CGRectMake(x - 6, y, size.width + 8, size.height)];
        _numberBackgroundImageView.image = [UIImage imageNamed:@"red_item.png"];
    }
    else{
        [_numberLabel removeFromSuperview];
        [_numberBackgroundImageView removeFromSuperview];
    }

   
}

@end
