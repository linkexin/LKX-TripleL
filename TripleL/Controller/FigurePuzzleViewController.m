//
//  FigurePuzzleViewController.m
//  TripleL
//
//  Created by charles on 5/6/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "FigurePuzzleViewController.h"
#import "SCLAlertView.h"
#import "GameCenter.h"
#import "DetailInfoViewController.h"

#define LENGTH 60
#define INTERVAL 5
@interface FigurePuzzleViewController()
{
    int n;
    int positionZero;
    NSMutableArray *arr;
    int num[20];
    int check[20];
    float originX;
    float originY;
    NSTimer *timer;
    UILabel *tempLabel;
    CGRect bounds;
    UILabel *background;
    int t;
}

@property (strong, nonatomic)UISwipeGestureRecognizer *swipeGestureRecognizerLeft;
@property (strong, nonatomic)UISwipeGestureRecognizer *swipeGestureRecognizerRight;
@property (strong, nonatomic)UISwipeGestureRecognizer *swipeGestureRecognizerUp;
@property (strong, nonatomic)UISwipeGestureRecognizer *swipeGestureRecognizerDown;
@property (strong, nonatomic)UIImageView *target;//目标图片
@property (strong, nonatomic)UILabel *timeCount;
@property (strong, nonatomic)UIImageView *bgView;
@property (strong, nonatomic)UIVisualEffectView *effectview;

@property (nonatomic, readonly) UIButton *m_btnNaviBack;
@property (nonatomic, readonly) UIButton *m_btnNaviRight;

@end

@implementation FigurePuzzleViewController
@synthesize m_btnNaviBack = _btnNaviBack;
@synthesize m_btnNaviRight = _btnNaviRight;
@synthesize bgView;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    [self.tabBarController.tabBar setHidden:YES];
    /*
     bgView = [[UIImageView alloc]init];
     bgView.image =[UIImage imageNamed:@"gameBackground.jpg"];
     
     [bgView setFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
     bgView.contentMode = UIViewContentModeScaleAspectFit;
     bgView.userInteractionEnabled = YES;
     [self.view addSubview: bgView];
     UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
     _effectview = [[UIVisualEffectView alloc] initWithEffect: blur];
     _effectview.frame =CGRectMake(0,0, bgView.frame.size.width, bgView.frame.size.height);
     [bgView addSubview: _effectview];
     */
    bounds = [[UIScreen mainScreen] bounds];
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight)
    {
        if(bounds.size.width < bounds.size.height)
        {
            float temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
        }
    }
    else
    {
        if(bounds.size.width > bounds.size.height)
        {
            float temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
        }
    }
    n = 3;
    t = _time;
    arr = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor whiteColor];
    //self.view.backgroundColor = [UIColor colorWithRed:102 green:153 blue:204 alpha:0.5];
    
    _timeCount = [[UILabel alloc]init];
    _timeCount.text = [NSString stringWithFormat:@"Time: %d", _time];
    _timeCount.textAlignment = NSTextAlignmentCenter;
    _timeCount.backgroundColor = [UIColor clearColor];
    
    _target = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"target%d.png", n]]];
    
    //UIBarButtonItem *myCoolButton = [[UIBarButtonItem alloc] initWithTitle:@"⟨放弃" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonDown)];
    //UIBarButtonItem *myCoolButton = [[UIBarButtonItem alloc]init];
    //self.navigationItem.leftBarButtonItem = myCoolButton;
    
    tempLabel = [[UILabel alloc]init];
    tempLabel.layer.zPosition = 1;
    [self.view addSubview:tempLabel];
    tempLabel.hidden = YES;
    
    _swipeGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft:)];
    _swipeGestureRecognizerLeft.numberOfTouchesRequired = 1;
    _swipeGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    _swipeGestureRecognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    _swipeGestureRecognizerRight.numberOfTouchesRequired = 1;
    _swipeGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    _swipeGestureRecognizerUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeUp:)];
    _swipeGestureRecognizerUp.numberOfTouchesRequired = 1;
    _swipeGestureRecognizerUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    _swipeGestureRecognizerDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown:)];
    _swipeGestureRecognizerDown.numberOfTouchesRequired = 1;
    _swipeGestureRecognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setNavTitle:@"数字迷宫"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self setUpNum];
    /*
     SCLAlertView *alert = [[SCLAlertView alloc] init];
     alert.view.layer.zPosition = 10;
     [alert addButton:@"开始" actionBlock:^{
     [self startGame];
     }];
     NSString *str = [NSString stringWithFormat:@"请在%d秒内完成解锁游戏", _time];
     [alert showNotice:self.navigationController title:@"游戏" subTitle:str closeButtonTitle:nil duration:0.0f];
     */
    [self startGame];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

