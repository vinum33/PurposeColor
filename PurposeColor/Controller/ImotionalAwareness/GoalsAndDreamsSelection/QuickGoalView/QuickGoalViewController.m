//
//  QuickGoalViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 19/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



typedef enum{
    
    eSectionInfo = 0,
    eSectionMedia = 1,
    
} eSectionDetails;


#define kCellHeight             250;
#define kHeightForHeader        100;
#define kHeightForFooter        .001;
#define kNumberOfSections       2;
#define kSuccessCode            200
#define kMinimumCellCount       1

#import "Constants.h"
#import "GemDetailsCustomTableViewCell.h"
#import "ActionDetailsCustomCell.h"
#import <AVKit/AVKit.h>
#import "CustomAudioPlayerView.h"
#import "PhotoBrowser.h"
#import "ActionCustomCell.h"
#import "QuickGoalViewController.h"

@interface QuickGoalViewController ()<GemDetailPageCellDelegate,CustomAudioPlayerDelegate,PhotoBrowserDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblTitle;
    IBOutlet UILabel *lblShareTitle;
    IBOutlet UIImageView *imgShareImage;
    NSArray *arrGemMedias;
    NSDictionary *_gemDetails;
    
    NSInteger playingIndex;
    BOOL isScrolling;
    BOOL isPlaying;
    BOOL isDataAvailable;
    
    IBOutlet  UIImageView *imgLike;
    CustomAudioPlayerView *vwAudioPlayer;
    PhotoBrowser *photoBrowser;
    
    AVPlayer *videoPlayer;
    AVPlayerItem *videoPlayerItem;
    UIActivityIndicatorView *videoIndicator;
}

@end

@implementation QuickGoalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
     tableView.hidden = true;
}

-(void)loadGoalDetailsWithGoalID:(NSString*)goalID{
   
    isDataAvailable = false;
    [self showLoadingScreen];
    [APIMapper getGoalDetailsWithGoalID:goalID userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        isDataAvailable = true;
        _gemDetails = responseObject;
        [self getGoalDetails];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         [self hideLoadingScreen];
          tableView.hidden = false;
        [tableView reloadData];
    }];
    
    
}

-(void)getGoalDetails{
    
    playingIndex = -1;
    arrGemMedias = [NSArray new];
    if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_media"]))
        arrGemMedias = [_gemDetails objectForKey:@"gem_media"];
    lblTitle.text = @"GOAL DETAILS";
    [tableView reloadData];
    tableView.hidden = false;
    
}


