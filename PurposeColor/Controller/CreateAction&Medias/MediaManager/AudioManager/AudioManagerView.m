//
//  AudioManagerView.m
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "AudioManagerView.h"
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

@interface AudioManagerView()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>{
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSInteger second;
    NSInteger minute;
    NSTimer *timer;
    
    
    
}

@end

@implementation AudioManagerView




-(void)setUp{
    
    
    NSString *prefixString = @"PurposeColorAudio";
    
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.aac",[Utility getMediaSaveFolderPath],uniqueFileName]];
    if (_isJournal) {
        outputFileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.aac",[Utility getJournalMediaSaveFolderPath],uniqueFileName]];
    }
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    
    // Define the recorder setting
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [NSNumber numberWithFloat:16000], AVSampleRateKey,
                              [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:AVAudioQualityMedium], AVSampleRateConverterAudioQualityKey,
                              [NSNumber numberWithInt:64000], AVEncoderBitRateKey,
                              [NSNumber numberWithInt:8], AVEncoderBitDepthHintKey,
                              nil];
    
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:settings error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    UIImageView *imgBubble = [UIImageView new];
    imgBubble.backgroundColor = [UIColor redColor];
    [self addSubview:imgBubble];
    imgBubble.layer.cornerRadius = 5.f;
    imgBubble.layer.borderWidth = 1.f;
    imgBubble.layer.borderColor = [UIColor clearColor].CGColor;
    imgBubble.clipsToBounds = YES;
    imgBubble.frame = CGRectMake(0, 0, 100, 40);
    
    UILabel *lblTime = [UILabel new];
    [self addSubview:lblTime];
    lblTime.frame = CGRectMake(0, 0, 100, 40);
    lblTime.textAlignment = NSTextAlignmentCenter;
    lblTime.text = [NSString stringWithFormat:@"%s","00:00"];
    lblTime.textColor = [UIColor whiteColor];
    lblTime.font = [UIFont fontWithName:CommonFont size:14];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:lblTime,@"TimerLabel", nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRecordingTime:) userInfo:userInfo repeats:YES];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)startRecording{
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [recorder record];
}

-(void)stopRecording{
    
    [recorder stop];
    recorder.delegate = nil;
    recorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    [timer invalidate];
    timer = nil;
    second = 0;
    minute = 0;
    

}


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    
}

-(void)updateRecordingTime:(NSTimer*)_timer{
    
    if (_timer.userInfo) {
        
        NSDictionary *userInfo = _timer.userInfo;
        if (NULL_TO_NIL([userInfo objectForKey:@"TimerLabel"])) {
           UILabel *lblTime = [userInfo objectForKey:@"TimerLabel"];
            second ++;
            if (second >= 60) {
                minute ++;
                second = 0;
            }
            lblTime.text =[NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
            
        }
        
    }
}


@end
