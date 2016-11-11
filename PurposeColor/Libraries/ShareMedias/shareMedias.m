//
//  PhotoBrowser.m
//  PurposeColor
//
//  Created by Purpose Code on 08/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "shareMedias.h"
#import "shareMediasCell.h"
#import "Constants.h"
#import "CustomAudioPlayerView.h"
#import <AVKit/AVKit.h>
@interface shareMedias() <CustomAudioPlayerDelegate>{
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UIButton *btnShare;
    NSArray *arrDataSource;
    CustomAudioPlayerView *vwAudioPlayer;
    NSMutableDictionary *selectedObjects;
    NSMutableDictionary *images;
    
    NSString *shareText;
    
}

@end

@implementation shareMedias

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUpWithShareItems:(NSArray*)items text:(NSString*)text{
    
    selectedObjects = [NSMutableDictionary new];
    images = [NSMutableDictionary new];
    arrDataSource = items;
    [collectionView registerNib:[UINib nibWithNibName:@"shareMediasCell" bundle:nil] forCellWithReuseIdentifier:@"shareMediasCell"];
    collectionView.backgroundColor = [UIColor clearColor];
    [collectionView reloadData];
    btnShare.enabled = false;
    shareText = text;
}


#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
     return  1;
}

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    return  arrDataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    shareMediasCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"shareMediasCell" forIndexPath:indexPath];
    if (indexPath.row < arrDataSource.count) {
        [cell.indicator stopAnimating];
        [self setUpMediasWithIndex:indexPath.row withCell:cell];
    }
    
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float width = _collectionView.bounds.size.width;
    float height = 300;
    
    return CGSizeMake(width, height);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([selectedObjects objectForKey:[NSNumber numberWithInteger:indexPath.row]]) {
        // Already Selected . Remove selection
        [selectedObjects removeObjectForKey:[NSNumber numberWithInteger:indexPath.row]];
    }else{
        // Add selection
        [selectedObjects setObject:[NSNumber numberWithBool:YES]  forKey:[NSNumber numberWithInteger:indexPath.row]];
    }
    btnShare.enabled = false;
    if (selectedObjects.count > 0) {
        btnShare.enabled = true;
    }
    [collectionView reloadData];
}

-(void)setUpMediasWithIndex:(NSInteger)tag withCell:(shareMediasCell *)cell{
    
    cell.btnAudio.tag = tag;
    cell.btnVideo.tag = tag;
    
    cell.btnVideo.hidden = true;
    cell.btnAudio.hidden = true;
    
    [cell.btnAudio addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnVideo addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.imageView.image = [UIImage imageNamed:@"NoImage.png"];
    
    if (tag < arrDataSource.count){
        NSDictionary * mediaInfo = arrDataSource[tag];
        NSString *mediaType ;
        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
            mediaType = [mediaInfo objectForKey:@"media_type"];
        }
        
        if (mediaType) {
            if ([mediaType isEqualToString:@"image"]) {
                NSURL *strUrl = [mediaInfo objectForKey:@"gem_media"];
                if (strUrl) {
                    [cell.indicator startAnimating];
                    [cell.imageView sd_setImageWithURL:strUrl
                                      placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                 [images setObject:image forKey:[NSNumber numberWithInteger:tag]];
                                                 [cell.indicator stopAnimating];
                                             }];

                }
                
            }
            
            else if ([mediaType isEqualToString:@"audio"]) {
                cell.btnVideo.hidden = true;
                cell.btnAudio.hidden = false;
                NSString *audioURL = [mediaInfo objectForKey:@"gem_media"];
                if (audioURL.length){
                    

                }
            }
            
            else if ([mediaType isEqualToString:@"video"]) {
                cell.btnVideo.hidden = false;
                cell.btnAudio.hidden = true;
                // Type Video
                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                    NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                    if (videoURL.length){
                        NSURL *strUrl = [mediaInfo objectForKey:@"video_thumb"];
                        if (strUrl) {
                            [cell.indicator startAnimating];
                            [cell.imageView sd_setImageWithURL:strUrl
                                              placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                         
                                                         [cell.indicator stopAnimating];
                                                     }];
                            
                        }

                    }
                }
                
            }
            
        }
    }
    if ([selectedObjects objectForKey:[NSNumber numberWithInteger:tag]]) {
        cell.bgView.backgroundColor = [UIColor orangeColor];
    }else{
        // Add selection
        cell.bgView.backgroundColor = [UIColor clearColor];
    }
    
}

