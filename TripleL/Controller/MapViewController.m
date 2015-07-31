//
//  MapViewController.m
//  toFace
//
//  Created by charles on 4/13/15.
//  Copyright (c) 2015 TripleL. All rights reserved.
//

#import "MapViewController.h"
#import "CusAnnotationView.h"
#import "MyServer.h"
#import "TLUser.h"
#import "MyHeader.h"
#import "MapFriendsInfo.h"
#import "MapFriendListCell.h"
#import "MapFriendListViewHeader.h"
#import "BriefUserInfo.h"
#import "UIImageView+WebCache.h"
#import "GameCenter.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"

#define kFilteringFactor 0.1
#define kEraseAccelerationThreshold 2.0
#define HEIGHT_PIN 80
#define WIDTH_PIN 80
#define HEIGHT_PHOTO 40
#define WIDTH_PHOTP 40
#define BANSHAKEINTERVAL 5
#define kCalloutViewMargin -8
#define EXCESS_SPACE 10

//#define     VC_FRIEND_SEARCH                @"friendSearchViewController"
#define     RE_CELL_IDENTIFY                @"map_friend_collection_cell"
#define     RE_HEADER_VIEW_IDENTIFY         @"map_friend_header_view"
#define     CELL_WIDTH_OF_VIEW_WIDTH        3.27
#define     HEADER_VIEW_HEIGHT              20

@interface MapViewController () <UICollectionViewDataSource, UICollectionViewDelegate, BriefUserInfoDelegate>
{
    int secondsCountDown;
    float latitude;//用户现在所处的位置坐标
    float longitude;//同上
    bool isShake;
    bool isCountDown;
    bool isFirstShow;
    NSArray *friendsData;
    NSTimer *countDownTimer;
    NSString *myPhoto;
    TLUser *myInfo;
    
    float cell_width;
    CGRect shortCutViewRect;
    
    MACoordinateRegion viewRegion;
    MACoordinateRegion adjustedRegion;
    
    MBProgressHUD *progressHUD;
}
@property (nonatomic, strong) NSMutableArray *annotations;
@property (strong,nonatomic) NSMutableArray *mapFriendInfo;
@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) NSMutableArray *sectionData;
@property (strong, nonatomic) BriefUserInfo *briefInfoView;
@property (nonatomic, strong) UIView *shortCutBackView; // shorcut的背景view，接受点击事件
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentcontroller;
@property (weak, nonatomic) IBOutlet UICollectionView *mapFriendListView;

@end

