//
//  Message.h
//  SOSimpleChatDemo
//
//  Created by Artur Mkrtchyan on 6/3/14.
//  Copyright (c) 2014 SocialOjbects Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TLMessageTypeText  = 0,
    TLMessageTypePhoto = 1 << 0,
    TLMessageTypeVideo = 1 << 1,
    TLMessageTypeOther = 1 << 2,
    TLMessageTypeVoice = 1 << 3,
} TLMessageType;

@interface TLMessage : NSObject

@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSString *to;
@property (nonatomic) BOOL fromMe;
@property (nonatomic) TLMessageType type;

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSDictionary *attributes;
@property (strong, nonatomic) NSDate *date;

@property (nonatomic, strong) NSURL *photoURL;

@property (nonatomic, strong) NSString *length;           // 录音时长
@property (nonatomic, strong) NSString *photoPath;
@property (nonatomic, strong) NSString *mediaPath;

@end
