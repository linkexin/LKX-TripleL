//
//  TLStream.m
//  twoFace
//
//  Created by 李伯坤 on 15/4/10.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "TLStream.h"
#import "TLPath.h"
#import "TLUser.h"
#import "TLNetCenter.h"
#import "ASIHTTPRequest.h"

@interface TLStream () <ASIHTTPRequestDelegate>

@end

@implementation TLStream

- (void) userLogin:(TLUser *)user
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: user.username forKey:@"username"];
    [dic setObject: user.password forKey:@"password"];
    [dic setObject: user.latitude forKey:@"latitude"];
    [dic setObject: user.longitude forKey:@"longtitude"];
    
    NSError *error;
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error != nil) {
        NSLog(@"error: %@", error);
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_LOGIN];
    NSURL *url = [NSURL URLWithString:str];
    
    ASIHTTPRequest *request = [TLNetCenter post:json toURL:url andTag:TAG_LOGIN];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) userRegister:(TLUser *)user
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: user.username forKey:@"username"];
    [dic setObject: user.nickname forKey:@"nick_name"];
    [dic setObject: user.password forKey:@"password"];
    [dic setObject: user.gender forKey:@"gender"];
    [dic setObject: user.birthday forKey:@"birthday"];
    [dic setObject: user.avatar forKey:@"avatar"];
    [dic setObject: user.latitude forKey:@"latitude"];
    [dic setObject: user.longitude forKey:@"longtitude"];
    
    NSError *error;
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error != nil) {
        NSLog(@"json error: %@", error);
        return;
    }
    
    NSString *str = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_REGISTER];
    NSURL *url = [NSURL URLWithString:str];
    
    ASIHTTPRequest *request = [TLNetCenter post:json toURL:url andTag:TAG_REGISTER];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) refreshUserInfo
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@", PATH_HOST, PATH_USER_INFO, self.user.username];
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [TLNetCenter getByUrl:url tag:TAG_UPDATE];
    [request addRequestHeader:AUTH_TOKEN value:self.token];
    request.delegate = self;
    [request startAsynchronous];
}


#pragma mark - ASIHttpRequest Dalegate

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
    NSData *data = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"error request:\n%@", error);
        return;
    }
    switch (request.tag) {
        case TAG_LOGIN:
            [self loginRequestInfo:dic];
            break;
        case TAG_REGISTER:
            [self registerRequestInfo:dic];
            break;
        case TAG_UPDATE:
            if ([[dic objectForKey:@"status"] isEqualToString:@"success"]) {
                NSDictionary *content = [dic objectForKey: @"content"];
                self.user.username = [content objectForKey:@"username"];
                self.user.gender = [content objectForKey:@"gender"];
                self.user.avatar = [content objectForKey:@"avatar"];
                self.user.nickname = [content objectForKey:@"nick_name"];
                self.user.mood = [[content objectForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [content valueForKey: @"mood"];
                [self.delegate refreshInfoFinishedWithStatus:YES];
            }
            else {
                [self.delegate refreshInfoFinishedWithStatus:NO];
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
        case TAG_LOGIN:
            [self.delegate loginFinishedWithStatus:NO userInfo:nil error:content];
            break;
        case TAG_REGISTER:
            [self.delegate registerFinishedWithStatus:NO userInfo:nil error:content];
            break;
        case TAG_UPDATE:
            [self.delegate refreshInfoFinishedWithStatus:NO];
            break;
        default:
            break;
    }

}

#pragma mark - requestInfo

- (void) loginRequestInfo: (NSDictionary *)dic
{
    NSString *status = [dic objectForKey:@"status"];
    if ([status isEqualToString:@"success"]) {
        NSDictionary *data = [dic objectForKey:@"content"];
        NSString *token = [data objectForKey:@"token"];
        NSDictionary *userDic = [data objectForKey:@"user"];
        _token = token;
        _user = [[TLUser alloc] init];
        _user.username = [userDic objectForKey:@"username"];
        _user.nickname = [userDic objectForKey:@"nick_name"];
        _user.gender = [userDic objectForKey:@"gender"];
        _user.avatar = [userDic objectForKey:@"avatar"];
        _user.mood = [[userDic valueForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [userDic valueForKey: @"mood"];
        _user.birthday = [userDic objectForKey:@"birthday"];
        [self.delegate loginFinishedWithStatus:YES userInfo:_user error:nil];
    }
    else if([status isEqualToString:@"error"]){
        NSString *content = [dic objectForKey:@"content"];
        [self.delegate loginFinishedWithStatus:NO userInfo:nil error:content];
    }
}

- (void) registerRequestInfo: (NSDictionary *)dic
{
    NSString *status = [dic objectForKey:@"status"];
    if ([status isEqualToString:@"success"]) {
        NSDictionary *data = [dic objectForKey:@"content"];
        NSString *token = [data objectForKey:@"token"];
        NSDictionary *userDic = [data objectForKey:@"user"];
        _token = token;
        _user = [[TLUser alloc] init];
        _user.username = [userDic objectForKey:@"username"];
        _user.nickname = [userDic objectForKey:@"nick_name"];
        _user.gender = [userDic objectForKey:@"gender"];
        _user.avatar = [userDic objectForKey:@"avatar"];
        _user.birthday = [userDic objectForKey:@"birthday"];
        _user.mood = [[userDic valueForKey:@"mood"] isEqual: [NSNull null]] ? DEFAULT_EMPTY_MOOD : [userDic valueForKey: @"mood"];
        [self.delegate registerFinishedWithStatus:YES userInfo:_user error:nil];
    }
    else if([status isEqualToString:@"error"]){
        NSString *content = [dic objectForKey:@"content"];
        [self.delegate registerFinishedWithStatus:NO userInfo:nil error:content];
    }
}

@end
