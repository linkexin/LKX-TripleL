

//
//  ModifyBaseViewController.m
//  TripleL
//
//  Created by charles on 5/17/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyBaseViewController.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"

@interface ModifyBaseViewController ()
@property (strong, nonatomic)UIView *bgView;
@property (strong, nonatomic)UITextField *companyField;
@property (strong, nonatomic)UILabel *tipLabel;

@end

@implementation ModifyBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    if(_index == 10 || _index == 11)
    {
        self.view.backgroundColor = [AppConfig getBGColor];
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
    
        _companyField = [[UITextField alloc]init];
        _companyField.text = [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:_index];
        _companyField.backgroundColor = [UIColor clearColor];
        _companyField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
        _tipLabel = [[UILabel alloc]init];
        _tipLabel.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:_index] objectForKey:@"tip"];
        _tipLabel.font = [UIFont boldSystemFontOfSize:TIPLABEL_FONT_SIZE];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.textColor = [UIColor lightGrayColor];
    
        [self.view addSubview:_bgView];
        [_bgView addSubview:_companyField];
        [self.view addSubview:_tipLabel];
        [_companyField becomeFirstResponder];
        [self orientChange:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(_index == 10 || _index == 11)
        [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:_index andcontent:_companyField.text];
}

- (void)orientChange:(NSNotification *)noti
{
    _bgView.frame = CGRectMake(0, 95, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT);
    _companyField.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 20, LABEL_HEIGHT);
    _tipLabel.frame = CGRectMake(20, _bgView.frame.origin.y - 30, [UIScreen mainScreen].bounds.size.width - 20, 30);
}

@end
