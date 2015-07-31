//
//  TLTimeLine.h
//  TripleL
//
//  Created by h1r0 on 15/5/22.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TLStream;

@interface TLTimeLine : NSObject

@property (nonatomic, weak) TLStream *stream;

- (id) initWithStream: (TLStream *) stream;                     // 初始化userceter

- (NSURLRequest *) getFriendTimelineRequest;

- (NSURLRequest *) getSelfTimelineRequest;

- (NSURLRequest *) getArounderTimeLineRequest;

@end
