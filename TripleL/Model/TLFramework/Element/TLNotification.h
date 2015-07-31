//
//  TLNotification.h
//  TripleL
//
//  Created by h1r0 on 15/5/26.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TLNotificationType) {
    TLNotificationTypeFriendRequest,
    TLNotificationTypeFriendAdded,
    TLNotificationTypeFriendRejected
};

@interface TLNotification : NSObject

@property (nonatomic) TLNotificationType type;
@property (nonatomic, strong) NSString *notiID;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *message;

@end