-(void)startGame
{
    //_time = 5;
    _time = t;
    for(int i = 0; i < [arr count]; i++)
        [[arr objectAtIndex:i] removeFromSuperview];
    [arr removeAllObjects];
    [background removeFromSuperview];
    [_timeCount removeFromSuperview];
    [_target removeFromSuperview];
    tempLabel.hidden = YES;
    [self setUpNum];
    
    [self.navigationController.view addGestureRecognizer:_swipeGestureRecognizerLeft];
    [self.navigationController.view addGestureRecognizer:_swipeGestureRecognizerRight];
    [self.navigationController.view addGestureRecognizer:_swipeGestureRecognizerUp];
    [self.navigationController.view addGestureRecognizer:_swipeGestureRecognizerDown];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeCountDown) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantPast]];
}

-(void)backButtonDown
{
    [self removeGesture];
    [timer invalidate];
    timer = nil;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.view.layer.zPosition = 10;
    [alert addButton:@"确定" actionBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popViewControllerAnimated:NO];
    }];
    [alert addButton:@"取消" actionBlock:^{
        [self startGame];
    }];
    [alert showInfo:self.navigationController title:@"返回" subTitle:@"确定要放弃游戏吗？" closeButtonTitle:nil duration:0.0f];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)setUpNum
{
    int k, zero = 0;
    //    for(int i = 0; i < n * n - 2; i++)
    //        num[i] = i + 1;
    //    num[n * n - 2] = 0;
    //    num[n * n - 1] = 8;
    //    positionZero = n * n - 2;
    
    
    while(1)
    {
        bool isUsed[20] = {false};
        for(int i = 0; i < n * n; i++)
        {
            while(1)
            {
                k = arc4random() % (n * n);
                if(!isUsed[k])
                    break;
            }
            num[i] = k;
            check[i] = k;
            isUsed[k] = true;
            if(k == 0)
            {
                zero = i;
                positionZero = zero;
            }
        }
        for(int i = 1; i <= zero / n; i ++)
        {
            int temp = check[zero];
            check[zero] = check[zero - n];
            check[zero - n] = temp;
            zero -= n;
        }
        for(int i = 1; i <= zero % n; i ++)
        {
            int temp = check[zero];
            check[zero] = check[zero - 1];
            check[zero - 1] = temp;
            zero --;
        }
        
        int k = 0;
        for(int i = 0; i < n * n - 1; i++)
            for(int j = i; j < n * n - 1; j++)
                if(check[i] > check[j]) k ++;
        if((k % 2 == 0 && n % 2 != 0) || (k % 2 == 1 && n % 2 != 1))
            break;
    }
    
    [self showNum];
}

-(void)swapNum :(int)a and:(int)b
{
    int temp = num[a];
    num[a] = num[b];
    num[b] = temp;
}

-(void)swapLabel:(int)a and:(int)b
{
    UILabel *temp = [arr objectAtIndex:a];
    arr[a] = [arr objectAtIndex:b];
    arr[b] = temp;
}

