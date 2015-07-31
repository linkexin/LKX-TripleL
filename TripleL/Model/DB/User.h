//
//  User.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/19.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, MsgRec, Setting;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) NSOrderedSet *msgRec;
@property (nonatomic, retain) Setting *setting;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(Friend *)value;
- (void)removeFriendsObject:(Friend *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

- (void)insertObject:(MsgRec *)value inMsgRecAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMsgRecAtIndex:(NSUInteger)idx;
- (void)insertMsgRec:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMsgRecAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMsgRecAtIndex:(NSUInteger)idx withObject:(MsgRec *)value;
- (void)replaceMsgRecAtIndexes:(NSIndexSet *)indexes withMsgRec:(NSArray *)values;
- (void)addMsgRecObject:(MsgRec *)value;
- (void)removeMsgRecObject:(MsgRec *)value;
- (void)addMsgRec:(NSOrderedSet *)values;
- (void)removeMsgRec:(NSOrderedSet *)values;
@end
