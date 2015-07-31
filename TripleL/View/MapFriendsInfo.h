//
//  MapFriendsInfo.h
//  TripleL
//
//  Created by charles on 4/23/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLUser.h"

@interface MapFriendsInfo : NSObject


@property (nonatomic) double callOutWidth;
@property (nonatomic) double callOutHeight;

+(MapFriendsInfo *)getMapFriendsInfo;

-(void)addFriendWithUsername:(NSString *)username nickname:(NSString *)nickname photoPath:(NSString *)photoPath islock:(NSString *)islock gamename:(NSString *)gamename gamelevel:(NSString *)gamelevel;

-(void)initself;
-(void)initNext;
-(int)nextToAdd;
-(void)alreadyAdd:(int)index;
-(NSString *)getPhotoPathAt :(int)index;
-(NSDictionary *)getInfoAt:(int)index;

@end