-(void)showNum
{
    _timeCount.frame = CGRectMake(bounds.size.width - LENGTH * 2 - INTERVAL, LENGTH, LENGTH * 2, LENGTH);
    [self.view addSubview:_timeCount];
    
    originX = (bounds.size.width - n * LENGTH - (n - 1) * INTERVAL) / 2;
    originY = (bounds.size.height - n * LENGTH - (n - 1) * INTERVAL) / 2;
    
    _target.frame = CGRectMake(bounds.size.width* 0.5 - LENGTH / 2, originY - LENGTH * 1.5, LENGTH, LENGTH);
    [self.view addSubview:_target];
    
    background = [[UILabel alloc]initWithFrame:CGRectMake(originX - INTERVAL, originY - INTERVAL, LENGTH * n + INTERVAL * (n + 1), LENGTH * n + INTERVAL * (n + 1))];
    background.backgroundColor = [UIColor grayColor];
    background.alpha = 0.5;
    background.layer.zPosition = 0;
    
    [self.view addSubview:background];
    for(int i = 0; i < n * n; i++)
    {
        if(i != 0)
        {
            UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(originX + LENGTH * (i % n) + INTERVAL * ((i % n)), originY + LENGTH * (i / n) + INTERVAL * ((i / n)), LENGTH, LENGTH)];
            
            if(num[i] != 0)
            {
                numLabel.text = [NSString stringWithFormat:@"%d", num[i]];
                numLabel.layer.zPosition = 2;
            }
            else
            {
                numLabel.layer.zPosition = 1;
            }
            numLabel.textAlignment = NSTextAlignmentCenter;
            numLabel.font = [UIFont fontWithName:@"Calibri" size:25];
            numLabel.backgroundColor = [UIColor lightGrayColor];
            numLabel.textColor = [UIColor blackColor];
            [self.view addSubview:numLabel];
            [arr addObject:numLabel];
        }
        else
        {
            UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(originX, originY, LENGTH, LENGTH)];
            if(num[i] != 0)
            {
                numLabel.text = [NSString stringWithFormat:@"%d", num[i]];
                numLabel.layer.zPosition = 2;
            }
            else
            {
                numLabel.layer.zPosition = 1;
            }
            numLabel.textAlignment = NSTextAlignmentCenter;
            //numLabel.font = [UIFont boldSystemFontOfSize:25];
            numLabel.font = [UIFont fontWithName:@"Calibri" size:25];
            numLabel.backgroundColor = [UIColor lightGrayColor];
            numLabel.textColor = [UIColor blackColor];
            
            [self.view addSubview:numLabel];
            [arr addObject:numLabel];
        }
    }
}

-(void)swipeLeft:(UISwipeGestureRecognizer *)recognizer
{
    tempLabel.hidden = YES;
    if(positionZero % n == n - 1)
        return;
    UILabel *label = [arr objectAtIndex:positionZero + 1];
    UILabel *zeroLabel = [arr objectAtIndex:positionZero];
    tempLabel.frame = zeroLabel.frame;
    tempLabel.backgroundColor = [UIColor lightGrayColor];
    tempLabel.hidden = NO;
    tempLabel.layer.zPosition = 1;
    zeroLabel.frame = label.frame;
    [UIView animateWithDuration:0.3 animations:^{
        label.frame = CGRectMake(originX + LENGTH * (positionZero % n) + INTERVAL * (positionZero % n), originY + LENGTH * (positionZero / n) + INTERVAL * (positionZero / n), LENGTH, LENGTH);
    }];
    [self swapLabel:positionZero and:positionZero + 1];
    [self swapNum:positionZero and:positionZero + 1];
    [self checkComplete];
    positionZero++;
    
}


-(void)swipeRight:(UISwipeGestureRecognizer *)recognizer
{
    tempLabel.hidden = YES;
    if(positionZero % n == 0)
        return;
    UILabel *label = [arr objectAtIndex:positionZero - 1];
    UILabel *zeroLabel = [arr objectAtIndex:positionZero];
    tempLabel.frame = zeroLabel.frame;
    tempLabel.backgroundColor = [UIColor lightGrayColor];
    tempLabel.hidden = NO;
    tempLabel.layer.zPosition = 1;
    zeroLabel.frame = label.frame;
    [UIView animateWithDuration:0.3 animations:^{
        label.frame = CGRectMake(originX + LENGTH * (positionZero % n) + INTERVAL * (positionZero % n), originY + LENGTH * (positionZero / n) + INTERVAL * (positionZero / n), LENGTH, LENGTH);
    }];
    [self swapLabel:positionZero and:positionZero - 1];
    [self swapNum:positionZero and:positionZero - 1];
    [self checkComplete];
    positionZero--;
    
}

