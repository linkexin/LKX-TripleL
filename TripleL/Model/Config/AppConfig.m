//
//  AppConfig.m
//  TripleL
//
//  Created by h1r0 on 15/5/24.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "AppConfig.h"

static NSArray *fontStyleArray;
static NSArray *colorStyleArray;
static NSArray *puppleStyleArray;

@implementation AppConfig

+ (NSArray *) getFontStyleArray
{
    if (fontStyleArray == nil) {
        fontStyleArray = [[NSArray alloc] initWithObjects:
                          @{
                            @"title" : @"默认",
                            @"titleFont": @"STHeitiSC-Light",
                            @"detailFont": @"STHeitiSC-Light"},
                          @{
                            @"title" : @"呆萌",
                            @"titleFont": @"Yuppy SC",
                            @"detailFont": @"Wawati SC"},
                          nil];
        
    }
    return fontStyleArray;
}

+ (NSArray *) getColorStyleArray
{
    if (colorStyleArray == nil) {
        colorStyleArray = [[NSArray alloc] initWithObjects:
                           @{
                             @"title" : @"默认",              // 方案名称
                             @"barTitleColor": [UIColor whiteColor],                      // navBar 标题颜色
                             @"batButtonColor": [UIColor whiteColor],                     // navBar button颜色
                             @"statusColor" : [UIColor colorWithRed:75.0/255.0 green:105.0/255.0 blue:193.0/255.0 alpha:1.0],       // statusBar 颜色（webView用）
                             @"barItemColor": [UIColor colorWithRed:75.0/255.0 green:105.0/255.0 blue:193/255.0 alpha:1.0],       // 选中的barItem 颜色
                             @"bgColor": [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0],           // 主背景色
                             @"mainColor": [UIColor whiteColor],                                                                    // 前景色
                             @"titleColor": [UIColor blackColor],                                                                   // 标题颜色
                             @"detailColor": [UIColor grayColor],                                                                   // 正文颜色
                             @"lineColor": [UIColor colorWithRed:205.0/255.0 green:210.0/255.0 blue:217.0/255.0 alpha:1]},          // 分割线颜色
                           @{
                             @"title" : @"夜间模式",
                             @"barTitleColor": [UIColor whiteColor],                      // navBar 标题颜色
                             @"batButtonColor": [UIColor whiteColor],                     // navBar button颜色
                             @"statusColor" : [UIColor colorWithRed:94.0/255.0 green:91.0/255.0 blue:149.0/255.0 alpha:1.0],                            @"barItemColor": [UIColor colorWithRed:100.0/255.0 green:204.0/255.0 blue:177.0/255.0 alpha:1.0],
                             @"bgColor": [UIColor colorWithRed:94.0/255.0 green:91.0/255.0 blue:149.0/255.0 alpha:1.0],
                             @"mainColor": [UIColor colorWithRed:108.0/255.0 green:105.0/255.0 blue:164.0/255.0 alpha:1.0],
                             @"titleColor": [UIColor whiteColor],
                             @"detailColor": [UIColor grayColor],
                             @"lineColor": [UIColor colorWithRed:94.0/255.0 green:91.0/255.0 blue:149.0/255.0 alpha:1.0]},
                           @{@"title" : @"橘黄",              // 方案名称
                             @"barTitleColor": [UIColor whiteColor],                      // navBar 标题颜色
                             @"batButtonColor": [UIColor whiteColor],                     // navBar button颜色
                             @"statusColor" : [UIColor colorWithRed:234.0/255.0 green:102.0/255.0 blue:2.0/255.0 alpha:1.0],       // statusBar 颜色（webView用）
                             @"barItemColor": [UIColor colorWithRed:234.0/255.0 green:102.0/255.0 blue:2.0/255.0 alpha:1.0],       // 选中的barItem 颜色
                             @"bgColor": [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0],           // 主背景色
                             @"mainColor": [UIColor whiteColor],                                                                    // 前景色
                             @"titleColor": [UIColor blackColor],                                                                   // 标题颜色
                             @"detailColor": [UIColor grayColor],                                                                   // 正文颜色
                             @"lineColor": [UIColor colorWithRed:205.0/255.0 green:210.0/255.0 blue:217.0/255.0 alpha:1]},          // 分割线颜色
                           nil];
    }
    return colorStyleArray;
}


+ (NSArray *) getPuppleStyleArray
{
    if (puppleStyleArray == nil) {
        puppleStyleArray = [[NSArray alloc] initWithObjects:
                            @{
                              @"title" : @"默认"}, nil];
    }
    return puppleStyleArray;
}

+ (NSString *) getTitleFont
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getFontStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"titleFont"];
}

+ (NSString *) getDetailFont
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"fontStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getFontStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"detailFont"];
}

+ (UIColor *) getBarTitleColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"barTitleColor"];
}

+ (UIColor *) getBarButtonColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"barButtonColor"];
}

+ (UIColor *) getStatusBarColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"statusColor"];
}

+ (UIColor *) getBarItemColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"barItemColor"];
}

+ (UIColor *) getBGColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"bgColor"];
}

+ (UIColor *) getFGColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"mainColor"];
}

+ (UIColor *) getTitleColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"titleColor"];
}

+ (UIColor *) getDetailColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"detailColor"];
}

+ (UIColor *) getLineColor
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    NSDictionary *dic = [[AppConfig getColorStyleArray] objectAtIndex:choose];
    return [dic objectForKey:@"lineColor"];
}

+ (UIImage *) getNavBarBgImage
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    return [UIImage imageNamed:[NSString stringWithFormat:@"navBar_BG_%d.png", choose]];
}

+ (UIImage *) getTabBarBgImage
{
    int choose = ((NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"colorStyle"]).intValue;
    return [UIImage imageNamed:[NSString stringWithFormat:@"tabBar_BG_%d.png", choose]];
}


@end
