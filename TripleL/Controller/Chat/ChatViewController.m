//
//  ViewController.m
//  ChatView
//
//  Created by h1r0 on 15/4/26.
//  Copyright (c) 2015年 h1r0. All rights reserved.
//

#import "ChatViewController.h"
#import "MessageViewController.h"
#import "TLMessage.h"
#import "MyHeader.h"

#import "TouchDownGestureRecognizer.h"
#import "EmotionsModule.h"
#import "RecordingView.h"
#import "JSMessageInputView.h"
#import "EmotionsViewController.h"
#import "ChatUtilityViewController.h"
#import "AudioTool.h"

#import "UIImageView+WebCache.h"

static ChatViewController *chatVC = nil;
static NSString *lastFriendName = nil;


@interface ChatViewController ()<JSMessageInputViewDelegate, UIGestureRecognizerDelegate, DDEmotionsViewControllerDelegate, ChatUtilityViewControllerDelegate, AudioToolDelegate, HPGrowingTextViewDelegate>
{
    DDBottomShowComponent _bottomShowComponent;
    float _inputViewY;
    NSString* currentInputContent;         // 输入文字的记录（切换到语音输入是保存）
}

@property (nonatomic, strong) id detailItem;

@property (nonatomic, strong) RecordingView *recordingView;                  // 录音视图（屏幕中间）
@property (nonatomic, strong) UIButton * recordButton;                       // 录音按钮
@property (nonatomic, strong) TouchDownGestureRecognizer* touchDownGestureRecognizer;       // 录音按钮的手势识别

@property (nonatomic,strong)JSMessageInputView *chatInputView;               // 输入框
@property (nonatomic,strong)ChatUtilityViewController *ddUtilityVC;          // 附件VC
@property (nonatomic,strong)EmotionsViewController *emotionsVC;              // 表情VC
@property (nonatomic,strong)AudioTool *audioTool;                            // 录音机

@property (strong, nonatomic) NSURL *myImageURL;
@property (strong, nonatomic) NSURL *partnerImageURL;

@end

@implementation ChatViewController

+ (ChatViewController *) getChatViewController
{
    if (chatVC == nil) {
        chatVC = [[ChatViewController alloc] init];
    }
    
    return chatVC;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialInput];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(p_tapOnTableView:)];
    pan.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    _audioTool = [AudioTool sharedAudioTool];
    _audioTool.delegate = self;
    
    [self loadMessages];

    [self.tableView addGestureRecognizer:tap];
    [self.view addGestureRecognizer:pan];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (lastFriendName == nil || ![self.friendUser.username isEqualToString:lastFriendName]) {
        lastFriendName = [NSString stringWithString:self.friendUser.username];
        [self loadMessages];
    }
    
    [super viewWillAppear:animated];

    self.kboardShow = NO;
    self.myImageURL      = [NSURL URLWithString: self.selfUser.avatar];
    self.partnerImageURL = [NSURL URLWithString: self.friendUser.avatar];
  
    [self.chatInputView.textView setText:nil];
    [self hideBottomComponent];           // 隐藏所有部件

    if (_friendUser.remarkName == nil) {
        _friendUser.remarkName = _friendUser.nickname;
    }
    [self.navigationItem setTitle:_friendUser.remarkName];
    [self.tabBarController.tabBar setHidden:YES];
    
    // 滚动到屏幕底端
    NSInteger section = [self numberOfSectionsInTableView:self.tableView] - 1;
    NSInteger row     = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
    if (row > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    self.tableView.frame = self.view.frame;      // 解决某些情况下，tableview frame不正常现象
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_audioTool.isPlaying) {
        [_audioTool stopPlaying];
    }
}

- (void) setFriendUser:(TLUser *)friendUser
{
    _friendUser = friendUser;
    if (_friendUser == nil) {
        return;
    }
    self.dataSource = [[DataCenter getDataCenter] getChatRecordFromUser:[[MyServer getServer] getSelfAccountInfo].username toFriend:friendUser.username];
}

