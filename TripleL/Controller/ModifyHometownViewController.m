//
//  ModifyHometownViewController.m
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyHometownViewController.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#define  INDEX 7

@interface ModifyHometownViewController ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    NSArray *pickData;
    NSMutableArray *provinceData;
    NSArray *citiesData;
}

@property (strong, nonatomic)UIPickerView *pickerView;
@property (strong, nonatomic)UIView *bgView;
@property (strong, nonatomic)UILabel *label;
@property (strong, nonatomic)UILabel *tipLabel;


@end

@implementation ModifyHometownViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [AppConfig getBGColor];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"city" ofType:@"plist"];
    NSArray *dic = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
    pickData = dic;
    
    provinceData = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < [pickData count]; i++)
        [provinceData addObject:[[pickData objectAtIndex:i] objectForKey:@"State"]];
    
    citiesData = [[pickData objectAtIndex:0]objectForKey:@"Cities"];
    
    
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = [UIColor whiteColor];
    
    _pickerView = [[UIPickerView alloc]init];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    _label = [[UILabel alloc]init];
    _label.text = [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:INDEX];
    _label.backgroundColor = [UIColor clearColor];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:INDEX]objectForKey:@"tip"];
    _tipLabel.font = [UIFont boldSystemFontOfSize:TIPLABEL_FONT_SIZE];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textColor = [UIColor lightGrayColor];

    
    [self.view addSubview: _pickerView];
    [self.view addSubview:_bgView];
    [_bgView addSubview:_label];
    [self.view addSubview:_tipLabel];
    [self orientChange:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orientChange:(NSNotification *)noti
{
    _bgView.frame = CGRectMake(0, 95, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT);
    _pickerView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height * 0.6, [UIScreen mainScreen].bounds.size.width, 216);//[UIScreen mainScreen].bounds.size.height * 0.4);
    _label.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT);
    _tipLabel.frame = CGRectMake(20, _bgView.frame.origin.y - 30, [UIScreen mainScreen].bounds.size.width - 20, 30);
}

#pragma mark UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
        return [provinceData count];
    else
        return [citiesData count];
}

#pragma mark UIPickerViewDelegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        [_pickerView selectRow:0 inComponent:1 animated:YES];
        return [provinceData objectAtIndex:row];
    }
    else
        return [citiesData objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        //NSString *seletedProvince = [provinceData objectAtIndex:row];
        NSArray *array = [[pickData objectAtIndex:row]objectForKey:@"Cities"];
        citiesData = array;
        [_pickerView reloadComponent:1];
    }
    int l = (int)[_pickerView selectedRowInComponent:0];
    int r = (int)[_pickerView selectedRowInComponent:1];
    if(l == 0 && r == 0)
        _label.text = @"";
    else
        _label.text = [NSString stringWithFormat:@"%@ %@", [provinceData objectAtIndex:l], [citiesData objectAtIndex:r]];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:_label.text];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
