//
//  TLCommunication.m
//  TripleL
//
//  Created by h1r0 on 15/4/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "TLCommunication.h"
#import "SRWebSocket.h"
#import "TLPath.h"
#import "TLStream.h"
#import "TLUser.h"
#import "TLNotification.h"

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIDownloadCache.h"
#import "ASIFormDataRequest.h"

#define         MSG_TYPE        @"message_type"

@interface TLCommunication () <SRWebSocketDelegate>
{
    SRWebSocket *socket;
    ASINetworkQueue *downloadQueue;
    ASINetworkQueue *uploadQueue;
    NSMutableArray *sendMsgQueue;
    NSMutableArray *recMsgQueue;
    
    NSURL *imageURL;
    NSURL *fileURL;
}

@end

@implementation TLCommunication

- (id) initWithStream:(TLStream *)stream delegate:(id<TLCommunicationDelegate>)delegate
{
    if (self = [super init]) {
        self.stream = stream;
        self.delegate = delegate;
        
        sendMsgQueue = [[NSMutableArray alloc] initWithCapacity:10];
        recMsgQueue = [[NSMutableArray alloc] initWithCapacity:10];
        
        [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
        downloadQueue = [[ASINetworkQueue alloc] init];
        [downloadQueue setDelegate:self];
        [downloadQueue setRequestDidFinishSelector:@selector(downloadCompeleted:)];
        [downloadQueue setRequestDidFailSelector:@selector(downloadFailed:)];
        [downloadQueue setShouldCancelAllRequestsOnFailure:NO];
        [downloadQueue setMaxConcurrentOperationCount:3];
        [downloadQueue go];
        
        uploadQueue = [[ASINetworkQueue alloc] init];
        [uploadQueue setDelegate:self];
        [uploadQueue setRequestDidFinishSelector:@selector(uploadCompeleted:)];
        [uploadQueue setRequestDidFailSelector:@selector(uploadFailed:)];
        [uploadQueue setShouldCancelAllRequestsOnFailure:NO];
        [uploadQueue setMaxConcurrentOperationCount:3];
        [uploadQueue go];
        
        imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_UPLOAD_IMAGE]];
        fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PATH_HOST, PATH_UPLOAD_FILE]];
    }
    
    return self;
}

- (void) conection
{
    if (socket.readyState == SR_CONNECTING) {
        [socket close];
    }
    NSURL *url = [NSURL URLWithString: PATH_SOCKET_HOST];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    socket = [[SRWebSocket alloc] initWithURLRequest:request];
    socket.delegate = self;
    [socket open];
}

- (void) disConnect
{
    [socket close];
}

- (void) sendAuth
{
    NSError *error;
    if (_stream.token == nil) {
        [self.delegate networkAnomaly];
        return;
    }
    NSDictionary *dic = @{
                          @"message_type": @"auth",
                          @"token": _stream.token,
                          };
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error != nil) {
        NSLog(@"error %@", error);
        return;
    }
    
    [socket send:json];
}

- (void) sendMessage:(TLMessage *)message
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithCapacity:2];
    [data setValue:@"message" forKey: MSG_TYPE];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:4];
    [dic setValue:message.to forKey:@"to"];
    switch (message.type) {
        case TLMessageTypeText:
        {
            [dic setValue:@"text" forKey:@"type"];
            [dic setValue:message.text forKey:@"detail"];
            [data setValue:dic forKey:@"content"];
            NSMutableData *json = [self dicToJson:data];
            [socket send:json];
        }
            break;
        case TLMessageTypePhoto:
        {
            [dic setValue:@"image" forKey:@"type"];
            [dic setValue:message.photoPath forKey:@"imagePath"];
            [data setValue:dic forKey:@"content"];
            [sendMsgQueue addObject:data];
            [self startUploadFrom:message.photoPath to:imageURL];
        }
            break;
        case TLMessageTypeVoice:
        {
            [dic setValue:@"voice" forKey:@"type"];
            [dic setValue:message.length forKey:@"length"];
            [dic setValue:message.mediaPath forKey:@"voicePath"];
            [data setValue:dic forKey:@"content"];
            [sendMsgQueue addObject:data];
            [self startUploadFrom:message.mediaPath to:fileURL];
        }
            break;
        case TLMessageTypeVideo:
        {
            [dic setValue:@"video" forKey:@"type"];
            [dic setValue:message.photoPath forKey:@"imagePath"];
            [dic setValue:message.mediaPath forKey:@"videoPath"];
            [data setValue:dic forKey:@"content"];
            [sendMsgQueue addObject:data];
            [self startUploadFrom:message.mediaPath to:fileURL];
            [self startUploadFrom:message.photoPath to:fileURL];
        }
            break;
        case TLMessageTypeOther:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void) sendFriendRequestReplayWithId:(NSString *)reqID accept:(BOOL)accept
{
    NSDictionary *dic = @{
                          @"message_type": @"friend_request_reply",
                          @"content": @{
                                  @"request_id": reqID,
                                  @"status": accept ? @"1" : @"0"
                                  }
                          };
    NSData *data = [self dicToJson:dic];
    [socket send:data];
}

