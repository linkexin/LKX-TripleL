//
//  RegisterViewController.h
//  toFace
//
//  Created by charles on 4/10/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPageControl.h"

@interface GuideViewController : UIViewController<UIScrollViewDelegate>
@property BOOL fromAboutUs;

- (void)animateShow;
- (void)animateHide;

@end
