//
//  DetailDataCell.m
//  TripleL
//
//  Created by charles on 5/13/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "DetailDataCell.h"
#import "AppConfig.h"
#define FONT_SIZE 17.0f
#define LABLE_CONTENT_MARGIN_Y 8.0f
#define LABLE_CONTENT_MARGIN_X 30


@interface DetailDataCell ()
{
    CGRect rect;
}

@end

@implementation DetailDataCell

- (id) initWithFrame:(CGRect)frame
{
    rect = frame;
    if (self = [super initWithFrame:frame]){
        [self setBackgroundColor:[AppConfig getFGColor]];
        
        _titleTextView = [[UITextView alloc] init                                                                                      ];
        _titleTextView.textAlignment = NSTextAlignmentRight;
        _titleTextView.multipleTouchEnabled = YES;
        _titleTextView.scrollEnabled = NO;
        [_titleTextView setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:FONT_SIZE]];
        _titleTextView.returnKeyType = UIReturnKeyDefault;
        _titleTextView.delegate = self;
        [_titleTextView setBackgroundColor:[UIColor clearColor]];
       
        
        _detailTextView = [[UITextView alloc]init];
        _detailTextView.backgroundColor = [UIColor clearColor];
        _detailTextView.multipleTouchEnabled = YES;
        _detailTextView.scrollEnabled = NO;
        _detailTextView.delegate = self;
        [_detailTextView setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:FONT_SIZE]];
        [_detailTextView setTag:1];
        
        [[self contentView] addSubview:_titleTextView];
        [[self contentView] addSubview:_detailTextView ];
    }
    return self;
}

-(void)setupCellwithTitle: (NSString *)title detail:(NSString *)detail
{
    _titleTextView.text = title;
    _detailTextView.text = [NSString stringWithFormat:@"%@", detail];
    CGSize size = [_titleTextView sizeThatFits:CGSizeMake(rect.size.width * 0.3, MAXFLOAT)];
    [_titleTextView setFrame:CGRectMake(rect.size.width * 0.04, (rect.size.height - size.height) / 2.0, rect.size.width * 0.3, size.height)];
    size = [_detailTextView sizeThatFits:CGSizeMake(rect.size.width * 0.6, MAXFLOAT)];
    [_detailTextView  setFrame:CGRectMake(rect.size.width * 0.37, (rect.size.height - size.height) / 2.0, rect.size.width * 0.6, size.height)];
}

@end
