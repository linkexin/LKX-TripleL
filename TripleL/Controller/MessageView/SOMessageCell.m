//
//  SOMessageCell.m
//  SOMessaging
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "SOMessageCell.h"
#import "NSString+Calculation.h"
#import "AudioTool.h"

#import "UIImageView+WebCache.h"
#import "MyHeader.h"

@interface SOMessageCell() < UIGestureRecognizerDelegate>
{
    int pCount;
    BOOL isHorizontalPan;
    NSTimer *vAnmationTimer;
}
@property (nonatomic) CGSize mediaImageViewSize;
@property (nonatomic) CGSize userImageViewSize;

@property (nonatomic) UIProgressView *progressView;

@end

@implementation SOMessageCell

static CGFloat messageTopMargin;
static CGFloat messageBottomMargin;
static CGFloat messageLeftMargin;
static CGFloat messageRightMargin;

static CGFloat maxContentOffsetX;
static CGFloat contentOffsetX;

static CGFloat initialTimeLabelPosX;
static BOOL cellIsDragging;

+ (void)load
{
    [self setDefaultConfigs];
}

+ (void)setDefaultConfigs
{
    messageTopMargin = 9;
    messageBottomMargin = 9;
    messageLeftMargin = 15;
    messageRightMargin = 15;
    
    contentOffsetX = 0;
    maxContentOffsetX = 50;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageMaxWidth:(CGFloat)messageMaxWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.messageMaxWidth = messageMaxWidth;
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGesture.delegate = self;
        [self addGestureRecognizer:self.panGesture];
        
        [self setInitialSizes];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationWillChandeNote:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    
    return self;
}

- (void)setInitialSizes
{
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    if (self.timeLabel) {
        [self.timeLabel removeFromSuperview];
    }
    
    self.userImageView = [[UIImageView alloc] init];
    self.userImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.messageMaxWidth, 0)];
    self.timeLabel = [[UILabel alloc] init];
    self.mediaImageView = [[UIImageView alloc] init];
    self.mediaOverlayView = [[UIView alloc] init];
    self.balloonImageView = [[UIImageView alloc] init];
    self.voiceImageView = [[UIImageView alloc] init];
    self.voiceLabel = [[UILabel alloc] init];

    if (!CGSizeEqualToSize(self.userImageViewSize, CGSizeZero)) {
        CGRect frame = self.userImageView.frame;
        frame.size = self.userImageViewSize;
        self.userImageView.frame = frame;
    }

    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.backgroundColor = [UIColor clearColor];
 //   self.userImageView.layer.cornerRadius = 5;
    
    if (!CGSizeEqualToSize(self.mediaImageViewSize, CGSizeZero)) {
        CGRect frame = self.mediaImageView.frame;
        frame.size = self.mediaImageViewSize;
        self.mediaImageView.frame = frame;
    }
    
    self.mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaImageView.clipsToBounds = YES;
    self.mediaImageView.backgroundColor = [UIColor clearColor];
    self.mediaImageView.userInteractionEnabled = YES;
//    self.mediaImageView.layer.cornerRadius = 10;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMediaTapped:)];
    [self.mediaImageView addGestureRecognizer:tap];
    
    self.mediaOverlayView.backgroundColor = [UIColor clearColor];
    [self.mediaImageView addSubview:self.mediaOverlayView];
    
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setTextContainerInset:UIEdgeInsetsZero];
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.font = self.messageFont;
    [self hideSubViews];
    
    self.containerView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self.contentView addSubview:self.containerView];
    
    [self.containerView addSubview:self.balloonImageView];
    [self.containerView addSubview:self.textView];
    [self.containerView addSubview:self.mediaImageView];
    [self.containerView addSubview:self.userImageView];
    
    [self.contentView addSubview:self.timeLabel];
    
    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void)hideSubViews
{
    self.userImageView.hidden = YES;
    self.textView.hidden = YES;
    self.mediaImageView.hidden = YES;
    self.voiceLabel.hidden = YES;
    self.voiceImageView.hidden = YES;
}

- (void)setMediaImageViewSize:(CGSize)size
{
    _mediaImageViewSize = size;
    CGRect frame = self.mediaImageView.frame;
    frame.size = size;
    self.mediaImageView.frame = frame;
}

- (void)setUserImageViewSize:(CGSize)size
{
    _userImageViewSize = size;
    CGRect frame = self.userImageView.frame;
    frame.size = size;
    self.userImageView.frame = frame;
}

