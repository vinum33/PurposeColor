//
//  AudioPlayerView.h
//  PurposeColor
//
//  Created by Purpose Code on 24/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"


@protocol CustomAudioPlayerDelegate <NSObject>



/*!
 *This method is invoked when user close the audio player view.
 */


-(void)closeAudioPlayerView;

@end


@interface CustomAudioPlayerView : UIView 

@property (nonatomic,weak)  id<CustomAudioPlayerDelegate>delegate;
-(void) setupAVPlayerForURL: (NSURL*) url;

@end
