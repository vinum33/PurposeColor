//
//  GoalsAndDreamsDetailViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 21/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eSectionInfo = 0,
    eSectionMedia = 1,
    
} eSectionDetails;


#define kSectionCount               2
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeaderHeight               0
#define kDefaultCellHeight          300
#define kEmptyHeaderAndFooter       0
#define kPadding                    130;
#define kHeightPercentage           80;

#import "ActionDetailPageViewController.h"
#import "Constants.h"
#import "GemDetailsCustomTableViewCell.h"
#import "ActionDetailsCustomCell.h"
#import <AVKit/AVKit.h>
#import "CustomAudioPlayerView.h"
#import "CreateActionInfoViewController.h"
#import "CommentComposeViewController.h"
#import "PhotoBrowser.h"
#import "MTDURLPreview.h"
#import "ActionDetailsCustomCellTitle.h"
#import "GemDetailsCustomCellLocation.h"
#import "GemDetailsCustomCellContact.h"
#import "GemDetailsCustomCellDescription.h"
#import "GemDetailsCustomCellPreview.h"

@interface ActionDetailPageViewController ()<GemDetailPageCellDelegate,ActionDetailsCustomCellDelegate,CustomAudioPlayerDelegate,CommentActionDelegate,PhotoBrowserDelegate,CreateMediaInfoDelegate>{
    
    IBOutlet  UITableView *tableView;
    IBOutlet  UIImageView *imgFavourite;
    IBOutlet  UIImageView *imgShared;
    IBOutlet  UILabel *lblShare;
    
    BOOL isDataAvailable;
    NSMutableArray *arrDataSource;
    
    NSInteger playingIndex;
    BOOL isScrolling;
    BOOL isPlaying;
    
    NSString *strTitle;
    NSString *strDescription;
    
    NSString *actionID;
    NSString *goalID;
    NSString *goalActionID;
    
    
    NSMutableDictionary *actionDetails;
    CustomAudioPlayerView *vwAudioPlayer;
    CommentComposeViewController *composeComment;
    PhotoBrowser *photoBrowser;
    NSMutableDictionary *heightsCache;
    
}


@end

@implementation ActionDetailPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];

    
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    
    arrDataSource = [NSMutableArray new];
    tableView.hidden = true;
    
    isDataAvailable = false;
    playingIndex = -1;
    
    strTitle = [NSString new];
    strDescription = [NSString new];
    heightsCache = [NSMutableDictionary new];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)getActionDetailsByGoalActionID:(NSString*)_goalActionID actionID:(NSString*)_actionID goalID:(NSString*)_goalID{
    
    goalID = _goalID;
    actionID = _actionID;
    goalActionID = _goalActionID;
    
    if (_actionID && _goalActionID &&_goalID) {
        [self showLoadingScreen];
        [APIMapper getGoalActionDetailsByGoalActionID:_goalActionID actionID:_actionID goalID:_goalID andUserID:[User sharedManager].userId  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self showActionDetailsWith:responseObject];
            [self hideLoadingScreen];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            tableView.hidden = false;
            isDataAvailable = false;
            [self hideLoadingScreen];
            
        }];
        
    }
}

