//
//  Setting.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/19.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Setting : NSManagedObject

@property (nonatomic, retain) NSNumber * recNewMsg;
@property (nonatomic, retain) NSNumber * msgShowDetail;
@property (nonatomic, retain) NSNumber * audio;
@property (nonatomic, retain) NSNumber * shock;
@property (nonatomic, retain) NSNumber * nightModal;
@property (nonatomic, retain) User *whoseSetting;

@end
