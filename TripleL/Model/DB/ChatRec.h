//
//  ChatRec.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/19.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend;

@interface ChatRec : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSNumber * fromMe;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * media;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * to;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Friend *whoseChatRec;

@end
