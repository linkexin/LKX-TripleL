//
//  CusAnnotationView.h
//  toFace
//
//  Created by charles on 4/14/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//
//自定义大头针上样式
#import <MAMapKit/MAMapKit.h>
#import "TLUser.h"
@protocol CusAnnotationDelegate <NSObject>
-(void)toGame:(TLUser *)user;
@end

@interface CusAnnotationView : MAAnnotationView <MAMapViewDelegate>
{
    NSDictionary *info;
}
@property (nonatomic, strong) UIImage *portrait;
@property (nonatomic, strong) UIImageView *portraitImageView;
@property (nonatomic, strong) UIImageView *pinView;
@property (nonatomic, strong) UIImage *pinBackground;
@property (nonatomic, strong) UIView *calloutView;

@property (nonatomic) id<CusAnnotationDelegate>delegate;
@end


