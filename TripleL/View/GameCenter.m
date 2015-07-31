//
//  GameCenter.m
//  TripleL
//
//  Created by charles on 5/23/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "GameCenter.h"
#import "TLUser.h"
#import "TLInfo.h"
#import "SCLAlertView.h"

#import "CommonGameViewController.h"
#import "FigurePuzzleViewController.h"
#import "GuessNumberViewController.h"

#import "DetailInfoViewController.h"

static GameCenter *gamecenter = nil;

@interface GameCenter()
{
    BOOL isTry;
    TLUser *userInfo;
    TLInfo *gameInfo;
    UINavigationController *navigation;
}

@property (nonatomic, strong) FigurePuzzleViewController *figurePuzzleView;
@property (nonatomic, strong) GuessNumberViewController *guessnumView;
@end

@implementation GameCenter

+(GameCenter *)getGameCenter
{
    if(gamecenter == nil){
        gamecenter = [[GameCenter alloc]init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"gameCenter" ofType:@"plist"];
        gamecenter.infoArr = [[NSMutableArray alloc] initWithContentsOfFile:path];
    }
    return gamecenter;
}


-(void)jump:(TLUser *)info from:(id)viewController
{
    isTry = NO;
    userInfo = info;
    navigation = ((UIViewController *)viewController).navigationController;
    //NSLog(@"%@", userInfo.gameInfo.lockDetailInfo);
    if(userInfo.gameInfo.lockDetailInfo.boolValue == YES)   //需要解锁
    {
        int gameid = userInfo.gameInfo.gameID.intValue;
        if(gameid == 1)
        {
            FigurePuzzleViewController *figurePuzzleView = [[FigurePuzzleViewController alloc]init];
            figurePuzzleView.delegate = self;
            figurePuzzleView.user = userInfo;
            int time = [[[[_infoArr objectAtIndex:gameid] objectForKey:@"time"] objectAtIndex:userInfo.gameInfo.gameDiff.intValue] intValue];
            //NSLog(@"time = %d", time);
            figurePuzzleView.time = time;
            [((UIViewController *)viewController).navigationController pushViewController:figurePuzzleView animated:YES];
        }
        else if(gameid == 2)
        {
            GuessNumberViewController *guessView = [[GuessNumberViewController alloc]init];
            guessView.delegate = self;
            [guessView setGameDiff:userInfo.gameInfo.gameDiff.intValue];
            [((UIViewController *)viewController).navigationController pushViewController:guessView animated:YES];
        }
    }
    else
    {
        DetailInfoViewController *_detailController = [DetailInfoViewController getDetailVC];
        _detailController.friendInfo = userInfo;
        _detailController.type = FromSearch;
        [((UIViewController *)viewController).navigationController pushViewController:_detailController animated:YES];
    }
}

-(void)tryGame:(TLInfo *)info from:(id)viewController
{
    isTry = YES;
    gameInfo = info;
    
    if(info.gameID.intValue == 1)
    {
        if (_figurePuzzleView == nil) {
            _figurePuzzleView = [[FigurePuzzleViewController alloc]init];
        }
        _figurePuzzleView.delegate = self;
        _figurePuzzleView.time = 120;
        [((UIViewController *)viewController).navigationController pushViewController:_figurePuzzleView animated:YES];

    }
    else if(info.gameID.intValue == 2){
        if (_guessnumView == nil) {
            _guessnumView = [[GuessNumberViewController alloc]init];
            _guessnumView.delegate = self;
        }
        [_guessnumView setGameDiff:info.gameDiff.intValue];
        
        [((UIViewController *)viewController).navigationController pushViewController:_guessnumView animated:YES];
    }
}

#pragma mark - delegte
-(void) gameSucceefully: (id)viewController
{
    if(!isTry)
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.view.layer.zPosition = 10;
        [alert addButton:@"确定" actionBlock:^{
            DetailInfoViewController *detailInfoView = [DetailInfoViewController getDetailVC];
            detailInfoView.friendInfo = userInfo;
            detailInfoView.type = FromSearch;
            if(userInfo.gameInfo.gameID.intValue == 1)
            {
                [((FigurePuzzleViewController *)viewController).navigationController popViewControllerAnimated:NO];
                [navigation pushViewController:detailInfoView animated:NO];
            }
            else
            {
                [((GuessNumberViewController *)viewController).navigationController popViewControllerAnimated:NO];
                [navigation pushViewController:detailInfoView animated:NO];
            }
        }];
        if(userInfo.gameInfo.gameID.intValue == 1)
            [alert showSuccess:((FigurePuzzleViewController *)viewController).tabBarController title:@"恭喜你" subTitle:@"完成解锁游戏！" closeButtonTitle:nil duration:0.0f];
        else
            [alert showSuccess:((GuessNumberViewController*)viewController).tabBarController title:@"恭喜你" subTitle:@"完成解锁游戏！" closeButtonTitle:nil duration:0.0f];
    }
    else
    {
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.view.layer.zPosition = 10;
        [alert addButton:@"确定" actionBlock:^{
            [((UIViewController *)viewController).navigationController popViewControllerAnimated:YES];
        }];
        [alert showSuccess:((UIViewController *)viewController).tabBarController title:@"试玩成功" subTitle:@"赶紧去解锁好友吧！" closeButtonTitle:nil duration:0];
    }
}


-(void)gameOver:(id)viewController
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    if (!isTry) {
        [alert addButton:@"再来一次" actionBlock:^{
            [(CommonGameViewController *) viewController startGame];
        }];
        
        [alert addButton:@"放弃解锁" actionBlock:^{
            [((CommonGameViewController *)viewController).navigationController popViewControllerAnimated:YES];
            return ;
        }];
        
        if (userInfo.gameInfo.applyWithoutUnlock){
        [alert addButton:@"加好友" actionBlock:^{
            
        }];
        [alert showNotice:((UIViewController *)viewController).tabBarController title:@"解锁失败" subTitle:@"该用户允许未成功解锁好友发出申请，你可以选择发出好友申请，或者再尝试一次！" closeButtonTitle:nil duration:0.0f];
        }
        else{
            [alert showNotice:((UIViewController *)viewController).tabBarController title:@"解锁失败" subTitle:@"你可以再尝试一次！" closeButtonTitle:nil duration:0.0f];
        }
    }
    else{
        [alert addButton:@"再来一次" actionBlock:^{
            [(CommonGameViewController *) viewController startGame];
        }];
        
        [alert addButton:@"结束游戏" actionBlock:^{
            [((CommonGameViewController *)viewController).navigationController popViewControllerAnimated:YES];
            return ;
        }];
        [alert showNotice:((UIViewController *)viewController).tabBarController title:@"试玩失败" subTitle:@"你可以再尝试一次！" closeButtonTitle:nil duration:0.0f];
    }
}


@end
