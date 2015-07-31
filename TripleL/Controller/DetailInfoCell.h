//
//  DetailInfoCell.h
//  TripleL
//
//  Created by charles on 4/29/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailInfoCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic)UILabel *titleLable;
@property (strong, nonatomic)UILabel *detailLable;

-(void)setupCellwithTitle: (NSString *)title detail:(NSString *)detail;
@end
