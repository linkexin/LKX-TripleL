//
//  GuessNumberViewController.m
//  game
//
//  Created by h1r0 on 15/5/23.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "GuessNumberViewController.h"

@interface GuessNumberViewController () <UITextFieldDelegate>
{
    int number;
    int time, chance;
    NSTimer *timer;
    NSString *logString;
}

@property (nonatomic, strong) UITextView *explanationTextView;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *chanceLabel;

@property (nonatomic, strong) UILabel *ansTitleLabel;
@property (nonatomic, strong) UITextField *numberField1;
@property (nonatomic, strong) UITextField *numberField2;
@property (nonatomic, strong) UITextField *numberField3;
@property (nonatomic, strong) UITextField *numberField4;
@property (nonatomic, strong) UITextView *ansView;

@property (nonatomic, strong) UITextField *textFiled;

@property (nonatomic, strong) UITapGestureRecognizer *tapGR;

@end

@implementation GuessNumberViewController

- (id) init
{
    if (self = [super init]) {
        _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard)];
        [_tapGR setNumberOfTapsRequired:1];
        [_tapGR setNumberOfTouchesRequired:1];
        
        _explanationTextView = [[UITextView alloc] init];
        [_explanationTextView setText:@"    后台已经生成了四个数字（0-9），快来猜猜看吧～"];
        [_explanationTextView setFont:[UIFont systemFontOfSize:14]];
        [_explanationTextView setTextAlignment:NSTextAlignmentNatural];
        [_explanationTextView setScrollEnabled:NO];
        [_explanationTextView setUserInteractionEnabled:NO];
        [_explanationTextView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]];
        _explanationTextView.layer.masksToBounds = YES;
        _explanationTextView.layer.cornerRadius = 2;
        [self.view addSubview:_explanationTextView];
        
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setTextAlignment:NSTextAlignmentLeft];
        [_timeLabel setFont:[UIFont systemFontOfSize:15]];
        [self.view addSubview:_timeLabel];
        
        _chanceLabel = [[UILabel alloc] init];
        [_chanceLabel setTextAlignment:NSTextAlignmentRight];
        [_chanceLabel setFont:[UIFont systemFontOfSize:15]];
        [self.view addSubview:_chanceLabel];
        
        _ansTitleLabel = [[UILabel alloc] init];
        [_ansTitleLabel setText:@"你的答案:"];
        [self.view addSubview:_ansTitleLabel];
        
        _numberField1 = [[UITextField alloc] init];
        _numberField1.layer.masksToBounds = YES;
        _numberField1.layer.borderWidth = 0.2;
        _numberField1.layer.cornerRadius = 2;
        _numberField1.userInteractionEnabled = NO;
        [_numberField1 setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_numberField1];
        _numberField2 = [[UITextField alloc] init];
        _numberField2.layer.masksToBounds = YES;
        _numberField2.layer.borderWidth = 0.2;
        _numberField2.layer.cornerRadius = 2;
        _numberField2.userInteractionEnabled = NO;
        [_numberField2 setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_numberField2];
        _numberField3 = [[UITextField alloc] init];
        _numberField3.layer.masksToBounds = YES;
        _numberField3.layer.borderWidth = 0.2;
        _numberField3.layer.cornerRadius = 2;
        _numberField3.userInteractionEnabled = NO;
        [_numberField3 setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_numberField3];
        _numberField4 = [[UITextField alloc] init];
        _numberField4.layer.masksToBounds = YES;
        _numberField4.layer.borderWidth = 0.2;
        _numberField4.layer.cornerRadius = 2;
        _numberField4.userInteractionEnabled = NO;
        [_numberField4 setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:_numberField4];
        
        _ansView = [[UITextView alloc] init];
        [_ansView setBackgroundColor:[UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:248.0/255.0 alpha:1.0]];
        [_ansView setUserInteractionEnabled:NO];
        [self.view addSubview:_ansView];
        
        _textFiled = [[UITextField alloc] init];
        _textFiled.keyboardType = UIKeyboardTypeNumberPad;
        _textFiled.delegate = self;
        [self.view addSubview:_textFiled];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setNavTitle:@"猜数字"];
    
    [self setAllViewFrame];

    [self.view addGestureRecognizer:_tapGR];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startGame];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:_tapGR];
}

- (void) setGameDiff: (int) diff
{
    if (diff == 1) {
        time = 90;
        chance = 20;
    }
    else if (diff == 2){
        time = 60;
        chance = 15;
    }
    else if (diff == 3){
        time = 60;
        chance = 10;
    }
}

