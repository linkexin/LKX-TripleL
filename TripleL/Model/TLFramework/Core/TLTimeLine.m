//
//  TLTimeLine.m
//  TripleL
//
//  Created by h1r0 on 15/5/22.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "TLTimeLine.h"
#import "TLStream.h"
#import "TLPath.h"

@implementation TLTimeLine

- (id) initWithStream: (TLStream *) stream
{
    if (self = [super init]) {
        self.stream = stream;
    }
    return self;
}

- (NSURLRequest *) getFriendTimelineRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_FRIEND_TIMELINE]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPShouldHandleCookies = YES;
    if (_stream.token != nil) {
        [request setValue:_stream.token forHTTPHeaderField:AUTH_TOKEN];
    }
    
    return request;
}

- (NSURLRequest *) getSelfTimelineRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_SELF_TIMELINE]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPShouldHandleCookies = YES;
    if (_stream.token != nil) {
        [request setValue:_stream.token forHTTPHeaderField:AUTH_TOKEN];
    }
    
    return request;
}

- (NSURLRequest *) getArounderTimeLineRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_AROUNDER_TIMELINE]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPShouldHandleCookies = YES;
    if (_stream.token != nil) {
        [request setValue:_stream.token forHTTPHeaderField:AUTH_TOKEN];
    }
    
    return request;
}

@end
