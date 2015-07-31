//
//  RegisterViewController.h
//  toFace
//
//  Created by charles on 4/10/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import "GuideViewController.h"
#import "MyHeader.h"

@interface GuideViewController (){
	CustomPageControl* _pageControl;
	UIScrollView *_scrollView;
	UIButton *btnTiYan;
	UIButton *	btnBinding;
	UIButton *	btnDoLater;
	BOOL  hasResetSubview;
	BOOL showBindingBtn;

}

@property(nonatomic, strong) UIScrollView *scrollView;
@end

@implementation GuideViewController
@synthesize scrollView = _scrollView;
@synthesize fromAboutUs;

- (id) init
{
    if (self = [super init]) {
        fromAboutUs = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	hasResetSubview = NO;
	showBindingBtn = NO;

	self.view.backgroundColor = [UIColor whiteColor];
	_scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN)];
	_scrollView.delegate=self;
	_scrollView.pagingEnabled=YES;
	_scrollView.showsHorizontalScrollIndicator=NO;
	[self.view addSubview:_scrollView];
	
	int index = 0;
	switch ([UIDevice deviceVerType]) {
		case DeviceVer6:
		{
			index = 6;
		}
			break;
		case DeviceVer6P:
		{
			index = 6;
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
	
	UIImageView *Image1 = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, WIDTH_SCREEN, HEIGHT_SCREEN)];
	[Image1 setContentMode:UIViewContentModeScaleAspectFill];
	[Image1 setClipsToBounds:YES];
	Image1.image = [UIImage imageNamed:[NSString stringWithFormat:@"Welcome_1_%d.png",index]];
	
	UIImageView *Image2 = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_SCREEN,0, WIDTH_SCREEN, HEIGHT_SCREEN)];
	[Image2 setContentMode:UIViewContentModeScaleAspectFill];
	[Image2 setClipsToBounds:YES];
	Image2.image = [UIImage imageNamed:[NSString stringWithFormat:@"Welcome_2_%d.png",index]];

	UIImageView *Image3 = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_SCREEN*2,0, WIDTH_SCREEN, HEIGHT_SCREEN)];
	Image3.image = [UIImage imageNamed:[NSString stringWithFormat:@"Welcome_3_%d.png",index]];
	Image3.userInteractionEnabled=YES;
	
	btnBinding=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 167, 45)];
	btnBinding.center = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2+140);
	[btnBinding setImage:[UIImage imageNamed:@"Welcome_bangding.png"] forState:UIControlStateNormal];
	[btnBinding setBackgroundColor:[UIColor clearColor]];
	[btnBinding addTarget:self action:@selector(onBtnBindingPressed) forControlEvents:UIControlEventTouchUpInside];
	[Image3 addSubview:btnBinding];
	btnBinding.hidden=NO;
	
	btnDoLater=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 171, 45)];
	btnDoLater.center = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2+190);
	[btnDoLater setImage:[UIImage imageNamed:@"Welcome_zaishuo.png"] forState:UIControlStateNormal];
	[btnDoLater setBackgroundColor:[UIColor clearColor]];
	[btnDoLater addTarget:self action:@selector(onBtnDoLaterPressed) forControlEvents:UIControlEventTouchUpInside];
	[Image3 addSubview:btnDoLater];
	btnDoLater.hidden=NO;

    [_scrollView addSubview:Image1];
	[_scrollView addSubview:Image2];
	[_scrollView addSubview:Image3];
	
    _scrollView.contentSize=CGSizeMake(3*WIDTH_SCREEN, HEIGHT_SCREEN);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark - IBAction
#pragma mark - IBAction
- (void)onBtnTiYanPressed
{
	[self hiddenSelf];
}
- (void)onBtnDoLaterPressed
{
	[self hiddenSelf];
}
- (void)onBtnBindingPressed
{
	[self hiddenSelf];

    
}
- (IBAction)onBtnPressed:(id)sender
{
    [self hiddenSelf];
}

#pragma mark - private
- (void)hiddenSelf
{
	if (self.fromAboutUs) {
		[self animateHide];
	}else{
		[[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"hiden_welcome"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	//	[APPDELEGETE welcomeFinished:NO];
	}
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.x >= 320*2.6) {
		[self hiddenSelf];
	}
	int page = (scrollView.contentOffset.x+320/2.0) / 320;
	_pageControl.currentPage=page;
	if (!hasResetSubview) {
		if (scrollView.contentOffset.x>=320*1) {
			hasResetSubview=YES;
			if (showBindingBtn) {
//				btnTiYan.hidden=YES;
//				btnBinding.hidden=NO;
//				btnDoLater.hidden=NO;
			}
			
		}
	}
}


- (void)animateShow{
	[_scrollView scrollRectToVisible:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN) animated:NO];
	[UIView beginAnimations:@"动画显示"  context:nil];
	[UIView setAnimationDelay:0.2];
	[self.view setAlpha:1];
	[UIView commitAnimations];
}
- (void)animateHide{
	[UIView beginAnimations:@"动画显示"  context:nil];
	[UIView setAnimationDelay:0.2];
	[self.view setAlpha:0];
	[UIView commitAnimations];
}


@end
