//
//  FigurePuzzleViewController.h
//  TripleL
//
//  Created by charles on 5/6/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "CommonGameViewController.h"
#import "TLUser.h"
#import "gameProtocol.h"


@interface FigurePuzzleViewController : CommonGameViewController

@property (nonatomic)int time;
@property (nonatomic, strong)TLUser *user;

@property(strong, nonatomic)id <gameProtocol>delegate;

@end
