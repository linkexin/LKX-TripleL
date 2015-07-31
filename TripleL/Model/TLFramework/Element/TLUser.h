//
//  TLUser.h
//  twoFace
//
//  Created by 李伯坤 on 15/4/10.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TLInfo;

@interface TLUser : NSObject

// 基本信息
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *remarkName;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *mood;
@property (nonatomic, strong) NSString *status;

// 摇一摇相关
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *distance;

// 列表相关
@property (nonatomic, strong) NSString *pinyin;

// 详细信息
@property (nonatomic, strong) NSString *age;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *constellation;
@property (nonatomic, strong) NSString *emotionCondition;
@property (nonatomic, strong) NSString *hometown;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *school;
@property (nonatomic, strong) NSString *career;
@property (nonatomic, strong) NSString *createTime;

@property (nonatomic, strong) NSString *credit;

// 解锁信息
@property (nonatomic, strong) TLInfo *gameInfo;

@end