#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!isDataAvailable) {
        return kMinimumCellCount;
    }
    return kNumberOfSections;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!isDataAvailable) return kMinimumCellCount;
  
    if (section == eSectionInfo) {
        NSInteger count = 1;
        if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])) {
            count ++;
        }
        return count;
        
    }else{
        return arrGemMedias.count;
    }
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *_cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (_cell == nil)
        _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    _cell.selectionStyle = UITableViewCellSelectionStyleNone;
    _cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
    _cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!isDataAvailable) {
        _cell = [Utility getNoDataCustomCellWith:_tableView withTitle:@"No Details Available."];
        _cell.backgroundColor = [UIColor clearColor];
        _cell.contentView.backgroundColor = [UIColor clearColor];
        _cell.textLabel.textColor = [UIColor blackColor];
        return _cell;
    }
    
    NSString *CellIdentifier = @"Date&Others";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (indexPath.section == eSectionInfo) {
        
        if (indexPath.row == 0) {
            NSString *CellIdentifier = @"Date&Others";
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            [self setUpGoalDateAndOtherInfoWithCell:cell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        else if (indexPath.row == 1) {
            NSString *CellIdentifier = @"Description";
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            [self setUpGoalDescriptionWithCell:cell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    }else{
        if (indexPath.row < arrGemMedias.count){
            
            NSString *CellIdentifier = @"reuseIdentifier";
            GemDetailsCustomTableViewCell *cell = (GemDetailsCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            [self resetCellVariables:cell];
            [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
            [self showMediaDetailsWithCell:cell andDetails:arrGemMedias[indexPath.row] index:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == eSectionInfo) {
        
        if (indexPath.row == 1) {
            // Description
            if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])) {
              CGFloat height = [self getLabelHeight:[_gemDetails objectForKey:@"gem_details"]];
                return height;
            }
           
        }
        
        if (indexPath.row == 0) {
            // Date amd Loc Info
            CGFloat height = 20;
            float padding = 0;
            
            if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"])) {
                height += [self getLabelHeightForOtherInfo:[_gemDetails objectForKey:@"contact_name"] withFont:[UIFont fontWithName:CommonFont size:12]];
                padding = 25;
               
            }
            
            if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"])) {
                height += [self getLabelHeightForOtherInfo:[_gemDetails objectForKey:@"location_name"] withFont:[UIFont fontWithName:CommonFontBold size:12]];
                padding = 25;
            }

            height += padding;
            return height;
            
        }
    }else{
       
        return kCellHeight;
    }
   
    return kCellHeight;
}
- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == eSectionMedia) return 0.1f;
    
    float widthPadding = 20;
    float heightPadding = 20;
    
    NSString *title = [_gemDetails objectForKey:@"gem_title"];
    CGSize constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    float height = 0;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [title boundingRectWithSize:constraint
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFontBold size:14]}
                                             context:context].size;
    height += boundingBox.height + heightPadding;
    if (height < 40) {
        height = 40;
    }
    
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return kHeightForFooter;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    if (section == eSectionMedia) return nil;
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor getBackgroundOffWhiteColor];
    
    if (isDataAvailable) {
        
        /*! Title !*/
        UILabel *_lblTitle = [UILabel new];
        _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:_lblTitle];
        _lblTitle.numberOfLines = 0;
        _lblTitle.textColor = [UIColor blackColor];;
        _lblTitle.font = [UIFont fontWithName:CommonFontBold size:14];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:_lblTitle
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblTitle]-50-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
        
        
        if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_title"]))
            _lblTitle.text = [_gemDetails objectForKey:@"gem_title"];
        
        
        /*! Border !*/
        
        UILabel *_lblBodrer = [UILabel new];
        _lblBodrer.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:_lblBodrer];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:_lblBodrer
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0]];
        
        [_lblBodrer addConstraint:[NSLayoutConstraint constraintWithItem:_lblBodrer
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0
                                                                constant:1]];
        _lblBodrer.backgroundColor = [UIColor getSeperatorColor];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblBodrer]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblBodrer)]];
    }
    
    
    
    
    // Close button
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    btnClose.translatesAutoresizingMaskIntoConstraints = NO;
    [btnClose addTarget:self action:@selector(goBack:)forControlEvents:UIControlEventTouchUpInside];
    [vwHeader addSubview:btnClose];
    [btnClose setImage:[UIImage imageNamed:@"Close_Transparent.png"] forState:UIControlStateNormal];
    
    
    [btnClose addConstraint:[NSLayoutConstraint constraintWithItem:btnClose
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:40]];
    
    [btnClose addConstraint:[NSLayoutConstraint constraintWithItem:btnClose
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:40]];
    
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnClose
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnClose
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0]];

    
    return vwHeader;
}

