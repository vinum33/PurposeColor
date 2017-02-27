//
//  JournalGalleryViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 22/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eMenuImage = 0,
    eMenuVideo = 1,
    eMenuAudio = 2
    
    
}EmenuType;

#import "JournalGalleryViewController.h"
#import "JournalGalleryCell.h"
#import "Constants.h"
#import <AVKit/AVKit.h>
#import "CustomAudioPlayerView.h"
#import "PhotoBrowser.h"

@interface JournalGalleryViewController () <CustomAudioPlayerDelegate,PhotoBrowserDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnAudioList;
    IBOutlet UIButton *btnVideoList;
    IBOutlet UIButton *btnImageList;
    
    NSMutableArray *arrImages;
    NSMutableArray *arrVideos;
    NSMutableArray *arrAudios;
    NSMutableArray *arrDataSource;
    EmenuType selectedMenu;
    CustomAudioPlayerView *vwAudioPlayer;
    PhotoBrowser *photoBrowser;
}

@end

@implementation JournalGalleryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self filterMedias];
   
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    selectedMenu = eMenuAudio;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 200;
    arrAudios = [NSMutableArray new];
    arrVideos = [NSMutableArray new];
    arrImages = [NSMutableArray new];
    [btnAudioList setHidden:true];
    [btnVideoList setHidden:true];
    [btnImageList setHidden:true];
    
}

-(void)filterMedias{
    BOOL isSet = false;
    for (NSDictionary *dict in _arrMedia) {
        if ([[dict objectForKey:@"media_type"] isEqualToString:@"audio"]) {
            [arrAudios addObject:dict];
        }
        if ([[dict objectForKey:@"media_type"] isEqualToString:@"image"]) {
            [arrImages addObject:dict];
        }
        if ([[dict objectForKey:@"media_type"] isEqualToString:@"video"]) {
            [arrVideos addObject:dict];
        }
    }
    if (arrImages.count){
        
        isSet = true;
        [btnImageList setHidden:false];
        [btnImageList setImage:[UIImage imageNamed:@"Journal_Image_Menu_Active"] forState:UIControlStateNormal];
        arrDataSource = [NSMutableArray arrayWithArray:arrImages];
        selectedMenu = eMenuImage;
        
    }
    if (arrAudios.count){
        
        [btnAudioList setHidden:false];
        if (!isSet) {
            [btnAudioList setImage:[UIImage imageNamed:@"Journal_Audio_Menu_Active"] forState:UIControlStateNormal];
            arrDataSource = [NSMutableArray arrayWithArray:arrAudios];
            selectedMenu = eMenuAudio;
            isSet = true;
        }
       

    }
    if (arrVideos.count){
        
        [btnVideoList setHidden:false];
        if (!isSet) {
            [btnVideoList setImage:[UIImage imageNamed:@"Journal_Video_Menu_Active"] forState:UIControlStateNormal];
            arrDataSource = [NSMutableArray arrayWithArray:arrVideos];
            selectedMenu = eMenuVideo;
            isSet = true;
        }
        
        

        
    }
    
     [tableView reloadData];
}

-(IBAction)showImages:(id)sender{
    
    [btnImageList setImage:[UIImage imageNamed:@"Journal_Image_Menu_Active"] forState:UIControlStateNormal];
    [btnAudioList setImage:[UIImage imageNamed:@"Journal_Audio_Menu_Normal"] forState:UIControlStateNormal];
    [btnVideoList setImage:[UIImage imageNamed:@"Journal_Video_Menu_Normal"] forState:UIControlStateNormal];
    
    selectedMenu = eMenuImage;
    arrDataSource = [NSMutableArray arrayWithArray:arrImages];
    [tableView reloadData];
}
-(IBAction)showVideos:(id)sender{
    
    [btnImageList setImage:[UIImage imageNamed:@"Journal_Image_Menu_Normal"] forState:UIControlStateNormal];
    [btnAudioList setImage:[UIImage imageNamed:@"Journal_Audio_Menu_Normal"] forState:UIControlStateNormal];
    [btnVideoList setImage:[UIImage imageNamed:@"Journal_Video_Menu_Active"] forState:UIControlStateNormal];
    
     selectedMenu = eMenuVideo;
     arrDataSource = [NSMutableArray arrayWithArray:arrVideos];
    [tableView reloadData];
}
-(IBAction)showAudios:(id)sender{
    
    [btnImageList setImage:[UIImage imageNamed:@"Journal_Image_Menu_Normal"] forState:UIControlStateNormal];
    [btnAudioList setImage:[UIImage imageNamed:@"Journal_Audio_Menu_Active"] forState:UIControlStateNormal];
    [btnVideoList setImage:[UIImage imageNamed:@"Journal_Video_Menu_Normal"] forState:UIControlStateNormal];
    
     selectedMenu = eMenuAudio;
     arrDataSource = [NSMutableArray arrayWithArray:arrAudios];
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return arrDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JournalGalleryCell *cell = (JournalGalleryCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalGalleryCell"];
    cell.btnVideoPlay.tag = indexPath.row;
    cell.btnAudioPlay.tag = indexPath.row;
    [self configureCell:cell index:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedMenu == eMenuImage) {
        
        if (indexPath.row < arrDataSource.count) {
            NSDictionary *mediaInfo = arrDataSource[indexPath.row];
            NSMutableArray *images = [NSMutableArray new];
            NSURL *url =  [NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]];
            [images addObject:url];
            for (NSDictionary *details in arrDataSource) {
                NSURL *url =  [NSURL URLWithString:[details objectForKey:@"gem_media"]];
                if (![images containsObject:url]) {
                    [images addObject:url];
                }
            }
            if (images.count) {
                [self presentGalleryWithImages:images];
            }
        }
    }
}

