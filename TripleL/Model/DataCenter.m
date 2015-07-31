//
//  DataCenter.m
//  TripleL
//
//  Created by 李伯坤 on 15/4/16.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "DataCenter.h"
#import "AppDelegate.h"
#import "MyHeader.h"

#import "MsgRecordItem.h"

#import "User.h"
#import "Friend.h"
#import "MsgRec.h"
#import "ChatRec.h"
#import "Setting.h"

static DataCenter *datacenter = nil;
static TLInfo *curSettingInfo = nil;


@implementation DataCenter
@synthesize msgRecArray;
@synthesize friendListArray;
@synthesize chatRecArray;

+ (DataCenter *) getDataCenter
{
    if (datacenter == nil) {
        datacenter = [[DataCenter alloc] init];
        datacenter.managedObjectContext = [((AppDelegate *)[UIApplication sharedApplication].delegate) managedObjectContext];
        datacenter.managedObjectModel = [((AppDelegate *)[UIApplication sharedApplication].delegate) managedObjectModel];
        datacenter.persistentStoreCoordinator = [((AppDelegate *)[UIApplication sharedApplication].delegate)persistentStoreCoordinator];
        datacenter.msgRecArray = [[NSMutableArray alloc] init];
        datacenter.friendListArray = [[NSMutableArray alloc] init];
        datacenter.chatRecArray = [[NSMutableArray alloc] init];
        curSettingInfo = [[TLInfo alloc] init];
    }
    return datacenter;
}

+ (void) reset
{
    datacenter.msgRecArray = [[NSMutableArray alloc] init];
    datacenter.friendListArray = [[NSMutableArray alloc] init];
    datacenter.chatRecArray = [[NSMutableArray alloc] init];
}


#pragma mark - user list

- (NSMutableArray *) getUsers       // 获取所有用户
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:_managedObjectContext];
    NSError *error = nil;
    NSArray *ans = [_managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
    }
    // 遍历数据
    
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (User *obj in ans) {
        TLUser *user = [[TLUser alloc] init];
        user.username = obj.username;
        user.nickname = obj.nickname;
        user.avatar = obj.avatar;
        [data addObject:user];
    }
    
    return data;
}

- (void) addUser:(TLUser *)user     // 添加用户(用户登陆)
{
    User *userItem = [self getUserByUsername:user.username];
    
    if (userItem == nil) {          // 如果用户已经存在，则修改，不存在，添加
        userItem = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:_managedObjectContext];
        userItem.username = user.username;
        
        TLInfo *info = [[TLInfo alloc] init];
        info.recNewMsg = YES;
        info.showMsgDetail = YES;
        info.audio = YES;
        info.shock = YES;
        info.nightModal = NO;
        [self setSettingInfo:info toUser:user.username];
    }
    userItem.nickname = user.nickname;
    userItem.avatar = user.avatar;
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
}

- (BOOL) removeUser:(TLUser *)user      // 删除用户
{
    User *item = [self getUserByUsername:user.username];
    if (item == nil) {
        return NO;
    }
    
    NSError *error;
    [_managedObjectContext deleteObject:item];
    [_managedObjectContext save:&error];
    if (error) {
        [NSException raise:@"删除错误" format:@"%@", [error localizedDescription]];
    }
    
    return YES;
}

- (User *) getUserByUsername: (NSString *) username         // 获取指定用户信息
{
    if (username == nil) {
        return nil;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username like[d] %@", username];
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:_managedObjectContext]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [_managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        [NSException raise:@"删除错误" format:@"%@", [error localizedDescription]];
    }
    if (result.count > 1) {
        NSLog(@"DB warning: result.count = %lu", (unsigned long)result.count);
    }
    else if (result.count == 0){
        return nil;
    }
    
    return [result objectAtIndex:0];
}

#pragma mark - msg List

- (NSMutableArray *) getMessageListFromUser:(NSString *)username                // 获取用户消息列表
{
    [msgRecArray removeAllObjects];
    
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"get message list , Don't find user: %@ in DB", username);
        return msgRecArray;
    }
    
    for (MsgRec *rec in user.msgRec) {
        Friend *friend = [self getFriendListUserItem:rec.username fromUser:username];
        if (friend == nil)
        {
            rec.whoseMsgRec = nil;
            continue;
        }
        MsgRecordItem *item = [[MsgRecordItem alloc] init];
        item.username = rec.username;
        item.remarkName = friend.remarkname;
        item.avatar = friend.avatar;
        item.time = rec.time;
        item.count = rec.count;
        item.message = rec.text;
        [msgRecArray addObject:item];
    }
    
    for (int i = 0; i < msgRecArray.count / 2; i ++) {
        id tmp = msgRecArray[i];
        msgRecArray[i] = msgRecArray[msgRecArray.count - i - 1];
        msgRecArray[msgRecArray.count - i - 1] = tmp;
    }
    
    return msgRecArray;
}

