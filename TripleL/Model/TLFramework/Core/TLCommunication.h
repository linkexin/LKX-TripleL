//
//  TLCommunication.h
//  TripleL
//
//  Created by h1r0 on 15/4/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLMessage.h"

@class TLStream;
@class TLNotification;

@protocol TLCommunicationDelegate <NSObject>

- (void) receivedMessage: (TLMessage *) message;
- (void) receivedNetNotification: (TLNotification *) noti;
- (void) authFailed;
- (void) networkAnomaly;

@end

@interface TLCommunication : NSObject
@property (nonatomic, strong) id<TLCommunicationDelegate> delegate;
@property (nonatomic, weak) TLStream *stream;


- (id) initWithStream: (TLStream *) stream delegate: (id<TLCommunicationDelegate>) delegate;
- (void) conection;
- (void) sendMessage: (TLMessage *) message;
- (void) sendFriendRequestReplayWithId: (NSString *) reqID accept: (BOOL) accept;
- (void) disConnect;


@end
