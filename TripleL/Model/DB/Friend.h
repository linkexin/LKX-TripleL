//
//  Friend.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/19.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatRec, User;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * mood;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * remarkname;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSOrderedSet *chatRec;
@property (nonatomic, retain) User *whoseFriend;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)insertObject:(ChatRec *)value inChatRecAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChatRecAtIndex:(NSUInteger)idx;
- (void)insertChatRec:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChatRecAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChatRecAtIndex:(NSUInteger)idx withObject:(ChatRec *)value;
- (void)replaceChatRecAtIndexes:(NSIndexSet *)indexes withChatRec:(NSArray *)values;
- (void)addChatRecObject:(ChatRec *)value;
- (void)removeChatRecObject:(ChatRec *)value;
- (void)addChatRec:(NSOrderedSet *)values;
- (void)removeChatRec:(NSOrderedSet *)values;
@end