- (void) addMessageListItem:(MsgRecordItem *)item toUser:(NSString *)username               // 往消息列表添加元素
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"Add Message Item, Don't find user: %@ in DB", username);
        return;
    }
    
    MsgRec *msgRec;
    for (MsgRec *rec in user.msgRec) {
        if ([rec.username isEqualToString:item.username]) {
            msgRec = rec;
            break;
        }
    }
    
    if (msgRec == nil) {
        msgRec = [NSEntityDescription insertNewObjectForEntityForName:@"MsgRec" inManagedObjectContext:_managedObjectContext];
        msgRec.username = item.username;
        msgRec.whoseMsgRec = user;
    }
    msgRec.time = item.time;
    msgRec.count = item.count;
    msgRec.text = item.message;
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
}

- (BOOL) removeMessageListItemByFriendName: (NSString *) friendName fromUser:(NSString *)username           // 删除消息列表单条数据
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"remove message list item, Don't find user: %@ in DB", username);
        return NO;
    }
    
    for (MsgRec *item in user.msgRec) {
        if ([item.username isEqualToString:friendName]) {
            item.whoseMsgRec = nil;
            break;
        }
    }
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
    return YES;
}

- (BOOL) removeAllMessageListItemsFromUser:(NSString *)username         // 清空消息列表
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"remove all message list, Don't find user: %@ in DB", username);
        return NO;
    }
    
    //   [user removeMsgRec:user.msgRec];
    for (MsgRec *item in user.msgRec) {
        item.whoseMsgRec = nil;
    }
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
    
    [msgRecArray removeAllObjects];
    
    return YES;
}


#pragma mark - friend List

- (NSMutableArray *) getFriendListFromUser:(NSString *)username         // 获取好友列表
{
    [friendListArray removeAllObjects];
    
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"get friend list, Don't find user: %@ in DB", username);
        return friendListArray;
    }
    
    for (Friend *item in user.friends) {
        TLUser *tluser = [[TLUser alloc] init];
        tluser.username = item.username;
        tluser.nickname = item.nickname;
        tluser.remarkName = item.remarkname;
        tluser.avatar = item.avatar;
        tluser.mood = item.mood;
        [friendListArray addObject:tluser];
    }
    
    return friendListArray;
}

- (void) updateFriendList:(NSArray *)data toUser:(NSString *)username           // 更新好友列表
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"update friend list, Don't find user: %@ in DB", username);
        return;
    }
    
    for (TLUser *tluser in data) {
        Friend *item = [self getFriendListUserItem:tluser.username fromUser:username];
        if (item == nil) {
            item = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:_managedObjectContext];
            item.username = tluser.username;
            item.whoseFriend = user;
        }
        item.nickname = tluser.nickname;
        item.remarkname = tluser.remarkName;
        item.avatar = tluser.avatar;
        item.mood = tluser.mood;
    }
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
}

- (void) addFriend:(TLUser *)userItem toUser:(NSString *)username
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"add friend, Don't find user: %@ in DB", username);
        return;
    }
    
    Friend *item = [self getFriendListUserItem:user.username fromUser:username];
    if (item == nil) {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:_managedObjectContext];
        item.username = userItem.username;
        item.whoseFriend = user;
    }
    
    item.nickname = userItem.nickname;
    item.remarkname = userItem.remarkName;
    item.avatar = userItem.avatar;
    item.mood = userItem.mood;
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
}

- (Friend *) getFriendListUserItem : (NSString *) friendName fromUser: (NSString *) username
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"get friend list item, Don't find user: %@ in DB", username);
        return nil;
    }
    
    for (Friend *item in user.friends) {
        if ([item.username isEqualToString:friendName]) {
            return item;
        }
    }
    return nil;
}

- (TLUser *) getFriendListItem: (NSString *) friendName fromUser: (NSString *) username
{
    Friend *item = [self getFriendListUserItem:friendName fromUser:username];
    if (item != nil) {
        TLUser *tluser = [[TLUser alloc] init];
        tluser.username = item.username;
        tluser.nickname = item.nickname;
        tluser.remarkName = item.remarkname;
        tluser.avatar = item.avatar;
        tluser.mood = item.mood;
        return tluser;
    }
    
    return nil;
}

- (BOOL) removeFriend:(NSString *)friendName fromUser:(NSString *)username
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"remove friend, Don't find user: %@ in DB", username);
        return NO;
    }
    
    Friend *item = [self getFriendListUserItem:friendName fromUser:username];
    if (item == nil) {
        return NO;
    }
    
    [user removeFriendsObject:item];
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
    
    return YES;
}

#pragma mark - chat rec