-(void)showMediaDetailsWithCell:(GemDetailsCustomTableViewCell*)cell andDetails:(NSDictionary*)mediaInfo index:(NSInteger)_index{
    
    NSString *mediaType ;
    if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
        mediaType = [mediaInfo objectForKey:@"media_type"];
    }
    
    if (mediaType) {
        
        if ([mediaType isEqualToString:@"image"]) {
            
            // Type Image
            [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
            [cell.activityIndicator startAnimating];
            [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]]
                                placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [UIView transitionWithView:cell.imgGemMedia
                                                             duration:.5f
                                                              options:UIViewAnimationOptionTransitionCrossDissolve
                                                           animations:^{
                                                               cell.imgGemMedia.image = image;
                                                           } completion:nil];
                                           
                                           [cell.activityIndicator stopAnimating];
                                       }];
        }
        
        else if ([mediaType isEqualToString:@"audio"]) {
            
            // Type Audio
            
            [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
            if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                [[cell btnAudioPlay]setHidden:false];
                
            }
            
        }
        
        else if ([mediaType isEqualToString:@"video"]) {
            
            // Type Video
            
            if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                if (videoURL.length){
                    [[cell btnVideoPlay]setHidden:false];
                }
            }
            
            if (NULL_TO_NIL([mediaInfo objectForKey:@"video_thumb"])) {
                NSString *videoThumb = [mediaInfo objectForKey:@"video_thumb"];
                if (videoThumb.length) {
                    [cell.activityIndicator startAnimating];
                    [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                        placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                   [cell.activityIndicator stopAnimating];
                                                   [UIView transitionWithView:cell.imgGemMedia
                                                                     duration:.5f
                                                                      options:UIViewAnimationOptionTransitionCrossDissolve
                                                                   animations:^{
                                                                       cell.imgGemMedia.image = image;
                                                                   } completion:nil];
                                               }];
                }
                
            }
            
        }
        
    }
    
    
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrolling = NO;
    [tableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    [videoPlayer pause];
    isPlaying = false;
    isScrolling = YES;
    [tableView reloadData];
    playingIndex = -1;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView reloadData];
    [videoPlayer pause];
    videoPlayer = nil;
    
    NSMutableArray *images = [NSMutableArray new];
    NSString *mediaType ;;
    if (indexPath.row < arrGemMedias.count) {
        NSDictionary *mediaInfo = arrGemMedias[indexPath.row];
        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
            mediaType = [mediaInfo objectForKey:@"media_type"];
        }
        if (mediaType) {
            if ([mediaType isEqualToString:@"image"]) {
                NSURL *url =  [NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]];
                [images addObject:url];
                for (NSDictionary *details in arrGemMedias) {
                    if (NULL_TO_NIL([details objectForKey:@"media_type"])) {
                        mediaType = [details objectForKey:@"media_type"];
                    }
                    if (mediaType) {
                        if ([mediaType isEqualToString:@"image"]) {
                            NSURL *url =  [NSURL URLWithString:[details objectForKey:@"gem_media"]];
                            if (![images containsObject:url]) {
                                [images addObject:url];
                            }
                            
                        }
                        
                    }
                }
                if (images.count) {
                    [self presentGalleryWithImages:images];
                }
            }
            else if ([mediaType isEqualToString:@"video"]){
                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                    NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                    if (videoURL.length){
                        NSError* error;
                        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                        [[AVAudioSession sharedInstance] setActive:NO error:&error];
                        NSURL *movieURL = [NSURL URLWithString:videoURL];
                        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                        [playerViewController.player play];
                        playerViewController.player = [AVPlayer playerWithURL:movieURL];
                        [self presentViewController:playerViewController animated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(videoDidFinish:)
                                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                                   object:[playerViewController.player currentItem]];
                        
                    }
                }
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

-(void)resetCellVariables:(GemDetailsCustomTableViewCell*)cell{
    
    cell.vwBg.layer.borderColor = [UIColor colorWithRed:193/255.f green:196/255.f blue:199/255.f alpha:1].CGColor;
    cell.vwBg.layer.borderWidth = 1.0;
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    [cell.activityIndicator stopAnimating];
    [[cell btnVideoPlay]setHidden:YES];
    [[cell btnAudioPlay]setHidden:YES];
    [videoPlayer pause];
    [cell.videoActivity stopAnimating];
    cell.videoPlayer = nil;
    [cell.videoPlayer pause];
    [cell.avLayer removeFromSuperlayer];
    cell.videoItem = nil;
    cell.imgGemMedia.hidden = false;
    [videoIndicator stopAnimating];
    videoIndicator = nil;
    
}

#pragma mark - Cell Customization methods

