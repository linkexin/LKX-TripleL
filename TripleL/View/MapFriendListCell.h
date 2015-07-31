//
//  FriendListCell.h
//  TripleL
//
//  Created by h1r0 on 15/4/14.
//  Copyright (c) 2015年 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapFriendListCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;


- (void) setUsername:(NSString *)username avatar:(NSURL *)avatarURL;


@end
