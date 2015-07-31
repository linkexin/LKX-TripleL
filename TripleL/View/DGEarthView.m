//
//  DGEarthView.m
//  animaByIdage
//
//  Created by chuangye on 15-3-11.
//  Copyright (c) 2015年 chuangye. All rights reserved.
//

#import "DGEarthView.h"
#import "UIDevice+Custom.h"

@implementation DGEarthView

{
    double angleEarth;
    double angle;
    UIImageView *imageView;
    UIImageView *imageViewEarth;
    NSMutableArray *imageArray;
    NSInteger value;
    
}
- (id)initWithFrame:(CGRect)frame
{
    //NSLog(@"%f %f", frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if (self) {
        _EarthSepped=1.0;
        _huojiansepped=2.0;
        value=1;
        self.backgroundColor=[UIColor clearColor];
        imageArray = [[NSMutableArray alloc]init];
        
        int index = 0;
        switch ([UIDevice deviceVerType]) {
            case DeviceVer6:
            {
                index = 6;
            }
                break;
            case DeviceVer6P:
            {
                index = 7;
            }
                break;
            case DeviceVer5:
            {
                index = 5;
            }
                break;
            default:{
                index = 4;
            }
                break;
        }
        
        if(index == 7)
        {
            imageViewEarth = [[UIImageView alloc]initWithFrame:CGRectMake(77, 220, 260, 260)];
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(192, 320, 30, 60)];
        }
        if(index == 6)
        {
            imageViewEarth = [[UIImageView alloc]initWithFrame:CGRectMake(58, 220, 260, 260)];
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(173, 320, 30, 60)];
        }
        if(index == 5)
        {
            imageViewEarth = [[UIImageView alloc]initWithFrame:CGRectMake(31, 150, 260, 260)];//(31, 160, 260, 260)
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(146, 250, 30, 60)];//150, 260
        }
        if(index == 4)
        {
            imageViewEarth = [[UIImageView alloc]initWithFrame:CGRectMake(27, 130, 260, 260)];//(31, 160, 260, 260)
            imageView = [[UIImageView alloc]initWithFrame:CGRectMake(141, 230, 30, 60)];//150, 260
        }
        
        
        imageViewEarth.image=[UIImage imageNamed:@"earth@3x"];
        imageView.image=[UIImage imageNamed:@"fire2@3X(1)"];
        [self addSubview:imageViewEarth];
        [self addSubview:imageView];
    }
    return self;
}

-(void)start
{
    [self startAnimation];
    [self startAnimationEarth];
}


-(void) startAnimation
{
    NSString *imageName;
    if (value>=3) {
        
        value=1;
    }
    imageName = [NSString stringWithFormat:@"fire%ld@3X(1)",(long)value];
    
    imageView.image = [UIImage imageNamed:imageName];
    value++;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimation)];
    
    imageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    // imageView.layer.position =CGPointMake(2.3,2.6);
    imageView.layer.anchorPoint=CGPointMake(5, 0.5);
    [UIView commitAnimations];
    
    
}
-(void)endAnimation
{
    angle += 5*_huojiansepped;
    [self startAnimation];
    
    //换图片
}

-(void) startAnimationEarth
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimationEarth)];
    imageViewEarth.transform = CGAffineTransformMakeRotation(angleEarth * (M_PI / -180.0f));
    // imageViewEarth.layer.anchorPoint=CGPointMake(2.2, 2.2);
    [UIView commitAnimations];
}

-(void)endAnimationEarth
{
    angleEarth += 5*_EarthSepped;
    [self startAnimationEarth];
}

@end