- (void)loadMessages
{
    self.dataSource = [DataCenter getDataCenter].chatRecArray;
}


- (void)textViewEnterSend {              // 发送文字消息
    NSString* text = [self.chatInputView.textView text];
    
    NSString* parten = @"\\s";
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:nil];
    NSString* checkoutText = [reg stringByReplacingMatchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, [text length]) withTemplate:@""];
    if ([checkoutText length] == 0) {
        return;
    }
    
    TLMessage *message = [[TLMessage alloc] init];
    message.date = [NSDate date];
    message.text = text;
    message.type = TLMessageTypeText;
    message.to = self.friendUser.username;
    message.from = self.selfUser.username;
    [self.chatInputView.textView setText:nil];
    [self sendMessage:message];
}

- (void)p_sendRecord:(UIButton*)button              // 发送语音
{
    [_audioTool stopRecording];
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:rec_start];
    [self.chatInputView.recordButton setHighlighted:NO];
    if (time < 1.0) {
        [self.recordingView setRecordingState:DDShowRecordTimeTooShort];
        return;
    }
    
    [_recordingView setHidden:YES];
    
    NSData *data = [NSData dataWithContentsOfURL:_audioTool.recorder.url];
    NSString *fileName = [NSString stringWithFormat:@"%@%@%ld", FILE_DOC, FILE_VOICE, (long)([[NSDate date] timeIntervalSince1970] * 10000)];
    [data writeToFile:fileName atomically:YES];
    
    TLMessage *message = [[TLMessage alloc] init];
    message.type = TLMessageTypeVoice;
    message.date = [NSDate date];
    message.length = [NSString stringWithFormat:@"%lf", time];
    message.to = self.friendUser.username;
    message.from = self.selfUser.username;
    message.mediaPath = fileName;
    [self sendMessage:message];
}

- (void) pickerImage: (NSString *) imagePath        // 发送图片
{
    TLMessage *message = [[TLMessage alloc] init];
    message.type = TLMessageTypePhoto;
    message.date = [NSDate date];
    message.photoPath = imagePath;
    message.to = self.friendUser.username;
    message.from = self.selfUser.username;
    [self sendMessage:message];
}

- (void) pickerMovie:(NSString *)moviePath thumbPath:(NSString *)thumbPath      // 发送视频
{
    TLMessage *message = [[TLMessage alloc] init];
    message.type = TLMessageTypeVideo;
    message.date = [NSDate date];
    message.mediaPath = moviePath;
    message.photoPath = thumbPath;
    message.to = self.friendUser.username;
    message.from = self.selfUser.username;
    [self sendMessage:message];
}

