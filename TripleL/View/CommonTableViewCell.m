//
//  CommonTableViewCell.m
//  TripleL
//
//  Created by h1r0 on 15/5/21.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "AppConfig.h"

@implementation CommonTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = [AppConfig getFGColor];
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [AppConfig getFGColor];
        [self.textLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:17]];
        [self.detailTextLabel setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:17]];
    }
    
    return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [AppConfig getFGColor];
        [self.textLabel setTextColor:[AppConfig getTitleColor]];
        [self.textLabel setFont:[UIFont fontWithName:[AppConfig getTitleFont] size:17]];
        [self.detailTextLabel setFont:[UIFont fontWithName:[AppConfig getDetailFont] size:17]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
