//
//  MyServer.m
//  twoFace
//
//  Created by 李伯坤 on 15/4/10.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MyServer.h"
#import "TLFramework.h"
#import "MyHeader.h"
#import "ChatViewController.h"
#import "MsgRecordItem.h"
#import "LTHPasscodeViewController.h"
#import "RootViewController.h"
#import "AudioTool.h"
#import <CoreLocation/CoreLocation.h>

static MyServer *server = nil;
static TLStream *stream = nil;
static TLNetCenter *netCenter = nil;
static TLUserCenter *userCenter = nil;
static TLCommunication *communication = nil;
static TLTimeLine *timeLine = nil;

@interface MyServer () <TLStreamDelegate, TLNetCenterDelegate, TLUserCenterDelegate, TLCommunicationDelegate>
{
    TLInfo *curSetingInfo;
}

@end

@implementation MyServer

+ (MyServer *) getServer
{
    if (server == nil) {
        server = [[MyServer alloc] init];
        stream = [[TLStream alloc] init];
        stream.delegate = server;
        netCenter = [[TLNetCenter alloc] init];
        netCenter.delegate = server;
        userCenter = [[TLUserCenter alloc] initWithStream:stream];
        userCenter.delegate = server;
        communication = [[TLCommunication alloc] initWithStream: stream delegate:server];
        timeLine = [[TLTimeLine alloc] initWithStream:stream];
    }
    
    return server;
}

- (NSString *) getAUTH_TOKEN
{
    return stream.token;
}

- (void) loginWithUsername:(NSString *)username andPassword:(NSString *)password
{
    TLUser *user = [[TLUser alloc] init];
    user.username = username;
    user.password = password;
    CLLocationCoordinate2D location = [UIDevice getPostion];
    user.latitude = [NSString stringWithFormat:@"%lf", location.latitude];
    user.longitude = [NSString stringWithFormat:@"%lf", location.longitude];
    [stream userLogin:user];
}


- (void) registerWithUsername:(NSString *)username nickname:(NSString *)nickname password:(NSString *)password gender:(NSString *)gender birthday:(NSString *)birthday avatarPath:(NSString *)avatarPath
{
    TLUser *user = [[TLUser alloc] init];
    user.username = username;
    user.nickname = nickname;
    user.password = password;
    user.gender = gender;
    user.birthday = birthday;
    user.avatar = avatarPath;
    CLLocationCoordinate2D location = [UIDevice getPostion];
    user.latitude = [NSString stringWithFormat:@"%lf", location.latitude];
    user.longitude = [NSString stringWithFormat:@"%lf", location.longitude];
    [stream userRegister:user];
}

- (void) logout
{
    [DataCenter reset];
    [communication disConnect];
}

- (void) ckeckUsernameIllegal: (NSString *) username;
{
    [userCenter ckeckUsernameIllegal:username];
}

- (void) modifyPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword
{
    [userCenter modifyPassword:newPassword oldPassword:oldPassword];
}

- (void) getUserPermisstionByUsername:(NSString *)username
{
    [userCenter getPermissionByUsername:username];
}

- (void) modifySelfPermisstion:(TLInfo *)info
{
    [userCenter modifyPermission:info];
}

- (void) uploadImageByPath:(NSString *)path
{
    [netCenter uploadImageByPath:path];
}

- (void) downloadImageFromURL:(NSURL *)url
{
    [netCenter downloadImageByURL:url];
}

- (TLUser *) getSelfAccountInfo
{
    return stream.user;
}

- (void) modifySelfAccountDetailInfo:(TLUser *)user
{
    [userCenter modifySelfAccountDetailedInfo:user];
}

- (void) getUserAccountDetailedInfoByUsername:(NSString *)username
{
    [userCenter getUserAccountDetailInfoByUsername:username];
}

- (TLUser *) getUserAccountInfoByUsername:(NSString *)username
{
    TLUser *user = [[DataCenter getDataCenter] getFriendListItem:username fromUser:[self getSelfAccountInfo].username];
    if (user == nil) {
        user = [userCenter getUserAccountInfoByUsername:username];
    }
    return user;
}

- (void) searchFriendByKeyword:(NSString *)keyword
{
    [userCenter searchFriendByKeyword:keyword];
}

- (void) addFriendByUsername:(NSString *)username andMessage: (NSString *) message
{
    [userCenter addFriendByUsername:username andMessage:message];
}