@implementation MapViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    {
        [self.navigationController.navigationBar setBackgroundImage:[AppConfig getNavBarBgImage] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setTintColor:[AppConfig getBarTitleColor]];
        [_segmentcontroller setTintColor:[AppConfig getBarButtonColor]];
    }
    _annotations = [[NSMutableArray alloc]init];
    _mapFriendInfo = [[NSMutableArray alloc]init];
    secondsCountDown = BANSHAKEINTERVAL;
    isShake = false;
    isCountDown = false;
    isFirstShow = true;
    [[MapFriendsInfo getMapFriendsInfo] initself];
    
    self.segmentcontroller.selectedSegmentIndex = 0;
    [self.mapFriendListView setHidden:YES];
    
    //得到自己的信息
    myInfo = [[MyServer getServer] getSelfAccountInfo];
    
    // 列表
    _mapFriendListView.dataSource = self;
    _mapFriendListView.delegate = self;
    cell_width = self.view.frame.size.width / CELL_WIDTH_OF_VIEW_WIDTH;
    
    //地图信息初始化
    [MapFriendsInfo getMapFriendsInfo].callOutHeight = self.view.frame.size.height * 0.6;
    [MapFriendsInfo getMapFriendsInfo].callOutWidth = [MapFriendsInfo getMapFriendsInfo].callOutHeight * 0.55;
    [[MapFriendsInfo getMapFriendsInfo]addFriendWithUsername:myInfo.username nickname:myInfo.nickname photoPath:myInfo.avatar islock:myInfo.gameInfo.lockDetailInfo gamename:myInfo.gameInfo.gameID gamelevel:myInfo.gameInfo.gameDiff];
    
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"0bb1d573415a1ed5351d56ee785bf1c3";
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    
    
    //设置地图
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.rotateEnabled= NO;
    [self.view addSubview:_mapView];

    // shortCutView
    _shortCutBackView = [[UIView alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenShortCutView)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [_shortCutBackView addGestureRecognizer:tap];
    [_shortCutBackView setHidden:NO];
    [self.view addSubview:_shortCutBackView];
    _briefInfoView = [[BriefUserInfo alloc]init];
    _briefInfoView.delegate = self;
    [_briefInfoView setHidden:YES];
    [_shortCutBackView addSubview:_briefInfoView];
    _shortCutBackView.userInteractionEnabled = YES;
    
    
    //大头针,用户位置
    _userPointAnnotation = [[MAPointAnnotation alloc] init];
    
    //感应器
    _shakeManager = [[CMMotionManager alloc]init];
    _shakeManager.accelerometerUpdateInterval=1.0/60.0;
    [_shakeManager startAccelerometerUpdates];
    [NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(shackAction) userInfo:nil repeats:YES];//启动一个定时器，时刻检测振动状态
    
    progressHUD = [[MBProgressHUD alloc] init];
    [self.tabBarController.view addSubview:progressHUD];
    [progressHUD setLabelText:@"请稍候"];
    [progressHUD setLabelText:@"正在请求数据"];
    
    //游戏中心初始化
    //[[GameCenter getGameCenter]initGameCenter];
    //[GameCenter getGameCenter].mapView = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapFriendListView setBackgroundColor:[AppConfig getBGColor]];
    [self.tabBarController.tabBar setHidden:NO];
    
    [_shortCutBackView setFrame:self.view.frame];
    
    cell_width = self.view.frame.size.width / CELL_WIDTH_OF_VIEW_WIDTH;
    float w = [MapFriendsInfo getMapFriendsInfo].callOutWidth;
    float h = [MapFriendsInfo getMapFriendsInfo].callOutHeight;
    float x = (self.view.frame.size.width - w) / 2.0;
    float y = (self.view.frame.size.height - h) / 2.0;
    shortCutViewRect = CGRectMake(x, y, w, h);
    [_briefInfoView setFrame: shortCutViewRect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendAroundMe:) name:INFO_GETFRIENDAROUNDME object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAnomaly) name:INFO_NETWORKANOMALY object:nil];
    
    //判断是否是地点漫游
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isLocationRoaming"] isEqualToString:@"YES"])
    {
        NSString *la = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
        NSString *lo = [[NSUserDefaults standardUserDefaults] objectForKey:@"longitude"];
        [self setCoordinateWithLatitude:la andLongitude:lo];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isLocationRoaming"];
        //NSLog(@"coor = %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"isLocationRoaming"]);
    }
    else
    {
        _mapView.showsUserLocation = YES;//开启定位功能
        [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];//地图跟随用户移动
        _mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
        _mapView.userTrackingMode = MAUserTrackingModeFollow;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"isLocationRoaming"] isEqualToString:@"YES"])
    {
        [_mapView removeAnnotation:_userPointAnnotation];
    }
    isFirstShow = YES;
}

- (void) networkAnomaly
{
    [progressHUD hide:YES];
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert addButton:@"确定" actionBlock:^{
        
    }];
    [alert showError:self.tabBarController title:@"出错啦～" subTitle:@"请求数据失败，请检查网络！" closeButtonTitle:nil duration:0.0f];
}

//地点漫游
-(void)setCoordinateWithLatitude:(NSString *)latitudeValue andLongitude:(NSString *)longitudeValue
{
    //NSLog(@"%f", _mapView.maxZoomLevel);
    [_mapView setZoomLevel:20 animated:NO];
    _mapView.showsUserLocation = NO;
    _userPointAnnotation.coordinate = CLLocationCoordinate2DMake(latitudeValue.floatValue, longitudeValue.floatValue);
    latitude = latitudeValue.floatValue;
    longitude = longitudeValue.floatValue;
    _mapView.centerCoordinate = _userPointAnnotation.coordinate;
    [_mapView addAnnotation: _userPointAnnotation];
    //创建一个以center为中心，上下各1000米，左右各1000米得区域，但其是一个矩形，不符合MapView的横纵比例
    MACoordinateRegion startRegion = MACoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude),5000, 5000);
    MACoordinateRegion Region = [_mapView regionThatFits:startRegion];
    //最终显示该区域
    [_mapView setRegion:Region animated:NO];
    [[MyServer getServer] getFriendAroundMe:longitude latitude:latitude];
}

