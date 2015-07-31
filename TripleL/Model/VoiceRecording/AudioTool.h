//
//  LVRecordTool.h
//  RecordAndPlayVoice
//
//  Created by PBOC CS on 15/3/14.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define         PLAYING_FINISHED            @"stop_playing_rec"

@class AudioTool;
@protocol AudioToolDelegate <NSObject>

@optional
- (void)audioTool:(AudioTool *)audioTool didstartRecoring:(int)no;

@end

@interface AudioTool : NSObject

/** 录音工具的单例 */
+ (instancetype)sharedAudioTool;

/** 开始录音 */
- (void)startRecording;

/** 停止录音 */
- (void)stopRecording;

/** 播放录音文件 */
- (void)playFromFile: (NSString *) file;

/** 停止播放录音文件 */
- (void)stopPlaying;

/** 销毁录音文件 */
- (void)destructionRecordingFile;

- (BOOL) isPlaying;

- (void) playSendMessageAudio;
- (void) playRecMessageAudio;
- (void) playNewMessageAudio;
- (void) playNewMessageShock;


/** 录音对象 */
@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, strong) AVAudioPlayer *player;

/** 更新图片的代理 */
@property (nonatomic, assign) id<AudioToolDelegate> delegate;



@end
