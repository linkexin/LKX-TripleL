//
//  CustomPageControl.h
//  JinshaForum
//
//  Created by 成荣 张 on 12-2-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//	注意：此pageControl默认选中是白色圆点，未选中为半透明白点的，在给imageNormal和imageCurrent赋值的时候图面最好遮住dot默认点大小 

//小红点之间的间距
#define WIDTH_SC_PADDING 5

//小红点的宽度
#define Pot_Width 5
//小红点的高度
#define Pot_Height 5

#define pc_color_normal [UIColor colorWithRed:115/256.0 green:120/256.0 blue:150/256.0 alpha:1.0]

#define pc_color_sel [UIColor colorWithRed:12/256.0 green:96/256.0 blue:254/256.0 alpha:1.0]


#import <UIKit/UIKit.h>
@protocol CustomPageControlDelegate;
@interface CustomPageControl : UIPageControl
{
	NSObject<CustomPageControlDelegate>* __unsafe_unretained m_delegate;
    UIImage* _imageCurrent;
    UIImage* _imageNormal;
	int		 _pointCount;
}
@property (unsafe_unretained,nonatomic)NSObject<CustomPageControlDelegate>* delegate;
@property (nonatomic,retain, readwrite) UIImage* imageNormal;
@property (nonatomic, retain, readwrite) UIImage* imageCurrent;
- (void) updateDots;
@end

@protocol CustomPageControlDelegate <NSObject>
@optional
- (void)onPageControlValueChangeTo:(NSInteger)pageIndex;

@end
