//
//  DGAaimaView.m
//  animaByIdage
//
//  Created by chuangye on 15-3-11.
//  Copyright (c) 2015年 chuangye. All rights reserved.
//

#import "DGAaimaView.h"
#import "DGEarthView.h"
@implementation DGAaimaView
{
    CGFloat  itemCloudY;
    CGFloat itemBigCloudY;
    CGFloat itemletterY;
    DGEarthView * ainme;
}

-(void)DGAaimaView:(DGAaimaView*)animView BigCloudSpeed:(CGFloat)BigCS smallCloudSpeed:(CGFloat)SmaCS earthSepped:(CGFloat)eCS huojianSepped:(CGFloat)hCS littleSpeed:(CGFloat)LCS
{
    itemCloudY=SmaCS;
    itemBigCloudY =BigCS;
    itemletterY=LCS;
    _ainmeView.EarthSepped=eCS;
    _ainmeView.huojiansepped=hCS;
    
}
- (void)awakeFromNib
{
    [self animaInit];
}

-(void)start
{
    [ainme start];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self animaInit];
    }
    return self;
}

-(void)animaInit
{
    itemBigCloudY=1.5;
    itemCloudY=1;
    itemletterY=2;
    self.backgroundColor =[UIColor blueColor];
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    ainme =[[DGEarthView alloc]initWithFrame:self.bounds];
    [self addSubview:ainme];
    
    _CloudY=100;
}

- (void)drawRect:(CGRect)rect
{
    //大云
    self.BigCloudY-=itemBigCloudY;
    if (self.BigCloudY <=-150 ) {
        self.BigCloudY = 400;
    }
    UIImage *imageBigYun = [UIImage imageNamed:@"ream@3x"];
    [imageBigYun drawAtPoint:CGPointMake(self.BigCloudY,50)];
    
    //D
    self.letterY-=itemletterY;
    if (self.letterY <=-150 ) {
        self.letterY = 400;
    }
    UIImage *imageD = [UIImage imageNamed:@"D@3X"];
    [imageD drawAtPoint:CGPointMake(self.letterY, 150)];
    
    //小云
    self.CloudY-=itemCloudY;
    
    if (self.CloudY <= -50) {
        self.CloudY = 400;
    }
    
    UIImage *image = [UIImage imageNamed:@"yun"];
    [image drawAtPoint:CGPointMake(self.CloudY, 170)];
    
}


@end
