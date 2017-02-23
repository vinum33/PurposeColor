//
//  GemDetailsCustomTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@protocol GemDetailPageCellDelegate <NSObject>



/*!
 *This method is invoked when user Clicks "PLAY MEDIA" Button
 */
-(void)resetPlayerVaiablesForIndex:(NSInteger)tag ;

/*!
 *This method is invoked when media ends playback
 */


@optional



@end


@interface GemDetailsCustomTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgGemMedia;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak) IBOutlet UIView *vwBg;
@property (nonatomic,weak) IBOutlet UIButton *btnVideoPlay;
@property (nonatomic,weak) IBOutlet  UIButton *btnAudioPlay;

@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *videoActivity;
@property (nonatomic,strong) AVPlayerItem *videoItem;
@property (nonatomic,strong) AVPlayer *videoPlayer;
@property (nonatomic,strong) AVPlayerLayer *avLayer;
@property (nonatomic, assign) BOOL videoPlaying;


@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic,weak)  id<GemDetailPageCellDelegate>delegate;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForHeight;


-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;


@end
