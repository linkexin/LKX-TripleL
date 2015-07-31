//
//  JSMessageInputView.m
//
//  Created by Jesse Squires on 2/12/13.
//  Copyright (c) 2013 Hexed Bits. All rights reserved.
//
//  http://www.hexedbits.com
//
//
//  Largely based on work by Sam Soffes
//  https://github.com/soffes
//
//  SSMessagesViewController
//  https://github.com/soffes/ssmessagesviewcontroller
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//  associated documentation files (the "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
//  following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
//  LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
//  OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "JSMessageInputView.h"
#import "AppConfig.h"
#define SEND_BUTTON_WIDTH 78.0f


@interface JSMessageInputView ()

- (void)setup;
- (void)setupTextView;
- (void)setupRecordButton;
@end



@implementation JSMessageInputView
{
    UIImageView *line;
}

@synthesize sendButton;

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame delegate:(id<JSMessageInputViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
        _delegate = delegate;
        [self setAutoresizesSubviews:NO];
        
        CGSize size = [UIScreen mainScreen].bounds.size;
        [line setFrame:CGRectMake(0, 0, size.width, 0.5)];
        self.voiceButton.frame = CGRectMake(10, 9.0, 28.0f, 28.0f);
        self.showUtilitysbutton.frame=CGRectMake(size.width - 36, 9.0f, 28.0f, 28.0f);
        self.emotionbutton.frame = CGRectMake(size.width - 72, 9.0f, 28.0f, 28.0f);
        CGFloat height = [JSMessageInputView textViewLineHeight];
        CGRect rect = CGRectMake(48, 7.0f, size.width - 80 - 50, height);
        self.textView.frame = rect;
        self.recordButton.frame = rect;
    }
    return self;
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [line setFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
    
    self.voiceButton.frame = CGRectMake(10, 9.0, 28.0f, 28.0f);

    self.showUtilitysbutton.frame=CGRectMake(frame.size.width - 36, 9.0f, 28.0f, 28.0f);
    self.emotionbutton.frame = CGRectMake(frame.size.width - 72, 9.0f, 28.0f, 28.0f);
    
    CGFloat height = [JSMessageInputView textViewLineHeight];
    CGRect rect = CGRectMake(48, 7.0f, frame.size.width - 80 - 50, height);
    self.textView.frame = rect;
    self.recordButton.frame = rect;
}

- (void)dealloc
{
    self.textView = nil;
    self.sendButton = nil;
}

- (BOOL)resignFirstResponder
{
    [self.textView resignFirstResponder];
    return [super resignFirstResponder];
}

+ (JSInputBarStyle)inputBarStyle
{
    return JSInputBarStyleDefault;
}
- (UIImage *)inputBar
{
    if ([JSMessageInputView inputBarStyle] == JSInputBarStyleFlat)
        return [UIImage imageNamed:@"input-bar-flat"];
    else      // jSInputBarStyleDefault
        return [[UIImage imageNamed:@"input-bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)];
}
#pragma mark - Setup
- (void)setup
{
    self.image = [self inputBar];
    self.backgroundColor = [UIColor whiteColor];
    
    self.opaque = YES;
    self.userInteractionEnabled = YES;
    line = [[UIImageView alloc] init];
    line.backgroundColor=[UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1.0];
    [self addSubview:line];
    [self setupTextView];
    self.emotionbutton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.emotionbutton setBackgroundImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
    
    if(sendButton)
        [sendButton removeFromSuperview];
    sendButton = self.emotionbutton;
    [self addSubview:self.sendButton];
    self.showUtilitysbutton  = [UIButton  buttonWithType:UIButtonTypeCustom];
    [self.showUtilitysbutton setBackgroundImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
    [self addSubview:self.showUtilitysbutton];
    
    self.voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
    self.voiceButton.tag = 0;
    [self addSubview:self.voiceButton];
    [self setupRecordButton];
}

- (void)setupTextView
{
    //    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH;
    self.textView = [[HPGrowingTextView  alloc] init];
    //    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.font = [UIFont fontWithName:[AppConfig getDetailFont] size:15];
    self.textView.minHeight = 31;
    self.textView.maxNumberOfLines = 5;
    self.textView.animateHeightChange = YES;
    self.textView.animationDuration = 0.25;
    self.textView.delegate = self;
    
    [self.textView.layer setBorderWidth:0.5];
    [self.textView.layer setBorderColor:[UIColor colorWithRed:188/255.0 green:188/255.0 blue:188/255.0 alpha:1.0].CGColor];
    [self.textView.layer setCornerRadius:2];
    self.textView.returnKeyType = UIReturnKeySend;
    [self addSubview:self.textView];
}

- (void)setupRecordButton
{
    //    CGFloat width = self.frame.size.width - SEND_BUTTON_WIDTH;
    self.recordButton = [[UIImageView alloc] init];
    [self.recordButton setUserInteractionEnabled:YES];
    UIImage* pressToSayImage = [UIImage imageNamed:@"dd_press_to_say_normal"];
    [self.recordButton setImage:pressToSayImage];
    UIImage* releaseToSend = [UIImage imageNamed:@"dd_record_release_end"];
    [self.recordButton setHighlightedImage:releaseToSend];
    //    [self.recordButton setAdjustsImageWhenHighlighted:NO];
    [self.recordButton setOpaque:YES];
    [self.recordButton setHidden:YES];
    [self addSubview:self.recordButton];
}

#pragma mark - HPTextViewDelegate
//- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;

//- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView;
//- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView;

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqual:@"\n"])
    {
        [self.delegate textViewEnterSend];
        return NO;
    }
    return YES;
}
//- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float bottom = self.bottom;
    if ([growingTextView.text length] == 0)
    {
        [self setHeight:height + 13];
    }
    else
    {
        [self setHeight:height + 10];
    }
    [self setBottom:bottom];
//    [growingTextView setContentInset:UIEdgeInsetsZero];
    //    [UIView animateKeyframesWithDuration:0.25 delay:0 options:0 animations:^{
    //
    //    } completion:^(BOOL finished) {
    //
    //    }];
    [self.delegate viewheightChanged:height];
}

//- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
//{
//}

//- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    return YES;
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self.delegate textViewShouldBeginEditing];
    return YES;
}


#pragma mark - Settersd
//- (void)setSendButton:(UIButton *)btn
//{
//    if(sendButton)
//        [sendButton removeFromSuperview];
//    
//    sendButton = btn;
//    [self addSubview:self.sendButton];
//}


#pragma mark - Message input view

+ (CGFloat)textViewLineHeight
{
    return 32.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines
{
    return 5.0f;
}

+ (CGFloat)maxHeight
{
    return ([JSMessageInputView maxLines] + 1.0f) * [JSMessageInputView textViewLineHeight];
}

- (void)willBeginRecord
{
    [self.textView setHidden:YES];
    [self.recordButton setHidden:NO];
}

- (void)willBeginInput
{
    [self.textView setHidden:NO];
    [self.recordButton setHidden:YES];
}

-(void)setDefaultHeight
{
    
}

- (CGFloat)bottom {
    return self.top + self.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setBottom:(CGFloat)bottom {
    if(bottom == self.bottom){
        return;
    }
    
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
    if(height == self.height){
        return;
    }
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

@end
