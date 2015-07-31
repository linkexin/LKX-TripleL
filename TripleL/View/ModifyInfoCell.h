//
//  ModifyInfoCell.h
//  TripleL
//
//  Created by charles on 5/15/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyInfoCell : UITableViewCell


-(void)setCellWithtitle:(NSString *)title andinfo:(NSString *)info titlelocation:(CGRect)titleRect infolocation:(CGRect)infoRect;

-(void)addPhoto:(NSString *)phohoPath local:(NSString *)lacalPhoto withRect:(CGRect)rect;

@end