- (void)setUserImageURL:(NSURL *)userImageURL
{
    _userImageURL = userImageURL;
    if (!userImageURL) {
        self.userImageViewSize = CGSizeZero;
    }
    [self adjustCell];
}

#pragma mark -
- (void)handleMediaTapped:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapMedia:)]) {
        if (self.message.type == TLMessageTypeVoice) {
            if ([[AudioTool sharedAudioTool] isPlaying]) {
                [[AudioTool sharedAudioTool] stopPlaying];
                return;
            }
            else{
                [self startVoiceAnimation];
                [[AudioTool sharedAudioTool] playFromFile:self.message.mediaPath];
            }
        }
        else{
            if ([[AudioTool sharedAudioTool] isPlaying]) {
                [[AudioTool sharedAudioTool] stopPlaying];
                return;
            }
            [self.delegate messageCell:self didTapMedia:self.message.mediaPath];
        }
    }
}

#pragma mark -
- (void)setMessage:(TLMessage *)message
{
    _message = message;

    [self setInitialSizes];
//    [self adjustCell];
}

- (void)adjustCell
{
    [self hideSubViews];
    
    if (self.message.type == TLMessageTypeText) {
        self.textView.hidden = NO;
        [self adjustForTextOnly];
    } else if (self.message.type == TLMessageTypePhoto) {
        self.mediaImageView.hidden = NO;
        [self adjustForPhotoOnly];
    } else if (self.message.type == TLMessageTypeVideo) {
        self.mediaImageView.hidden = NO;
        [self adjustForVideoOnly];
    }else if (self.message.type == TLMessageTypeVoice) {
        pCount = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoiceAnimation) name: PLAYING_FINISHED object:nil];
        self.mediaImageView.hidden = NO;
        self.voiceImageView.hidden = NO;
        self.voiceLabel.hidden = NO;
        [self adjustForVoiceOnly];
    } else if (self.message.type == TLMessageTypeVideo) {
        if (!CGSizeEqualToSize(self.userImageViewSize, CGSizeZero) && self.userImageURL) {
            self.userImageView.hidden = NO;
        }
    }
    
    self.containerView.autoresizingMask = self.message.fromMe ? UIViewAutoresizingFlexibleLeftMargin : UIViewAutoresizingFlexibleRightMargin;
    initialTimeLabelPosX = self.timeLabel.frame.origin.x;
}

- (void)adjustForTextOnly
{
    CGFloat userImageViewLeftMargin = 3;
    
    CGRect usedFrame = [self usedRectForWidth:self.messageMaxWidth];;
    if (self.balloonMinWidth) {
        CGFloat messageMinWidth = self.balloonMinWidth - messageLeftMargin - messageRightMargin;
        if (usedFrame.size.width <  messageMinWidth) {
            usedFrame.size.width = messageMinWidth;
            
            usedFrame.size.height = [self usedRectForWidth:messageMinWidth].size.height;
        }
    }
    
    CGFloat messageMinHeight = self.balloonMinHeight - messageTopMargin - messageBottomMargin;
    
    if (self.balloonMinHeight && usedFrame.size.height < messageMinHeight) {
        usedFrame.size.height = messageMinHeight;
    }
    
    CGRect frame = self.textView.frame;
    frame.size.width  = usedFrame.size.width;
    frame.size.height = usedFrame.size.height;
    frame.origin.y = messageTopMargin;

    CGRect balloonFrame = self.balloonImageView.frame;
    balloonFrame.size.width = frame.size.width + messageLeftMargin + messageRightMargin;
    balloonFrame.size.height = frame.size.height + messageTopMargin + messageBottomMargin;
    balloonFrame.origin.y = 0;
    frame.origin.x = self.message.fromMe ? messageLeftMargin : (balloonFrame.size.width - frame.size.width - messageLeftMargin);
    if (!self.message.fromMe && self.userImageURL) {
        frame.origin.x += userImageViewLeftMargin + self.userImageViewSize.width;
        balloonFrame.origin.x = userImageViewLeftMargin + self.userImageViewSize.width;
    }
    
    frame.origin.x += self.contentInsets.left - self.contentInsets.right;
    
    self.textView.frame = frame;
    
    CGRect userRect = self.userImageView.frame;
    
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImageURL) {
        if (balloonFrame.size.height < userRect.size.height) {
            balloonFrame.size.height = userRect.size.height;
        }
    }
    
    self.balloonImageView.frame = balloonFrame;
    self.balloonImageView.backgroundColor = [UIColor clearColor];
    self.balloonImageView.image = self.balloonImage;
    
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
    

    
    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
        userRect.origin.y = balloonFrame.size.height - userRect.size.height;
    } else {
        userRect.origin.y = 0;
    }

    if (self.message.fromMe) {
        userRect.origin.x = balloonFrame.origin.x + userImageViewLeftMargin + balloonFrame.size.width;
    } else {
        userRect.origin.x = balloonFrame.origin.x - userImageViewLeftMargin - userRect.size.width;
    }
    self.userImageView.frame = userRect;
    [self.userImageView sd_setImageWithURL:_userImageURL placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    
    CGRect frm = self.containerView.frame;
    frm.origin.x = self.message.fromMe ? self.contentView.frame.size.width - balloonFrame.size.width - kBubbleRightMargin : kBubbleLeftMargin;
    frm.origin.y = kBubbleTopMargin;
    frm.size.height = balloonFrame.size.height;
    frm.size.width = balloonFrame.size.width;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImageURL) {
        self.userImageView.hidden = NO;
        frm.size.width += userImageViewLeftMargin + userRect.size.width;
        if (self.message.fromMe) {
            frm.origin.x -= userImageViewLeftMargin + userRect.size.width;
        }
    }


    if (frm.size.height < self.userImageViewSize.height) {
        CGFloat delta = self.userImageViewSize.height - frm.size.height;
        frm.size.height = self.userImageViewSize.height;
        
        for (UIView *sub in self.containerView.subviews) {
            CGRect fr = sub.frame;
            fr.origin.y += delta;
            sub.frame = fr;
        }
    }
    self.containerView.frame = frm;
    
    // Adjusing time label
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.timeLabel.frame = CGRectZero;
    self.timeLabel.text = [formatter stringFromDate:self.message.date];

    [self.timeLabel sizeToFit];
    CGRect timeLabel = self.timeLabel.frame;
    timeLabel.origin.x = self.contentView.frame.size.width + 5;
    self.timeLabel.frame = timeLabel;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.containerView.center.y);
    
}

