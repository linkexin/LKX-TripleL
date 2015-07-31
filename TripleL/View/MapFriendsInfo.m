//
//  MapFriendsInfo.m
//  TripleL
//
//  Created by charles on 4/23/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "MapFriendsInfo.h"

static MapFriendsInfo *mapFriendsInfo = nil;


@interface MapFriendsInfo()
{
    NSMutableArray *friendInfo;
    bool isSelfAdd;
    int next;
}


@end

@implementation MapFriendsInfo

+(MapFriendsInfo *)getMapFriendsInfo
{
    if(mapFriendsInfo == nil)
    {
        mapFriendsInfo = [[MapFriendsInfo alloc]init];
    }
    return mapFriendsInfo;
}

-(void)initself
{
    isSelfAdd = true;
}

-(void)initNext
{
    next = 1;
}

-(void)addFriendWithUsername:(NSString *)username nickname:(NSString *)nickname photoPath:(NSString *)photoPath islock:(NSString *)islock gamename:(NSString *)gamename gamelevel:(NSString *)gamelevel
{
    if(friendInfo == nil)
    {
        friendInfo = [[NSMutableArray alloc]initWithCapacity:20];
    }
    NSMutableDictionary *info = [[NSMutableDictionary alloc]initWithCapacity:10];
    [info setValue:username forKey:@"username"];
    [info setValue:nickname forKey:@"nickname"];
    [info setValue:photoPath forKey:@"photopath"];
    [info setValue:islock forKey:@"islock"];
    [info setValue:gamename forKey:@"gameID"];
    [info setValue:gamelevel forKey:@"gameDiff"];
    [info setObject:@"false" forKey:@"isadd"];
    
    if(isSelfAdd == true)
    {
        [friendInfo insertObject:info atIndex:0];
        isSelfAdd = false;
    }
    else
        [friendInfo insertObject:info atIndex:next++];
}

-(int)nextToAdd
{
    for(int i = 0; i < [friendInfo count]; i++)
    {
        if([[[friendInfo objectAtIndex:i] objectForKey:@"isadd"] isEqualToString:@"false"])
            return i;
    }
    return -1;
}

-(NSString *)getPhotoPathAt:(int)index
{
    return [[friendInfo objectAtIndex:index] objectForKey:@"photopath"];
}

-(NSDictionary *)getInfoAt:(int)index
{
    return [friendInfo objectAtIndex:index];
}

-(void)alreadyAdd:(int)index
{
    [[friendInfo objectAtIndex:index]setObject:@"true" forKey:@"isadd"];
}

@end