- (void) getFriendAroundMe:(float)longitude latitude:(float)latitude
{
    [userCenter getFriendAroundMe:longitude latitude:latitude];
}

- (void) getMyFriendList
{
    [userCenter getMyFriendList];
}

- (void) sendMessage:(TLMessage *)message
{
    if (curSetingInfo == nil) {
        curSetingInfo = [[DataCenter getDataCenter] getSettingInfoFromUser:[[MyServer getServer] getSelfAccountInfo].username];
    }
    [communication sendMessage:message];
    [self updateMsgRecList:message];
    
    
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH"];
    int h = [dateformatter stringFromDate:senddate].intValue;
    if (!curSetingInfo.nightModal || (curSetingInfo.nightModal && h >= 7 && h <= 22)) {
        if (curSetingInfo.audio) {
            [[AudioTool sharedAudioTool] playSendMessageAudio];
        }
    }
}

- (void) sendFriendRequestReplayWithId:(NSString *)reqID accept:(BOOL)accept
{
    [communication sendFriendRequestReplayWithId:reqID accept:accept];
}

- (void) sendFeedbackTitle: (NSString *) title detail: (NSString *) text
{
    [userCenter sendFeedbackTitle:title detail:text];
}

- (void) getTravelData
{
    [userCenter getTravelData];
}

- (void) getFriendRecommend
{
    [userCenter getFriendRecommend];
}

- (NSURLRequest *) getFriendTimelineRequest
{
    return [timeLine getFriendTimelineRequest];
}

- (NSURLRequest *) getSelfTimelineRequest
{
    return [timeLine getSelfTimelineRequest];
}

- (NSURLRequest *) getArounderTimelineRequest
{
    return [timeLine getArounderTimeLineRequest];
}

#pragma mark - TLStreamDelegate

- (void) loginFinishedWithStatus:(BOOL)status userInfo:(TLUser *)userInfo error: (NSString *) error
{
    if (status) {
        NSLog(@"login successful");
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_LOGINSUCCESSFUL object:userInfo.username];
        
        [LTHPasscodeViewController setUsername:userInfo.username andServiceName:@"iOS"];
        [[DataCenter getDataCenter] addUser:userInfo];
        [self startCommunication];
        [self getMyFriendList];
    }
    else{
        NSLog(@"login error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_LOGINFAILED object:error];
    }
}

- (void) registerFinishedWithStatus:(BOOL)status userInfo:(TLUser *)userInfo error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_REGSTERSUCCESSFUL object:nil];
        [LTHPasscodeViewController setUsername:userInfo.username andServiceName:@"iOS"];
        [[DataCenter getDataCenter] addUser:userInfo];
        [self startCommunication];
        [self getMyFriendList];
    }
    else{
        NSLog(@"register error: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_REGISTERFAILED object:nil];
    }
}

- (void) refreshInfoFinishedWithStatus:(BOOL)status
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_REFRESHUSERINFO object:nil];
    }
}

#pragma mark - TLNetworkDelegate

- (void) uploadImageFinishedWithStatus:(BOOL)status url:(NSString *)url path:(NSString *)path error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_UPLOADIMAGESUCCESSFUL object:url];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_UPLOADIMAGEFAILDE object:error];
    }
}

- (void) downloadImageFinishedWithStatus:(BOOL)status path:(NSString *)path url:(NSString *)url error:(NSString *)error
{
    if (status) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:url forKey:@"url"];
        [dic setObject:path forKey:@"path"];
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_DOWNLOADIMAGE object:dic];
    }
    else{
        NSLog(@"download image failed:\n%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_DOWNLOADIMAGEFAILED object:nil];
    }
}

#pragma mark - TLUserCenterDelegate

// 网络异常
- (void) networkAnomaly
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INFO_NETWORKANOMALY object:nil];
}

// 用户名合法性
- (void) getUsernameIllegalFinishedWithStatus:(BOOL)status data:(id) data error:(NSString *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INFO_USERNAMEISLEGAL object:data];
}

// 修改用户密码
- (void) modifyPasswordFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYPASSWORDSUCCESSFUL object:nil];
    }
    else {
        NSLog(@"modify password failed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYPASSWORDFAILED object:error];
    }
}