- (NSMutableArray *) getChatRecordFromUser:(NSString *)username toFriend:(NSString *)friendName
{
    [chatRecArray removeAllObjects];
    Friend *friend = [self getFriendListUserItem:friendName fromUser:username];
    if (friend == nil){
        NSLog(@"Don't find friend: %@ in DB", friendName);
        return chatRecArray;
    }
    
    for (ChatRec *message in friend.chatRec) {
        TLMessage *msgRec = [[TLMessage alloc] init];
        msgRec.type = message.type.intValue;
        msgRec.text = message.text;
        msgRec.length = message.length;
        msgRec.from = message.from;
        msgRec.to = message.to;
        msgRec.fromMe = message.fromMe.boolValue;
        msgRec.date = message.date;
        if (msgRec.type == TLMessageTypeVoice) {
            msgRec.mediaPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_VOICE, message.media];
        }
        else if(msgRec.type == TLMessageTypeVideo){
            msgRec.mediaPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_VIDEO, message.media];
            msgRec.photoPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_IMAGE, message.image];
        }
        else if(msgRec.type == TLMessageTypePhoto){
            msgRec.photoPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_IMAGE, message.image];
        }
        
        [chatRecArray addObject:msgRec];
    }
    
    return chatRecArray;
}

- (void) addChatRecordItem:(TLMessage *)message from:(NSString *)friendname toUser:(NSString *)username
{
    Friend *friend = [self getFriendListUserItem:friendname fromUser:username];
    if (friend == nil){
        NSLog(@"Add Chat Rec Failed! Don't find friend: %@ in DB", friendname);
        return;
    }
    
    ChatRec *chatrec = [NSEntityDescription insertNewObjectForEntityForName:@"ChatRec" inManagedObjectContext:_managedObjectContext];
    chatrec.type = [NSNumber numberWithInt:message.type];
    chatrec.image = [message.photoPath lastPathComponent];
    chatrec.media = [message.mediaPath lastPathComponent];
    chatrec.text = message.text;
    chatrec.length = message.length;
    chatrec.from = message.from;
    chatrec.to = message.to;
    chatrec.fromMe = [NSNumber numberWithBool: message.fromMe];
    chatrec.date = message.date;
    
    chatrec.whoseChatRec = friend;
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
}

- (BOOL) removeAllChatRecordFromUser:(NSString *)username
{
    User *user = [self getUserByUsername:username];
    if (user == nil) {
        NSLog(@"remove all char rec, Don't find user: %@ in DB", username);
        return NO;
    }
    
    for (Friend *friend in user.friends) {
        //  [friend removeChatRec:friend.chatRec];
        for (ChatRec *item in friend.chatRec) {
            item.whoseChatRec = nil;
        }
    }
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
    
    return YES;
}

- (BOOL) removeChatRecordByFriendName:(NSString *)friendName toUser:(NSString *)username
{
    Friend *friend = [self getFriendListUserItem:friendName fromUser:username];
    if (friend == nil){
        NSLog(@"Don't find friend: %@ in DB", friendName);
        return NO;
    }
    
    //  [friend removeChatRec:friend.chatRec];
    for (ChatRec *item in friend.chatRec) {
        item.whoseChatRec = nil;
    }
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
    return YES;
}

#pragma mark - setting
- (TLInfo *) getSettingInfoFromUser:(NSString *)username
{
    User *user = [self getUserByUsername:username];
    Setting *setting = user.setting;
    
    curSettingInfo.recNewMsg = setting.recNewMsg.boolValue;
    curSettingInfo.showMsgDetail = setting.msgShowDetail.boolValue;
    curSettingInfo.audio = setting.audio.boolValue;
    curSettingInfo.shock = setting.shock.boolValue;
    curSettingInfo.nightModal = setting.nightModal.boolValue;
    
    return curSettingInfo;
}

- (BOOL) setSettingInfo:(TLInfo *)info toUser:(NSString *)username
{
    User *user = [self getUserByUsername:username];
    Setting *setting = [NSEntityDescription insertNewObjectForEntityForName:@"Setting" inManagedObjectContext:_managedObjectContext];
    
    setting.recNewMsg = [NSNumber numberWithBool: info.recNewMsg];
    setting.msgShowDetail = [NSNumber numberWithBool: info.showMsgDetail];
    setting.audio = [NSNumber numberWithBool:info.audio];
    setting.shock = [NSNumber numberWithBool:info.shock];
    setting.nightModal = [NSNumber numberWithBool:info.nightModal];
    user.setting = setting;
    
    NSError *error = nil;
    BOOL success = [_managedObjectContext save:&error];
    if (!success) {
        [NSException raise:@"数据库存储错误" format:@"%@", [error localizedDescription]];
    }
    return YES;
}

@end
