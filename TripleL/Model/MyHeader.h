//
//  MyHeader.h
//  TripleL
//
//  Created by h1r0 on 15/4/14.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#ifndef TripleL_MyHeader_h
#define TripleL_MyHeader_h

#import "TLFramework.h"
#import "MyServer.h"
#import "DataCenter.h"
#import "AppConfig.h"
#import "DataProcessCenter.h"
#import "GameCenter.h"

#import "UIDevice+Custom.h"


// user status
#define     USER_ONLINE      @"online"
#define     USER_OFFLINE     @"offline"
#define     USER_BUSY        @"busy"

// other
#define     DEFAULT_AVATARPATH   @"defaultphoto.jpg"

// notification
#define     INFO_DOWNLOADIMAGE          @"received_image"
#define     INFO_DOWNLOADIMAGEFAILED    @"receoved_download_image_failed"
#define     INFO_GETMYFRIENDLIST           @"received_friend_list"
#define     INFO_USERNAMEISLEGAL        @"received_username_legal"
#define     INFO_REGISTERFAILED         @"received_register_failed"
#define     INFO_REGSTERSUCCESSFUL      @"received_register_seccessful"
#define     INFO_REFRESHUSERINFO        @"refresh_user_info"
#define     INFO_LOGINSUCCESSFUL        @"received_login_successful"
#define     INFO_LOGINFAILED            @"received_login_failed"
#define     INFO_MODIFYPASSWORDSUCCESSFUL   @"modify_password_successful"
#define     INFO_MODIFYPASSWORDFAILED       @"modify_password_failed"
#define     INFO_UPLOADIMAGESUCCESSFUL      @"received_upload_image_successful"
#define     INFO_UPLOADIMAGEFAILDE          @"received_upload_image_failed"
#define     INFO_GETFRIENDAROUNDME          @"received_get_friend_around_me"
#define     INFO_GETDETAILINFOSUCCESSFUL    @"received_get_detail_info"
#define     INFO_GETDETAILINFOFAILED        @"received_get_detail_failed"
#define     INFO_SHOWCHATVC                 @"show_chat_vc"
#define     INFO_REFRESHMESSAGELIST         @"refresh_message_list"
#define     INFO_GETPERMISSTIONINFOSUCCESSFUL       @"get_permisstion_info_successful"
#define     INFO_GETPERMISSTIONINFOFAILED           @"get_permisstion_info_failed"
#define     INFO_MODIFYPERMISSTIONINFOSUCCESSFUL    @"modify_permisstion_info_successful"
#define     INFO_MODIFYPERMISSTIONINFOFAILED        @"modify_permisstion_info_failed"
#define     INFO_SENDFEEDBACKSUCCESSFUL             @"send_feedback_successful"
#define     INFO_SENDFEEDBACKFAILED                 @"send_feedback_failed"
#define     INFO_MODIFYSELFINFO                     @"send_modify_self_info"
#define     INFO_SEARCHFRIENDSUCCESSFUL             @"search_friend_successful"
#define     INFO_SEARCHFRIENDFAILED                 @"search_friend_failed"
#define     INFO_ADDFRIENDSUCCESSFUL                @"add_friend_successful"
#define     INFO_ADDFRIENDFAILED                    @"add_friend_failed"
#define     INFO_MODIFYREMARKNAMESUCCESSFUL         @"modify_remarkname_successful"
#define     INFO_MODIFYREMARKNAMEFAILED             @"modify_remarkname_failed"
#define     INFO_DELETEFRIENDSUCCESSFUL             @"delete_friend_successful"
#define     INFO_DELETEFRIENDFAILED                 @"delete_friend_failed"
#define     INFO_GETTRAVELDATASUCCESSFUL            @"get_travel_data_successful"
#define     INFO_GETTRAVELDATAFAILED                @"get_travel_data_failed"
#define     INFO_GETFRIENDRECOMMENDSUCCESSFUL       @"get_friend_recommend_successful"
#define     INFO_GETFRIENDRECOMMENDFAILED           @"get_friend_recommend_failed"
#define     INFO_RECIEVEDNETNOTIFICATION            @"recievec_net_notification"
#define     INFO_AUTHFAILED                         @"auth_failed"
#define     INFO_NETWORKANOMALY                     @"network_anomaly"

// color
#define     DEFAULT_WHITE_COLOR     [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]
#define     DEFAULT_INPUT_COLOR     [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.4]

#endif
