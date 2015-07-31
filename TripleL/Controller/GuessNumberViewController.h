//
//  GuessNumberViewController.h
//  game
//
//  Created by h1r0 on 15/5/23.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "CommonGameViewController.h"
#import "gameProtocol.h"

@interface GuessNumberViewController : CommonGameViewController

@property (nonatomic, strong) id <gameProtocol> delegate;

- (void) setGameDiff: (int) diff;

@end