// 获取详细信息
- (void) getUserDetailedAccountInfoFinishedWithStatus:(BOOL)status info:(TLUser *)userInfo error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETDETAILINFOSUCCESSFUL object:userInfo];
    }
    else{
        NSLog(@"get user account info failed:\n%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETDETAILINFOFAILED object:error];
    }
}

// 修改详细信息
- (void) modifySelfDetailInfoFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        NSLog(@"modify self detail info successful");
        [stream refreshUserInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYSELFINFO object:@""];
    }
    else {
        NSLog(@"modify self detail info failed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYSELFINFO object:error];
    }
    
}

// 获取权限,游戏信息
- (void) getPermissionFinishedWithStatus:(BOOL)status info:(TLInfo *)user error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETPERMISSTIONINFOSUCCESSFUL object:user];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETPERMISSTIONINFOFAILED object:error];
        NSLog(@"get permission failed: %@", error);
    }
}

// 修改权限
- (void) modifyPermissionFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYPERMISSTIONINFOSUCCESSFUL object:nil];
    }
    else{
        NSLog(@"modify permission failed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYPERMISSTIONINFOSUCCESSFUL object:nil];
    }
}

- (void) modifyRemarkNameFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYREMARKNAMESUCCESSFUL object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_MODIFYREMARKNAMEFAILED object:error];
    }
}

- (void) deleteFriendFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_DELETEFRIENDSUCCESSFUL object:nil];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_DELETEFRIENDFAILED object:nil];
    }
}

//  搜索好友
- (void) searchFriendFinishedWithStatus:(BOOL)status data:(NSArray *)data error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_SEARCHFRIENDSUCCESSFUL object:data];
    }
    else {
        NSLog(@"search friend failed: %@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_SEARCHFRIENDFAILED object:error];
    }
}


// 添加好友
- (void) addFriendFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        NSLog(@"add friend Successful");
    }
    else {
        NSLog(@"add friend failed: %@", error);
    }
}

// 修改备注
- (void) modifyRemarkName:(NSString *)remarkname toUser:(NSString *)username
{
    [userCenter modifyRemarkName:remarkname toUser:username];
}

// 删除好友
- (void) deleteFriendByUsername:(NSString *)username
{
    [userCenter deleteFriendByUsername:username];
}

// 附近的人
- (void) getFriendAroundMeFinishedWithStatus:(BOOL)status data:(NSArray *)data error:(NSString *)error
{
    if (status) {
        NSLog(@"get friend arround me successfully, count = %lu", (unsigned long)[data count]);
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETFRIENDAROUNDME object: data];
    }
    else {
        NSLog(@"get friend around me failed: %@", error);
    }
}

// 好友列表
- (void) getFriendListFinishedWithStatus:(BOOL)status data:(NSArray *)data error:(NSString *)error
{
    if (status) {
        NSLog(@"get friend list successful, number: %lu\n", (unsigned long)data.count);
        [[DataCenter getDataCenter] updateFriendList:data toUser:[self getSelfAccountInfo].username];
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETMYFRIENDLIST object:data];
    }
    else{
        NSLog(@"get friend list faild: %@", error);
    }
}

// 地点漫游数据
- (void) getTravelDataFinishedWithStatus:(BOOL)status data:(NSArray *)data error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETTRAVELDATASUCCESSFUL object:data];
    }
    else{
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETTRAVELDATAFAILED object:error];
    }
}

// 好友推荐数据
- (void) getFriendRecommendFinishedWithStatus:(BOOL)status data:(NSArray *)data error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETFRIENDRECOMMENDSUCCESSFUL object:data];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_GETFRIENDRECOMMENDFAILED object:error];
    }
}

// 反馈
- (void) sendFeedbackFinishedWithStatus:(BOOL)status error:(NSString *)error
{
    if (status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_SENDFEEDBACKSUCCESSFUL object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:INFO_SENDFEEDBACKFAILED object:error];
    }
}
#pragma mark - TLCommunication

- (void) startCommunication
{
    [communication conection];
}

- (void) authFailed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INFO_AUTHFAILED object:nil];
}

