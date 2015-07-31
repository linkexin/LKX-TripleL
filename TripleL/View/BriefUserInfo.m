//
//  BriefUserInfo.m
//  TripleL
//
//  Created by charles on 5/2/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "BriefUserInfo.h"
#import "UIImageView+WebCache.h"
#import "MapFriendsInfo.h"
#import "MyHeader.h"

#define CALLOUTVIEW_WIDTH  [MapFriendsInfo getMapFriendsInfo].callOutWidth
#define CALLOUTVIEW_HEIGH  [MapFriendsInfo getMapFriendsInfo].callOutHeight
#define CALLOUTVIEW_WIDTH_LR  [MapFriendsInfo getMapFriendsInfo].callOutHeight
#define CALLOUTVIEW_HEIGH_LR  [MapFriendsInfo getMapFriendsInfo].callOutWidth
#define SPACE CALLOUTVIEW_HEIGH * 0.03

@implementation BriefUserInfo
@synthesize btn, photo, name, gameLavelLabel, gameNameLabel, gameTimeLabel, line, gameNameImage, gameLevelImage;


- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 12;
        
        info = [[NSMutableDictionary alloc]initWithCapacity:10];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        //添加好友按钮
        btn = [[UIButton alloc]init];
        [btn setTitle:@"解锁好友" forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.alpha = 0.5;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        btn.userInteractionEnabled = YES;
        [self addSubview:btn];
        
        //头像
        photo = [[UIImageView alloc]init];
        [self addSubview:photo];
        
        //名字
        name = [[UILabel alloc] init];
        name.backgroundColor = [UIColor clearColor];
        name.textColor = [UIColor whiteColor];
        name.textAlignment = NSTextAlignmentCenter;
        [self addSubview:name];
        
        //横杠
        line = [[UIView alloc]init];
        line.backgroundColor = [UIColor grayColor];
        [self addSubview:line];
        
        //游戏类型
        gameNameImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gamename.png"]];
        [self addSubview:gameNameImage];
        
        gameNameLabel = [[UILabel alloc]init];
        gameNameLabel.font = [UIFont systemFontOfSize:15];
        gameNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:gameNameLabel];
        
        
        //游戏难度
        gameLevelImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gamelevel.png"]];
        [self addSubview:gameLevelImage];
        
        gameLavelLabel = [[UILabel alloc]init];
        gameLavelLabel.font = [UIFont systemFontOfSize:15];
        gameLavelLabel.textAlignment = NSTextAlignmentCenter;;
        [self addSubview:gameLavelLabel];
        
        [self orientChange:nil];
    }
    return self;
}

