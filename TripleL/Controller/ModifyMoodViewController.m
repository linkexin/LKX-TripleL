//
//  ModifyMoodViewController.m
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyMoodViewController.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#define INDEX 5

@interface ModifyMoodViewController ()
@property (strong, nonatomic)UIView *bgView;
@property (strong, nonatomic)UITextView *moodTextView;
@property (strong, nonatomic)UILabel *tipLabel;
@end

@implementation ModifyMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [AppConfig getBGColor];
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = [UIColor whiteColor];
    
    _moodTextView = [[UITextView alloc]init];
    _moodTextView.backgroundColor = [UIColor clearColor];
    _moodTextView.textAlignment = NSTextAlignmentLeft;
    _moodTextView.text = [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:INDEX];
    [_moodTextView setFont:[UIFont systemFontOfSize:17]];
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:INDEX]objectForKey:@"tip"];
    _tipLabel.font = [UIFont boldSystemFontOfSize:TIPLABEL_FONT_SIZE];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textColor = [UIColor lightGrayColor];
    
    if(_isFromMenu)
    {
        //[[DetailInfoCenter getDetailInfoCenter] initself];
        UIBarButtonItem *myCoolButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(completeDown)];
        _moodTextView.text = _moodString;
        self.navigationItem.rightBarButtonItem = myCoolButton;
    }
    
    [self.view addSubview:_bgView];
    [_bgView addSubview:_moodTextView];
    [self.view addSubview:_tipLabel];
    [_moodTextView becomeFirstResponder];
    [self orientChange:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!_isFromMenu)
        [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:_moodTextView.text];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)completeDown
{
    [DetailInfoCenter getDetailInfoCenter].mood = _moodTextView.text;
    [[DetailInfoCenter getDetailInfoCenter]completeModifyMoodInfo];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)orientChange:(NSNotification *)noti
{
    _bgView.frame = CGRectMake(0, 95, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT * 3);
    _moodTextView.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 40, LABEL_HEIGHT * 3);
    _tipLabel.frame = CGRectMake(20, _bgView.frame.origin.y - 30, [UIScreen mainScreen].bounds.size.width - 20, 30);
}
@end