- (void) receivedMessage:(TLMessage *)message
{
    if (curSetingInfo == nil) {
        curSetingInfo = [[DataCenter getDataCenter] getSettingInfoFromUser:[[MyServer getServer] getSelfAccountInfo].username];
    }
    ChatViewController *chatVC = [ChatViewController getChatViewController];
    
    // 推送
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = 0;
        notification.soundName = UILocalNotificationDefaultSoundName;
        if (curSetingInfo.showMsgDetail) {
            NSString *detail;
            if (message.type == TLMessageTypeText) {
                detail = message.text;
            }
            else if (message.type == TLMessageTypeVoice){
                detail = @"[语音]";
            }
            else if (message.type == TLMessageTypePhoto){
                detail = @"[图片]";
            }
            else if (message.type == TLMessageTypeVideo){
                detail = @"[视频]";
            }
            notification.alertBody = [NSString stringWithFormat:@"%@: %@", message.from, detail];
        }
        else{
            notification.alertBody = @"你有一条新消息";
        }
        notification.alertAction = @"打开";
        notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        notification.userInfo = [NSDictionary dictionaryWithObject:message.from forKey:@"username"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    // 播放声音
    NSDate * senddate=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH"];
    int h = [dateformatter stringFromDate:senddate].intValue;
    if (!curSetingInfo.nightModal || (curSetingInfo.nightModal && h >= 7 && h <= 22)) {
        if ([chatVC.friendUser.username isEqualToString:message.from]) {
            [chatVC receiveMessage:message];
            if (curSetingInfo.audio) {
                [[AudioTool sharedAudioTool] playRecMessageAudio];
            }
            if (curSetingInfo.shock) {
                [[AudioTool sharedAudioTool] playNewMessageShock];
            }
        }
        else {
            [[RootViewController getRootViewController] changeMsgCountInTabBar:1];
            if (curSetingInfo.audio) {
                [[AudioTool sharedAudioTool] playNewMessageAudio];
            }
            if (curSetingInfo.shock) {
                [[AudioTool sharedAudioTool] playNewMessageShock];
            }
        }
    }
    [self updateMsgRecList:message];
}

- (void) receivedNetNotification:(TLNotification *)noti
{
    [[NSNotificationCenter defaultCenter] postNotificationName:INFO_RECIEVEDNETNOTIFICATION object:noti];
}


- (void) updateMsgRecList: (TLMessage *) message
{
    NSString *username = [self getSelfAccountInfo].username;
    NSString *friendname = message.fromMe ? message.to : message.from;
    NSMutableArray *data = [[DataCenter getDataCenter] getMessageListFromUser:username];
    MsgRecordItem *item = nil;
    
    // 判断消息列表中是否已存在该用户的记录
    for (MsgRecordItem *i in data) {
        if ((message.fromMe && [i.username isEqualToString: message.to]) || (!message.fromMe && [i.username isEqualToString:message.from])){
            item = i;
            break;
        }
    }

    // 消息列表中没有该用户的记录，要添加新纪录
    if (item == nil) {
        item = [[MsgRecordItem alloc] init];
        [data insertObject:item atIndex:0];
        item.username = message.fromMe ? message.to : message.from;
        item.count = @"0";
        item.avatar = item.remarkName = @"";
        TLUser *user = [self getUserAccountInfoByUsername:item.username];
        item.avatar = user.avatar;
        item.remarkName = user.remarkName;
    }
    else{
        [data removeObject:item];
        [data insertObject:item atIndex:0];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    item.time =  [dateFormatter stringFromDate:message.date];
    
    // 判断消息数目是否清零
    ChatViewController *chatVC = [ChatViewController getChatViewController];
    if (([chatVC.friendUser.username isEqualToString:message.to] && message.fromMe) || (!message.fromMe && [chatVC.friendUser.username isEqualToString:message.from])) {
        item.count = @"0";
    }
    else{
        item.count = [NSString stringWithFormat:@"%d", item.count.intValue + 1];
    }
    
    // 消息类型
    if (message.type == TLMessageTypeText) {
        item.message = message.text;
    }
    else if (message.type == TLMessageTypeVoice){
        item.message = @"[语音]";
    }
    else if (message.type == TLMessageTypePhoto){
        item.message = @"[图片]";
    }
    else if (message.type == TLMessageTypeVideo){
        item.message = @"[视频]";
    }
    else{
        return;
    }
    
    [[DataCenter getDataCenter] addMessageListItem:item toUser:username];
    [[DataCenter getDataCenter] addChatRecordItem:message from:friendname toUser:username];
    [[NSNotificationCenter defaultCenter] postNotificationName:INFO_REFRESHMESSAGELIST object:nil];
}



@end