-(void)showActionDetailsWith:(NSDictionary*)details{
    
    [heightsCache removeAllObjects];
    isDataAvailable = true;
    [arrDataSource removeAllObjects];
    if (NULL_TO_NIL([details objectForKey:@"gem_media"]))
        arrDataSource = [NSMutableArray arrayWithArray:[details objectForKey:@"gem_media"]];
    actionDetails = [NSMutableDictionary dictionaryWithDictionary:details];
    [tableView reloadData];
    tableView.hidden = false;
    imgFavourite.image = [UIImage imageNamed:@"Favourite.png"];
    if ([[actionDetails objectForKey:@"favourite_status"] boolValue])
        imgFavourite.image = [UIImage imageNamed:@"Favourite_Active.png"];
    imgShared.image = [UIImage imageNamed:@"Share.png"];
    lblShare.text = @"Share";
    if ([[actionDetails objectForKey:@"share_status"] boolValue]) {
        imgShared.image = [UIImage imageNamed:@"Shared.png"];
        lblShare.text = @"Shared";
        lblShare.textColor = [UIColor getThemeColor];
    }

}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!isDataAvailable) return kMinimumCellCount;
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
    if (section == eSectionInfo){
        NSInteger rows = 5;
        if (NULL_TO_NIL([actionDetails objectForKey:@"gem_details"])){
            NSString *string = [actionDetails objectForKey:@"gem_details"];
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
            NSArray *matches = [detector matchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
            if (matches.count > 0) {
                rows = 6;
            }
        }
        return rows;
    }
    else
        return arrDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Details Available."];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if (indexPath.section == eSectionInfo){
        
        if (indexPath.row == 0) {
            
            ActionDetailsCustomCellTitle *cell = (ActionDetailsCustomCellTitle *)[tableView dequeueReusableCellWithIdentifier:@"ActionDetailsCustomCellTitle"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.lbltTitle.text = [actionDetails objectForKey:@"gem_title"];
            cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[actionDetails objectForKey:@"gem_datetime"] doubleValue]];
            return cell;
            
        }
        
        if (indexPath.row == 1) {
            GemDetailsCustomCellLocation *cell = (GemDetailsCustomCellLocation *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellLocation"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (NULL_TO_NIL([actionDetails objectForKey:@"location_name"])){
                cell.lblLocation.text = [actionDetails objectForKey:@"location_name"];
            }
            return cell;
        }
        
        if (indexPath.row == 2) {
            GemDetailsCustomCellContact *cell = (GemDetailsCustomCellContact *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellContact"];
            if (NULL_TO_NIL([actionDetails objectForKey:@"contact_name"])){
                cell.lblContact.text = [actionDetails objectForKey:@"contact_name"];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
        if (indexPath.row == 3) {
            GemDetailsCustomCellDescription *cell = (GemDetailsCustomCellDescription *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellDescription"];
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont fontWithName:CommonFont_New size:14],
                                         };
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[actionDetails objectForKey:@"gem_details"] attributes:attributes];
            cell.lbltDescription.attributedText = attributedText;
            cell.lbltDescription.systemURLStyle = YES;
            cell.lbltDescription.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                // Open URLs
                [self attemptOpenURL:[NSURL URLWithString:string]];
            };
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (indexPath.row == 4) {
            cell = [self configureActionDetailsInfoCell:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (indexPath.row == 5) {
            GemDetailsCustomCellPreview *cell = (GemDetailsCustomCellPreview *)[tableView dequeueReusableCellWithIdentifier:@"GemDetailsCustomCellPreview"];
            if (NULL_TO_NIL([actionDetails objectForKey:@"gem_details"])){
                NSString *string = [actionDetails objectForKey:@"gem_details"];
                NSError *error = nil;
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                           error:&error];
                NSArray *matches = [detector matchesInString:string
                                                     options:0
                                                       range:NSMakeRange(0, [string length])];
                if (matches.count > 0) {
                    NSTextCheckingResult *match = [matches firstObject];
                    [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                        [cell.indicator stopAnimating];
                        cell.lblTitle.text = preview.title;
                        cell.lblDescription.text = preview.content;
                        cell.lblDomain.text = preview.domain;
                        [cell.imgPreview sd_setImageWithURL:preview.imageURL
                                           placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                  }];
                        
                    }];
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    }
    
    else{
        static NSString *CellIdentifier = @"mediaListingCell";
        GemDetailsCustomTableViewCell *cell = (GemDetailsCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [self resetCellVariables:cell];
        cell.delegate = self;
        [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
        if (indexPath.row < arrDataSource.count)
            [self showMediaDetailsWithCell:cell andDetails:arrDataSource[indexPath.row] index:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
      
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == eSectionInfo) {
        
        if (indexPath.row == 1) {
            if (NULL_TO_NIL([actionDetails objectForKey:@"location_name"]))
                return UITableViewAutomaticDimension;
            else
                return 0;
        }
        else if (indexPath.row == 2) {
            if (NULL_TO_NIL([actionDetails objectForKey:@"contact_name"]))
                return UITableViewAutomaticDimension;
            else
                return 0;
        }
        else if (indexPath.row == 3) {
            if (NULL_TO_NIL([actionDetails objectForKey:@"gem_details"]))
                return UITableViewAutomaticDimension;
            else
                return 0;
        }
        
        return UITableViewAutomaticDimension;
    }
    else{
        if (indexPath.row < arrDataSource.count) {
            NSDictionary *details = arrDataSource[indexPath.row];
            float imageHeight = 0;
            float padding = 10;
            if ([heightsCache objectForKey:[NSNumber numberWithInteger:indexPath.row]]) {
                imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInteger:indexPath.row]] floatValue];
            }else{
                float width = [[details objectForKey:@"image_width"] floatValue];
                float height = [[details objectForKey:@"image_height"] floatValue];
                float ratio = width / height;
                imageHeight = (_tableView.frame.size.width - padding) / ratio;
                [heightsCache setObject:[NSNumber numberWithInteger:imageHeight] forKey:[NSNumber numberWithInteger:indexPath.row]];
                
            }
            return imageHeight + 5;
            
        }
    }
    float height = 250;
    return height;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 5) {
        [self openPreviewURL];
        
    }else{
        NSString *mediaType ;
        NSMutableArray *images = [NSMutableArray new];
        if (indexPath.section == eSectionMedia){
            if (indexPath.row < arrDataSource.count) {
                NSDictionary *mediaInfo = arrDataSource[indexPath.row];
                
                if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                    mediaType = [mediaInfo objectForKey:@"media_type"];
                }
                if (mediaType) {
                    if ([mediaType isEqualToString:@"image"]) {
                        NSURL *url =  [NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]];
                        [images addObject:url];
                        
                        for (NSDictionary *details in arrDataSource) {
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
                    
                }
            }
        }
    }
    
    
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    playingIndex = -1;
    isScrolling = NO;
    isPlaying = FALSE;
   // [tableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    isScrolling = YES;
    isPlaying = FALSE;
   // [tableView reloadData];
}

