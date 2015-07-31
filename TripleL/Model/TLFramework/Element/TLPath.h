//
//  TLPath.h
//  twoFace
//
//  Created by 李伯坤 on 15/4/10.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#ifndef TLPath_h
#define TLPath_h

// Path

//#define     PATH_HOST               @"http://192.168.1.116:8000"
//#define     PATH_SOCKET_HOST        @"ws://121.42.32.129:8888/ws"     // socket 服务器
#define     PATH_HOST               @"http://server.tmqdu.com"          // 服务器
#define     PATH_SOCKET_HOST        @"ws://121.42.32.129:8888/ws"     // socket 服务器

#define     PATH_LOGIN              @"/login/"                          // 登陆
#define     PATH_REGISTER           @"/register/"                       // 注册
#define     PATH_CHECK_USERNAME     @"/info_check/?name=username&data="        // 检查用户名可用性
#define     PATH_UPLOAD_IMAGE       @"/upload_image/"                   // 上传图片
#define     PATH_UPLOAD_FILE        @"/upload_file/"                    // 上传文件

#define     PATH_MODIFY_SELF_INFO   @"/user/"                           // 修改详细信息
#define     PATH_USER_INFO          @"/user/?username="                 // 获取用户账号的简要信息
#define     PATH_USER_DETAIL_INFO   @"&detail=true"                     // 详细信息后缀，讲到上面接口后边

#define     PATH_USER_PERMISSTION   @"/user_permission/?username="      // 获取用户权限
#define     PATH_MODIFY_PERMISSTION @"/user_permission/"                // 修改用户权限

#define     PATH_SEARCH_FRIEND      @"/friends/management/?keyword="    // 搜索好友
#define     PATH_ADD_FRIEND         @"/friends/management/"             // 添加好友
#define     PATH_SHAKE              @"/shake/"                          // 摇一摇
#define     PATH_MY_FRIEND_LIST     @"/friends/"                        // 好友列表

#define     PATH_MODIFY_REMARDKNAME @"/friends/"                        // 修改备注
#define     PATH_DELETE_FRIEND      @"/friends/"                        // 删除好友

#define     PATH_MODIFY_PASSWORD    @"/user/password/"                  // 修改密码

#define     PATH_FEEDBACK           @"/feedback/"                       // 反馈

#define     PATH_FRIEND_TIMELINE    @"/timeline/"                       // 时间线
#define     PATH_SELF_TIMELINE      @"/my_timeline/"
#define     PATH_AROUNDER_TIMELINE  @"/timeline/around/"

#define     PATH_TRAVEL             @"/travel/"                         // 地点漫游
#define     PATH_FRIEND_RECOMMEND   @"/friends/recommend/"              // 好友推荐

// Tag
#define     AUTH_TOKEN              @"AUTH-TOKEN"

#define     TAG_LOGIN                   0
#define     TAG_REGISTER                1
#define     TAG_USERNAMEILLEGAL         2
#define     TAG_UPDATE                  3
#define     TAG_MODIFYDETAILINFO        4
#define     TAG_ACCOUNTDETAILEDINFO     5
#define     TAG_ADDFRIEND               6
#define     TAG_FRIENDAROUNDME          7
#define     TAG_MYFRIENDLIST            8
#define     TAG_MODIFYPASSWORD          9
#define     TAG_MODIFYPERMISSTION       10
#define     TAG_GETPERMISSTION          11
#define     TAG_FEEDBACK                12
#define     TAG_SEARCHFRIEND            13
#define     TAG_MODIFYREMARKNAME        14
#define     TAG_DELETEFRIEND            15
#define     TAG_TRAVEL                  16
#define     TAG_FRIENDRECOMMEND         17

// file
#define     FILE_DOC                [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]
#define     FILE_VIDEO              @"/video/"
#define     FILE_IMAGE              @"/image/"
#define     FILE_VOICE              @"/voice/"

// other
#define     DEFAULT_EMPTY_MOOD      @"该好友暂无状态"

#endif