- (void) startUploadFrom: (NSString *) path to: (NSURL *) url
{
    ASIFormDataRequest *request= [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setFile:path withFileName:nil andContentType:nil forKey:@"file"];
    [request setTimeOutSeconds:100];
    request.userInfo = @{@"path": path};
    
    [uploadQueue addOperation:request];
}

- (void) startDownloadFrom: (NSURL *) url to: (NSString *) path
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL: url];
    [request setDownloadDestinationPath:path];
    
    [downloadQueue addOperation:request];
}

- (NSMutableData *) dicToJson: (NSDictionary *) dic
{
    NSError *error;
    NSMutableData *json = [[NSMutableData alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error]];
    if (error != nil) {
        NSLog(@"error %@", error);
        return nil;
    }
    return json;
}

- (NSDictionary *) jsonStringToDic:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    [self.delegate networkAnomaly];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSDictionary *dic = [self jsonStringToDic:message];
    NSString *type = [dic objectForKey:MSG_TYPE];
    
    if ([type isEqualToString:@"connect"]){             // 连接
        NSString *status = [dic objectForKey:@"status"];
        if ([status isEqualToString:@"success"]) {
            [self sendAuth];
        }
        else{
            [self.delegate networkAnomaly];
        }
    }
    else if([type isEqualToString:@"auth"]){            // 认证
        NSString *status = [dic objectForKey:@"status"];
        if ([status isEqualToString:@"success"]) {
            
        }
        else{
            NSLog(@"auth failed!");
            [socket close];
            [self.delegate authFailed];
        }
    }
    else if([type isEqualToString:@"message"]){         // 消息
        TLMessage *message = [[TLMessage alloc] init];
        NSDictionary *content = [dic objectForKey:@"content"];
        NSString *type = [content objectForKey:@"type"];
        message.fromMe = NO;
        message.from = [content objectForKey:@"from"];
        message.to = self.stream.user.username;
        NSString *tmS = [content objectForKey:@"create_time"];
        float tm = tmS.floatValue / 1000;
        message.date = [NSDate dateWithTimeIntervalSince1970:tm];
        if ([type isEqualToString:@"text"]) {
            message.type = TLMessageTypeText;
            message.text = [content objectForKey:@"detail"];
            [self.delegate receivedMessage:message];
        }
        else if ([type isEqualToString:@"image"]){
            message.type = TLMessageTypePhoto;
            NSURL *url = [NSURL URLWithString:[content objectForKey:@"image"]];
            NSString *name = url.lastPathComponent;
            message.photoPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_IMAGE, name];
            [self startDownloadFrom:url to: message.photoPath];
            [recMsgQueue addObject:message];
        }
        else if ([type isEqualToString:@"voice"]){
            message.type = TLMessageTypeVoice;
            message.length = [content objectForKey:@"length"];
            NSURL *url = [NSURL URLWithString:[content objectForKey:@"voice"]];
            NSString *name = url.lastPathComponent;
            message.mediaPath = [NSString stringWithFormat:@"%@%@%@",FILE_DOC, FILE_VOICE, name];
            [self startDownloadFrom:url to: message.mediaPath];
            [recMsgQueue addObject:message];
        }
        else if ([type isEqualToString:@"video"]){
            message.type = TLMessageTypeVideo;
            NSURL *url = [NSURL URLWithString:[content objectForKey:@"image"]];
            NSString *name = url.lastPathComponent;
            message.photoPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_IMAGE, name];
            [self startDownloadFrom:url to: message.photoPath];
            url = [NSURL URLWithString:[content objectForKey:@"video"]];
            name = url.lastPathComponent;
            message.mediaPath = [NSString stringWithFormat:@"%@%@%@", FILE_DOC, FILE_VOICE, name];
            [self startDownloadFrom:url to: message.mediaPath];
            [recMsgQueue addObject:message];
        }
    }
    else if ([type isEqualToString:@"friend_request"]){
        NSDictionary *content = [dic objectForKey:@"content"];
        TLNotification *noti = [[TLNotification alloc] init];
        NSString *type = [content objectForKey:@"type"];
        noti.from = [content objectForKey:@"user_name"];
        noti.message = [content objectForKey:@"message"] == [NSNull null] ? @"" : [content objectForKey:@"message"];
        if ([type isEqualToString:@"add_friend_request"]) {
            noti.type = TLNotificationTypeFriendRequest;
            noti.notiID = [content objectForKey:@"request_id"];
        }
        else if ([type isEqualToString:@"friend_added"]){
            noti.type = TLNotificationTypeFriendAdded;
        }
        else if ([type isEqualToString:@"friend_request_rejected"]){
            noti.type = TLNotificationTypeFriendRejected;
        }
        [self.delegate receivedNetNotification:noti];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _stream.token = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    NSLog(@"Websocket received pong");
}


