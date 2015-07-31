//
//  DetailInfoCenter.m
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "DetailInfoCenter.h"
#import "MyHeader.h"

static DetailInfoCenter *detailInfoCenter = nil;

@interface DetailInfoCenter()
{
    NSString *path;
}

@end

@implementation DetailInfoCenter

+(DetailInfoCenter*)getDetailInfoCenter
{
    if(detailInfoCenter == nil)
    {
        detailInfoCenter = [[DetailInfoCenter alloc]init];
    }
    return detailInfoCenter;
}


-(void)initself
{
    path = [[NSBundle mainBundle] pathForResource:@"detailInfo" ofType:@"plist"];
    _infoArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    _content = [[NSMutableArray alloc]init];
    _photoIndex = 0;
    _avater = DEFAULT_AVATARPATH;
}

-(void)initFriendInfo
{
    NSString *p = [[NSBundle mainBundle] pathForResource:@"friend" ofType:@"plist"];
    _friendArr = [[NSMutableArray alloc]initWithContentsOfFile:p];
}

-(void)initMajorData
{
    NSString *p = [[NSBundle mainBundle] pathForResource:@"major" ofType:@"plist"];
    _majorData = [[NSMutableArray alloc] initWithContentsOfFile:p];
}

-(void)modifyDataAtIndex:(int)index andcontent:(NSString *)content
{
    [_content setObject:content atIndexedSubscript:index];
    //NSLog(@"%@", [_content objectAtIndex:index]);
}

-(void)completeModifyMoodInfo
{
    TLUser *newData = [[TLUser alloc]init];
    newData.mood = _mood;
    
    [[MyServer getServer]modifySelfAccountDetailInfo:newData];
}

-(void)completeModifySelfInfo
{
    if (_content == nil || _content.count == 0) {
        return;
    }
    TLUser *newData = [[TLUser alloc]init];
   
    newData.nickname = [_content objectAtIndex:1];
    newData.age = [_content objectAtIndex:2];
    newData.constellation = [_content objectAtIndex:3];
    newData.mood = [_content objectAtIndex:5];
    newData.emotionCondition = [_content objectAtIndex:6];
    newData.hometown = [_content objectAtIndex:7];
    newData.location = [_content objectAtIndex:8];
    newData.company = [_content objectAtIndex:10];
    newData.school = [_content objectAtIndex:11];
    newData.career = [_content objectAtIndex:12];
    newData.birthday = _Birthday;
    newData.username = _username;
    
    if(![_avater isEqualToString:@"defaultphoto.jpg"])
        newData.avatar = _avater;
    
    if([newData.mood isEqualToString:@""])
        newData.mood = nil;
    
    if([newData.emotionCondition isEqualToString:@""])
        newData.emotionCondition = nil;
    
    if([newData.hometown isEqualToString:@""])
        newData.hometown = nil;
    if([newData.location isEqualToString:@""])
        newData.location = nil;
    if([newData.company isEqualToString:@""])
        newData.company = nil;
    if([newData.school isEqualToString:@""])
        newData.school = nil;
    if([newData.career isEqualToString:@""])
        newData.career = nil;
    
    [[MyServer getServer]modifySelfAccountDetailInfo:newData];
}

@end
