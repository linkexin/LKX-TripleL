//
//  CusAnnotationView.m
//  toFace
//
//  Created by charles on 4/14/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import "CusAnnotationView.h"
#import "CustomCallOutView.h"
#import "MapFriendsInfo.h"
#import "UIImageView+WebCache.h"
#import "MyHeader.h"
#import "GameCenter.h"

@implementation CusAnnotationView

#define kWidth  150.f
#define kHeight 60.f

#define kHoriMargin 0.f
#define kVertMargin 0.f

#define kPortraitWidth  50.f
#define kPortraitHeight 50.f

#define CALLOUTVIEW_WIDTH  [MapFriendsInfo getMapFriendsInfo].callOutWidth
#define CALLOUTVIEW_HEIGH  [MapFriendsInfo getMapFriendsInfo].callOutHeight

#define HEIGHT_PIN 80
#define WIDTH_PIN 80

#define SPACE CALLOUTVIEW_HEIGH * 0.03

- (UIImage *)portrait
{
    return self.portraitImageView.image;
}

- (void)setPortrait:(UIImage *)portrait
{
    self.portraitImageView.image = portrait;
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:NO];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected)
    {
        return;
    }
    
    if (selected)
    {
        if (self.calloutView == nil)
        {
            //得到好友信息
            info = [[MapFriendsInfo getMapFriendsInfo] getInfoAt:(int)self.tag];
            
            [[MyServer getServer]getUserPermisstionByUsername: [info objectForKey:@"username"]];
            
            /* Construct custom callout. */
            self.calloutView = [[CustomCalloutView alloc] initWithFrame:CGRectMake(0, 0, CALLOUTVIEW_WIDTH, CALLOUTVIEW_HEIGH)];
            self.calloutView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x, -CGRectGetHeight(self.calloutView.bounds) / 2.f + self.calloutOffset.y);
            self.calloutView.layer.masksToBounds = YES;
            self.calloutView.layer.cornerRadius = 12;
            
            //添加好友按钮
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(CALLOUTVIEW_WIDTH * 0.05, CALLOUTVIEW_HEIGH * 0.85, CALLOUTVIEW_WIDTH * 0.9, CALLOUTVIEW_HEIGH * 0.1)];
            [btn setTitle:@"解锁好友" forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
            btn.alpha = 0.5;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
            btn.userInteractionEnabled = YES;
            if(self.tag == 0)
            {
                btn.userInteractionEnabled = NO;
                [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
            [self.calloutView addSubview:btn];
            
            //头像
            UIImageView *photo = [[UIImageView alloc]initWithFrame:CGRectMake(CALLOUTVIEW_WIDTH * 0.05, 10, CALLOUTVIEW_WIDTH * 0.9, CALLOUTVIEW_HEIGH * 0.5)];
            [photo sd_setImageWithURL:[NSURL URLWithString:[info objectForKey:@"photopath"]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
            [self.calloutView addSubview:photo];
            
            
            //名字
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CALLOUTVIEW_WIDTH * 0.05, photo.frame.origin.y + photo.frame.size.height, CALLOUTVIEW_WIDTH * 0.9, CALLOUTVIEW_HEIGH * 0.1)];
            name.backgroundColor = [UIColor clearColor];
            name.textColor = [UIColor whiteColor];
            name.textAlignment = NSTextAlignmentCenter;
            name.text = [info objectForKey:@"nickname"];
            [self.calloutView addSubview:name];
            //NSLog(@"%@", name.text);
            
            //横杠
            UIView *line = [[UIView alloc]init];
            line.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.1, name.frame.origin.y + name.frame.size.height, CALLOUTVIEW_WIDTH * 0.8, 1);
            line.backgroundColor = [UIColor grayColor];
            [self.calloutView addSubview:line];
            
            //游戏类型
            int index = [[info objectForKey:@"gameID"] intValue];
            NSDictionary *dic = [[GameCenter getGameCenter].infoArr objectAtIndex:index];
            
            NSString *ima = [dic objectForKey:@"gameAvater"];
            
            UIImageView *gameNameImage = [[UIImageView alloc]init];
            if(ima != nil)
            {
                gameNameImage.image = [UIImage imageNamed:ima];
            }
            //UIImageView *gameNameImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:ima]];
            gameNameImage.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.22, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
            [_calloutView addSubview:gameNameImage];
            
            UILabel *gameNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(gameNameImage.frame.origin.x - 5, gameNameImage.frame.origin.y + gameNameImage.frame.size.height, CALLOUTVIEW_WIDTH / 2, gameNameImage.frame.size.height)];
            gameNameLabel.center = CGPointMake(gameNameImage.center.x, gameNameImage.center.y + gameNameImage.frame.size.height);
            
            gameNameLabel.text = [[[GameCenter getGameCenter].infoArr objectAtIndex:index] objectForKey:@"name"];
            gameNameLabel.textAlignment = NSTextAlignmentCenter;
            [_calloutView addSubview:gameNameLabel];
            
            
            //游戏难度
            
            NSString *image = [dic objectForKey:@"levelAvater"];
            
            UIImageView *gameLevelImage = [[UIImageView alloc]init];
            gameLevelImage.image = [UIImage imageNamed:image];
            
            gameLevelImage.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.63, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
            [_calloutView addSubview:gameLevelImage];
            
            UILabel *gameLavelLabel = [[UILabel alloc]initWithFrame:CGRectMake(gameLevelImage.frame.origin.x - 5, gameLevelImage.frame.origin.y + gameLevelImage.frame.size.height + 10, CALLOUTVIEW_WIDTH / 3, gameLevelImage.frame.size.height)];
            gameLavelLabel.center = CGPointMake(gameLevelImage.center.x, gameLevelImage.center.y + gameLevelImage.frame.size.height);
            int x = [[info objectForKey:@"gameDiff"] intValue];
            gameLavelLabel.text = [[dic objectForKey:@"level"]objectAtIndex:x];
            gameLavelLabel.textAlignment = NSTextAlignmentCenter;;
            [_calloutView addSubview:gameLavelLabel];
            
            gameLavelLabel.font = [UIFont systemFontOfSize:15];
            gameNameLabel.font = [UIFont systemFontOfSize:15];
            //游戏时间
            /*
             UIImageView *gameTimeImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"gametime.png"]];
             gameTimeImage.frame = CGRectMake(CALLOUTVIEW_WIDTH * 0.705, line.frame.origin.y + line.frame.size.height + SPACE, CALLOUTVIEW_WIDTH * 0.15, CALLOUTVIEW_WIDTH * 0.15);
             [_calloutView addSubview:gameTimeImage];
             
             UILabel *gameTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(gameTimeImage.frame.origin.x - 5, gameTimeImage.frame.origin.y + gameTimeImage.frame.size.height, CALLOUTVIEW_WIDTH / 3, gameTimeImage.frame.size.height)];
             gameTimeLabel.center = CGPointMake(gameTimeImage.center.x, gameTimeImage.center.y + gameTimeImage.frame.size.height);
             gameTimeLabel.text = [info objectForKey:@"gametime"];
             gameTimeLabel.textAlignment = NSTextAlignmentCenter;
             [_calloutView addSubview:gameTimeLabel];
             */
        }
        [self addSubview:self.calloutView];
    }
    else
    {
        [self.calloutView removeFromSuperview];
    }
    
    [super setSelected:selected animated:animated];
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{//如果触摸calloutView 那么响应calloutView上面的空间 如果不是，那么就隐藏calloutView
    BOOL inside = [super pointInside:point withEvent:event];
    if (!inside && self.selected)
    {
        inside = [self.calloutView pointInside:[self convertPoint:point toView:self.calloutView] withEvent:event];
    }
    return inside;
}

-(void)btnAction
{
    TLUser *user = [[TLUser alloc]init];
    user.username = [info objectForKey:@"username"];
    user.nickname = [info objectForKey:@"nickname"];
    user.avatar = [info objectForKey:@"photopath"];
    user.gameInfo = [[TLInfo alloc]init];
    user.gameInfo.gameID = [info objectForKey:@"gameID"];
    user.gameInfo.gameDiff = [info objectForKey:@"gameDiff"];
    user.gameInfo.lockDetailInfo = [info objectForKey:@"islock"];
    [self.delegate toGame:user];
}


- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.portraitImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHoriMargin, kVertMargin, kPortraitWidth, kPortraitWidth)];
        [self addSubview:self.portraitImageView];
        
        _pinView = [[UIImageView alloc]init];
        [_pinView setFrame:CGRectMake(0, 0, WIDTH_PIN, HEIGHT_PIN)];
        _pinBackground = [UIImage imageNamed:@"pingray.png"];
        _pinView.image = _pinBackground;
        [self.portraitImageView addSubview: _pinView];
    }
    
    return self;
}



@end