-(void)configureCell:(JournalGalleryCell*)cell index:(NSInteger)row{
    
    switch (selectedMenu) {
        case eMenuImage:
            [self configureImageCellWithCell:cell index:row];
            cell.btnAudioPlay.hidden = true;
            cell.btnVideoPlay.hidden = true;
            break;
            
        case eMenuAudio:
            [self configureAudioCellWithCell:cell index:row];
            cell.btnAudioPlay.hidden = false;
            cell.btnVideoPlay.hidden = true;
            break;
            
        case eMenuVideo:
            [self configureVideoCellWithCell:cell index:row];
            cell.btnAudioPlay.hidden = true;
            cell.btnVideoPlay.hidden = false;
            break;
            break;
            
        default:
            break;
    }
}

-(void)configureImageCellWithCell:(JournalGalleryCell*)cell index:(NSInteger)row{
    
    if (row < arrDataSource.count) {
        
        NSDictionary *_journalDetails = arrDataSource[row];
        float imageHeight = 0;
        float width = [[_journalDetails objectForKey:@"image_width"] floatValue];
        float height = [[_journalDetails objectForKey:@"image_height"] floatValue];
        float ratio = width / height;
        float padding = 10;
        imageHeight = (tableView.frame.size.width - padding) / ratio;
        [cell.activityIndicator startAnimating];
        [cell.imgGem sd_setImageWithURL:[NSURL URLWithString:[_journalDetails objectForKey:@"gem_media"]]
                       placeholderImage:[UIImage imageNamed:@""]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  
                                  [cell.activityIndicator stopAnimating];
                                  
                              }];
        cell.heightConstraint.constant = imageHeight;
    }
   

}

-(void)configureAudioCellWithCell:(JournalGalleryCell*)cell index:(NSInteger)row{
    
    if (row < arrDataSource.count) {
        
        float imageHeight = 0;
        float width = 250;
        float height = 250;
        float ratio = width / height;
        float padding = 10;
        imageHeight = (tableView.frame.size.width - padding) / ratio;
        [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
         cell.heightConstraint.constant = imageHeight;
        [cell.activityIndicator stopAnimating];
    }
    
    
}

-(void)configureVideoCellWithCell:(JournalGalleryCell*)cell index:(NSInteger)row{
    
    if (row < arrDataSource.count) {
        
        NSDictionary *_journalDetails = arrDataSource[row];
        float imageHeight = 0;
        float width = [[_journalDetails objectForKey:@"image_width"] floatValue];
        float height = [[_journalDetails objectForKey:@"image_height"] floatValue];
        float ratio = width / height;
        float padding = 10;
        imageHeight = (tableView.frame.size.width - padding) / ratio;
        [cell.activityIndicator startAnimating];
        cell.heightConstraint.constant = imageHeight;
        if (NULL_TO_NIL([_journalDetails objectForKey:@"video_thumb"])) {
            NSString *videoThumb = [_journalDetails objectForKey:@"video_thumb"];
            if (videoThumb.length) {
                [cell.activityIndicator startAnimating];
                [cell.imgGem sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                    placeholderImage:[UIImage imageNamed:@""]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               [cell.activityIndicator stopAnimating];
                                            }];
            }
            
        }
        
    }
    
    
}
-(IBAction)playAudio:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        NSDictionary *mediaInfo = arrDataSource[sender.tag];
        if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
            NSString *audioURL = [mediaInfo objectForKey:@"gem_media"];
            if (audioURL.length){
                NSURL *movieURL = [NSURL URLWithString:audioURL];
                [self showAudioPlayerWithURL:movieURL];
                
            }
        }
        
    }
}


-(void)showAudioPlayerWithURL:(NSURL*)url{
    
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
        [vwAudioPlayer setupAVPlayerForURL:url];
    }];
    
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
-(IBAction)playVideo:(UIButton*)sender{
    
    if (sender.tag < arrDataSource.count) {
        
        NSDictionary *mediaInfo = arrDataSource[sender.tag];
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
                [self presentViewController:playerViewController animated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoDidFinish:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:[playerViewController.player currentItem]];
                
            }
        }

        
    }
 }

- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}

#pragma mark - Photo Browser & Deleagtes

- (void)presentGalleryWithImages:(NSArray*)images
{
    
    if (!photoBrowser) {
        photoBrowser = [[[NSBundle mainBundle] loadNibNamed:@"PhotoBrowser" owner:self options:nil] objectAtIndex:0];
        photoBrowser.delegate = self;
    }
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = photoBrowser;
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
        [photoBrowser setUpWithImages:images];
    }];
    
}

-(void)closePhotoBrowserView{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        photoBrowser.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser removeFromSuperview];
        photoBrowser = nil;
    }];
}


-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
