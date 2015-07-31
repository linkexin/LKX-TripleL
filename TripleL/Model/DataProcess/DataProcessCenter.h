//
//  DataProcessCenter.h
//  TripleL
//
//  Created by h1r0 on 15/4/15.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataProcessCenter : NSObject

+ (NSDictionary *) transformFriendList: (NSArray *) list;
+ (NSDictionary *) transformArounderList: (NSArray *) list;
+ (NSString *) getPinyin: (NSString *) str;

@end
