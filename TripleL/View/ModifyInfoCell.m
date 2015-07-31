//
//  ModifyInfoCell.m
//  TripleL
//
//  Created by charles on 5/15/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyInfoCell.h"
#import "UIImageView+WebCache.h"
#import "MyHeader.h"
#define AVATAR_LENGTH 50


@interface ModifyInfoCell()
@property (strong, nonatomic)UILabel *title;
@property (strong, nonatomic)UILabel *info;

@end

@implementation ModifyInfoCell

- (void)awakeFromNib {

}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setBackgroundColor:[AppConfig getFGColor]];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _title = [[UILabel alloc]initWithFrame: CGRectZero];
        _title.textAlignment = NSTextAlignmentRight;
        _title.backgroundColor = [UIColor clearColor];
        [_title setFont:[UIFont systemFontOfSize:18]];
        
        _info = [[UILabel alloc]initWithFrame: CGRectZero];
        [_info setMinimumScaleFactor:18];
        _info.textAlignment = NSTextAlignmentLeft;
        _info.backgroundColor = [UIColor clearColor];
        _info.lineBreakMode = NSLineBreakByWordWrapping;
        _info.numberOfLines = 0;
        _info.backgroundColor = [AppConfig getFGColor];
        
        [[self contentView] addSubview:_title];
        [[self contentView] addSubview:_info];
    }
    return self;
}


-(void)addPhoto:(NSString *)phohoPath local:(NSString *)localPhoto withRect:(CGRect)rect
{
    UIImageView *avatar = [[UIImageView alloc]initWithFrame:rect];
    if(localPhoto != nil)
        [avatar sd_setImageWithURL:[NSURL URLWithString:phohoPath] placeholderImage:[UIImage imageNamed:localPhoto]];
    avatar.layer.cornerRadius = rect.size.width / 5.0;
    avatar.layer.masksToBounds = YES;
    [_info addSubview:avatar];
}

-(void)setCellWithtitle:(NSString *)title andinfo:(NSString *)info titlelocation:(CGRect)titleRect infolocation:(CGRect)infoRect
{
    _title.text = title;
    _info.text = info;
    _title.frame = titleRect;
    _info.frame = infoRect;
}

@end
