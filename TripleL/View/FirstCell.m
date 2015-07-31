//
//  FirstCell.m
//  TripleL
//
//  Created by charles on 5/22/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "MyHeader.h"
#import "FirstCell.h"
#import "UIImageView+WebCache.h"

@interface FirstCell ()
{
    CGRect selfRect;
}

@property (strong, nonatomic) UIImageView *avatarImage;
@property (strong, nonatomic) UILabel *titleLabel;

@property (strong, nonatomic) UILabel *genderLabel;
@property (strong, nonatomic) UIImageView *genderView;
@property (strong, nonatomic) UILabel *remarkName;

@property (strong, nonatomic) UILabel *fadeLabel;

@end

@implementation FirstCell

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[AppConfig getFGColor]];
        selfRect = frame;
        self.avatarImage = [[UIImageView alloc] init ];
        self.avatarImage.layer.cornerRadius = 50;
        self.avatarImage.layer.masksToBounds = YES;
        self.avatarImage.layer.borderWidth = 3;
        self.avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;
        self.avatarImage.clipsToBounds = YES;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:23];
        
        _remarkName = [[UILabel alloc] init];
        [_remarkName setTextColor:[UIColor grayColor]];
        _remarkName.textAlignment = NSTextAlignmentLeft;
        _remarkName.font = [UIFont boldSystemFontOfSize:15];
        _remarkName.backgroundColor = [UIColor clearColor];
        
        _genderLabel = [[UILabel alloc]init];
        _genderView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
        
        _fadeLabel = [[UILabel alloc] init];
        [_fadeLabel setTextColor:[UIColor colorWithRed:254.0/ 255.0 green:67.0/255.0 blue:101.0/255.0 alpha:1.0]];
        [_fadeLabel setTextAlignment:NSTextAlignmentLeft];
        [_fadeLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:11]];
        
        self.avatarImage.layer.cornerRadius = 10;
        self.avatarImage.layer.borderWidth = 3;
        self.avatarImage.layer.borderColor = [UIColor whiteColor].CGColor;

        [[self contentView] addSubview:_fadeLabel];
        [[self contentView] addSubview:_avatarImage];
        [[self contentView] addSubview:_titleLabel];
        [[self contentView] addSubview:_genderLabel];
        [_genderLabel addSubview:_genderView];
    }
    return self;
}


- (void)SetTableViewWithAvatar:(NSString *)avatar username:(NSString *)userName remarkName:(NSString *)remarkString gender:(NSString *)gender star: (int) star isSelf:(BOOL)isself
{
    _titleLabel.text = userName;
    if([gender isEqualToString:@"m"])
        _genderView.image = [UIImage imageNamed:@"male.png"];
    else
        _genderView.image = [UIImage imageNamed:@"female.png"];
    [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    
    NSString *str = @"";
    for (int i = 0; i < star; i ++) {
        str = [NSString stringWithFormat:@"%@★", str];
    }
    [_fadeLabel setText:str];
    
    float x = selfRect.size.height * 0.2;
    float y = selfRect.size.height * 0.1;
    float w = selfRect.size.height * 0.8;
    self.avatarImage.frame = CGRectMake(x, y, w, w);
    
    x += w + 10;
    w = selfRect.size.width - x - 20;
    y += 2;
    _titleLabel.frame = CGRectMake(x, y, w, 25);
    
    y += 25 + 5;
    
    if(remarkString != nil)
    {
        [self addSubview:_remarkName];
        _remarkName.frame = CGRectMake(x, y, w, 20);
        y += 27;
        _genderLabel.frame = CGRectMake(x, y, 15, 15);
        _fadeLabel.frame = CGRectMake(x + 20, y, 100, 15);
        _remarkName.text = [NSString stringWithFormat:@"备注：%@", remarkString];
    }
    else
    {
        [_remarkName removeFromSuperview];
        _genderLabel.frame = CGRectMake(x, y, 15, 15);
        _fadeLabel.frame = CGRectMake(x + 20, y, 100, 15);
    }
}

@end
