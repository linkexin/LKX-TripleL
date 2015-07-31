//
//  ModifyMoodViewController.h
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModifyBaseViewController.h"

@interface ModifyMoodViewController : ModifyBaseViewController

@property (nonatomic)BOOL isFromMenu;
@property (strong, nonatomic)NSString *moodString;

@end
