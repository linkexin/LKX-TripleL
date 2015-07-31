//
//  FriendListViewHeader.m
//  TripleL
//
//  Created by h1r0 on 15/4/15.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "MapFriendListViewHeader.h"
#import "MyHeader.h"

@implementation MapFriendListViewHeader

- (void) setText:(NSString *)test
{
    [self setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    [_textLabel setBackgroundColor:[UIColor clearColor]];
    [_textLabel setTextColor:[UIColor grayColor]];
    [_textLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:14]];
    [_textLabel setText:test];
}

@end