- (void) adjustForVoiceOnly
{
    CGFloat userImageViewLeftMargin = 3;
    
    CGRect usedFrame = [self usedRectForWidth:self.messageMaxWidth];;
    if (self.balloonMinWidth) {
        CGFloat messageMinWidth = self.balloonMinWidth - messageLeftMargin - messageRightMargin;
        if (usedFrame.size.width <  messageMinWidth) {
            usedFrame.size.width = messageMinWidth;
            
            usedFrame.size.height = [self usedRectForWidth:messageMinWidth].size.height;
        }
    }
    
    CGFloat messageMinHeight = self.balloonMinHeight - messageTopMargin - messageBottomMargin;
    
    if (self.balloonMinHeight && usedFrame.size.height < messageMinHeight) {
        usedFrame.size.height = messageMinHeight;
    }
    
    CGRect frame;
    frame.size.width  = usedFrame.size.width;
    frame.size.height = usedFrame.size.height;
    frame.origin.y = messageTopMargin;
    
    CGRect balloonFrame = self.balloonImageView.frame;
    balloonFrame.size.width = frame.size.width + messageLeftMargin + messageRightMargin;
    balloonFrame.size.height = frame.size.height + messageTopMargin + messageBottomMargin;
    balloonFrame.origin.y = 0;
    frame.origin.x = self.message.fromMe ? messageLeftMargin : (balloonFrame.size.width - frame.size.width - messageLeftMargin);
    if (!self.message.fromMe && self.userImageURL) {
        frame.origin.x += userImageViewLeftMargin + self.userImageViewSize.width;
        balloonFrame.origin.x = userImageViewLeftMargin + self.userImageViewSize.width;
    }
    frame.origin.x += self.contentInsets.left - self.contentInsets.right;

    CGRect userRect = self.userImageView.frame;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImageURL) {
        if (balloonFrame.size.height < userRect.size.height) {
            balloonFrame.size.height = userRect.size.height;
        }
    }
    
    // 气泡，长度
    float buW = [UIScreen mainScreen].bounds.size.width * 0.42;
    float tm = [self.message.length floatValue];
    float len = tm > 10 ? buW : buW / 2.0 + buW / 2.0 * tm / 10;
    balloonFrame.size.width += len;
    self.balloonImageView.frame = balloonFrame;
    self.balloonImageView.backgroundColor = [UIColor clearColor];
    self.balloonImageView.image = self.balloonImage;
    
    self.mediaImageView.frame = balloonFrame;
    
    // 语音
    CGRect vRect = balloonFrame;
    CGRect vLRect = balloonFrame;
    float w = 40;
    if (self.message.fromMe == YES) {
        vRect.origin.x += vRect.size.width - vRect.size.height - 3;
        vRect.origin.y += 8;
        vRect.size.height -= 16;
        vRect.size.width = vRect.size.height;
        [self.voiceImageView setImage:[UIImage imageNamed:@"RVoice3.png"]];
      
        vLRect.origin.x -= w;
        vLRect.origin.y += 10;
        vLRect.size.width = w;
        vLRect.size.height /= 2;
    }
    else{
        vRect.origin.x -= 25;
        vRect.origin.y += 8;
        vRect.size.height -= 16;
        vRect.size.width = vRect.size.height;
        [self.voiceImageView setImage:[UIImage imageNamed:@"LVoice3.png"]];
        
        vLRect.origin.x += vLRect.size.width - 20;
        vLRect.origin.y += 10;
        vLRect.size.width = w;
        vLRect.size.height /= 2;
    }
    self.voiceImageView.frame = vRect;
    [self.balloonImageView addSubview:self.voiceImageView];
    tm *= 100;
    float f = tm / 100;
    tm = (int)tm %100;
    [self.voiceLabel setText:[NSString stringWithFormat:@"%02d'%02d", (int)f, (int)tm]];
    [self.voiceLabel setFont:[UIFont systemFontOfSize:10]];
    [self.voiceLabel setTextColor:[UIColor grayColor]];
    self.voiceLabel.frame = vLRect;
    [self.balloonImageView addSubview:self.voiceLabel];
    
    
    
    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
        userRect.origin.y = balloonFrame.origin.y + balloonFrame.size.height - userRect.size.height;
    } else {
        userRect.origin.y = 0;
    }
    
    if (self.message.fromMe) {
        userRect.origin.x = balloonFrame.origin.x + userImageViewLeftMargin + balloonFrame.size.width;
    } else {
        userRect.origin.x = balloonFrame.origin.x - userImageViewLeftMargin - userRect.size.width;
    }
    self.userImageView.frame = userRect;
    [self.userImageView sd_setImageWithURL:self.userImageURL placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    
    CGRect frm = self.containerView.frame;
    frm.origin.x = self.message.fromMe ? self.contentView.frame.size.width - balloonFrame.size.width - kBubbleRightMargin : kBubbleLeftMargin;
    frm.origin.y = kBubbleTopMargin;
    frm.size.height = balloonFrame.size.height;
    frm.size.width = balloonFrame.size.width;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImageURL) {
        self.userImageView.hidden = NO;
        frm.size.width += userImageViewLeftMargin + userRect.size.width;
        if (self.message.fromMe) {
            frm.origin.x -= userImageViewLeftMargin + userRect.size.width;
        }
    }
    
    if (frm.size.height < self.userImageViewSize.height) {
        CGFloat delta = self.userImageViewSize.height - frm.size.height;
        frm.size.height = self.userImageViewSize.height;
        
        for (UIView *sub in self.containerView.subviews) {
            CGRect fr = sub.frame;
            fr.origin.y += delta;
            sub.frame = fr;
        }
    }
    self.containerView.frame = frm;
    
    // 时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.timeLabel.frame = CGRectZero;
    self.timeLabel.text = [formatter stringFromDate:self.message.date];
    [self.timeLabel sizeToFit];
    CGRect timeLabel = self.timeLabel.frame;
    timeLabel.origin.x = self.contentView.frame.size.width + 5;
    self.timeLabel.frame = timeLabel;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.containerView.center.y);
}