-(void)swipeUp:(UISwipeGestureRecognizer *)recognizer
{
    tempLabel.hidden = YES;
    if(positionZero / n == n - 1)
        return;
    UILabel *label = [arr objectAtIndex:positionZero + n];
    UILabel *zeroLabel = [arr objectAtIndex:positionZero];
    tempLabel.frame = zeroLabel.frame;
    tempLabel.backgroundColor = [UIColor lightGrayColor];
    //tempLabel.backgroundColor = [UIColor redColor];
    tempLabel.hidden = NO;
    tempLabel.layer.zPosition = 1;
    zeroLabel.frame = label.frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        label.frame = CGRectMake(originX + LENGTH * (positionZero % n) + INTERVAL * (positionZero % n), originY + LENGTH * (positionZero / n) + INTERVAL * (positionZero / n), LENGTH, LENGTH);
    }];
    [self swapLabel:positionZero and:positionZero + n];
    [self swapNum:positionZero and:positionZero + n];
    [self checkComplete];
    positionZero += n;
}

-(void)swipeDown:(UISwipeGestureRecognizer *)recognizer
{
    tempLabel.hidden = YES;
    if(positionZero / n == 0)
        return;
    UILabel *label = [arr objectAtIndex:positionZero - n];
    UILabel *zeroLabel = [arr objectAtIndex:positionZero];
    tempLabel.frame = zeroLabel.frame;
    tempLabel.backgroundColor = [UIColor lightGrayColor];
    tempLabel.hidden = NO;
    tempLabel.layer.zPosition = 1;
    zeroLabel.frame = label.frame;
    [UIView animateWithDuration:0.3 animations:^{
        //zeroLabel.frame = label.frame;
        label.frame = CGRectMake(originX + LENGTH * (positionZero % n) + INTERVAL * (positionZero % n), originY + LENGTH * (positionZero / n) + INTERVAL * (positionZero / n), LENGTH, LENGTH);
    }];
    [self swapLabel:positionZero and:positionZero - n];
    [self swapNum:positionZero and:positionZero - n];
    [self checkComplete];
    positionZero -= n;
}

-(void)checkComplete
{
    int b = 0;
    for(int i = 0; i < n * n; i++)
        if(num[i] == i + 1) b ++;
    if(b == n * n - 1)
    {
        [self removeGesture];
        [self.delegate gameSucceefully:self];
        [timer invalidate];
        timer = nil;
    }
}

-(void)removeGesture
{
    [self.view removeGestureRecognizer: _swipeGestureRecognizerDown];
    [self.view removeGestureRecognizer: _swipeGestureRecognizerLeft];
    [self.view removeGestureRecognizer: _swipeGestureRecognizerRight];
    [self.view removeGestureRecognizer: _swipeGestureRecognizerUp];
}

-(void)timeUp
{
    [self removeGesture];
    [timer invalidate];
    timer = nil;
    [self.delegate gameOver:self];
}


-(void)timeCountDown
{
    if(_time < 0)
        return;
    _time --;
    _timeCount.text = [NSString stringWithFormat:@"Time: %d", _time];
    if(_time == 0)
        [self timeUp];
}

-(void)orientChange:(NSNotification *)noti
{
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight)
    {
        if(bounds.size.width < bounds.size.height)
        {
            float temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
        }
    }
    else
    {
        if(bounds.size.width > bounds.size.height)
        {
            float temp = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = temp;
        }
    }
    
    for(int i = 0; i < [arr count]; i++)
        [[arr objectAtIndex:i] removeFromSuperview];
    [arr removeAllObjects];
    [background removeFromSuperview];
    [_timeCount removeFromSuperview];
    [_target removeFromSuperview];
    tempLabel.hidden = YES;
    [self showNum];
}

@end