- (void)orientChange:(NSNotification *)noti
{
    [_shortCutBackView setFrame:self.view.frame];
    [_mapFriendListView reloadData];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight){
        cell_width = self.view.frame.size.height / CELL_WIDTH_OF_VIEW_WIDTH;
        float w = [MapFriendsInfo getMapFriendsInfo].callOutHeight + EXCESS_SPACE;
        float h = [MapFriendsInfo getMapFriendsInfo].callOutWidth;
        float x = (self.view.frame.size.width - w) / 2.0;
        float y = (self.view.frame.size.height - h) / 2.0;
        shortCutViewRect = CGRectMake(x, y, w, h);
        [_briefInfoView setFrame: shortCutViewRect];
    }
    else {
        cell_width = self.view.frame.size.width / CELL_WIDTH_OF_VIEW_WIDTH;
        float w = [MapFriendsInfo getMapFriendsInfo].callOutWidth;
        float h = [MapFriendsInfo getMapFriendsInfo].callOutHeight;
        float x = (self.view.frame.size.width - w) / 2.0;
        float y = (self.view.frame.size.height - h) / 2.0;
        shortCutViewRect = CGRectMake(x, y, w, h);
        [_briefInfoView setFrame: shortCutViewRect];
    }
}

#pragma mark-
//delegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{//定时检测更新用户的位置
    _userPointAnnotation.coordinate = userLocation.coordinate;
    if(updatingLocation)
    {
        //取出当前位置的坐标
        latitude = userLocation.coordinate.latitude;
        longitude = userLocation.coordinate.longitude;
        //_userPointAnnotation.coordinate = userLocation.coordinate;
        if(isFirstShow)
        {
            isFirstShow = false;
            //创建一个以center为中心，上下各1000米，左右各1000米得区域，但其是一个矩形，不符合MapView的横纵比例
            MACoordinateRegion startRegion = MACoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude),3000, 3000);
            //创建出来一个符合MapView横纵比例的区域
            MACoordinateRegion Region = [_mapView regionThatFits:startRegion];
            //最终显示该区域
            [_mapView setRegion:Region animated:NO];
        }
        
        [_mapView addAnnotation: _userPointAnnotation];
        [_mapView setUserTrackingMode: MAUserTrackingModeNone animated:YES];//地图跟随用户移动
    }
    
    if(isShake && !isCountDown)
    {
        isCountDown = true;
        secondsCountDown = BANSHAKEINTERVAL;
        countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethor) userInfo:nil repeats:YES];
    }
}


- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{
    /* 自定义定位精度对应的MACircleView. */
    if (overlay == mapView.userLocationAccuracyCircle)
    {
        MACircleView *accuracyCircleView = [[MACircleView alloc] initWithCircle:overlay];
        
        accuracyCircleView.lineWidth    = 1.f;//外围一圈的宽度
        accuracyCircleView.strokeColor  = [UIColor lightGrayColor];
        accuracyCircleView.fillColor    = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
        
        return accuracyCircleView;
    }
    
    return nil;
}


- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
        if ([annotation isKindOfClass:[MAPointAnnotation class]])
        {
            static NSString *customReuseIndetifier = @"customReuseIndetifier";
            
            CusAnnotationView *annotationView = (CusAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
            
            
            if (annotationView == nil)
            {
                annotationView = [[CusAnnotationView alloc] initWithAnnotation:annotation
                                                               reuseIdentifier:customReuseIndetifier];
                annotationView.delegate = self;
            }
            
            // must set to NO, so we can show the custom callout view.
            annotationView.canShowCallout   = NO;
            annotationView.draggable        = YES;
            annotationView.calloutOffset    = CGPointMake(0, -5);
            
            [annotationView setFrame:CGRectMake(0, 0, WIDTH_PIN, HEIGHT_PIN)];
            annotationView.backgroundColor = [UIColor clearColor];
            annotationView.layer.cornerRadius = annotationView.frame.size.width / 2;
            annotationView.centerOffset = CGPointMake(0, -HEIGHT_PIN / 2);
            
            //地图标注层 移动到CusAnnotationView中
            //头像层
            UIView *photoView = [[UIView alloc]initWithFrame:CGRectMake(WIDTH_PIN / 4, 2, WIDTH_PHOTP, HEIGHT_PHOTO)];
            photoView.layer.masksToBounds = YES;
            photoView.layer.cornerRadius = WIDTH_PHOTP / 2;
            
            int x = [[MapFriendsInfo getMapFriendsInfo]nextToAdd];
            if(x != -1)
            {
                //NSLog(@"%d", x);
                annotationView.tag = x;
                
                UIImageView *photo = [[UIImageView alloc]init];
                NSString *url = [[MapFriendsInfo getMapFriendsInfo]getPhotoPathAt:x];
                [photo sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
                
                [photo setFrame:CGRectMake(0, 0, WIDTH_PHOTP, HEIGHT_PHOTO)];
                photo.layer.cornerRadius = WIDTH_PHOTP / 2;
                [photoView addSubview:photo];
            
                [annotationView.pinView addSubview: photoView];
                [[MapFriendsInfo getMapFriendsInfo] alreadyAdd:x];
            }
        return annotationView;
        
    }
    return nil;
}

- (CGSize)offsetToContainRect:(CGRect)innerRect inRect:(CGRect)outerRect
{//计算calloutView弹出时地图的偏移值
    return CGSizeMake(CGRectGetMidX(outerRect) - CGRectGetMidX(innerRect), CGRectGetMidY(outerRect) - CGRectGetMidY(innerRect) - HEIGHT_PIN * 0.4);
}


- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{//选中标注时运行
    /* Adjust the map center in order to show the callout view completely. */
    if ([view isKindOfClass:[CusAnnotationView class]])
    {
        CusAnnotationView *cusView = (CusAnnotationView *)view;
        CGRect frame = [cusView convertRect:cusView.calloutView.frame toView:_mapView];
        frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin, kCalloutViewMargin));
        
        if (!CGRectContainsRect(_mapView.frame, frame))
        {
            // Calculate the offset to make the callout view show up.
            CGSize offset = [self offsetToContainRect:frame inRect:_mapView.frame];
            
            CGPoint theCenter = _mapView.center;
            theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height);
            
            CLLocationCoordinate2D coordinate = [_mapView convertPoint:theCenter toCoordinateFromView:_mapView];
            
            [_mapView setCenterCoordinate:coordinate animated:YES];
        }
    }
}

-(void)toGame:(TLUser*)user
{
    [[GameCenter getGameCenter]jump:user from:self];
}

#pragma mark-

- (IBAction)shakeButton:(id)sender {
    
    [progressHUD show:YES];
    
    [_mapView removeAnnotations:_annotations];
    //[_mapView removeAnnotation:_userPointAnnotation];
    isShake = true;
    //NSLog(@"shake!!");
    [[MapFriendsInfo getMapFriendsInfo] initNext];
    [[MyServer getServer] getFriendAroundMe:longitude latitude:latitude];
}

-(void)checkMapRegion
{
    if(_mapView.region.span.latitudeDelta < 0.01 || _mapView.region.span.longitudeDelta < 0.01)
    {
        viewRegion = MACoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude),1000, 1000);
        adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];
    }
}

-(void)shackAction
{
    if(!isShake){
        if(self.tabBarController.selectedIndex == 2)
        {
            //时刻判断加速计的x,y,z，超过一定程度即为筛子振动
            if (fabs(_shakeManager.accelerometerData.acceleration.x) > 2.5 || fabs(_shakeManager.accelerometerData.acceleration.y) > 4.0 || fabs(_shakeManager.accelerometerData.acceleration.z) > 2.5)
            {
                [progressHUD show:YES];
        
                [_mapView removeAnnotations:_annotations];
                isShake = true;
                [[MapFriendsInfo getMapFriendsInfo] initNext];
                [[MyServer getServer]getFriendAroundMe:longitude latitude:latitude];
            }
        }
    }
}

-(void)friendAroundMe:(NSNotification *)notification
{
    friendsData = notification.object;
    NSDictionary *dic = [DataProcessCenter transformArounderList:friendsData];
    _listData = [dic objectForKey:@"data"];
    _sectionData = [dic objectForKey:@"section"];
    [self.mapFriendListView reloadData];
    
    //[[MapFriendsInfo getMapFriendsInfo]addFriendWithUsername:myInfo.username nickname:myInfo.nickname photoPath:myInfo.avatar islock:myInfo.gameInfo.lockDetailInfo gamename:myInfo.gameInfo.gameID gamelevel:myInfo.gameInfo.gameDiff];
    //_userPointAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    //[_mapView addAnnotation:_userPointAnnotation];
    
    for (TLUser *friendsInfo in friendsData)
    {
        MAPointAnnotation *newAnnotation = [[MAPointAnnotation alloc]init];
        newAnnotation.coordinate = CLLocationCoordinate2DMake(friendsInfo.latitude.floatValue, friendsInfo.longitude.floatValue);
        [[MapFriendsInfo getMapFriendsInfo]addFriendWithUsername:friendsInfo.username nickname:friendsInfo.nickname photoPath:friendsInfo.avatar islock:friendsInfo.gameInfo.lockDetailInfo gamename:friendsInfo.gameInfo.gameID gamelevel:friendsInfo.gameInfo.gameDiff];
        
        [_mapView addAnnotation:newAnnotation];
        [_annotations addObject:newAnnotation];
    }
    
    [self.mapFriendListView reloadData];
    [progressHUD hide:YES];
}

