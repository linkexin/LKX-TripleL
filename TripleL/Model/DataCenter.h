//
//  DataCenter.h
//  TripleL
//
//  Created by 李伯坤 on 15/4/16.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MsgRecordItem;
@class TLMessage;
@class TLUser;
@class TLInfo;

@interface DataCenter : NSObject

@property (nonatomic, strong) NSMutableArray *msgRecArray;
@property (nonatomic, strong) NSMutableArray *friendListArray;
@property (nonatomic, strong) NSMutableArray *chatRecArray;

+ (DataCenter *) getDataCenter;
+ (void) reset;

// 用户列表
- (NSMutableArray *) getUsers;
- (void) addUser: (TLUser *) user;
- (BOOL) removeUser: (TLUser *) user;

// 消息列表
- (NSMutableArray *) getMessageListFromUser: (NSString *) username;
- (void) addMessageListItem: (MsgRecordItem *) item toUser: (NSString *) username;
- (BOOL) removeMessageListItemByFriendName: (NSString *) friendName fromUser:(NSString *)username;
- (BOOL) removeAllMessageListItemsFromUser: (NSString *) username;

// 好友列表
- (NSMutableArray *) getFriendListFromUser: (NSString *) username;
- (TLUser *) getFriendListItem: (NSString *) friendName fromUser: (NSString *) username;
- (void) updateFriendList: (NSArray *) data  toUser: (NSString *) username;
- (void) addFriend: (TLUser *) user toUser: (NSString *) username;
- (BOOL) removeFriend: (NSString *) friendName fromUser: (NSString *) username;

// 聊天记录
- (NSMutableArray *) getChatRecordFromUser: (NSString *) username toFriend: (NSString *) friendName;
- (void) addChatRecordItem: (TLMessage *) message from: (NSString *) friendname toUser: (NSString *) username;
- (BOOL) removeChatRecordByFriendName: (NSString *) friendName toUser: (NSString *) username;
- (BOOL) removeAllChatRecordFromUser: (NSString *) username;

// 个人设置
- (TLInfo *) getSettingInfoFromUser: (NSString *) username;
- (BOOL) setSettingInfo: (TLInfo *) info toUser: (NSString *) username;

// CoreData
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end