- (CGRect)usedRectForWidth:(CGFloat)width
{
    CGRect usedFrame = CGRectZero;
    
    if (self.message.attributes) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.message.text attributes:self.message.attributes];
        self.textView.attributedText = attributedText;
        CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
        usedFrame.size = [self.textView sizeThatFits:constraintSize];
    } else {
        if (self.message.text == nil) {
            self.message.text = @" ";
        }
        self.textView.text = self.message.text;
        CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
        usedFrame.size = [self.textView sizeThatFits:constraintSize];
    }
    return usedFrame;
}

- (void)adjustForPhotoOnly
{
    CGFloat userImageViewLeftMargin = 3;
    
    
    CGRect frame = CGRectZero;
    frame.size = self.mediaImageViewSize;
    
    if (!self.message.fromMe && self.userImageURL) {
        frame.origin.x += userImageViewLeftMargin + self.userImageViewSize.width;
    }
    
    if (self.message.photoPath != nil && self.message.photoPath.length > 1) {
        UIImage *image = [UIImage imageNamed:self.message.photoPath];
        self.mediaImageView.image = image;
    }
    else {
        [self.mediaImageView sd_setImageWithPreviousCachedImageWithURL:self.message.photoURL andPlaceholderImage:[UIImage imageNamed:@"loadingImage.png"] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            if (self.progressView == nil) {
                self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width * 0.1, frame.origin.y + frame.size.height / 2.0 - 3, frame.size.width * 0.8, 6)];
                [self.progressView setProgressTintColor:[AppConfig getStatusBarColor]];
                [self.containerView addSubview:self.progressView];
            }
            [self.progressView setProgress:receivedSize / expectedSize];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.progressView removeFromSuperview];
        }];
    }

    
    self.mediaImageView.frame = frame;

    self.balloonImageView.frame = frame;
    self.balloonImageView.backgroundColor = [UIColor clearColor];
    self.balloonImageView.image = self.balloonImage;
    
    CGRect userRect = self.userImageView.frame;
    
    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
        userRect.origin.y = frame.origin.y + frame.size.height - userRect.size.height;
    } else {
        userRect.origin.y = 0;
    }
    
    if (self.message.fromMe) {
        userRect.origin.x = frame.origin.x + userImageViewLeftMargin + frame.size.width;
    } else {
        userRect.origin.x = frame.origin.x - userImageViewLeftMargin - userRect.size.width;
    }
    self.userImageView.frame = userRect;
    [self.userImageView sd_setImageWithURL:self.userImageURL placeholderImage:[UIImage imageNamed:DEFAULT_AVATARPATH]];
    
    CGRect frm = self.containerView.frame;
    frm.origin.x = self.message.fromMe ? self.contentView.frame.size.width - frame.size.width - kBubbleRightMargin : kBubbleLeftMargin;
    frm.origin.y = kBubbleTopMargin;
    frm.size.width = frame.size.width;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImageURL) {
        self.userImageView.hidden = NO;
        frm.size.width += userImageViewLeftMargin + userRect.size.width;
        if (self.message.fromMe) {
            frm.origin.x -= userImageViewLeftMargin + userRect.size.width;
        }
    }

    frm.size.height = frame.size.height;
    if (frm.size.height < self.userImageViewSize.height) {
        CGFloat delta = self.userImageViewSize.height - frm.size.height;
        frm.size.height = self.userImageViewSize.height;
        
        for (UIView *sub in self.containerView.subviews) {
            CGRect fr = sub.frame;
            fr.origin.y += delta;
            sub.frame = fr;
        }
    }
    self.containerView.frame = frm;

    //Masking mediaImageView with balloon image
    CALayer *layer = self.balloonImageView.layer;
    layer.frame    = (CGRect){{0,0},self.balloonImageView.layer.frame.size};
    self.mediaImageView.layer.mask = layer;
    [self.mediaImageView setNeedsDisplay];
    
    
    // Adjusing time label
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.timeLabel.frame = CGRectZero;
    self.timeLabel.text = [formatter stringFromDate:self.message.date];
    
    [self.timeLabel sizeToFit];
    CGRect timeLabel = self.timeLabel.frame;
    timeLabel.origin.x = self.contentView.frame.size.width + 5;
    self.timeLabel.frame = timeLabel;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.containerView.center.y);
}