-(void)timeFireMethor
{
    secondsCountDown --;
    if(secondsCountDown == 0)
    {
        [countDownTimer invalidate];
        isShake = false;
        isCountDown = false;
        //NSLog(@"time end");
    }
}


#pragma mark - UICollectionView
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.listData.count;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *array = [self.listData objectAtIndex:section];
    return array.count;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *text = [self.sectionData objectAtIndex:indexPath.section];
        MapFriendListViewHeader *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:RE_HEADER_VIEW_IDENTIFY forIndexPath:indexPath];
        [view setText:text];
        
        return view;
    }
    return nil;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [self.listData objectAtIndex:indexPath.section];
    TLUser *user = [array objectAtIndex:indexPath.row];
    MapFriendListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RE_CELL_IDENTIFY forIndexPath:indexPath];
    [cell setUsername:user.nickname avatar:[NSURL URLWithString:user.avatar]];
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.frame.size.width, HEADER_VIEW_HEIGHT);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cell_width, cell_width);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 3, 2, 3);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_mapFriendListView setUserInteractionEnabled:NO];
    
    UICollectionViewLayout *layout = _mapFriendListView.collectionViewLayout;
    UICollectionViewLayoutAttributes *attribute = [layout layoutAttributesForItemAtIndexPath:indexPath];
    CGRect rect = [_mapFriendListView convertRect:attribute.frame toView:self.view];
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        [_briefInfoView setFrame:CGRectMake(rect.origin.x, rect.origin.y, [MapFriendsInfo getMapFriendsInfo].callOutHeight + EXCESS_SPACE, [MapFriendsInfo getMapFriendsInfo].callOutWidth)];
    else
        [_briefInfoView setFrame:CGRectMake(rect.origin.x, rect.origin.y, [MapFriendsInfo getMapFriendsInfo].callOutWidth, [MapFriendsInfo getMapFriendsInfo].callOutHeight)];
    
    [_shortCutBackView setHidden:NO];
    
    NSArray *infoArray = [self.listData objectAtIndex:indexPath.section];
    TLUser *user = [infoArray objectAtIndex:indexPath.row];
    
    int index = user.gameInfo.gameID.intValue;
    NSDictionary *dic = [[GameCenter getGameCenter].infoArr objectAtIndex:index];
    NSString *ima = [dic objectForKey:@"gameAvater"];
    
    int x = user.gameInfo.gameDiff.intValue;

    
    [_briefInfoView setInfoWithPhoto:user.avatar userName:user.username islock:user.gameInfo.lockDetailInfo gameName:[dic objectForKey:@"name"] gameLevel:[[dic objectForKey:@"level"]objectAtIndex:x] gamenamepicture:ima gamelevelpicture:[dic objectForKey:@"levelAvater"]];
    
    [UIView animateWithDuration:0.3 animations:^{
        [_briefInfoView setHidden:NO];
        [_briefInfoView setFrame:shortCutViewRect];
    } completion:^(BOOL finished) {}];
    
}


- (void) hiddenShortCutView
{
    [_briefInfoView setHidden:YES];
    [_shortCutBackView setHidden:YES];
    [_mapFriendListView setUserInteractionEnabled:YES];
}

#pragma mark - segmentcontroller
- (IBAction)changeViewController:(id)sender {
    if (self.segmentcontroller.selectedSegmentIndex == 0)
    {
        [self.mapFriendListView setHidden:YES];
        [self hiddenShortCutView];
        [_mapView setHidden:NO];
    }
    else{
        [self.mapFriendListView setHidden:NO];
        [self hiddenShortCutView];
        [_mapView setHidden:YES];
    }
}


@end
