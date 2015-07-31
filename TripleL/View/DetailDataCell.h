//
//  DetailDataCell.h
//  TripleL
//
//  Created by charles on 5/13/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailDataCell : UITableViewCell<UITextViewDelegate>

@property (strong, nonatomic)UITextView *titleTextView;
@property (strong, nonatomic)UITextView *detailTextView;

-(void)setupCellwithTitle: (NSString *)title detail:(NSString *)detail;

@end
