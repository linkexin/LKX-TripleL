//
//  SearchResultCell.h
//  TripleL
//
//  Created by 李伯坤 on 15/5/25.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultCell : UITableViewCell

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *moodLabel;

- (void) setAvatar: (NSURL *) avatarURL name: (NSString *) name nikename: (NSString *) nikename mood: (NSString *) mood;


@end
