//
//  LVRecordTool.m
//  RecordAndPlayVoice
//
//  Created by PBOC CS on 15/3/14.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#define LVRecordFielName @"lvRecord.caf"

#import <UIKit/UIDevice.h>
#import <UIKit/UIKit.h>
#import "AudioTool.h"

@interface AudioTool () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

/** 录音文件地址 */
@property (nonatomic, strong) NSURL *recordFileUrl;

/** 定时器 */

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AudioTool

static AudioTool *instance;

#pragma mark - 单例

+ (instancetype) sharedAudioTool {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
    });
    return instance;
}

- (void)startRecording {
    // 录音时停止播放 删除曾经生成的文件
    [self stopPlaying];
    [self destructionRecordingFile];
    [self.recorder record];
 
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(updateImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [timer fire];
    
    self.timer = timer;
}

- (void)updateImage {
    [self.recorder updateMeters];
    
    float result  = 10 * pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
    int no = 0;
    
    if (result > 0 && result <= 0.6) {
        no = 1;
    } else if (result > 0.6 && result <= 1.2) {
        no = 2;
    } else if (result > 1.2 && result <= 2.0) {
        no = 3;
    } else if (result > 2.0 && result <= 3.0) {
        no = 4;
    } else if (result > 3.0 && result <= 4.0) {
        no = 5;
    } else if (result > 4.0 && result <= 5.2) {
        no = 6;
    } else if (result > 5.2 && result <= 6.5) {
        no = 7;
    } else if (result > 6.5 && result <= 8.0){
        no = 8;
    } else if (result > 8.0 && result < 10.0) {
        no = 9;
    } else {
        no = 10;
    }
    
    if ([self.delegate respondsToSelector:@selector(audioTool:didstartRecoring:)]) {
        [self.delegate audioTool:self didstartRecoring:no];
    }
}

- (BOOL) isPlaying
{
    return self.player.isPlaying;
}

- (void)stopRecording {
    [self.recorder stop];
    
    [self.timer invalidate];
}

- (void)playFromFile:(NSString *)file {
    if ([self isPlaying]) {
        [self stopPlaying];
    }
    
    // 播放时停止录音
    [self.recorder stop];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];

    self.player = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:file] fileTypeHint:nil error:nil];
    
    self.player.delegate = self;
    [self.player play];
}

- (void)stopPlaying {
    [self.player stop];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYING_FINISHED object:nil];
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYING_FINISHED object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYING_FINISHED object:nil];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark - 懒加载

- (AVAudioRecorder *)recorder {
    if (!_recorder) {       // 真机环境下需要的代码
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];

        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
        
        // 1.获取沙盒地址
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [path stringByAppendingPathComponent:LVRecordFielName];
        self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    //    NSLog(@"%@", filePath);
        
        // 3.设置录音的一些参数
        NSMutableDictionary *setting = [NSMutableDictionary dictionary];
        setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);              // 音频格式
        setting[AVSampleRateKey] = @(44100);                            // 录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
        setting[AVNumberOfChannelsKey] = @(1);                          // 音频通道数 1 或 2
        setting[AVLinearPCMBitDepthKey] = @(8);                         // 线性音频的位深度  8、16、24、32
        setting[AVEncoderAudioQualityKey] = [NSNumber numberWithInt:AVAudioQualityHigh];        //录音的质量
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:setting error:NULL];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
    return _recorder;
}

- (void)destructionRecordingFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (self.recordFileUrl) {
        [fileManager removeItemAtURL:self.recordFileUrl error:NULL];
    }
}

#pragma mark - 距离感应

- (void)sensorStateChange:(NSNotification *)notification {
    if ([UIDevice currentDevice].isProximityMonitoringEnabled) {    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
        if ([[UIDevice currentDevice] proximityState] == YES) {     //        听筒;
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        }
        else {                                                      //        扬声器"
            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        }
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        NSLog(@"录音成功");
    }
}

#pragma mark - new message

- (void) playRecMessageAudio
{
    [self playAudioByName:@"ReceivedMessage"];
}

- (void) playSendMessageAudio
{
    [self playAudioByName:@"SentMessage"];
}

- (void) playNewMessageAudio
{
    [self playAudioByName:@"sms-received1"];
}

- (void) playNewMessageShock
{
    SystemSoundID soundID = kSystemSoundID_Vibrate;
    AudioServicesPlaySystemSound(soundID);
}

- (void) playAudioByName: (NSString *) name
{
    SystemSoundID soundID;
    NSString *path = [NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@.caf", name];
    if (path) {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundID);
        
        if (error != kAudioServicesNoError) {//获取的声音的时候，出现错误
            return;
        }
    }
    AudioServicesPlaySystemSound(soundID);
}


@end