#pragma mark - Custom Cell Customization Methods

-(ActionDetailsCustomCell*)configureActionDetailsInfoCell:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"infoCustomCell";
    ActionDetailsCustomCell *cell = (ActionDetailsCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.bottomForStatus.constant = 20;
    cell.vwURLPreview.hidden = true;
    if (NULL_TO_NIL([actionDetails objectForKey:@"gem_title"])){
        cell.lblTitle.text = [actionDetails objectForKey:@"gem_title"];
        strTitle = [actionDetails objectForKey:@"gem_title"];
   }
   if (NULL_TO_NIL([actionDetails objectForKey:@"gem_datetime"]))
        cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[actionDetails objectForKey:@"gem_datetime"] doubleValue]];
    
    cell.vwLocInfo.hidden = true;
    if (NULL_TO_NIL([actionDetails objectForKey:@"location_name"])){
        cell.vwLocInfo.hidden = false;
        cell.lblLocDetails.text = [actionDetails objectForKey:@"location_name"];
    }
    cell.vwContactInfo.hidden = true;
    if (NULL_TO_NIL([actionDetails objectForKey:@"contact_name"])){
        cell.lblContactDetails.text =[actionDetails objectForKey:@"contact_name"];
        cell.vwContactInfo.hidden = false;
    }
   
    if (NULL_TO_NIL([actionDetails objectForKey:@"gem_details"])){
        
        UIFont *font = [UIFont fontWithName:CommonFont size:14];
        NSDictionary *attributes = @{NSFontAttributeName:font
                                     
                                     };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[actionDetails objectForKey:@"gem_details"] attributes:attributes];
        cell.lblDescription.attributedText = attributedText;
        strDescription = [actionDetails objectForKey:@"gem_details"];
    }
    
    if (NULL_TO_NIL([actionDetails objectForKey:@"action_status"])){
        cell.isStatusPending = ![[actionDetails objectForKey:@"action_status"] boolValue];
    }
    if (strDescription) {
        NSString *string = strDescription;
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
        NSArray *matches = [detector matchesInString:string
                                             options:0
                                               range:NSMakeRange(0, [string length])];
        if (matches.count > 0){
            cell.vwURLPreview.hidden = false;
            cell.bottomForStatus.constant = 110;
            NSTextCheckingResult *match = [matches firstObject];
            [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                [cell.previewIndicator stopAnimating];
                cell.lblPreviewTitle.text = preview.title;
                cell.lblPreviewDescription.text = preview.content;
                cell.lblPreviewTitle.text = preview.title;
                cell.lblPreviewDomain.text = preview.domain;
                [cell.imgPreview sd_setImageWithURL:preview.imageURL
                                   placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          }];
            }];
            
        }
    }
    
    cell.delegate = self;
    [cell setUp];
    return cell;
    
}

