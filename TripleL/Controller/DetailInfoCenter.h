//
//  DetailInfoCenter.h
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLUser.h"
#define TIPLABEL_FONT_SIZE 13
#define LABEL_HEIGHT 45

@interface DetailInfoCenter : NSObject

@property (strong, nonatomic)NSMutableArray *infoArr;
@property (strong, nonatomic)NSMutableArray *majorData;
@property (strong, nonatomic)NSMutableArray *friendArr;
@property (strong, nonatomic)TLUser *selfInfo;

@property (strong, nonatomic)NSMutableArray *content;
@property (strong, nonatomic)NSString *username;
@property (strong, nonatomic)NSString *Birthday;
@property (strong, nonatomic)NSString *avater;
@property (nonatomic)int photoIndex;
@property (strong, nonatomic)NSString *mood;

+(DetailInfoCenter *)getDetailInfoCenter;
-(void)initself;
-(void)initFriendInfo;
-(void)initMajorData;
-(void)modifyDataAtIndex: (int)index andcontent:(NSString *)content;
-(void)completeModifySelfInfo;
-(void)completeModifyMoodInfo;

@end
