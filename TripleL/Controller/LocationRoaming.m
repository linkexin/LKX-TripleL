//
//  LocationRoaming.m
//  TripleL
//
//  Created by charles on 5/25/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "LocationRoaming.h"
#import "SCLAlertView.h"
#import "DGAaimaView.h"
#import "MyHeader.h"
#import "MyServer.h"
#import "MBProgressHUD.h"

#import "MapViewController.h"
#define TIME 0.1f

@interface LocationRoaming()
{
    NSArray *data;
    NSString *error;
    UILabel *locationLabel1;
    UILabel *locationLabel2;
    int index;
    NSTimer *timer;
    CGRect rectInside;
    CGRect rectOutsizeRight;
    CGRect rectOutsizeLeft;
    
    DGAaimaView *animaView;
}
@end

@implementation LocationRoaming

-(void)viewDidLoad
{
    [self.navigationItem setTitle:@"地点漫游"];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    switch ([UIDevice deviceVerType]) {
        case DeviceVer6:
        {
            rectInside = CGRectMake(bounds.size.width / 2.7, bounds.size.height * 0.75, 100, 40);
            rectOutsizeRight = CGRectMake(bounds.size.width + 100, bounds.size.height * 0.75, 100, 40);
            rectOutsizeLeft = CGRectMake(-100, bounds.size.height * 0.75, 100, 40);
        }
            break;
        case DeviceVer6P:
        {
            rectInside = CGRectMake(bounds.size.width / 2.6, bounds.size.height * 0.75, 100, 40);
            rectOutsizeRight = CGRectMake(bounds.size.width + 100, bounds.size.height * 0.75, 100, 40);
            rectOutsizeLeft = CGRectMake(-100, bounds.size.height * 0.75, 100, 40);
        }
            break;
        case DeviceVer5:
        {
            rectInside = CGRectMake(bounds.size.width / 2.9, bounds.size.height * 0.75, 100, 40);
            rectOutsizeRight = CGRectMake(bounds.size.width + 100, bounds.size.height * 0.75, 100, 40);
            rectOutsizeLeft = CGRectMake(-100, bounds.size.height * 0.75, 100, 40);
        }
            break;
        default:
        {
            rectInside = CGRectMake(bounds.size.width / 3, bounds.size.height * 0.75, 100, 40);
            rectOutsizeRight = CGRectMake(bounds.size.width + 100, bounds.size.height * 0.75, 100, 40);
            rectOutsizeLeft = CGRectMake(-100, bounds.size.height * 0.75, 100, 40);
        }
            break;
    }
    
    locationLabel1 = [[UILabel alloc]init];
    locationLabel1.layer.anchorPoint = CGPointMake(0, 0);
    locationLabel1.frame = rectInside;
    locationLabel1.backgroundColor = [UIColor colorWithRed:173 green:216 blue:230 alpha:0.4];
    locationLabel1.font = [UIFont boldSystemFontOfSize:20];
    locationLabel1.textAlignment = NSTextAlignmentCenter;
    locationLabel1.textColor = [UIColor whiteColor];
    [self.view addSubview:locationLabel1];
    locationLabel1.layer.zPosition = 2;
    locationLabel1.hidden = YES;
    
    locationLabel2 = [[UILabel alloc]init];
    locationLabel2.layer.anchorPoint = CGPointMake(0, 0);
    locationLabel2.frame = rectOutsizeLeft;
    locationLabel2.backgroundColor = [UIColor colorWithRed:173 green:216 blue:230 alpha:0.4];
    locationLabel2.font = [UIFont boldSystemFontOfSize:20];
    locationLabel2.textAlignment = NSTextAlignmentCenter;
    locationLabel2.textColor = [UIColor whiteColor];
    [self.view addSubview:locationLabel2];
    locationLabel2.layer.zPosition = 2;
    locationLabel2.hidden = YES;
    
    animaView = [[DGAaimaView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:animaView];
    animaView.layer.zPosition = 1;
    [animaView DGAaimaView:animaView BigCloudSpeed:1 smallCloudSpeed:1.5 earthSepped:1.0 huojianSepped:2.0 littleSpeed:2];
    
    self.view.backgroundColor = [UIColor blueColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [animaView start];
    
    [self.tabBarController.tabBar setHidden:YES];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getdataSuccessful:) name:INFO_GETTRAVELDATASUCCESSFUL object: nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(getdataFailed:) name:INFO_GETTRAVELDATAFAILED object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
    [[MyServer getServer]getTravelData];
}


- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
    locationLabel1.hidden = YES;
    locationLabel2.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) networkAnomaly
{
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"请求数据失败，请检查网络！" closeButtonTitle:nil duration:0.0f];
}

-(void)showLcation
{
    locationLabel1.hidden = NO;
    locationLabel2.hidden = NO;
    locationLabel1.text = ((TLPosition *)[data objectAtIndex:index++]).cityName;
    if(index >= [data count])
        index = 0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeLocation) userInfo:nil repeats:YES];
    
    int time = arc4random() % 3 + 3;
    [self performSelector:@selector(stop) withObject:nil afterDelay:time];
}


-(void)stop
{
    if(timer == nil)
        return;
    [timer invalidate];
    timer = nil;
    index --;
    if (index < 0) {
        index = (int)[data count] - 1;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = [NSString stringWithFormat:@"正在前往%@...", ((TLPosition *)[data objectAtIndex:index]).cityName];
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
    
    [self performSelector:@selector(jumpToMap) withObject:nil afterDelay:3.5];
}


-(void)changeLocation
{
    if(locationLabel1.frame.origin.x < 0)
    {
        [UIView animateWithDuration:TIME animations:^{
            locationLabel1.frame = rectInside;
            locationLabel2.frame = rectOutsizeRight;
            locationLabel1.text = ((TLPosition *)[data objectAtIndex:index++]).cityName;
            if(index >= [data count])
                index = 0;
        }];
        [self performSelector:@selector(changeProcess:) withObject:@"1" afterDelay:TIME];
    }
    else
    {
        [UIView animateWithDuration:TIME animations:^{
            locationLabel2.frame = rectInside;
            locationLabel1.frame = rectOutsizeRight;
            locationLabel2.text = ((TLPosition *)[data objectAtIndex:index++]).cityName;
            if(index >= [data count])
                index = 0;
        }];
        [self performSelector:@selector(changeProcess:) withObject:@"2" afterDelay:TIME];
    }
}

-(void)changeProcess:(NSString *)tip
{
    if([tip isEqualToString:@"1"])
        locationLabel2.frame = rectOutsizeLeft;
    else
        locationLabel1.frame = rectOutsizeLeft;
}

-(void)jumpToMap
{
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"isLocationRoaming"];
    [[NSUserDefaults standardUserDefaults] setObject:((TLPosition *)[data objectAtIndex:index]).latitude forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults] setObject:((TLPosition *)[data objectAtIndex:index]).longitude forKey:@"longitude"];
    [self.tabBarController setSelectedIndex:2];
    
    [self.navigationController popViewControllerAnimated:NO];
}


-(void)getdataSuccessful:(NSNotification *)notification
{
    data = notification.object;
    index = arc4random() % [data count];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert addButton:@"开始" actionBlock:^{
        [self showLcation];
    }];
    
    [alert showNotice:self.tabBarController title:@"地点漫游" subTitle:@"系统将为你随机分配地点" closeButtonTitle:nil duration:0.0f];
}

-(void)getdataFailed:(NSNotification *)notification
{
    error = notification.object;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.tabBarController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"获取信息失败:(";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:3];
}


@end
