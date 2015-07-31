//
//  AppConfig.h
//  TripleL
//
//  Created by h1r0 on 15/5/24.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppConfig : NSObject

#define WIDTH_SCREEN	[UIScreen mainScreen].bounds.size.width
#define HEIGHT_SCREEN	[UIScreen mainScreen].bounds.size.height

+ (NSArray *) getFontStyleArray;
+ (NSArray *) getColorStyleArray;
+ (NSArray *) getPuppleStyleArray;

+ (NSString *) getTitleFont;
+ (NSString *) getDetailFont;
+ (UIColor *) getBarItemColor;
+ (UIColor *) getBGColor;
+ (UIColor *) getFGColor;
+ (UIColor *) getTitleColor;
+ (UIColor *) getLineColor;
+ (UIColor *) getDetailColor;
+ (UIColor *) getStatusBarColor;
+ (UIColor *) getBarTitleColor;
+ (UIColor *) getBarButtonColor;

+ (UIImage *) getNavBarBgImage;
+ (UIImage *) getTabBarBgImage;

@end
