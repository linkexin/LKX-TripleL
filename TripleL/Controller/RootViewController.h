//
//  StartViewController.h
//  toFace
//
//  Created by charles on 4/10/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UINavigationControllerDelegate>

+ (RootViewController *) getRootViewController;
- (void) reloadVC;
- (void) logout;

- (void) setMsgCountInTabBar: (int) count;
- (void) changeMsgCountInTabBar: (int) count;

@end

