//
//  CustomPageControl.m
//  JinshaForum
//
//  Created by 成荣 张 on 12-2-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomPageControl.h"


@interface CustomPageControl (Private)
- (void) updateDots;
@end

@implementation CustomPageControl
@synthesize imageNormal = _imageNormal;
@synthesize imageCurrent = _imageCurrent;
@synthesize delegate = m_delegate;

- (id)initWithFrame:(CGRect)frame
{
	self=[super initWithFrame:frame];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}
#pragma mark - life recycle
- (void) dealloc
{
    _imageNormal = nil;
    _imageCurrent = nil;
    
}
#pragma mark- 重写pagecongrol的方法
- (void)setNumberOfPages:(NSInteger)numberOfPages
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[super setNumberOfPages:numberOfPages];
		[self updateDots];
	});
   
}
- (void) setCurrentPage:(NSInteger)currentPage
{
	if (self.currentPage!=currentPage) {
		[super setCurrentPage:currentPage];
		
		// update dot views
		[self updateDots];
		if (m_delegate!=nil&&[m_delegate respondsToSelector:@selector(onPageControlValueChangeTo:)]) {
			[m_delegate onPageControlValueChangeTo:currentPage];
		}
	}
}
#pragma mark - (用于更新图片)
- (void) updateDots
{
    if(_imageCurrent || _imageNormal)
    {
        // Get subviews
        NSArray* dotViews = self.subviews;
		[dotViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[(UIView *)obj removeFromSuperview];
		}];
		for (int i=0; i<self.numberOfPages; i++) {
			UIImageView *dot=[[UIImageView alloc]initWithFrame:CGRectMake((WIDTH_SC_PADDING+Pot_Width)*i, 0, Pot_Width, Pot_Height)];
			[self addSubview:dot];
			if (i==self.currentPage){
				[dot setImage:[UIImage imageNamed:@"pageControl_select.png"]];
			}else{
				[dot setImage:[UIImage imageNamed:@"pageControl_nor.png"]];
			}
		}
    }
}

//-(void)resizeDotsFrame{
//	NSArray* dotViews = self.subviews;
//	for(int i = 0; i < dotViews.count; ++i)
//	{
//		UIView* dot = (UIView *)[dotViews objectAtIndex:i];
//		[dot setFrameHeight:8];
//		[dot setFrameWidth:8];
//		CGPoint point=CGPointMake(dot.center.x-i*2, dot.center.y);
//		[dot setCenter:point];
//	}
//}
@end
