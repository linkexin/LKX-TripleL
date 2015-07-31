//
//  SOMessagingViewController.h
//  SOMessaging
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import <UIKit/UIKit.h>
#import "TLMessage.h"
#import "SOMessagingDataSource.h"
#import "SOMessagingDelegate.h"
#import "SOMessageCell.h"

typedef NS_ENUM(NSUInteger, DDBottomShowComponent){         // 显示部件
    DDInputViewUp                       = 1,
    DDShowKeyboard                      = 1 << 1,
    DDShowEmotion                       = 1 << 2,
    DDShowUtility                       = 1 << 3
};

typedef NS_ENUM(NSUInteger, DDBottomHiddComponent){         // 隐藏部件
    DDInputViewDown                     = 14,
    DDHideKeyboard                      = 13,
    DDHideEmotion                       = 11,
    DDHideUtility                       = 7
};

typedef NS_ENUM(NSUInteger, DDInputType){
    DDVoiceInput,
    DDTextInput
};

typedef NS_ENUM(NSUInteger, PanelStatus){
    VoiceStatus,
    TextInputStatus,
    EmotionStatus,
    ImageStatus
};

#define     NAVBAR_HEIGHT               64.f
#define     SCREEN_WIDTH                self.view.frame.size.width
#define     SCREEN_HEIGHT               self.view.frame.size.height
#define     DDCOMPONENT_BOTTOM          CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT, SCREEN_WIDTH, 216)
#define     DDINPUT_BOTTOM_FRAME        CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) - self.chatInputView.frame.size.height + NAVBAR_HEIGHT,SCREEN_WIDTH,self.chatInputView.frame.size.height)
#define     DDINPUT_HEIGHT              self.chatInputView.frame.size.height
#define     DDINPUT_TOP_FRAME           CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) - self.chatInputView.frame.size.height + NAVBAR_HEIGHT - 216, SCREEN_WIDTH, self.chatInputView.frame.size.height)
#define     DDUTILITY_FRAME             CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT -216, SCREEN_WIDTH, 216)
#define     DDEMOTION_FRAME             CGRectMake(0, (SCREEN_HEIGHT - NAVBAR_HEIGHT) + NAVBAR_HEIGHT-216, SCREEN_WIDTH, 216)

@interface SOMessagingViewController : UIViewController <SOMessagingDataSource, SOMessagingDelegate, UITableViewDataSource>

#pragma mark - Properties
@property (strong, nonatomic) UITableView *tableView;
@property BOOL kboardShow;
@property CGRect kboardRect;

#pragma mark - Methods

- (void)sendMessage:(TLMessage *)message;

- (void)receiveMessage:(TLMessage *)message;

- (void)refreshMessages;

@end
