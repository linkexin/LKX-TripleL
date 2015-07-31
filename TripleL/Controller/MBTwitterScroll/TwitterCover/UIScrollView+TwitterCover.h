//
//  MapViewController.h
//  toFace
//
//  Created by charles on 4/13/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//


#import <UIKit/UIKit.h>
#define CHTwitterCoverViewHeight 200

@interface CHTwitterCoverView : UIImageView
@property (nonatomic, weak) UIScrollView *scrollView;
- (id)initWithFrame:(CGRect)frame andContentTopView:(UIView*)view;
@end


@interface UIScrollView (TwitterCover)
@property(nonatomic,weak)CHTwitterCoverView *twitterCoverView;
- (void)addTwitterCoverWithImage:(UIImage*)image;
- (void)addTwitterCoverWithImage:(UIImage*)image withTopView:(UIView*)topView;
- (void)removeTwitterCoverView;
@end

@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end