//
//  MakeFriendCell.m
//  TripleL
//
//  Created by h1r0 on 15/5/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MakeFriendCell.h"
#import "MyHeader.h"

@interface MakeFriendCell ()
{
    CGRect curRect;
}

@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UILabel *titleL;

@end

@implementation MakeFriendCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[AppConfig getFGColor]];
        curRect = frame;
        _imageV = [[UIImageView alloc] init];
        [self addSubview:_imageV];
        _titleL = [[UILabel alloc] init];
        [_titleL setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:16.5]];
        [self addSubview:_titleL];
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (void) setImage:(UIImage *)image andTitle:(NSString *)title
{
    [_imageV setImage:image];
    [_titleL setText:title];
    
    float x = curRect.size.width * 0.05;
    float y = curRect.size.height * 0.2;
    float w = curRect.size.height * 0.6;
    float h = w;
    [_imageV setFrame:CGRectMake(x, y, w, h)];
    
    x = w + x * 2;
    w = curRect.size.width - x;
    
    float sh = [_titleL sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    y = (curRect.size.height - sh) / 2 - 0.5;
    [_titleL setFrame:CGRectMake(x, y, w, sh)];
}

@end