-(void)showMediaDetailsWithCell:(GemDetailsCustomTableViewCell*)cell andDetails:(NSDictionary*)mediaInfo index:(NSInteger)index{
    
    NSString *mediaType ;
    if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
        mediaType = [mediaInfo objectForKey:@"media_type"];
    }
    float imageHeight = 0;
    if ([heightsCache objectForKey:[NSNumber numberWithInt:index]]) {
        imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:index]] integerValue];
        cell.constraintForHeight.constant = imageHeight;
    }
    
    if (mediaType) {
        
        if ([mediaType isEqualToString:@"image"]) {
            
            // Type Image
           // [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
            [cell.activityIndicator startAnimating];
            [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]]
                                placeholderImage:[UIImage imageNamed:@""]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
                    float imageHeight = 0;
                    if ([heightsCache objectForKey:[NSNumber numberWithInt:index]]) {
                        imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:index]] integerValue];
                        cell.constraintForHeight.constant = imageHeight;
                    }
                    [cell.activityIndicator startAnimating];
                    [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                        placeholderImage:[UIImage imageNamed:@""]
                                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                   [cell.activityIndicator stopAnimating];
                                                }];
                }
                
            }
            
        }
        
    }
    
}


-(void)resetCellVariables:(GemDetailsCustomTableViewCell*)cell{
    
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    [cell.activityIndicator stopAnimating];
    [[cell btnVideoPlay]setHidden:YES];
    [[cell btnAudioPlay]setHidden:YES];
    
}
#pragma mark - Custom Cell Delegates

-(void)resetPlayerVaiablesForIndex:(NSInteger)tag{
    
    if (tag < arrDataSource.count){
        
        NSDictionary * mediaInfo = arrDataSource[tag];
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

-(void)updateGoalActionStatus{
    
    if (goalID && actionID) {
        
        [APIMapper updateGoalActionStatusWithActionID:actionID goalID:goalID goalActionID:goalActionID andUserID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([self.delegate respondsToSelector:@selector(refershGoalsAndDreamsAfterUpdate)]) {
                [self.delegate refershGoalsAndDreamsAfterUpdate];
            }
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];
    }
    
}

-(IBAction)editButtonClicked{
    
      if ([lblShare.text isEqualToString:@"Shared"]) {
          
          AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
          UINavigationController *nav = delegate.navGeneral;
          
          UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EDIT GEM"
                                                                         message:@"This is a shared GEM.Do you still want to change it?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
          UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                    
                                                                    CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
                                                                    detailPage.actionType = eActionTypeActions;
                                                                    detailPage.strTitle = @"EDIT ACTION";
                                                                    detailPage.delegate = self;
                                                                    [[self navigationController]pushViewController:detailPage animated:YES];
                                                                    [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:goalActionID GEMType:@"action"];
                                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                                    
                                                                }];
          UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               
                                                                [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
          
          [alert addAction:firstAction];
          [alert addAction:second];
          [nav presentViewController:alert animated:YES completion:nil];
          
      }else{
          
          CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
          detailPage.actionType = eActionTypeActions;
          detailPage.strTitle = @"EDIT ACTION";
          detailPage.delegate = self;
          [[self navigationController]pushViewController:detailPage animated:YES];
          [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:goalActionID GEMType:@"action"];
      }

    
}
-(void)actionStatusChanged{
    
    if ([[actionDetails objectForKey:@"action_status"] integerValue] == 1) {
        [actionDetails setObject:[NSNumber numberWithInteger:0] forKey:@"action_status"];
    }else{
         [actionDetails setObject:[NSNumber numberWithInteger:1] forKey:@"action_status"];
    }
}

-(void)newActionCreatedWithActionTitle:(NSString*)actionTitle actionID:(NSInteger)_actionID{
    
    [self getActionDetailsByGoalActionID:goalActionID actionID:actionID goalID:goalID];
    if ([self.delegate respondsToSelector:@selector(refershGoalsAndDreamsAfterUpdate)]) {
        [self.delegate refershGoalsAndDreamsAfterUpdate];
    }
    // Refresh the Goal deatil page to reflect the changes
}

#pragma mark - Generic Methods

- (void)openPreviewURL
{
    if (NULL_TO_NIL([actionDetails objectForKey:@"gem_details"])){
        NSString *string = [actionDetails objectForKey:@"gem_details"];
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
        NSArray *matches = [detector matchesInString:string
                                             options:0
                                               range:NSMakeRange(0, [string length])];
        if (matches.count > 0) {
            NSTextCheckingResult *match = [matches firstObject];
            [[UIApplication sharedApplication] openURL:[match URL]];
        }
        
    }
    
}


- (void)attemptOpenURL:(NSURL *)url
{
    
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (!safariCompatible) {
        
        NSString *urlString = url.absoluteString;
        urlString = [NSString stringWithFormat:@"http://%@",url.absoluteString];
        url = [NSURL URLWithString:urlString];
        
    }
    safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem"
                                                        message:@"The selected link cannot be opened."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


-(IBAction)previewClickedWithGesture:(UIButton*)btn{
    
    if (strDescription){
        
        NSString *string = strDescription;
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
        NSArray *matches = [detector matchesInString:string
                                             options:0
                                               range:NSMakeRange(0, [string length])];
        if (matches.count > 0) {
            NSTextCheckingResult *match = [matches firstObject];
            [[UIApplication sharedApplication] openURL:[match URL]];
            
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


- (CGFloat)getLabelHeight:(NSInteger)index
{
    float heightPadding = 100;
    CGFloat height = 0;
    
    float widthPadding = 20;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (strDescription) {
        
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        CGSize boundingBox = [strDescription boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                                    NSParagraphStyleAttributeName:paragraphStyle}
                                                          context:context].size;
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height += size.height;
    }
    
    if (strTitle) {
        
        widthPadding = 70;
        constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        CGSize boundingBox = [strTitle boundingRectWithSize:constraint
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFontBold size:14]}
                                                    context:context].size;
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height += size.height;
    }
    
    return height + heightPadding;
    
}

#pragma mark - Comment Showing and its Delegate

-(IBAction)commentComposeView{
    
    if (!composeComment) {
        composeComment =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCommentCompose];
        composeComment.delegate = self;
    }
    NSDictionary *gemDetails = actionDetails;
    composeComment.dictGemDetails = gemDetails;
    composeComment.isFromCommunityGem = false;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window.rootViewController addChildViewController:composeComment];
    UIView *vwPopUP = composeComment.view;
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
    }];
    
}