-(IBAction)playAudio:(UIButton*)btn{
    
    NSInteger tag = btn.tag;
    if (tag < arrDataSource.count){
        NSDictionary * mediaInfo = arrDataSource[tag];
        NSString *mediaType ;
        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"]))
            mediaType = [mediaInfo objectForKey:@"media_type"];
        if (mediaType) {
            if ([mediaType isEqualToString:@"audio"]) {
                NSString *audioURL = [mediaInfo objectForKey:@"gem_media"];
                if (audioURL.length){
                    
                    if (!vwAudioPlayer) {
                        vwAudioPlayer = [[[NSBundle mainBundle] loadNibNamed:@"CustomAudioPlayerView" owner:self options:nil] objectAtIndex:0];
                        vwAudioPlayer.delegate = self;
                    }
                    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    UIView *vwPopUP = vwAudioPlayer;
                    [app.window.rootViewController.view addSubview:vwPopUP];
                    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
                    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
                    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
                    
                    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
                    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        // animate it to the identity transform (100% scale)
                        vwPopUP.transform = CGAffineTransformIdentity;
                    } completion:^(BOOL finished){
                        // if you want to do something once the animation finishes, put it here
                        [vwAudioPlayer setupAVPlayerForURL:[NSURL URLWithString:audioURL]];
                    }];

                    
                }
            }
        }
    }
    
}

-(void)closeAudioPlayerView{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwAudioPlayer.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwAudioPlayer removeFromSuperview];
        vwAudioPlayer = nil;
        NSError* error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
    }];
    
}

-(IBAction)playVideo:(UIButton*)btn{
    
    NSInteger tag = btn.tag;
    if (tag < arrDataSource.count){
        NSDictionary * mediaInfo = arrDataSource[tag];
        NSString *mediaType ;
        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"]))
            mediaType = [mediaInfo objectForKey:@"media_type"];
        if (mediaType) {
            
            if ([mediaType isEqualToString:@"video"]) {
                // Type Video
                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                    NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                    if (videoURL.length){
                        NSError* error;
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                        [[AVAudioSession sharedInstance] setActive:NO error:&error];
                        NSURL *movieURL = [NSURL URLWithString:videoURL];
                        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                        playerViewController.player = [AVPlayer playerWithURL:movieURL];
                         [playerViewController.player play];
                        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        [app.window.rootViewController presentViewController:playerViewController animated:TRUE completion:nil];
                        
                    }
                }
            }
        }
        
    }
    
}

- (void)videoDidFinish:(id)notification
{
     AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [app.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}

-(IBAction)shareMedias:(UIButton*)btn{
    
    NSMutableArray *arrImages = [NSMutableArray new];
    NSMutableArray *arrAudio = [NSMutableArray new];
    NSMutableArray *arrVideo = [NSMutableArray new];
    
    NSArray *keys = [selectedObjects allKeys];
    for (NSNumber *index in keys) {
        NSInteger tag = [index integerValue];
        if (tag < arrDataSource.count){
            NSDictionary * mediaInfo = arrDataSource[tag];
            NSString *mediaType ;
            if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                mediaType = [mediaInfo objectForKey:@"media_type"];
            }
            
            if (mediaType) {
                if ([mediaType isEqualToString:@"image"]) {
                    if ([images objectForKey:[NSNumber numberWithInteger:tag]]) {
                        UIImage *image = [images objectForKey:[NSNumber numberWithInteger:tag]];
                        [arrImages addObject:image];
                    }
                }
                
                else if ([mediaType isEqualToString:@"audio"]) {
                    NSString *audioURL = [mediaInfo objectForKey:@"gem_media"];
                    if (audioURL.length){
                        [arrAudio addObject:audioURL];
                        
                    }
                }
                
                else if ([mediaType isEqualToString:@"video"]) {
                    // Type Video
                    if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                        NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                        if (videoURL.length){
                            NSURL *strUrl = [mediaInfo objectForKey:@"video_thumb"];
                            if (strUrl) {
                                 [arrVideo addObject:videoURL];
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    if (shareText) {
        [sharingItems addObject:shareText];
    }
    if (arrVideo.count) {
        [sharingItems addObjectsFromArray:arrVideo];
    }
    if (arrImages.count) {
        [sharingItems addObjectsFromArray:arrImages];
    }
    if (arrAudio.count) {
        [sharingItems addObjectsFromArray:arrAudio];
    }
    
    UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypeAssignToContact,UIActivityTypeAirDrop];
    activityVC.excludedActivityTypes = excludeActivities;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window.rootViewController presentViewController:activityVC animated:TRUE completion:nil];
}



-(IBAction)closePopUp:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(closeShareMediasView)]) {
        [self.delegate closeShareMediasView];
    }
    
}

-(void)dealloc{
    
}

@end
