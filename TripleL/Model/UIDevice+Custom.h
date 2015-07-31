//
//  UIDevice+Custom.h
//  yingyongshangdian
//
//  Created by 张 成荣 on 13-6-20.
//  Copyright (c) 2013年 PubuTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

typedef NS_ENUM(NSInteger,DeviceVerType){
    DeviceVer4,//4s以及以下
    DeviceVer5,//5或者5s
    DeviceVer6,//iphone6
    DeviceVer6P,//iphone6 plus
};

@interface UIDevice (Custom)

+(BOOL)isIPad;

+(BOOL)isIPod;

//mac地址
+ (NSString *)macAddress;
//
+ (NSString*)deviceString;

+ (DeviceVerType) deviceVerType;

+ (CLLocationCoordinate2D) getPostion;

@end


