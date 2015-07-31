//
//  BriefUserInfo.h
//  TripleL
//
//  Created by charles on 5/2/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FigurePuzzleViewController.h"

@protocol BriefUserInfoDelegate <NSObject>
-(void)toGame:(TLUser *)user;
@end

@interface BriefUserInfo : UIView
{
    NSMutableDictionary *info;
}
@property (strong, nonatomic)UIButton *btn;
@property (strong, nonatomic)UIImageView *photo;
@property (strong, nonatomic)UILabel *name;
@property (strong, nonatomic)UIView *line;
@property (strong, nonatomic)UIImageView *gameNameImage;
@property (strong, nonatomic)UILabel *gameNameLabel;
@property (strong, nonatomic)UIImageView *gameLevelImage;
@property (strong, nonatomic)UILabel *gameLavelLabel;
@property (strong, nonatomic)UIImageView *gameTimeImage;
@property (strong, nonatomic)UILabel *gameTimeLabel;
@property (nonatomic)id<BriefUserInfoDelegate>delegate;


-(void)setInfoWithPhoto:(NSString *)photoName userName:(NSString *)userName islock:(NSString *)islock gameName:(NSString *)gameName gameLevel:(NSString *)gameLevel gamenamepicture:(NSString *)namepicture gamelevelpicture:(NSString *)levelpicture;
@end