- (NSDictionary *) getDicWithString: (NSString *) str
{
    NSError *error;
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) {
        return nil;
    }
    
    return dic;
}


#pragma mark - network
- (void) downloadCompeleted: (ASIFormDataRequest *)request
{
    NSString *path = request.downloadDestinationPath;
    TLMessage *msg;
    for (TLMessage *item in recMsgQueue) {
        if (item.photoPath != nil && [item.photoPath isEqualToString:path]) {
            msg = item;
            break;
        }
        else if(item.mediaPath != nil && [item.mediaPath isEqualToString:path]){
            if (item.type == TLMessageTypeVideo) {
                return;
            }
            msg = item;
            break;
        }
    }
    if (msg == nil) {
        return;
    }
    [self.delegate receivedMessage:msg];
    [recMsgQueue removeObject:msg];
}

- (void) downloadFailed:(ASIFormDataRequest *)request
{
    NSLog(@"download Failed: %@\n %@", [request.url path], [request.error description]);
    
}

- (void) uploadCompeleted: (ASIFormDataRequest *)request
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
    
    if ([status isEqualToString:@"success"]) {
        NSMutableDictionary *msg;
        for (NSMutableDictionary *data in sendMsgQueue) {
            NSMutableDictionary *dic = [data objectForKey:@"content"];
            NSString *type = [dic objectForKey:@"type"];
            if ([type isEqualToString:@"image"]) {
                NSString *path = [dic objectForKey:@"imagePath"];
                if ([path isEqualToString:path]) {
                    [dic removeObjectForKey:@"imagePath"];
                    [dic setObject:content forKey:@"image"];
                    msg = data;
                    break;
                }
            }
            else if([type isEqualToString:@"voice"]){
                NSString *path = [dic objectForKey:@"voicePath"];
                if ([path isEqualToString:path]) {
                    [dic removeObjectForKey:@"voicePath"];
                    [dic setObject:content forKey:@"voice"];
                    msg = data;
                    break;
                }
            }
            else if([type isEqualToString:@"video"]){
                NSString *path = [dic objectForKey:@"imagePath"];
                if ([path isEqualToString:path]) {
                    [dic removeObjectForKey:@"imagePath"];
                    [dic setObject:content forKey:@"image"];
                    msg = data;
                    if ([dic objectForKey:@"video"] != nil) {
                        break;
                    }
                    else {
                        return;
                    }
                }
                path = [dic objectForKey:@"videoPath"];
                if ([path isEqualToString:path]) {
                    [dic removeObjectForKey:@"videoPath"];
                    [dic setObject:content forKey:@"video"];
                    msg = data;
                    if ([dic objectForKey:@"image"] != nil) {
                        break;
                    }
                    else {
                        return;
                    }
                    break;
                }
            }
        }
        if (msg == nil) {
            return;
        }
        NSMutableData *json = [self dicToJson:msg];
        [socket send:json];
        [sendMsgQueue removeObject:msg];
    }
    else{
        NSLog(@"upload faild");
    }
}

- (void) uploadFailed:(ASIFormDataRequest *)request
{
    NSLog(@"upload Failed: %@\n %@", [request.url path], [request.error description]);
}


@end