#pragma mark - SOMessaging data source
- (NSMutableArray *)messages
{
    return self.dataSource;
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{
    TLMessage *message = self.dataSource[index];
    if (!message.fromMe) {
        cell.contentInsets = UIEdgeInsetsMake(0, 3.0f, 0, 0); //Move content for 3 pt. to right
        cell.textView.textColor = [UIColor blackColor];
    } else {
        cell.contentInsets = UIEdgeInsetsMake(0, 0, 0, 3.0f); //Move content for 3 pt. to left
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.userImageView.layer.cornerRadius = self.userImageSize.width/2;
    cell.userImageView.autoresizingMask = message.fromMe ? UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingFlexibleBottomMargin;
    cell.userImageURL = message.fromMe ? self.myImageURL : self.partnerImageURL;
}


#pragma mark - SOMessaging delegate
- (void)didSelectMediaInCell:(SOMessageCell *)cell
{
    [super didSelectMediaInCell:cell];
}

- (void)messageInputView:(SOMessageInputView *)inputView didSendMessage:(NSString *)message
{
    if (![[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return;
    }
}

- (void)messageInputViewDidSelectMediaButton:(SOMessageInputView *)inputView
{
    
}


#pragma mark - 输入框初始化
- (void)initialInput
{
    CGRect inputFrame = CGRectMake(0, SCREEN_HEIGHT - 44.0f,SCREEN_WIDTH,44.0f);
    self.chatInputView = [[JSMessageInputView alloc] initWithFrame:inputFrame delegate:self];               // 初始化输入框，并设置delegate为self
    [self.chatInputView setBackgroundColor:[UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0]];
    [self.view addSubview:self.chatInputView];
    
    [self.chatInputView.emotionbutton addTarget:self action:@selector(showEmotions:) forControlEvents:UIControlEventTouchUpInside];             // 显示表情view按钮
    [self.chatInputView.showUtilitysbutton addTarget:self action:@selector(showUtilitys:) forControlEvents:UIControlEventTouchDown];            // 显示附件view按钮
    [self.chatInputView.voiceButton addTarget:self action:@selector(clickRec_TextButton:) forControlEvents:UIControlEventTouchUpInside];      // 语音键盘切换按钮
    
    
    _touchDownGestureRecognizer = [[TouchDownGestureRecognizer alloc] initWithTarget:self action:nil];          // 手势事件,用于改变录音视图
    __weak ChatViewController* weakSelf = self;
    _touchDownGestureRecognizer.touchDown = ^{
        [weakSelf p_record:nil];
    };
    _touchDownGestureRecognizer.moveInside = ^{
        [weakSelf p_endCancelRecord:nil];
    };
    _touchDownGestureRecognizer.moveOutside = ^{
        [weakSelf p_willCancelRecord:nil];
    };
    _touchDownGestureRecognizer.touchEnd = ^(BOOL inside){
        if (inside)
            [weakSelf p_sendRecord:nil];
        else
            [weakSelf p_cancelRecord:nil];
    };
    [self.chatInputView.recordButton addGestureRecognizer:_touchDownGestureRecognizer];                      // 给语音按钮加上手势事件
    
    _recordingView = [[RecordingView alloc] initWithState:DDShowVolumnState];                                // 录音视图
    [_recordingView setHidden:YES];
    [_recordingView setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    
    [self addObserver:self forKeyPath:@"_inputViewY" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - 输入框按键响应
- (void)clickRec_TextButton:(UIButton*)button           // 语音输入和文字输入框切换
{
    switch (button.tag) {
        case DDVoiceInput:            //开始录音
            [self hideBottomComponent];
            [button setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
            [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
            [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
            button.tag = DDTextInput;
            [self.chatInputView willBeginRecord];
            [self.chatInputView.textView resignFirstResponder];
            currentInputContent = self.chatInputView.textView.text;
            [self.chatInputView.textView setText:nil];
            break;
        case DDTextInput:            //开始输入文字
            [button setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];
            button.tag = DDVoiceInput;
            [self.chatInputView willBeginInput];
            if ([currentInputContent length] > 0){          // 恢复上次记录
                [self.chatInputView.textView setText:currentInputContent];
            }
            [self.chatInputView.textView becomeFirstResponder];
            break;
    }
}

-(void) showEmotions: (id)sender                    // 显示表情
{
    [self.chatInputView.voiceButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];            // 先切换回文字输入框
    self.chatInputView.voiceButton.tag = DDVoiceInput;
    [self.chatInputView willBeginInput];
    if ([currentInputContent length] > 0) {
        [self.chatInputView.textView setText:currentInputContent];
    }
    
    if (self.emotionsVC == nil) {
        self.emotionsVC = [EmotionsViewController new];
        [self.emotionsVC.view setBackgroundColor:[UIColor darkGrayColor]];
        self.emotionsVC.view.frame=DDCOMPONENT_BOTTOM;
        self.emotionsVC.delegate = self;
        [self.view addSubview:self.emotionsVC.view];
    }
    if (_bottomShowComponent & DDShowKeyboard) {        // 显示的是键盘,这是需要隐藏键盘，显示表情，不需要动画
        [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        _bottomShowComponent = (_bottomShowComponent & 0) | DDShowEmotion;
        [self.chatInputView.textView resignFirstResponder];
        [self.emotionsVC.view setFrame:DDEMOTION_FRAME];
        [self.ddUtilityVC.view setFrame:DDCOMPONENT_BOTTOM];
        [self inputUtilityViewWillShow];
    }
    else if (_bottomShowComponent & DDShowEmotion) {     // 表情面板本来就是显示的,显示键盘
        [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
        [self.chatInputView.textView becomeFirstResponder];
        _bottomShowComponent = _bottomShowComponent & DDHideEmotion;
      //  [self hideBottomComponent];
    }
    else if (_bottomShowComponent & DDShowUtility) {     // 显示的是插件，这时需要隐藏插件，显示表情
        [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
        [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        [self.ddUtilityVC.view setFrame:DDCOMPONENT_BOTTOM];
        [self.emotionsVC.view setFrame:DDEMOTION_FRAME];
        _bottomShowComponent = (_bottomShowComponent & DDHideUtility) | DDShowEmotion;
    }
    else {       // 这是什么都没有显示，需用动画显示表情
        [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        _bottomShowComponent = _bottomShowComponent | DDShowEmotion;
        [UIView animateWithDuration:0.25 animations:^{
            [self.emotionsVC.view setFrame:DDEMOTION_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
            [self inputUtilityViewWillShow];
        }];
        [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
    }
}

-(void) showUtilitys:(id)sender
{
    [self.chatInputView.voiceButton setImage:[UIImage imageNamed:@"dd_record_normal"] forState:UIControlStateNormal];       // 切换会文字输入框
    self.chatInputView.voiceButton.tag = DDVoiceInput;
    [self.chatInputView willBeginInput];
    if ([currentInputContent length] > 0) {
        [self.chatInputView.textView setText:currentInputContent];
    }
    
    if (self.ddUtilityVC == nil) {
        self.ddUtilityVC = [ChatUtilityViewController new];
        self.ddUtilityVC.delegate = self;
        [self addChildViewController:self.ddUtilityVC];
        self.ddUtilityVC.view.frame=CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , 280);
        [self.view addSubview:self.ddUtilityVC.view];
    }
    
    if (_bottomShowComponent & DDShowKeyboard) {        //显示的是键盘,这是需要隐藏键盘，显示插件，不需要动画
        [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        _bottomShowComponent = (_bottomShowComponent & 0) | DDShowUtility;
        [self.chatInputView.textView resignFirstResponder];
        [self.ddUtilityVC.view setFrame:DDUTILITY_FRAME];
        [self.emotionsVC.view setFrame:DDCOMPONENT_BOTTOM];
        [self inputUtilityViewWillShow];
    }
    else if (_bottomShowComponent & DDShowUtility) {        //插件面板本来就是显示的,显示键盘
        [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
        [self.chatInputView.textView becomeFirstResponder];
        _bottomShowComponent = _bottomShowComponent & DDHideUtility;
    }
    else if (_bottomShowComponent & DDShowEmotion) {        //显示的是表情，这时需要隐藏表情，显示插件
        [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
        [self.emotionsVC.view setFrame:DDCOMPONENT_BOTTOM];
        [self.ddUtilityVC.view setFrame:DDUTILITY_FRAME];
        _bottomShowComponent = (_bottomShowComponent & DDHideEmotion) | DDShowUtility;
    }
    else {    //这是什么都没有显示，需用动画显示插件
        [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_input_normal"] forState:UIControlStateNormal];
        _bottomShowComponent = _bottomShowComponent | DDShowUtility;
        [UIView animateWithDuration:0.25 animations:^{
            [self.ddUtilityVC.view setFrame:DDUTILITY_FRAME];
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
            [self inputUtilityViewWillShow];
        }];
        [self setValue:@(DDINPUT_TOP_FRAME.origin.y) forKeyPath:@"_inputViewY"];
    }
}

- (void)hideBottomComponent         // 隐藏所有小部件
{
    _bottomShowComponent = _bottomShowComponent * 0;
    [self.chatInputView.textView resignFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        self.ddUtilityVC.view.frame = DDCOMPONENT_BOTTOM;
        self.emotionsVC.view.frame = DDCOMPONENT_BOTTOM;
        self.chatInputView.frame = DDINPUT_BOTTOM_FRAME;
        [self inputUtilityViewWillHide];
    }];
    [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
    [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
    [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
}

static NSDate *rec_start;

- (void)p_record:(UIButton*)button          // 开始录音
{
    [self.chatInputView.recordButton setHighlighted:YES];
    if (![[self.view subviews] containsObject:_recordingView]){
        [self.view addSubview:_recordingView];
    }
    [_recordingView setHidden:NO];
    [_recordingView setRecordingState:DDShowVolumnState];
    rec_start = [NSDate date];
    [_audioTool startRecording];
}

- (void)p_endCancelRecord:(UIButton*)button         // 手指移除后再次移入
{
    [_recordingView setHidden:NO];
    [_recordingView setRecordingState:DDShowVolumnState];
}

- (void)p_willCancelRecord:(UIButton*)button            // 手指移出
{
    [_recordingView setHidden:NO];
    [_recordingView setRecordingState:DDShowCancelSendState];
}

- (void)p_cancelRecord:(UIButton*)button            // 手指移出后 松手
{
    [self.chatInputView.recordButton setHighlighted:NO];
    [_recordingView setHidden:YES];

    [_audioTool stopRecording];
    [_audioTool destructionRecordingFile];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_inputViewY"]) {
        //            [self p_unableLoadFunction];
        [UIView animateWithDuration:0.25 animations:^{
            if (_bottomShowComponent & DDShowEmotion) {
                CGRect frame = self.emotionsVC.view.frame;
                frame.origin.y = self.chatInputView.bottom;
                self.emotionsVC.view.frame = frame;
            }
            else if (_bottomShowComponent & DDShowUtility) {
                CGRect frame = self.ddUtilityVC.view.frame;
                frame.origin.y = self.chatInputView.bottom;
                self.ddUtilityVC.view.frame = frame;
            }
        } completion:^(BOOL finished) {
            //                [self p_enableLoadFunction];
        }];
    }
    
}
- (void)p_tapOnTableView:(UIGestureRecognizer*)sender
{
    if (_bottomShowComponent) {
        [self hideBottomComponent];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"_inputViewY"];
}

#pragma mark - 表情view
- (void)emotionViewClickSendButton
{
    [self textViewEnterSend];
}
-(void)insertEmojiFace:(NSString *)string
{
    NSMutableString* content = [NSMutableString stringWithString:self.chatInputView.textView.text];
    [content appendString:string];
    [self.chatInputView.textView setText:content];
}
-(void)deleteEmojiFace
{
    EmotionsModule* emotionModule = [EmotionsModule shareInstance];
    NSString* toDeleteString = nil;
    if (self.chatInputView.textView.text.length == 0){
        return;
    }
    if (self.chatInputView.textView.text.length == 1){
        self.chatInputView.textView.text = @"";
    }
    else {
        toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 1];
        int length = [emotionModule.emotionLength[toDeleteString] intValue];
        if (length == 0){
            toDeleteString = [self.chatInputView.textView.text substringFromIndex:self.chatInputView.textView.text.length - 2];
            length = [emotionModule.emotionLength[toDeleteString] intValue];
        }
        length = length == 0 ? 1 : length;
        self.chatInputView.textView.text = [self.chatInputView.textView.text substringToIndex:self.chatInputView.textView.text.length - length];
    }
    
}

#pragma mark - 手势识别
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (CGRectContainsPoint(DDINPUT_BOTTOM_FRAME, location)) {
        return NO;
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isEqual:self]){
        return YES;
    }
    return NO;
}

#pragma mark - 输入框 delegate
- (void) viewheightChanged: (float)height {
    [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
}

- (void) textViewShouldBeginEditing
{
    [self.chatInputView.emotionbutton setImage:[UIImage imageNamed:@"dd_emotion"] forState:UIControlStateNormal];
    [self.chatInputView.showUtilitysbutton setImage:[UIImage imageNamed:@"dd_utility"] forState:UIControlStateNormal];
}


#pragma mark - 键盘通知

- (void)handleWillShowKeyboard:(NSNotification *)notification
{
    CGRect keyboardRect;
    keyboardRect = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    _bottomShowComponent = _bottomShowComponent | DDShowKeyboard;
    [UIView animateWithDuration:0.1 animations:^{
        [self.chatInputView setFrame:CGRectMake(0, keyboardRect.origin.y - DDINPUT_HEIGHT, self.view.frame.size.width, DDINPUT_HEIGHT)];
    }];
    [self setValue:@(keyboardRect.origin.y - DDINPUT_HEIGHT) forKeyPath:@"_inputViewY"];
}

- (void)handleDidShowKeyboard:(NSNotification *)notification
{
    self.kboardShow = YES;
    CGRect keyboardRect;
    keyboardRect = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    self.kboardRect = keyboardRect;
    
    float cellH = 0;
    if (self.messages.count > 0) {
        cellH = [self heightForMessageForIndex: self.messages.count - 1] + 40;
    }
    float h = self.view.frame.size.height - self.tableView.contentSize.height - cellH;
    if (h < keyboardRect.size.height) {
        h = h < 0 ? 0 : h;
        [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - (self.kboardRect.size.height - h), self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void)handleWillHideKeyboard:(NSNotification *)notification
{
    self.kboardShow = NO;
    CGRect keyboardRect;
    keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    _bottomShowComponent = _bottomShowComponent & DDHideKeyboard;
    if (_bottomShowComponent & DDShowUtility){              //显示的是插件
        [UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
    }
    else if (_bottomShowComponent & DDShowEmotion){         //显示的是表情
        [UIView animateWithDuration:0.25 animations:^{
            [self.chatInputView setFrame:DDINPUT_TOP_FRAME];
        }];
        [self setValue:@(self.chatInputView.frame.origin.y) forKeyPath:@"_inputViewY"];
    }
    else {
        [self hideBottomComponent];
    }
    [self.tableView setFrame:self.view.frame];
}

- (void) inputUtilityViewWillShow
{
    float cellH = 0;
    if (self.messages.count > 0) {
        cellH = [self heightForMessageForIndex: self.messages.count - 1] + 40;
    }
    float h = self.view.frame.size.height - self.tableView.contentSize.height - cellH;
    if (h < DDEMOTION_FRAME.size.height) {
        h = h < 0 ? 0 : h;
        [self.tableView setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - (DDEMOTION_FRAME.size.height - h), self.view.frame.size.width, self.view.frame.size.height)];
    }
}

- (void) inputUtilityViewWillHide
{
    [self.tableView setFrame:self.view.frame];
}

- (void)orientChange: (NSNotification *) notification
{
    [self.tableView reloadData];
    CGRect inputFrame = CGRectMake(0, SCREEN_HEIGHT - 44.0f, SCREEN_WIDTH, 44.0f);
    [self.inputView setFrame:inputFrame];
    [self hideBottomComponent]; 
}

#pragma mark - LVRecordTool
- (void) audioTool:(AudioTool *)audioTool didstartRecoring:(int)no
{
    [_recordingView setVolume:no];
}



#pragma mark -
- (void)playingStoped
{

}


@end
