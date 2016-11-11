//
//  AudioPlayerView.m
//  PurposeColor
//
//  Created by Purpose Code on 24/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "CustomAudioPlayerView.h"
#import "UIImage+animatedGIF.h"
#import <CoreMedia/CoreMedia.h>
#import <AudioToolbox/AudioToolbox.h>

@interface CustomAudioPlayerView () {
    
    NSString *strURL;
    IBOutlet UIImageView *imgAnimatedView;
    BOOL isStarted;
    AVPlayer *player;
    
    IBOutlet UIButton *btnPlay;
}

@end

@implementation CustomAudioPlayerView



-(void) setupAVPlayerForURL:(NSURL*)url {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showLoadingScreen];
        
        NSURL *gifURL = [[NSBundle mainBundle] URLForResource:@"Equalizer" withExtension:@"gif"];
        UIImage *testImage = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:gifURL]];
        imgAnimatedView.animationImages = testImage.images;
        imgAnimatedView.animationDuration = testImage.duration;
        imgAnimatedView.animationRepeatCount = 0;
        imgAnimatedView.image = testImage.images.lastObject;
       
        NSError* error;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *setCategoryError = nil;
        if (![session setCategory:AVAudioSessionCategoryPlayback
                      withOptions:AVAudioSessionCategoryOptionMixWithOthers
                            error:&setCategoryError]) {
            // handle error
        }
        
        AVAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        AVPlayerItem *anItem = [AVPlayerItem playerItemWithAsset:asset];
        
        player = [AVPlayer playerWithPlayerItem:anItem];
        [player addObserver:self forKeyPath:@"status" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[player currentItem]];
        
       
                
    });

    
    
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == player && [keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        } else if (player.status == AVPlayerStatusReadyToPlay) {
            [self hideLoadingScreen];
            NSLog(@"AVPlayer Ready to Play");
        } else if (player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}

-(IBAction) BtnPlay:(id)sender {
    if (btnPlay.tag == 0) {
         btnPlay.tag = 1;
         [player play];
         [btnPlay setImage:[UIImage imageNamed:@"Pause_Button.png"] forState:UIControlStateNormal];
         [imgAnimatedView startAnimating];
    }else{
         btnPlay.tag = 0;
         [player pause];
         [btnPlay setImage:[UIImage imageNamed:@"Video_Play_Button.png"] forState:UIControlStateNormal];
         [imgAnimatedView stopAnimating];
    }
    [btnPlay setSelected:false];
    
}

-(void)playerItemDidReachEnd{
    
    btnPlay.tag = 0;
    [btnPlay setImage:[UIImage imageNamed:@"Video_Play_Button.png"] forState:UIControlStateNormal];
    [imgAnimatedView stopAnimating];
    [player seekToTime:kCMTimeZero];

}

-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self animated:YES];
    
}

-(void)removeAudioPlayer{
    
    [player setRate:0.0];
    [player removeObserver:self forKeyPath:@"status"];
    player = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(IBAction)closePopUp:(id)sender{
    
    [self removeAudioPlayer];
    if ([self.delegate respondsToSelector:@selector(closeAudioPlayerView)]) {
        [self.delegate closeAudioPlayerView];
    }
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
