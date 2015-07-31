//
//  TLUserCenter.m
//  twoFace
//
//  Created by h1r0 on 15/4/12.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "TLUserCenter.h"
#import "TLPath.h"
#import "ASIHTTPRequest.h"
#import "TLUser.h"
#import "TLStream.h"
#import "TLNetCenter.h"
#import "TLInfo.h"
#import "TLPosition.h"

@interface TLUserCenter ()<ASIHTTPRequestDelegate>

@end

@implementation TLUserCenter

- (id) initWithStream:(TLStream *)stream
{
    if (self = [super init]) {
        _stream = stream;
    }
    return self;
}

- (void) ckeckUsernameIllegal: (NSString *) username;
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", PATH_HOST, PATH_CHECK_USERNAME, username];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_USERNAMEILLEGAL];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) modifyPassword:(NSString *)newPassword oldPassword:(NSString *)oldPassword
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_MODIFY_PASSWORD];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:newPassword forKey:@"new_password"];
    [dic setObject:oldPassword forKey:@"old_password"];
    
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter put:json toURL:url andTag:TAG_MODIFYPASSWORD];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (TLUser *) getUserAccountInfoByUsername: (NSString *) username
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", PATH_HOST, PATH_USER_INFO, username];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:0];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error)
        return nil;
    
    NSData *data = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"error request:\n%@", error);
        return nil;
    }
    
    NSString *status = [dic objectForKey:@"status"];
    if ([status isEqualToString:@"success"]) {
        NSDictionary *content = [dic objectForKey: @"content"];
        TLUser *user = [[TLUser alloc] init];
        user.username = [content objectForKey:@"username"];
        user.gender = [content objectForKey:@"gender"];
        user.avatar = [content objectForKey:@"avatar"];
        user.nickname = [content objectForKey:@"nick_name"];
        user.mood = [[content valueForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [dic valueForKey: @"mood"];
        return user;
    }
    else{
        return nil;
    }
}

- (void) getUserAccountDetailInfoByUsername:(NSString *)username
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@", PATH_HOST, PATH_USER_INFO, username, PATH_USER_DETAIL_INFO];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_ACCOUNTDETAILEDINFO];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) modifyRemarkName:(NSString *)remarkname toUser:(NSString *)username
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_MODIFY_REMARDKNAME];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:username forKey:@"username"];
    [dic setObject:remarkname forKey:@"remark"];
    
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter put:json toURL:url andTag:TAG_MODIFYREMARKNAME];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
    //NSLog(@"success");
}