- (void)adjustForVideoOnly
{
    [self adjustForPhotoOnly];
    
    CGRect frame = self.mediaOverlayView.frame;
    frame.origin = CGPointZero;
    frame.size   = self.mediaImageView.frame.size;
    self.mediaOverlayView.frame = frame;
    
    [self.mediaOverlayView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = self.mediaImageView.bounds;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4f;
    [self.mediaOverlayView addSubview:bgView];
    
    UIImageView *playButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button.png"]];
    playButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
    playButtonImageView.clipsToBounds = YES;
    playButtonImageView.backgroundColor = [UIColor clearColor];
    CGRect playFrame = playButtonImageView.frame;
    playFrame.size   = CGSizeMake(20, 20);
    playButtonImageView.frame = playFrame;
    playButtonImageView.center = CGPointMake(self.mediaOverlayView.frame.size.width/2 + self.contentInsets.left - self.contentInsets.right, self.mediaOverlayView.frame.size.height/2);
    [self.mediaOverlayView addSubview:playButtonImageView];
}


#pragma mark - GestureRecognizer delegates
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{

    CGPoint velocity = [self.panGesture velocityInView:self.panGesture.view];
    if (self.panGesture.state == UIGestureRecognizerStateBegan) {
        isHorizontalPan = fabs(velocity.x) > fabs(velocity.y);
    }
    
    return !isHorizontalPan;
}

#pragma mark - 
- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint velocity = [pan velocityInView:pan.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        isHorizontalPan = fabs(velocity.x) > fabs(velocity.y);
        
        if (!cellIsDragging) {
            initialTimeLabelPosX = self.timeLabel.frame.origin.x;
        }
    }
    
    if (isHorizontalPan) {
        NSArray *visibleCells = [self.tableView visibleCells];
        
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
            cellIsDragging = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                for (SOMessageCell *cell in visibleCells) {
                    
                    contentOffsetX = 0;
                    CGRect frame = cell.contentView.frame;
                    frame.origin.x = contentOffsetX;
                    cell.contentView.frame = frame;
                    
                    if (!cell.message.fromMe) {
                        CGRect timeframe = cell.timeLabel.frame;
                        timeframe.origin.x = initialTimeLabelPosX;
                        cell.timeLabel.frame = timeframe;
                    }
                }
            }];
        } else {
            cellIsDragging = YES;
            
            CGPoint translation = [pan translationInView:pan.view];
            CGFloat delta = translation.x * (1 - fabs(contentOffsetX / maxContentOffsetX));
            contentOffsetX += delta;
            if (contentOffsetX > 0) {
                contentOffsetX = 0;
            }
            if (fabs(contentOffsetX) > fabs(maxContentOffsetX)) {
                contentOffsetX = -fabs(maxContentOffsetX);
            }
            for (SOMessageCell *cell in visibleCells) {
                if (cell.message.fromMe) {
                    CGRect frame = cell.contentView.frame;
                    frame.origin.x = contentOffsetX;
                    cell.contentView.frame = frame;
                } else {
                    CGRect frame = cell.timeLabel.frame;
                    frame.origin.x = initialTimeLabelPosX - fabs(contentOffsetX);
                    cell.timeLabel.frame = frame;
                }
            }
        }
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    CGRect frame = self.contentView.frame;
    frame.origin.x = contentOffsetX;
    self.contentView.frame = frame;
}

