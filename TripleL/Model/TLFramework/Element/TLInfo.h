//
//  TLInfo.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/18.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLInfo : NSObject

@property (nonatomic, strong) NSString *username;

// 权限相关
@property (nonatomic, strong) NSString *lockDetailInfo;
@property (nonatomic, strong) NSString *applyWithoutUnlock;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) NSString *gameDiff;
@property (nonatomic, strong) NSString *addFriendWay;

// 通知设置
@property (nonatomic) BOOL recNewMsg;
@property (nonatomic) BOOL showMsgDetail;
@property (nonatomic) BOOL audio;
@property (nonatomic) BOOL shock;
@property (nonatomic) BOOL nightModal;

@end
