//
//  PromptView.h
//  TripleL
//
//  Created by h1r0 on 15/5/27.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PromptView;

@protocol PromptViewDelegate <NSObject>

- (void) promptViewButtonDown:(PromptView *) sender;

@end

@interface PromptView : UIView

@property (nonatomic, strong) id<PromptViewDelegate>delegate;

@property BOOL show;

- (void) showMessage: (NSString *) message buttonTitle: (NSString *) btnTitle;
- (void) hidden;

@end
