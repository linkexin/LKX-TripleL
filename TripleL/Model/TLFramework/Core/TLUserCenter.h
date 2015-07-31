//
//  TLUserCenter.h
//  twoFace
//
//  Created by h1r0 on 15/4/12.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TLStream;
@class TLUser;
@class TLInfo;

@protocol TLUserCenterDelegate <NSObject>

- (void) getUsernameIllegalFinishedWithStatus: (BOOL) status data: (id) data error: (NSString *) error;

- (void) modifyPasswordFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) modifyRemarkNameFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) deleteFriendFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) getUserDetailedAccountInfoFinishedWithStatus: (BOOL) status info: (TLUser *) userInfo error: (NSString *) error;

- (void) modifyPermissionFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) getPermissionFinishedWithStatus: (BOOL) status info: (TLInfo *) user error: (NSString *) error;

- (void) modifySelfDetailInfoFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) searchFriendFinishedWithStatus: (BOOL) status data: (NSArray *) data error: (NSString *) error;

- (void) addFriendFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) getFriendAroundMeFinishedWithStatus: (BOOL) status data: (NSArray *) data error: (NSString *) error;

- (void) getFriendListFinishedWithStatus: (BOOL) status data: (NSArray *) data error: (NSString *) error;

- (void) sendFeedbackFinishedWithStatus: (BOOL) status error: (NSString *) error;

- (void) getTravelDataFinishedWithStatus: (BOOL) status data: (NSArray *) data error: (NSString *) error;

- (void) getFriendRecommendFinishedWithStatus: (BOOL) status data: (NSArray *) data error: (NSString *) error;

- (void) networkAnomaly;

@end

@interface TLUserCenter : NSObject

@property (nonatomic, strong) TLStream *stream;
@property (nonatomic, strong) id<TLUserCenterDelegate>delegate;

- (id) initWithStream: (TLStream *) stream;                     // 初始化userceter

- (void) modifyPassword: (NSString *) newPassword oldPassword: (NSString *) oldPassword;        // 修改密码
- (void) ckeckUsernameIllegal: (NSString *) username;           // 检查用户名是否合法

- (void) modifyRemarkName: (NSString *) remarkname toUser: (NSString *) username;       // 备注
- (void) deleteFriendByUsername: (NSString *) username;                                 // 删除好友

- (void) modifySelfAccountDetailedInfo: (TLUser *) user;              // 修改账号信息
- (void) getUserAccountDetailInfoByUsername: (NSString *) username;   // 获取好友的账号的详细信息

- (void) modifyPermission: (TLInfo *) info;                     // 修改账号权限
- (void) getPermissionByUsername: (NSString *) username;        // 获取账号权限

- (void) searchFriendByKeyword: (NSString *) keyword;         // 搜索好友
- (void) addFriendByUsername: (NSString *) username andMessage: (NSString *) message;            // 添加好友

- (void) getFriendAroundMe: (float) longitude  latitude: (float)latitude;   // 获取附近的好友
- (void) getMyFriendList;                                       // 获取好友列表

- (void) getTravelData;                                         // 获取地点漫游数据
- (void) getFriendRecommend;

- (void) sendFeedbackTitle: (NSString *) title detail:(NSString *)text;         // 反馈

- (TLUser *) getUserAccountInfoByUsername: (NSString *) username;         // 获取好友的账号信息

@end