-(void)setInfoWithPhoto:(NSString *)photoName userName:(NSString *)userName islock:(NSString *)islock gameName:(NSString *)gameName gameLevel:(NSString *)gameLevel gamenamepicture:(NSString *)namepicture gamelevelpicture:(NSString *)levelpicture
{
    [self orientChange:nil];
    [info setValue:userName forKey:@"username"];
    [info setValue:photoName forKey:@"photopath"];
    [info setValue:islock forKey:@"islock"];
    [info setValue:gameName forKey:@"gameID"];
    [info setValue:gameLevel forKey:@"gameDiff"];
    
    [photo sd_setImageWithURL:[NSURL URLWithString: photoName] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    name.text = userName;
    gameNameLabel.text = gameName;
    gameNameImage.image = [UIImage imageNamed:namepicture];
    gameLevelImage.image = [UIImage imageNamed:levelpicture];
    gameLavelLabel.text = gameLevel;
}

- (void)orientChange:(NSNotification *)noti
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight)
    {
        photo.frame = CGRectMake(10, CALLOUTVIEW_HEIGH_LR * 0.05, CALLOUTVIEW_WIDTH_LR * 0.5, CALLOUTVIEW_HEIGH_LR * 0.9);
        name.frame = CGRectMake(CALLOUTVIEW_WIDTH_LR * 0.55, 20, CALLOUTVIEW_WIDTH_LR * 0.5 * 0.9, CALLOUTVIEW_HEIGH_LR * 0.2);
        line.frame = CGRectMake(CALLOUTVIEW_WIDTH_LR * 0.55 , name.frame.origin.y + name.frame.size.height, CALLOUTVIEW_HEIGH_LR * 0.7, 1);
        
        gameNameImage.frame = CGRectMake(CALLOUTVIEW_WIDTH_LR * 0.63, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
        gameNameLabel.frame = CGRectMake(gameNameImage.frame.origin.x - 5, gameNameImage.frame.origin.y + gameNameImage.frame.size.height, CALLOUTVIEW_WIDTH / 3, gameNameImage.frame.size.height);
        gameNameLabel.center = CGPointMake(gameNameImage.center.x, gameNameImage.center.y + gameNameImage.frame.size.height);
        
        gameLevelImage.frame = CGRectMake(CALLOUTVIEW_WIDTH_LR * 0.85, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
        gameLavelLabel.frame = CGRectMake(gameLevelImage.frame.origin.x - 5, gameLevelImage.frame.origin.y + gameLevelImage.frame.size.height + 10, CALLOUTVIEW_WIDTH / 3, gameLevelImage.frame.size.height);
        gameLavelLabel.center = CGPointMake(gameLevelImage.center.x, gameLevelImage.center.y + gameLevelImage.frame.size.height);
        
        //gameTimeImage.frame = CGRectMake(CALLOUTVIEW_WIDTH_LR * 0.89, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
        //gameTimeLabel.frame = CGRectMake(gameTimeImage.frame.origin.x - 5, gameTimeImage.frame.origin.y + gameTimeImage.frame.size.height, CALLOUTVIEW_WIDTH / 3, gameTimeImage.frame.size.height);
        //gameTimeLabel.center = CGPointMake(gameTimeImage.center.x, gameTimeImage.center.y + gameTimeImage.frame.size.height);
        
        btn.frame = CGRectMake(CALLOUTVIEW_WIDTH_LR * 0.55, photo.frame.origin.y + photo.frame.size.height - CALLOUTVIEW_WIDTH_LR * 0.1, CALLOUTVIEW_WIDTH_LR * 0.5 * 0.9, CALLOUTVIEW_WIDTH_LR * 0.1);
        name.center = CGPointMake(btn.frame.origin.x + btn.frame.size.width / 2, name.frame.origin.y + name.frame.size.height / 2);
    }
    else
    {
        btn.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.05, CALLOUTVIEW_HEIGH - CALLOUTVIEW_HEIGH * 0.14, CALLOUTVIEW_WIDTH * 0.9, CALLOUTVIEW_HEIGH * 0.1);
        photo.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.05, 10, CALLOUTVIEW_WIDTH * 0.9, CALLOUTVIEW_HEIGH * 0.5);
        name.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.05, photo.frame.origin.y + photo.frame.size.height, CALLOUTVIEW_WIDTH * 0.9, CALLOUTVIEW_HEIGH * 0.1);
        line.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.1, name.frame.origin.y + name.frame.size.height, CALLOUTVIEW_WIDTH * 0.8, 1);
        
        gameNameImage.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.22, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
        gameNameLabel.frame = CGRectMake(gameNameImage.frame.origin.x - 5, gameNameImage.frame.origin.y + gameNameImage.frame.size.height, CALLOUTVIEW_WIDTH / 2, gameNameImage.frame.size.height);
        gameNameLabel.center = CGPointMake(gameNameImage.center.x, gameNameImage.center.y + gameNameImage.frame.size.height);
        
        gameLevelImage.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.63, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
        gameLavelLabel.frame = CGRectMake(gameLevelImage.frame.origin.x - 5, gameLevelImage.frame.origin.y + gameLevelImage.frame.size.height + 10, CALLOUTVIEW_WIDTH / 3, gameLevelImage.frame.size.height);
        gameLavelLabel.center = CGPointMake(gameLevelImage.center.x, gameLevelImage.center.y + gameLevelImage.frame.size.height);
        //gameTimeImage.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.705, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
        //gameTimeLabel.frame = CGRectMake(gameTimeImage.frame.origin.x - 5, gameTimeImage.frame.origin.y + gameTimeImage.frame.size.height, CALLOUTVIEW_WIDTH / 3, gameTimeImage.frame.size.height);
        //gameTimeLabel.center = CGPointMake(gameTimeImage.center.x, gameTimeImage.center.y + gameTimeImage.frame.size.height);
    }
}

-(void)addFriend
{
    TLUser *user = [[TLUser alloc]init];
    user.username = [info objectForKey:@"username"];
    user.nickname = [info objectForKey:@"nickname"];
    user.avatar = [info objectForKey:@"photopath"];
    user.gameInfo = [[TLInfo alloc]init];
    if([[info objectForKey:@"gameID"] isEqualToString:@"数字拼图"])
        user.gameInfo.gameID = @"1";
    else
        user.gameInfo.gameID = @"2";
    
    if([[info objectForKey:@"gameDiff"] isEqualToString:@"简单"])
        user.gameInfo.gameDiff = @"1";
    else if([[info objectForKey:@"gameDiff"] isEqualToString:@"中等"])
        user.gameInfo.gameDiff = @"2";
    else
        user.gameInfo.gameDiff = @"3";
    
    user.gameInfo.lockDetailInfo = [info objectForKey:@"islock"];
    [self.delegate toGame:user];
}

@end


