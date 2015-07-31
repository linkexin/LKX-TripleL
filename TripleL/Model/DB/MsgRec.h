//
//  MsgRec.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/19.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface MsgRec : NSManagedObject

@property (nonatomic, retain) NSString * count;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) User *whoseMsgRec;

@end
