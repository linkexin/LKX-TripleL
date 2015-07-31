//
//  TFNetCenter.h
//  twoFace
//
//  Created by h1r0 on 15/4/11.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;

@protocol TLNetCenterDelegate <NSObject>

- (void) uploadImageFinishedWithStatus: (BOOL) status url: (NSString *) url path: (NSString *) path error: (NSString *) error;

- (void) downloadImageFinishedWithStatus: (BOOL) status path: (NSString *) path url: (NSString *) url error: (NSString *) error;

@end

@interface TLNetCenter : NSObject

@property (nonatomic, strong) id<TLNetCenterDelegate>delegate;

+ (ASIHTTPRequest *) getByUrl: (NSURL *) url tag: (int)tag;
+ (ASIHTTPRequest *) post:(NSMutableData *)data toURL:(NSURL *)url andTag:(int)tag;
+ (ASIHTTPRequest *) put: (NSMutableData *)data toURL: (NSURL *) url andTag: (int)tag;

- (void) uploadImageByPath:(NSString *) path;                               // 上传图片
- (void) downloadImageByURL: (NSURL *) url;                                 // 下载图片

@end
