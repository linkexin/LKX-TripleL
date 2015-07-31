//
//  MsgRecordItem.h
//  TripleL
//
//  Created by h1r0 on 15/4/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgRecordItem : NSObject

@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *remarkName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *count;
@property (nonatomic, strong) NSString *time;

@end
