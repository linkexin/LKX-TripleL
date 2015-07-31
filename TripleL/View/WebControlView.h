//
//  WebControlView.h
//  TripleL
//
//  Created by h1r0 on 15/5/24.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebControlDelegate <NSObject>

- (void) closeButtonDown;
- (void) backButtonDown;
- (void) preButtonDown;
- (void) homeButtonDown;
- (void) refreshButtonDown;

@end

@interface WebControlView : UIView

@property (nonatomic, strong) id <WebControlDelegate> delegate;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *preButton;
@property (nonatomic, strong) UIButton *homeButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *refreshButton;

@end