- (void) deleteFriendByUsername:(NSString *)username
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_DELETE_FRIEND];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:username forKey:@"username"];
    
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter post:json toURL:url andTag:TAG_MODIFYREMARKNAME];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) modifySelfAccountDetailedInfo: (TLUser *) user
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_MODIFY_SELF_INFO];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:user.nickname forKey:@"nick_name"];
    [dic setValue:user.gender forKey:@"gender"];
    [dic setValue:user.avatar forKey:@"avatar"];
    [dic setValue:user.mood forKey:@"mood"];
    [dic setValue:user.birthday forKey:@"birthday"];
    [dic setValue:user.emotionCondition forKey:@"emotion_condition"];
    [dic setValue:user.hometown forKey:@"hometown"];
    [dic setValue:user.location forKey:@"location"];
    [dic setValue:user.company forKey:@"company"];
    [dic setValue:user.school forKey:@"school"];
    [dic setValue:user.career forKey:@"career"];
    
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter put:json toURL:url andTag:TAG_MODIFYDETAILINFO];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) modifyPermission:(TLInfo *)info
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_MODIFY_PERMISSTION];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:info.lockDetailInfo forKey:@"lock_detail"];
    [dic setValue:info.applyWithoutUnlock forKey:@"apply_without_unlock"];
    [dic setValue:info.addFriendWay forKey:@"add_friend_setting"];
    [dic setValue:info.gameID forKey:@"game_id"];
    [dic setValue:info.gameDiff forKey:@"game_difficulty"];

    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter put:json toURL:url andTag:TAG_MODIFYPERMISSTION];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) getPermissionByUsername:(NSString *)username
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", PATH_HOST, PATH_USER_PERMISSTION, username];
    NSURL *url = [NSURL URLWithString:urlString];

    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_GETPERMISSTION];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) searchFriendByKeyword:(NSString *)keyword
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", PATH_HOST, PATH_SEARCH_FRIEND, keyword];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_SEARCHFRIEND];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) getTravelData
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_TRAVEL];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_TRAVEL];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) getFriendRecommend
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_FRIEND_RECOMMEND];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_FRIENDRECOMMEND];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) addFriendByUsername:(NSString *)username andMessage:(NSString *)message
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_ADD_FRIEND];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: username forKey:@"username"];
    message == nil ? nil:[dic setObject: message forKey:@"message"];
    NSError *error;
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter post:json toURL:url andTag:TAG_ADDFRIEND];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) getFriendAroundMe: (float) longitude  latitude: (float)latitude
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_SHAKE];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    [dic setObject: [NSString stringWithFormat:@"%f", latitude] forKey:@"latitude"];
    NSError *error;
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter post:json toURL:url andTag:TAG_FRIENDAROUNDME];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) getMyFriendList
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_MY_FRIEND_LIST];
    NSURL *url = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_MYFRIENDLIST];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) sendFeedbackTitle:(NSString *)title detail:(NSString *)text
{
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_FEEDBACK];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSError *error;
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:title forKey:@"title"];
    [dic setObject:text forKey:@"content"];
    
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error) {
        NSLog(@"error json:\n%@", error);
        return;
    }
    
    ASIHTTPRequest *request = [TLNetCenter post:json toURL:url andTag:TAG_FEEDBACK];
    [request addRequestHeader:AUTH_TOKEN value:_stream.token];
    request.delegate = self;
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSData *data = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"error request:\n%@", error);
        return;
    }
    
    NSString *status = [dic objectForKey:@"status"];
    switch (request.tag) {
        case TAG_ACCOUNTDETAILEDINFO:
        {
            if ([status isEqualToString:@"success"]) {
                NSDictionary *content = [dic objectForKey:@"content"];
                [self getUserAccountDetailedInfoSuccessfully:content];
            }
            else if ([status isEqualToString:@"error"]) {
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate getUserDetailedAccountInfoFinishedWithStatus:NO info:nil error:content];
            }
        }
            break;
        case TAG_USERNAMEILLEGAL:
        {
            [self.delegate getUsernameIllegalFinishedWithStatus:YES data:[dic objectForKey:@"content"] error: nil];
        }
            break;
        case TAG_SEARCHFRIEND:
        {
            if ([status isEqualToString:@"success"]) {
                NSArray *content = [dic objectForKey:@"content"];
                NSMutableArray *data = [[NSMutableArray alloc] init];
                for (NSDictionary * item in content) {
                    TLUser *user = [[TLUser alloc] init];
                    user.username = [item objectForKey:@"username"];
                    user.nickname = [item objectForKey:@"nick_name"];
                    user.avatar = [item objectForKey:@"avatar"];
                    user.mood = [[item objectForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [item valueForKey: @"mood"];
                    user.gender = [item objectForKey:@"gender"];
                    NSDictionary *userPermission = [item objectForKey:@"permission"];
                    user.gameInfo = [[TLInfo alloc] init];
                    user.gameInfo.lockDetailInfo = [userPermission objectForKey:@"lock_detail"];
                    user.gameInfo.addFriendWay = [userPermission objectForKey:@"add_friend_setting"];
                    user.gameInfo.gameDiff = [userPermission objectForKey:@"game_difficulty"];
                    user.gameInfo.gameID = [userPermission objectForKey:@"game_id"];
                    user.gameInfo.applyWithoutUnlock = [userPermission objectForKey:@"apply_without_unlock"];
                    [data addObject:user];
                }
                [self.delegate searchFriendFinishedWithStatus:YES data:data error:nil];
            }
            else{
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate searchFriendFinishedWithStatus:NO data:nil error:content];
            }
        }
            break;
        case TAG_ADDFRIEND:
        {
            if ([status isEqualToString:@"success"]) {
                [self.delegate addFriendFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]) {
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate addFriendFinishedWithStatus:NO error:content];
            }
        }
            break;
        case TAG_FRIENDAROUNDME:
        {
            NSMutableArray *data = [[NSMutableArray alloc] init];
            if ([status isEqualToString:@"success"]) {
                NSArray *content = [dic objectForKey:@"content"];
                for (NSDictionary *item in content) {
                    TLUser *user = [[TLUser alloc] init];
                    user.latitude = [item objectForKey:@"latitude"];
                    user.longitude = [item objectForKey:@"longitude"];
                    user.distance = [item objectForKey:@"distance"];
                    user.createTime = [item objectForKey:@"create_time"];
                    NSDictionary *s_item = [item objectForKey:@"user_info"];
                    user.username = [s_item objectForKey:@"username"];
                    user.nickname = [s_item objectForKey:@"nick_name"];
                    user.gender = [s_item objectForKey:@"gender"];
                    user.avatar = [s_item objectForKey:@"avatar"];
                    NSDictionary *userPermission = [s_item objectForKey:@"user_permission"];
                    user.gameInfo = [[TLInfo alloc] init];
                    user.gameInfo.lockDetailInfo = [userPermission objectForKey:@"lock_detail"];
                    user.gameInfo.addFriendWay = [userPermission objectForKey:@"add_friend_setting"];
                    user.gameInfo.gameDiff = [userPermission objectForKey:@"game_difficulty"];
                    user.gameInfo.gameID = [userPermission objectForKey:@"game_id"];
                    user.gameInfo.applyWithoutUnlock = [userPermission objectForKey:@"apply_without_unlock"];
                    [data addObject:user];
                }
                [self.delegate getFriendAroundMeFinishedWithStatus:YES data:data error:nil];
            }
            else if ([status isEqualToString:@"error"]) {
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate getFriendAroundMeFinishedWithStatus:NO data:nil error:content];
            }
        }
            break;
        case TAG_MYFRIENDLIST:
        {
            if ([status isEqualToString:@"success"]) {
                NSArray *content = [dic objectForKey:@"content"];
                NSMutableArray *data = [[NSMutableArray alloc] init];
                for (NSDictionary *item in content) {
                    TLUser *user = [[TLUser alloc] init];
                    user.status = [item objectForKey:@"status"];
                    user.createTime = [item objectForKey:@"createtime"];
                    user.remarkName = [item objectForKey:@"remark"];
                    user.distance = [item objectForKey:@"distance"];

                    NSDictionary *friend = [item objectForKey:@"friend"];
                    user.username = [friend objectForKey:@"username"];
                    user.nickname = [friend objectForKey:@"nick_name"];
                    user.avatar = [friend objectForKey:@"avatar"];
                    user.age = [friend objectForKey:@"age"];
                    user.gender = [friend objectForKey:@"gender"];
                    user.emotionCondition = [friend objectForKey:@"emmotion_condition"];
                    user.credit = [friend objectForKey:@"credit"];
                    user.mood = [[friend valueForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [friend valueForKey: @"mood"];
                    [data addObject:user];
                }
                [self.delegate getFriendListFinishedWithStatus:YES data:data error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate getFriendListFinishedWithStatus:NO data:nil error:content];
            }
        }
            break;
        case TAG_MODIFYDETAILINFO:
        {
            if ([status isEqualToString:@"success"]) {
                [self.delegate modifySelfDetailInfoFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate modifySelfDetailInfoFinishedWithStatus:NO error:content];
            }

        }
            break;
        case TAG_MODIFYPASSWORD:
        {
            if ([status isEqualToString:@"success"]) {
                [self.delegate modifyPasswordFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate modifyPasswordFinishedWithStatus:NO error:content];
            }
        }
            break;
        case TAG_MODIFYPERMISSTION:
        {
            if ([status isEqualToString:@"success"]) {
                [self.delegate modifyPermissionFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate modifyPermissionFinishedWithStatus:NO error:content];
            }
        }
            break;
        case TAG_GETPERMISSTION:
        {
            if ([status isEqualToString:@"success"]) {
                TLInfo *info = [[TLInfo alloc] init];
                
                NSDictionary *content = [dic objectForKey:@"content"];
                info.username = [content objectForKey:@"username"];
                info.lockDetailInfo = [content objectForKey:@"lock_detail"];
                info.applyWithoutUnlock = [content objectForKey:@"apply_without_unlock"];
                info.addFriendWay = [content objectForKey:@"add_friend_setting"];
                info.gameID = [content objectForKey:@"game_id"];
                info.gameDiff = [content objectForKey:@"game_difficulty"];
                
                [self.delegate getPermissionFinishedWithStatus:YES info:info error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate getPermissionFinishedWithStatus:NO info:nil error:content];
            }
        }
            break;
        case TAG_FEEDBACK:
            if ([status isEqualToString:@"success"]) {
                [self.delegate sendFeedbackFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate sendFeedbackFinishedWithStatus:NO error:content];
            }
            break;
        case TAG_MODIFYREMARKNAME:
            if ([status isEqualToString:@"success"]) {
                [self.delegate modifyRemarkNameFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate modifyRemarkNameFinishedWithStatus:NO error:content];
            }
            break;
        case TAG_DELETEFRIEND:
            if ([status isEqualToString:@"success"]) {
                [self.delegate deleteFriendFinishedWithStatus:YES error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate deleteFriendFinishedWithStatus:NO error:content];
            }
            break;
        case TAG_TRAVEL:
            if ([status isEqualToString:@"success"]){
                NSMutableArray *data = [[NSMutableArray alloc]init];
                NSArray *content = [dic objectForKey:@"content"];
                for (NSDictionary *item in content) {
                    TLPosition *pos = [[TLPosition alloc] init];
                    pos.cityName = [item objectForKey:@"name"];
                    pos.latitude = [item objectForKey:@"latitude"];
                    pos.longitude = [item objectForKey:@"longitude"];
                    [data addObject:pos];
                }
                [self.delegate getTravelDataFinishedWithStatus:YES data:data error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate getTravelDataFinishedWithStatus:NO data:nil error:content];
            }
            break;
        case TAG_FRIENDRECOMMEND:
        {
            if ([status isEqualToString:@"success"]) {
                NSArray *content = [dic objectForKey:@"content"];
                NSMutableArray *data = [[NSMutableArray alloc] init];
                for (NSDictionary *item in content) {
                    TLUser *user = [[TLUser alloc] init];
                    user.username = [item objectForKey:@"username"];
                    user.nickname = [item objectForKey:@"nick_name"];
                    user.avatar = [item objectForKey:@"avatar"];
                    user.mood = [[item objectForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [item valueForKey: @"mood"];
                    user.gender = [item objectForKey:@"gender"];
                    user.age = [item objectForKey:@"age"];
                    user.credit = [item objectForKey:@"credit"];
                    NSDictionary *userPermission = [item objectForKey:@"permission"];
                    user.gameInfo = [[TLInfo alloc] init];
                    user.gameInfo.lockDetailInfo = [userPermission objectForKey:@"lock_detail"];
                    user.gameInfo.addFriendWay = [userPermission objectForKey:@"add_friend_setting"];
                    user.gameInfo.gameDiff = [userPermission objectForKey:@"game_difficulty"];
                    user.gameInfo.gameID = [userPermission objectForKey:@"game_id"];
                    user.gameInfo.applyWithoutUnlock = [userPermission objectForKey:@"apply_without_unlock"];
                    [data addObject:user];
                }
                [self.delegate getFriendRecommendFinishedWithStatus:YES data:data error:nil];
            }
            else if ([status isEqualToString:@"error"]){
                NSString *content = [dic objectForKey:@"content"];
                [self.delegate getFriendRecommendFinishedWithStatus:NO data:nil error:content];
            }
        }
            break;
        default:
            break;
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSString *content = [request.error description];
    switch (request.tag) {
        case TAG_ACCOUNTDETAILEDINFO:
            [self.delegate getUserDetailedAccountInfoFinishedWithStatus:NO info:nil error:content];
            break;
        case TAG_USERNAMEILLEGAL:
            [self.delegate getUserDetailedAccountInfoFinishedWithStatus:NO info:nil error:content];
            break;
        case TAG_SEARCHFRIEND:
            [self.delegate searchFriendFinishedWithStatus:NO data:nil error:content];
            break;
        case TAG_ADDFRIEND:
            [self.delegate addFriendFinishedWithStatus:NO error:content];
            break;
        case TAG_FRIENDAROUNDME:
            [self.delegate getFriendAroundMeFinishedWithStatus:NO data:nil error:content];
            break;
        case TAG_MYFRIENDLIST:
            [self.delegate getFriendListFinishedWithStatus:NO data:nil error:content];
            break;
        case TAG_MODIFYDETAILINFO:
            [self.delegate modifySelfDetailInfoFinishedWithStatus:NO error:content];
            break;
        case TAG_MODIFYPASSWORD:
            [self.delegate modifyPasswordFinishedWithStatus:NO error:content];
            break;
        case TAG_MODIFYPERMISSTION:
            [self.delegate modifyPermissionFinishedWithStatus:NO error:content];
            break;
        case TAG_GETPERMISSTION:
            [self.delegate getPermissionFinishedWithStatus:NO info:nil error:content];
            break;
        case TAG_FEEDBACK:
            [self.delegate sendFeedbackFinishedWithStatus:NO error:content];
            break;
        case TAG_TRAVEL:
            [self.delegate getTravelDataFinishedWithStatus:NO data:nil error:content];
            break;
        case TAG_FRIENDRECOMMEND:
            [self.delegate getFriendRecommendFinishedWithStatus:NO data:nil error:content];
            break;
        default:
            break;
    }
}

#pragma mark - request info

- (void) getUserAccountDetailedInfoSuccessfully: (NSDictionary *) dic
{
    TLUser *user = [[TLUser alloc] init];
    user.username = [dic objectForKey:@"username"];
    user.gender = [dic objectForKey:@"gender"];
    user.avatar = [dic objectForKey:@"avatar"];
    user.nickname = [dic objectForKey:@"nick_name"];
    user.mood = [[dic valueForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [dic valueForKey: @"mood"];
    user.age = [dic objectForKey:@"age"];
    user.constellation = [dic objectForKey:@"constellation"];
    user.createTime = [dic objectForKey:@"create_time"];
    user.birthday = [dic objectForKey:@"birthday"];
    user.hometown = [dic objectForKey:@"hometown"];
    user.location = [dic objectForKey:@"location"];
    user.company = [dic objectForKey:@"company"];
    user.school = [dic objectForKey:@"school"];
    user.career = [dic objectForKey:@"career"];
    user.emotionCondition = [dic objectForKey:@"emotion_condition"];
    user.remarkName = [dic objectForKey:@"remark"];
    [self.delegate getUserDetailedAccountInfoFinishedWithStatus:YES info:user error:nil];
}


@end
