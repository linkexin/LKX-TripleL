//
//  DetailInfoCell.m
//  TripleL
//
//  Created by charles on 4/29/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "DetailInfoCell.h"
#define FONT_SIZE 17.0f
#define LABLE_CONTENT_MARGIN 15.0f

@interface DetailInfoCell()



@end

@implementation DetailInfoCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setUpCell];
        
    }
    return self;
}


-(void)setUpCell
{
    _titleLable = [[UILabel alloc]initWithFrame: CGRectMake(LABLE_CONTENT_MARGIN, LABLE_CONTENT_MARGIN, 100, 30)];
    
    _detailLable = [[UILabel alloc]initWithFrame: CGRectZero];
    [_detailLable setLineBreakMode:NSLineBreakByWordWrapping];
    [_detailLable setMinimumScaleFactor:FONT_SIZE];
    [_detailLable setNumberOfLines:0];
    [_detailLable setFont:[UIFont systemFontOfSize:FONT_SIZE]];
    [_detailLable setTag:1];
    
    [[self contentView] addSubview:_titleLable];
    [[self contentView] addSubview:_detailLable];
}

-(void)setupCellwithTitle: (NSString *)title detail:(NSString *)detail
{
    _titleLable.text = title;
    _detailLable.text = detail;
}

@end
