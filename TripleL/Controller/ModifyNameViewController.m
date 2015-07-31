//
//  ModifyNameViewController.m
//  TripleL
//
//  Created by charles on 5/16/15.
//  Copyright (c) 2015 李伯坤. All rights reserved.
//

#import "ModifyNameViewController.h"
#import "DetailInfoCenter.h"
#import "MyHeader.h"
#define INDEX 1

@interface ModifyNameViewController ()
@property (strong, nonatomic)UIView *bgView;
@property (strong, nonatomic)UITextField *nameField;
@property (strong, nonatomic)UILabel *tipLabel;

@end

@implementation ModifyNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [AppConfig getBGColor];
    _bgView = [[UIView alloc]init];
    _bgView.backgroundColor = [UIColor whiteColor];
    _bgView.layer.zPosition = 1;
    
    _nameField = [[UITextField alloc]init];
    _nameField.text = [[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:INDEX];
    _nameField.backgroundColor = [UIColor clearColor];
    _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameField.layer.zPosition = 2;
    
    _tipLabel = [[UILabel alloc]init];
    _tipLabel.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:INDEX]objectForKey:@"tip"];
    _tipLabel.font = [UIFont boldSystemFontOfSize:TIPLABEL_FONT_SIZE];
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.textColor = [UIColor lightGrayColor];
    
    [self.view addSubview:_bgView];
    //[self.view addSubview:_nameField];
    [_bgView addSubview:_nameField];
    [self.view addSubview:_tipLabel];
    [_nameField becomeFirstResponder];
    [self orientChange:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(![_nameField.text isEqualToString:[[DetailInfoCenter getDetailInfoCenter].content objectAtIndex:INDEX]])
    {
        [[DetailInfoCenter getDetailInfoCenter]modifyDataAtIndex:INDEX andcontent:_nameField.text];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)orientChange:(NSNotification *)noti
{
    _bgView.frame =  CGRectMake(0, 95, [UIScreen mainScreen].bounds.size.width, LABEL_HEIGHT);
    _nameField.frame = CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 40, LABEL_HEIGHT);
    //_nameField.text = [[[DetailInfoCenter getDetailInfoCenter].infoArr objectAtIndex:INDEX] objectForKey:@"content"];
    _tipLabel.frame = CGRectMake(20, _bgView.frame.origin.y - 30, [UIScreen mainScreen].bounds.size.width - 20, 30);
}

@end
