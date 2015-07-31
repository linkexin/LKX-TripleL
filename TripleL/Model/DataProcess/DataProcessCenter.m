//
//  DataProcessCenter.m
//  TripleL
//
//  Created by h1r0 on 15/4/15.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "DataProcessCenter.h"
#import "MyHeader.h"
#import "pinyin.h"

@implementation DataProcessCenter

+ (NSDictionary *) transformFriendList:(NSArray *)list
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *sectionData = [[NSMutableArray alloc] init];
    if (list.count == 0) {
        return @{@"data": data, @"section": sectionData};
    }
    
    for (TLUser *item in list) {            // 获取remarkName的拼音首字母
        if (item.pinyin == nil) {
            if (item.remarkName == nil || [item.remarkName isEqualToString:@""]) {
                item.remarkName = item.nickname;
            }
            item.pinyin = [DataProcessCenter getPinyin: item.remarkName];
        }
    }
    
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {        // 排序
        int i;
        NSString *strA = ((TLUser *)obj1).pinyin;
        NSString *strB = ((TLUser *)obj2).pinyin;
        for (i = 0; i < strA.length && i < strB.length; i ++) {
            char a = [strA characterAtIndex:i];
            char b = [strB characterAtIndex:i];
            if (a > b) {
                return (NSComparisonResult)NSOrderedDescending;          // 上升
            }
            else if (a < b) {
                return (NSComparisonResult)NSOrderedAscending;         // 下降
            }
        }
        
        if (strA.length > strB.length) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        else if (strA.length < strB.length){
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    char c = [((TLUser *)[list objectAtIndex:0]).pinyin characterAtIndex:0];
    if (!isalpha(c)) {
        c = '#';
    }

    NSMutableArray *item = [[NSMutableArray alloc] initWithObjects:[list objectAtIndex:0], nil];
    [data addObject:item];
    
    char lastC = c;
    for (int i = 1; i < list.count; i ++) {
        TLUser *user = [list objectAtIndex:i];
        c = [user.pinyin characterAtIndex:0];
        if (isalpha(c) && c != lastC) {
            item = [[NSMutableArray alloc] init];
            [data addObject:item];
            lastC = c;
        }
        
        [item addObject:user];
    }
    
    
    for (NSArray *array in data) {
        TLUser *user = [array objectAtIndex:0];
        char c = [user.pinyin characterAtIndex:0];
        if (!isalpha(c)) {
            c = '#';
        }
        else{
            c = toupper(c);
        }
        [sectionData addObject:[NSString stringWithFormat:@"%c", c]];
    }

    return @{@"data": data, @"section": sectionData};
}


+ (NSString *) getPinyin:(NSString *)str
{
    NSMutableString *pinyin = [[NSMutableString alloc] init];
    
    for (int i = 0; i < str.length; i++) {
        char c = pinyinFirstLetter([str characterAtIndex:i]);
        [pinyin appendString:[NSString stringWithFormat:@"%c", tolower(c)]];
    }
    
    return [NSString stringWithFormat:@"%@", pinyin];
}


+ (NSDictionary *) transformArounderList: (NSArray *) list
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    NSMutableArray *sectionData = [[NSMutableArray alloc] init];
    if (list.count == 0) {
        return @{@"data": data, @"section": sectionData};
    }
    
    list = [list sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {        // 排序
        float disA = ((TLUser *)obj1).distance.floatValue;
        float disB = ((TLUser *)obj2).distance.floatValue;

        if (disA > disB) {
            return (NSComparisonResult)NSOrderedDescending;          // 上升
        }
        else if (disA < disB) {
            return (NSComparisonResult)NSOrderedAscending;         // 下降
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    

    NSMutableArray *item = [[NSMutableArray alloc] init];
    [data addObject:item];
    float start = ((TLUser *)[list firstObject]).distance.floatValue;
    float lastDistance = start;
    for (int i = 1; i < list.count; i ++) {
        TLUser *user = [list objectAtIndex:i];
        if (item.count >= 2 && (user.distance.floatValue - lastDistance > (lastDistance - start) * 0.3)) {
            start = user.distance.floatValue;
            item = [[NSMutableArray alloc] init];
            [data addObject:item];
        }
        lastDistance = user.distance.floatValue;
        [item addObject:user];
    }
    
    float end;
    for (NSArray *array in data) {
        start = ((TLUser *)[array firstObject]).distance.floatValue;
        end = ((TLUser *)[array lastObject]).distance.floatValue;
        [sectionData addObject:[NSString stringWithFormat:@"%.2f - %.2f km", start, end]];
    }
    
    return @{@"data": data, @"section": sectionData};
}


@end
