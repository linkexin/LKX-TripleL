//
//  GameCenter.h
//  TripleL
//
//  Created by charles on 5/23/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "gameProtocol.h"

@class TLUser;
@class TLInfo;

@interface GameCenter : NSObject<gameProtocol>

@property (strong, nonatomic)NSMutableArray *infoArr;

+(GameCenter *)getGameCenter;

-(void)jump:(TLUser *)userInfo from:(id)viewController;
-(void)tryGame:(TLInfo *)info from:(id)viewController;

@end
