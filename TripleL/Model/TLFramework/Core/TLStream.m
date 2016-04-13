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
#import "AFNetworking.h"

@implementation TLStream

- (void)userLogin:(TLUser *)user
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];

    NSDictionary *dic = @{@"username": user.username,
                          @"password": user.password,
                          @"latitude": user.latitude,
                          @"longtitude": user.longitude
                          };

    NSString *urlstr = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_LOGIN];
    [sessionManager POST:urlstr
              parameters:dic
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *_Nonnull responseDic) {
                     NSString *status = [responseDic objectForKey:@"status"];
                     if ([status isEqualToString:@"success"]) {
                         NSDictionary *data = [responseDic objectForKey:@"content"];
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
                         NSString *content = [responseDic objectForKey:@"content"];
                         [self.delegate loginFinishedWithStatus:NO userInfo:nil error:content];
                     }
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     [self.delegate loginFinishedWithStatus:NO userInfo:nil error:@"登录失败"];
                     NSLog(@"%@", error);
                 }];
}

- (void)userRegister:(TLUser *)user
{
    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_REGISTER];
    NSDictionary *dic = @{@"username": user.username,
                          @"nick_name": user.nickname,
                          @"password": user.password,
                          @"gender": user.gender,
                          @"birthday": user.birthday,
                          @"avatar": user.avatar,
                          @"latitude": user.latitude,
                          @"longtitude": user.longitude
                        };

    [sessionManager POST:urlStr
              parameters:dic
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* _Nullable responseDic) {
                     NSString *status = [responseDic objectForKey:@"status"];
                     if ([status isEqualToString:@"success"]) {
                         NSDictionary *data = [responseDic objectForKey:@"content"];
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
                         NSString *content = [responseDic objectForKey:@"content"];
                         [self.delegate registerFinishedWithStatus:NO userInfo:nil error:content];
                     }
                 }
                 failure:
                ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [self.delegate registerFinishedWithStatus:NO userInfo:nil error:@"注册失败"];
                    NSLog(@"%@", error);
     }];
}

- (void)refreshUserInfo
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", PATH_HOST, PATH_USER_INFO, self.user.username];

    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    [sessionManager.requestSerializer setValue:self.token forHTTPHeaderField:AUTH_TOKEN];
    [sessionManager POST:urlStr
              parameters:nil
                progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary* _Nullable responseDic) {
                     if ([[responseDic objectForKey:@"status"] isEqualToString:@"success"]) {
                         NSDictionary *content = [responseDic objectForKey: @"content"];
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

                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     [self.delegate refreshInfoFinishedWithStatus:NO];
                 }];

}

@end