-(void)setUpGoalDateAndOtherInfoWithCell:(UITableViewCell*)cell{
    
    if ([[[cell contentView] viewWithTag:100] isKindOfClass:[UILabel class]]){
        UILabel *lblDate = [[cell contentView] viewWithTag:100];
        if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_datetime"]))
            lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[_gemDetails objectForKey:@"gem_datetime"] doubleValue]];
    }
    
    if ([[[cell contentView] viewWithTag:3] isKindOfClass:[UIView class]]){
        UIView *vwBg = [[cell contentView] viewWithTag:3];
        vwBg.hidden = true;
        if ([[vwBg viewWithTag:4] isKindOfClass:[UILabel class]]){
            UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:4];
            lblAddress.text = @"";
            if (NULL_TO_NIL([_gemDetails objectForKey:@"location_name"])) {
                lblAddress.text = [_gemDetails objectForKey:@"location_name"];
                vwBg.hidden = false;
            }
            
        }
        
    }
    
    if ([[[cell contentView] viewWithTag:5] isKindOfClass:[UIView class]]){
        UIView *vwBg = [[cell contentView] viewWithTag:5];
        vwBg.hidden = true;
        if ([[vwBg viewWithTag:6] isKindOfClass:[UILabel class]]){
            UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:6];
            lblAddress.text = @"";
            if (NULL_TO_NIL([_gemDetails objectForKey:@"contact_name"])) {
                lblAddress.text = [_gemDetails objectForKey:@"contact_name"];
                vwBg.hidden = false;
            }
            
        }
        
    }

}

-(void)setUpGoalDescriptionWithCell:(UITableViewCell*)cell{
    
    if ([[[cell contentView] viewWithTag:1] isKindOfClass:[UILabel class]]){
        UILabel *lblDescription = [[cell contentView] viewWithTag:1];
        
        if (NULL_TO_NIL([_gemDetails objectForKey:@"gem_details"])){
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.2f;
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                         NSParagraphStyleAttributeName:paragraphStyle,
                                         };
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[_gemDetails objectForKey:@"gem_details"] attributes:attributes];
            lblDescription.attributedText = attributedText;
        }
    }
}

- (CGFloat)getLabelHeight:(NSString*)text
{
    float heightPadding = 20;
    float widthPadding = 20;
    CGFloat height = 0;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (text) {
        
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        CGSize boundingBox = [text boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                                    NSParagraphStyleAttributeName:paragraphStyle}
                                                          context:context].size;
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height += size.height;
    }
    
    
    return height + heightPadding;
    
}

- (CGFloat)getLabelHeightForOtherInfo:(NSString*)description withFont:(UIFont*)font
{
    CGFloat height = 0;
    float widthPadding = 25;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize boundingBox = [description boundingRectWithSize:constraint
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:font
                                                             }
                                                   context:context].size;
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    height = size.height;
    //    if (height < 15) {
    //        height = 15;
    //    }
    
    return height;
    
}


#pragma mark - Custom Cell Delegates

-(void)resetPlayerVaiablesForIndex:(NSInteger)tag{
    
    [tableView reloadData];
    [videoPlayer pause];
    videoPlayer = nil;
    
    if (tag < arrGemMedias.count){
        
        NSDictionary * mediaInfo = arrGemMedias[tag];
        NSString *mediaType ;
        if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
            mediaType = [mediaInfo objectForKey:@"media_type"];
        }
        
        if (mediaType) {
            
            if ([mediaType isEqualToString:@"image"]) {
                
            }
            
            else if ([mediaType isEqualToString:@"audio"]) {
                
                NSString *audioURL = [mediaInfo objectForKey:@"gem_media"];
                if (audioURL.length){
                    NSURL *movieURL = [NSURL URLWithString:audioURL];
                    [self showAudioPlayerWithURL:movieURL];
                }
            }
            
            else if ([mediaType isEqualToString:@"video"]) {
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
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(videoDidFinish:)
                                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                                   object:[playerViewController.player currentItem]];
                        [self presentViewController:playerViewController animated:YES completion:nil];
                        
                    }
                }
                
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

#pragma mark - Photo Browser & Deleagtes

- (void)presentGalleryWithImages:(NSArray*)images
{
    [videoPlayer pause];
    videoPlayer = nil;
    
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


-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}




-(IBAction)goBack:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(closeQuickGoalViewPopUp)]) {
        [self.delegate closeQuickGoalViewPopUp];
    }

    
}

- (void)dealloc {
    // or
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