- (void)handleOrientationWillChandeNote:(NSNotification *)note
{
    self.panGesture.enabled = NO;
    self.panGesture.enabled = YES;
}

#pragma mark - Getters and Setters
+ (CGFloat) messageTopMargin
{
    return messageTopMargin;
}

+ (void) setMessageTopMargin:(CGFloat)margin
{
    messageTopMargin = margin;
}

+ (CGFloat) messageBottomMargin;
{
    return messageBottomMargin;
}

+ (void) setMessageBottomMargin:(CGFloat)margin
{
    messageBottomMargin = margin;
}

+ (CGFloat) messageLeftMargin
{
    return messageLeftMargin;
}

+ (void) setMessageLeftMargin:(CGFloat)margin
{
    messageLeftMargin = margin;
}

+ (CGFloat) messageRightMargin
{
    return messageRightMargin;
}

+ (void) setMessageRightMargin:(CGFloat)margin
{
    messageRightMargin = margin;
}

+ (CGFloat)maxContentOffsetX
{
    return maxContentOffsetX;
}

+ (void)setMaxContentOffsetX:(CGFloat)offsetX
{
    maxContentOffsetX = offsetX;
}

- (void) startVoiceAnimation
{
    pCount = 0;
    vAnmationTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(changePhoto)  userInfo:nil repeats:YES];
}
- (void) changePhoto
{
    NSString *name;
    if (self.message.fromMe) {
        name = @"R";
    }
    else{
        name = @"L";
    }
    name = [NSString stringWithFormat:@"%@Voice%d.png", name, pCount];
    [self.voiceImageView setImage:[UIImage imageNamed:name]];
    pCount = (pCount + 1) % 4;
}

- (void) stopVoiceAnimation
{
    [vAnmationTimer invalidate];
    if (self.message.fromMe) {
        [self.voiceImageView setImage:[UIImage imageNamed:@"RVoice3.png"]];
    }
    else{
        [self.voiceImageView setImage:[UIImage imageNamed:@"LVoice3.png"]];
    }
}

#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
