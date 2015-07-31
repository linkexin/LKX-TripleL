//
//  FirstCell.h
//  TripleL
//
//  Created by charles on 5/22/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstCell : UITableViewCell


- (void)SetTableViewWithAvatar:(NSString *)avatar username:(NSString *)userName remarkName:(NSString *)remarkString gender:(NSString *)gender star: (int) star isSelf:(BOOL)isself;

@end
