//
//  LoadindView.h
//  TripleL
//
//  Created by charles on 5/2/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadindView : UIView

@property (nonatomic, strong) UIColor *hudColor;

-(void)showAnimated:(BOOL)animated;
-(void)hide;


@end