-(void)commentPopUpCloseAppplied{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        composeComment.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [composeComment.view removeFromSuperview];
        [composeComment removeFromParentViewController];
        composeComment = nil;
        
    }];
    
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

#pragma mark - Add to Favourite Showing

-(IBAction)shareButtonClicked{
    
    
    UIAlertController * alert=  [UIAlertController
                                  alertControllerWithTitle:@"Share"
                                  message:@"You are going to inspire someone by sharing this GEM."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             NSDictionary *gemDetails =  actionDetails;
                             NSString *gemID;
                             NSString *gemType;
                             
                             if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
                                 gemID = [gemDetails objectForKey:@"gem_id"];
                             
                             if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
                                 gemType = [gemDetails objectForKey:@"gem_type"];
                             
                             if (gemID && gemType) {
                                 
                                 [APIMapper shareAGEMToCommunityWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     
                                     if ([[responseObject objectForKey:@"code"]integerValue] == kSuccessCode){
                                         
                                         [[[UIAlertView alloc] initWithTitle:@"Share" message:@"Shared to Inspiring gems." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                                         
                                         imgShared.image = [UIImage imageNamed:@"Shared.png"];
                                         lblShare.text = @"Shared";
                                         lblShare.textColor = [UIColor getThemeColor];
                                     }
                                     
                                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                     
                                 }];
                             }

                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:@"CANCEL"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    
   }

#pragma mark - Add to Favourite Showing

-(IBAction)addToFavouriteClicked{
    
    NSMutableDictionary *gemDetails = [NSMutableDictionary dictionaryWithDictionary:actionDetails];
    NSString *gemID;
    NSString *gemType;
    
    if (![[actionDetails objectForKey:@"favourite_status"] boolValue]){
        imgFavourite.image = [UIImage imageNamed:@"Favourite_Active.png"];
        [gemDetails setValue:[NSNumber numberWithBool:1] forKey:@"favourite_status"];
    }
    
    if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
        gemID = [gemDetails objectForKey:@"gem_id"];
    
    if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
        gemType = [gemDetails objectForKey:@"gem_type"];
    
    
    if (gemID && gemType) {
        [APIMapper addGemToFavouritesWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];
    }
}



-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}



-(IBAction)goBack:(id)sender{
    
    if (self.navigationController.viewControllers.count == 1) {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.navGeneral willMoveToParentViewController:nil];
        [app.navGeneral.view removeFromSuperview];
        [app.navGeneral removeFromParentViewController];
        app.navGeneral = nil;
        [app showLauchPage];
    }else{
        [[self navigationController] popViewControllerAnimated:YES];
    }
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
