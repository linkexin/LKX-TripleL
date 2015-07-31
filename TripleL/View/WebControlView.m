//
//  WebControlView.m
//  TripleL
//
//  Created by h1r0 on 15/5/24.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "WebControlView.h"
#define     FONTSIZE        16

@implementation WebControlView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE]];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton addTarget:self.delegate action:@selector(closeButtonDown) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_closeButton];
        
        _backButton = [[UIButton alloc] init];
        [_backButton.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE]];
        [_backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"后退" forState:UIControlStateNormal];
        [_backButton addTarget:self.delegate action:@selector(backButtonDown) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_backButton];
        
        _preButton = [[UIButton alloc] init];
        [_preButton.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE]];
        [_preButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_preButton setTitle:@"前进" forState:UIControlStateNormal];
        [_preButton addTarget:self.delegate action:@selector(preButtonDown) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_preButton];
        
        _homeButton = [[UIButton alloc] init];
        [_homeButton.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE]];
        [_homeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_homeButton setTitle:@"主页" forState:UIControlStateNormal];
        [_homeButton addTarget:self.delegate action:@selector(homeButtonDown) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_homeButton];
        
        _refreshButton = [[UIButton alloc] init];
        [_refreshButton.titleLabel setFont:[UIFont systemFontOfSize:FONTSIZE]];
        [_refreshButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_refreshButton setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshButton addTarget:self.delegate action:@selector(refreshButtonDown) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_refreshButton];
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    float w = frame.size.width / 5;
    float h = frame.size.height;
    [_backButton setFrame:CGRectMake(0, 0, w, h)];
    [_preButton setFrame:CGRectMake(w, 0, w, h)];
    [_homeButton setFrame:CGRectMake(w * 2, 0, w, h)];
    [_refreshButton setFrame:CGRectMake(w * 3, 0, w, h)];
    [_closeButton setFrame:CGRectMake(w * 4, 0, w, h)];
}



@end
