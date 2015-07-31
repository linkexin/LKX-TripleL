//
//  ModifyBirthdayViewController.m
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyBirthdayViewController.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#define INDEX 2

@interface ModifyBirthdayViewController ()

@property (strong, nonatomic)UIView *bgView1;
@property (strong, nonatomic)UIView *bgView2;
@property (strong, nonatomic)UILabel *ageTitle;
@property (strong, nonatomic)UILabel *xingzuoTitle;
@property (strong, nonatomic)UILabel *ageData;
@property (strong, nonatomic)UILabel *xingzuoData;
@property (strong, nonatomic)UILabel *tipLabel;
@property (strong, nonatomic)UIDatePicker *datePicker;
@end

@implementation ModifyBirthdayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [AppConfig getBGColor];
    _bgView1 = [[UIView alloc]init];
    _bgView1.backgroundColor = [UIColor whiteColor];
    
    _bgView2 = [[UIView alloc]init];
    _bgView2.backgroundColor = [UIColor whiteColor];
    
    _ageTitle = [[UILabel alloc]init];
    _ageTitle.backgroundColor = [UIColor clearColor];
    _ageTitle.text = @"年龄";
    
    _ageData = [[UILabel alloc]init];
    _ageData.text = [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:INDEX];
    _ageData.textAlignment = NSTextAlignmentRight;
    _ageData.backgroundColor = [UIColor clearColor];
    
    _xingzuoTitle = [[UILabel alloc]init];
    _xingzuoTitle.backgroundColor = [UIColor clearColor];
    _xingzuoTitle.text = @"星座";
    
    _xingzuoData = [[UILabel alloc]init];
    _xingzuoData.frame = CGRectMake(self.view.frame.size.width / 2, 0, self.view.frame.size.width / 2 - 20, 50);
    _xingzuoData.text = [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:INDEX + 1];
    _xingzuoData.textAlignment = NSTextAlignmentRight;
    _xingzuoData.backgroundColor = [UIColor clearColor];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:INDEX]objectForKey:@"tip"];
    _tipLabel.font = [UIFont boldSystemFontOfSize:TIPLABEL_FONT_SIZE];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textColor = [UIColor lightGrayColor];

    //double lastactivityInterval = [[DetailInfoCenter getDetailInfoCenter].selfInfo.birthday doubleValue] / 1000;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    //NSDate* date = [NSDate dateWithTimeIntervalSince1970:lastactivityInterval];
    //NSString* dateString = [formatter stringFromDate:date];
    
    _datePicker = [[UIDatePicker alloc]init];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    NSDateComponents *comp = [[NSDateComponents alloc]init];
    [comp setMonth:01];
    [comp setDay:01];
    [comp setYear:1970];
    NSCalendar *myCal = [[NSCalendar alloc]initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate *myDate = [myCal dateFromComponents:comp];
    [_datePicker setMinimumDate: myDate];
    [_datePicker setMaximumDate:[NSDate date]];
    [_datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"zh_Hans_CN"]];//地区
    [_datePicker setCalendar:[NSCalendar currentCalendar]];
    [_datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview: _datePicker];
    [self.view addSubview:_bgView1];
    [self.view addSubview:_bgView2];
    [self.view addSubview:_tipLabel];
    [_bgView1 addSubview:_ageTitle];
    [_bgView1 addSubview:_ageData];
    [_bgView2 addSubview:_xingzuoTitle];
    [_bgView2 addSubview:_xingzuoData];
    [self orientChange:nil];
}

-(void)datePickerValueChanged
{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    int year = (int)[dateComponent year] + 1;//当前年份
    
    NSDate *birthDate = [_datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *m = [NSString stringWithFormat: @"%@", [dateFormatter stringFromDate: birthDate]];
    [dateFormatter setDateFormat:@"dd"];
    NSString *d = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: birthDate]];
    
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *y = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate: birthDate]];
    
    NSString *result = [NSString stringWithFormat:@"%@", [astroString substringWithRange:NSMakeRange(m.floatValue * 2 - (d.floatValue < [[astroFormat substringWithRange: NSMakeRange((m.floatValue - 1), 1)] intValue] - (-19)) * 2, 2)]];
    _xingzuoData.text = [NSString stringWithFormat:@"%@座", result];
    _ageData.text = [NSString stringWithFormat:@"%d", year - y.intValue];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSTimeInterval time = [birthDate timeIntervalSince1970] * 1000;//转为时间戳格式
    [DetailInfoCenter getDetailInfoCenter].Birthday = [NSString stringWithFormat:@"%.0lf", time];//转为字符串形式
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:_ageData.text];
    [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX + 1 andcontent:_xingzuoData.text];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orientChange:(NSNotification *)noti
{
    _bgView1.frame = CGRectMake(0, 95, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT);
    _bgView2.frame = CGRectMake(0, _bgView1.frame.origin.y + 60, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT);
    _ageTitle.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width / 2, LABEL_HEIGHT);
    _ageData.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0, [UIScreen mainScreen].bounds.size.width / 2 - 20, 50);
    _xingzuoTitle.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width / 2, LABEL_HEIGHT);
    _xingzuoData.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2, 0, [UIScreen mainScreen].bounds.size.width / 2 - 20, 50);
    _tipLabel.frame = CGRectMake(20, _bgView1.frame.origin.y - 30, [UIScreen mainScreen].bounds.size.width, 30);
    [_datePicker setFrame: CGRectMake(0, [UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.height * 0.35, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.35)];
}

@end