- (void) compare
{
    if (_numberField1.text.length == 0 || _numberField2.text.length == 0 || _numberField3.text.length == 0 || _numberField4.text.length == 0) {
        return;
    }
    int userAns = _numberField1.text.intValue * 1000 + _numberField2.text.intValue * 100 + _numberField3.text.intValue * 10 + _numberField4.text.intValue;
    [_textFiled setText:@""];
    [_numberField1 setText:@""];
    [_numberField2 setText:@""];
    [_numberField3 setText:@""];
    [_numberField4 setText:@""];

    int x = 0, y = 0;
    BOOL visI[4] = {0}, visJ[4] = {0};
    for (int i = 0; i < 4; i ++) {
        int p = [self getNum:number inPos:i];
        int q = [self getNum:userAns inPos:i];
        if (p == q) {
            x ++;
            visI[i] = 1;
            visJ[i] = 1;
        }
    }
    for (int i = 0; i < 4; i ++) {
        if (visI[i]) {
            continue;
        }
        for (int j = 0; j < 4; j ++) {
            if (visJ[j]) {
                continue;
            }
            int p = [self getNum:number inPos:i];
            int q = [self getNum:userAns inPos:j];
            if (p == q) {
                y ++;
                visJ[j] = 1;
            }
        }
    }
    NSString *str = [NSString stringWithFormat:@"%d    完全正确: %d    仅数字正确: %d\n", userAns, x, y];
    logString = [NSString stringWithFormat:@"%@\n%@", str, logString];
    [_ansView setText:logString];
    
    if (x == 4) {
        [self gameSuccessful];
    }
    else {
        chance_count ++;
        [self setChance:chance - chance_count];
        [_numberField1 becomeFirstResponder];
        if (chance - chance_count <= 0) {
            [self gameOver];
        }
    }
}

- (void) showKeyboard
{
    if ([_textFiled isFirstResponder]) {
        [_textFiled resignFirstResponder];
    }
    else {
        [_textFiled becomeFirstResponder];
    }
}

- (int) getNum: (int) num inPos: (int) pos
{
    int t = pow(10, pos);
    int ans = (num % (t * 10)) / t;
    return ans;
}


static int time_count;
static int chance_count;
- (void) startGame
{
    number = arc4random() % 10000;
    NSLog(@"ans: %d", number);
    [_timeLabel setText:[NSString stringWithFormat:@"剩余时间: %d s", time]];
    [_chanceLabel setText: [NSString stringWithFormat:@"剩余机会: %d", chance]];

    [_numberField1 setText:@""];
    [_numberField2 setText:@""];
    [_numberField3 setText:@""];
    [_numberField4 setText:@""];
    [_textFiled setText:@""];
    [_ansView setText:@""];
    
    time_count = chance_count = 0;
    logString = @"";
    [_ansView setText:logString];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [_textFiled becomeFirstResponder];
}

- (void) update
{
    time_count ++;
    [self setTime:time - time_count];
    if (time_count >= time) {
        [timer invalidate];
        [self gameOver];
    }
}

- (void) gameSuccessful
{
    [_textFiled resignFirstResponder];
    [timer invalidate];
    [self.delegate gameSucceefully:self];
}

- (void) gameOver
{
    [_textFiled resignFirstResponder];
    [timer invalidate];
    [self.delegate gameOver:self];
}

- (void) setTime: (int) t
{
    [_timeLabel setText:[NSString stringWithFormat:@"剩余时间: %d s", t]];
}

- (void) setChance: (int) c
{
    [_chanceLabel setText: [NSString stringWithFormat:@"剩余机会: %d", c]];
}


- (void) setAllViewFrame
{
    CGSize size = self.view.frame.size;
    float x = size.width * 0.06;
    float y = 80;
    float w = size.width * 0.88;
    float h = [_explanationTextView sizeThatFits:CGSizeMake(w, MAXFLOAT)].height;
    [_explanationTextView setFrame:CGRectMake(x, y, w, h)];

    y += h + 20;
    [_timeLabel setText:@" "];
    h = [_timeLabel sizeThatFits:CGSizeMake(w, MAXFLOAT)].height;
    [_timeLabel setFrame:CGRectMake(x, y, w / 2, h)];
    [_chanceLabel setFrame:CGRectMake(x + w / 2, y, w / 2, h)];

    y += h + 30;
    CGSize labelSize = [_ansTitleLabel sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    [_ansTitleLabel setFrame:CGRectMake(x, y, labelSize.width, labelSize.height)];
    float p = x + labelSize.width + 15;
    float q = (w - labelSize.width - 15) / 4;
    [_numberField1 setFrame:CGRectMake(p + q * 0.3, y - 3, q * 0.7, labelSize.height + 6)];
    [_numberField2 setFrame:CGRectMake(p + q * 1.3, y - 3, q * 0.7, labelSize.height + 6)];
    [_numberField3 setFrame:CGRectMake(p + q * 2.3, y - 3, q * 0.7, labelSize.height + 6)];
    [_numberField4 setFrame:CGRectMake(p + q * 3.3, y - 3, q * 0.7, labelSize.height + 6)];
    
    y += labelSize.height + 6 + 20;
    [_ansView setFrame:CGRectMake(x, y, w, self.view.frame.size.height - 270 - y)];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int len = (int)(textField.text.length);
    if (string.length > 0 && !isdigit([string characterAtIndex:0])) {
        return NO;
    }
    else if (string.length == 0){
        if (len == 3) {
            [_numberField3 setText:@""];
        }
        else if (len == 2){
            [_numberField2 setText:@""];
        }
        else if (len == 1){
            [_numberField1 setText:@""];
        }
        return YES;
    }
    
    if (len == 0) {
        [_numberField1 setText:string];
    }
    else if (len == 1){
        [_numberField2 setText:string];
    }
    else if (len == 2){
        [_numberField3 setText:string];
    }
    else {
        [_numberField4 setText:string];
        [self compare];
        return NO;
    }

    return YES;
}


@end
