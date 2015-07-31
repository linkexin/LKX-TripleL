//
//  TLStream.h
//  twoFace
//
//  Created by 李伯坤 on 15/4/10.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TLUser;

@protocol TLStreamDelegate <NSObject>

- (void) loginFinishedWithStatus:(BOOL)status userInfo:(TLUser *)userInfo error: (NSString *) error;

- (void) registerFinishedWithStatus: (BOOL) status userInfo: (TLUser *) userInfo error: (NSString *) error;

- (void) refreshInfoFinishedWithStatus: (BOOL) status;

@end

@interface TLStream : NSObject

@property (nonatomic, strong) id<TLStreamDelegate>delegate;

@property (nonatomic, strong) TLUser *user;             // 登陆用户信息
@property (nonatomic, strong) NSString *token;

- (void) userRegister: (TLUser *) user;                 // 用户注册
- (void) userLogin: (TLUser *) user;                    // 用户登陆
- (void) refreshUserInfo;

@end
