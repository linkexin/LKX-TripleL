//
//  TFNetCenter.m
//  twoFace
//
//  Created by h1r0 on 15/4/11.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "TLNetCenter.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "TLPath.h"

static ASINetworkQueue *downloadImageQueue = nil;
static ASINetworkQueue *uploadImageQueue = nil;

@interface TLNetCenter () <ASIHTTPRequestDelegate>

@end

@implementation TLNetCenter

+ (ASIHTTPRequest *) getByUrl: (NSURL *) url tag: (int)tag
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:10];
    [request setRequestMethod:@"GET"];
    [request setTag:tag];
    return request;
}

+ (ASIHTTPRequest *) post:(NSMutableData *)data toURL:(NSURL *)url andTag:(int)tag
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:10];
    [request setTag:tag];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setPostBody:data];
    return request;
}

+ (ASIHTTPRequest *) put: (NSMutableData *)data toURL: (NSURL *) url andTag: (int)tag
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setTimeOutSeconds:10];
    [request setTag:tag];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setRequestMethod:@"PUT"];
    [request appendPostData:data];
    return request;
}

- (id) init
{
    if (self = [super init]) {
        downloadImageQueue = [[ASINetworkQueue alloc] init];
        uploadImageQueue = [[ASINetworkQueue alloc] init];
        
        [downloadImageQueue reset];
        [downloadImageQueue setDelegate:self];
        [downloadImageQueue setRequestDidFinishSelector:@selector(downloadImageCompeleted:)];
        [downloadImageQueue setRequestDidFailSelector:@selector(downloadImageFailed:)];
        [downloadImageQueue setShouldCancelAllRequestsOnFailure:NO];
        [downloadImageQueue setMaxConcurrentOperationCount:3];
        
        [uploadImageQueue reset];
        [uploadImageQueue setDelegate:self];
        [uploadImageQueue setRequestDidFinishSelector:@selector(uploadImageCompeleted:)];
        [uploadImageQueue setRequestDidFailSelector:@selector(uploadImageFailed:)];
        [uploadImageQueue setShouldCancelAllRequestsOnFailure:NO];
        [uploadImageQueue setMaxConcurrentOperationCount:3];

        
        [downloadImageQueue go];
        [uploadImageQueue go];
    }
    
    return self;
}

- (void) uploadImageByPath:(NSString *)path
{
    NSString *url = [NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_UPLOAD_IMAGE];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setRequestMethod:@"POST"];
    [request setFile:path withFileName:nil andContentType:nil forKey:@"file"];
    [request setTimeOutSeconds:60];

    [uploadImageQueue addOperation:request];
}

- (void) downloadImageByURL:(NSURL *)url
{
    NSString *name = url.lastPathComponent;
    NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), name];

    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL: url];
    [request setDownloadDestinationPath:path];
    
    [downloadImageQueue addOperation:request];
}



#pragma mark - queue

- (void) downloadImageCompeleted: (ASIFormDataRequest *)request
{
    NSString *url = [NSString stringWithFormat:@"%@", request.url];
    [self.delegate downloadImageFinishedWithStatus:YES path:request.downloadDestinationPath url:url error:nil];
}

- (void) downloadImageFailed:(ASIFormDataRequest *)request
{
    NSString *urlString = [NSString stringWithFormat:@"%@", request.url];
    [self.delegate downloadImageFinishedWithStatus:NO path:request.downloadDestinationPath url:urlString error:[request.error description]];
}

- (void) uploadImageCompeleted: (ASIFormDataRequest *)request
{
    NSError *error;
    NSData *data = [request responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error) {
        NSLog(@"error request:\n%@", error);
        return;
    }
    NSString *status = [dic objectForKey:@"status"];
    NSString *content = [dic objectForKey:@"content"];
    NSString *path = request.downloadDestinationPath;
    if ([status isEqualToString:@"success"]) {
        [self.delegate uploadImageFinishedWithStatus:YES url:content path:path error:nil];
    }
    else {
        [self.delegate uploadImageFinishedWithStatus:NO url:nil path:path error:content];
    }
}

- (void) uploadImageFailed:(ASIFormDataRequest *)request
{
    NSString *path = request.downloadDestinationPath;
    [self.delegate uploadImageFinishedWithStatus:NO url:nil path:path error:[request.error description]];
}


@end
