//
//  PromptView.m
//  TripleL
//
//  Created by h1r0 on 15/5/27.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "PromptView.h"
#import "AppConfig.h"

@interface PromptView ()
{
    CGRect rect;
    CGRect rectStart;
    CGRect rectEnd;
}

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation PromptView

- (id) initWithFrame:(CGRect)frame
{
    rect = frame;
    rectStart = CGRectMake(-frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
    rectEnd = CGRectMake(frame.size.width, frame.origin.y, frame.size.width, frame.size.height);
    
    if (self = [super initWithFrame:rectStart]) {
        [self setBackgroundColor:[AppConfig getStatusBarColor]];
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.8, frame.size.height)];
        [_textView setBackgroundColor:[UIColor clearColor]];
        [_textView setTextColor:[AppConfig getTitleColor]];
        [_textView setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:14]];
        [self addSubview:_textView];
        _button = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width * 0.8, 0, frame.size.width * 0.2, frame.size.height)];
        [_button setBackgroundColor:[UIColor redColor]];
        [_button.titleLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:16]];
        [_button addTarget:self action:@selector(buttonDown) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_button];
    }
    return self;
}

- (void) showMessage: (NSString *) message buttonTitle: (NSString *) btnTitle
{
    self.show = YES;
    [_textView setText: message];
    [_button setTitle:btnTitle forState:UIControlStateNormal];
    [self setFrame:rectStart];
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:rect];
    }];
}

- (void) hidden
{
    self.show = NO;
    [UIView animateWithDuration:0.5 animations:^{
        [self setFrame:rectEnd];
    }];
}

- (void) buttonDown
{
    [self.delegate promptViewButtonDown:self];
}

@end
