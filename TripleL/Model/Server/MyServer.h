//
//  MyServer.h
//  twoFace
//
//  Created by 李伯坤 on 15/4/10.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TLUser;
@class TLMessage;
@class TLInfo;

@interface MyServer : NSObject

+ (MyServer *) getServer;

- (NSString *) getAUTH_TOKEN;

// 登陆
- (void) loginWithUsername:(NSString *) username
               andPassword: (NSString *) password;

// 注册
- (void) registerWithUsername: (NSString *) username
                     nickname: (NSString *) nickname
                     password: (NSString *) password
                       gender: (NSString *) gender
                     birthday: (NSString *) birthday
                   avatarPath: (NSString *) avatarPath;

// 注销
- (void) logout;

// 检查用户名是否可用
- (void) ckeckUsernameIllegal: (NSString *) username;

// 修改密码
- (void) modifyPassword: (NSString *) newPassword oldPassword:(NSString *)oldPassword;

// 上传下载图片
- (void) uploadImageByPath: (NSString *) path;
- (void) downloadImageFromURL: (NSURL *) url;

// 获取自己账号信息
- (TLUser *) getSelfAccountInfo;
- (void) modifySelfAccountDetailInfo: (TLUser *) user;

// 好友账号信息
- (TLUser *) getUserAccountInfoByUsername: (NSString *) username;
- (void) getUserAccountDetailedInfoByUsername: (NSString *) username;

// 修改备注、删除好友
- (void) modifyRemarkName: (NSString *)remarkname toUser:(NSString *)username;
- (void) deleteFriendByUsername: (NSString *) username;

// 获取修改好友权限
- (void) getUserPermisstionByUsername: (NSString *) username;
- (void) modifySelfPermisstion: (TLInfo *) info;

// 添加好友
- (void) searchFriendByKeyword: (NSString *) keyword;
- (void) addFriendByUsername:(NSString *)username andMessage: (NSString *) message;
- (void) sendFriendRequestReplayWithId: (NSString *) reqID accept: (BOOL) accept;

// 获取好友、附近的好友列表
- (void) getFriendAroundMe: (float) longitude
                  latitude: (float)latitude;
- (void) getMyFriendList;

// 发送返回
- (void) sendFeedbackTitle: (NSString *) title detail: (NSString *) text;

// 发送消息
- (void) sendMessage: (TLMessage *) message;

// 好友漫游数据
- (void) getTravelData;

// 好友推荐
- (void) getFriendRecommend;

// 好友圈时间线
- (NSURLRequest *) getFriendTimelineRequest;
- (NSURLRequest *) getSelfTimelineRequest;
- (NSURLRequest *) getArounderTimelineRequest;



@end
