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
    eSectionActions = 2,
    
} eSectionDetails;


#define kSectionCount               3
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeaderHeight               0
#define kDefaultCellHeight          300
#define kEmptyHeaderAndFooter       0
#define kPadding                    130;
#define kActionCellHeight           50;

#import "GoalDetailViewController.h"
#import "Constants.h"
#import "GemDetailsCustomTableViewCell.h"
#import "ActionDetailsCustomCell.h"
#import <AVKit/AVKit.h>
#import "CustomAudioPlayerView.h"
#import "CreateActionInfoViewController.h"
#import "CommentComposeViewController.h"
#import "PhotoBrowser.h"
#import "ActionCustomCell.h"
#import "ActionDetailPageViewController.h"

@interface GoalDetailViewController ()<GemDetailPageCellDelegate,ActionDetailsCustomCellDelegate,CustomAudioPlayerDelegate,CommentActionDelegate,PhotoBrowserDelegate,CreateMediaInfoDelegate,ActionDetailsDelegate>{
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UITableView *tableView;
    IBOutlet  UIImageView *imgFavourite;
    IBOutlet  UIButton *btnHeaderAction;
    IBOutlet  UIImageView *imgShared;
    IBOutlet  UILabel *lblShare;
    IBOutlet  UIButton *btnCreateAction;
    
    BOOL isDataAvailable;
    NSMutableArray *arrDataSource;
    NSMutableArray *arrActions;
    
    NSInteger playingIndex;
    BOOL isScrolling;
    BOOL isPlaying;
    BOOL isUpdated;
    
    NSString *strTitle;
    NSString *strDescription;
    
    NSString *goalID;
    
    NSDictionary *actionDetails;
    CustomAudioPlayerView *vwAudioPlayer;
    CommentComposeViewController *composeComment;
    PhotoBrowser *photoBrowser;
    NSMutableDictionary *heightsCache;
    
}


@end

@implementation GoalDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
    
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    arrDataSource = [NSMutableArray new];
    actionDetails = [NSDictionary new];
    tableView.hidden = true;
    btnHeaderAction.hidden = true;
    isDataAvailable = false;
    playingIndex = -1;
    btnCreateAction.hidden = false;
    strTitle = [NSString new];
    strDescription = [NSString new];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    heightsCache =  [NSMutableDictionary new];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)getGoaDetailsByGoalID:(NSString*)_goalID{
    
    goalID = _goalID;
    
    if (_goalID) {
        [self showLoadingScreen];
        [APIMapper getGoalDetailsWithGoalID:_goalID userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self showGemDetailsWith:responseObject];
            [self hideLoadingScreen];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [self hideLoadingScreen];
            tableView.hidden = false;
            isDataAvailable = false;
            [tableView reloadData];
            
        }];
        
    }
}

-(void)showGemDetailsWith:(NSDictionary*)details{
    
    isDataAvailable = true;
    if (NULL_TO_NIL([details objectForKey:@"gem_media"]))
        arrDataSource = [NSMutableArray arrayWithArray:[details objectForKey:@"gem_media"]];
    actionDetails = details;
    tableView.hidden = false;
    imgFavourite.image = [UIImage imageNamed:@"Favourite.png"];
    if ([[actionDetails objectForKey:@"favourite_status"] boolValue])
        imgFavourite.image = [UIImage imageNamed:@"Favourite_Active.png"];
    if (NULL_TO_NIL([details objectForKey:@"action"]))
        arrActions = [NSMutableArray arrayWithArray:[details objectForKey:@"action"]];
    lblTitle.text = [[NSString stringWithFormat:@"%@ DETAILS",[actionDetails objectForKey:@"gem_type"]] uppercaseString];
    imgShared.image = [UIImage imageNamed:@"Share.png"];
    lblShare.text = @"Share";
    if ([[actionDetails objectForKey:@"share_status"] boolValue]) {
        imgShared.image = [UIImage imageNamed:@"Shared.png"];
        lblShare.text = @"Shared";
        lblShare.textColor = [UIColor getThemeColor];
        
    }
    if ([[actionDetails objectForKey:@"goal_status"] boolValue]) btnCreateAction.hidden = true;
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!isDataAvailable) return kMinimumCellCount;
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
    if (section == eSectionInfo)
        return kMinimumCellCount;
    else if (section == eSectionActions){
        if (arrActions.count <= 0)  return kMinimumCellCount;
        btnHeaderAction.hidden = false;
        return arrActions.count;
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    if (indexPath.section == eSectionInfo)
        cell = [self configureActionDetailsInfoCell:indexPath];
    
    else if (indexPath.section == eSectionMedia){
        static NSString *CellIdentifier = @"mediaListingCell";
        GemDetailsCustomTableViewCell *cell = (GemDetailsCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [self resetCellVariables:cell];
        cell.delegate = self;
        [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
        if (indexPath.row < arrDataSource.count)
            [self showMediaDetailsWithCell:cell andDetails:arrDataSource[indexPath.row] index:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
        
    }else{
        if (arrActions.count <= 0) {
           UITableViewCell *cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Actions Available."];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
        static NSString *CellIdentifier = @"ActionCell";
        ActionCustomCell *cell = (ActionCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row < arrActions.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.btnStatus.tag = indexPath.row;
            [cell.btnStatus addTarget:self action:@selector(updateStatus:) forControlEvents:UIControlEventTouchUpInside];
            NSDictionary *goalsDetails = arrActions[indexPath.row];
            if (NULL_TO_NIL([goalsDetails objectForKey:@"action_title"]))
                cell.lblTitle.text = [goalsDetails objectForKey:@"action_title"];
            if (NULL_TO_NIL([goalsDetails objectForKey:@"action_status"])){
                [cell.btnStatus setImage:[UIImage imageNamed:@"CheckBox_Goals_Active.png"] forState:UIControlStateNormal];
                NSInteger status = [[goalsDetails objectForKey:@"action_status"] integerValue];
                if (status == 0) {
                    [cell.btnStatus setImage:[UIImage imageNamed:@"CheckBox_Goals.png"] forState:UIControlStateNormal];
                }
            }
        }
        return cell;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == eSectionInfo) {
        CGFloat height = [self getLabelHeight:indexPath.row];
        if (NULL_TO_NIL([actionDetails objectForKey:@"location_name"])){
            height += 15;
        }
        if (NULL_TO_NIL([actionDetails objectForKey:@"contact_name"])){
            height += 15;
        }
        return height;
    }
    else if (indexPath.section == eSectionMedia) {
      
        if (indexPath.row < arrDataSource.count) {
            NSDictionary *details = arrDataSource[indexPath.row];
            float imageHeight = 0;
            float padding = 10;
            if ([heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
                imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]] floatValue];
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
    float height = kActionCellHeight;
    return height;

}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == eSectionActions) {
        CGFloat height = 45;
        return height;
    }
    return kHeaderHeight;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    playingIndex = -1;
    isScrolling = NO;
    isPlaying = FALSE;
    [tableView reloadData];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)aScrollView
{
    isScrolling = YES;
    isPlaying = FALSE;
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
    else if (indexPath.section == eSectionActions){
        
        ActionDetailPageViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGoalsDreamsDetailPage];
         detailPage.delegate = self;
        [[self navigationController]pushViewController:detailPage animated:YES];
        
        if (indexPath.row < arrActions.count){
            NSDictionary *_actionDetails = arrActions[indexPath.row];
            NSString *actionID = [_actionDetails objectForKey:@"action_id"];
            NSString *goalActionID = [_actionDetails objectForKey:@"goalaction_id"];
            [detailPage getActionDetailsByGoalActionID:goalActionID actionID:actionID goalID:goalID];
            
        }

    }
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == eSectionActions){
        UIView *vwHeader = [UIView new];
        
        UIView *vwBG = [UIView new];
        [vwHeader addSubview:vwBG];
        vwBG.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[vwBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBG)]];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBG)]];
         vwBG.backgroundColor = [UIColor getThemeColor];
       
        UILabel *_lblTitle = [UILabel new];
        _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [vwBG addSubview:_lblTitle];
        [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
        [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
        _lblTitle.text = @"ACTIONS";
        _lblTitle.font = [UIFont fontWithName:CommonFont size:14];
        _lblTitle.textColor = [UIColor whiteColor];
        return vwHeader;
    }
    return nil;
   
}


#pragma mark - Custom Cell Customization Methods

-(ActionDetailsCustomCell*)configureActionDetailsInfoCell:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"infoCustomCell";
    ActionDetailsCustomCell *cell = (ActionDetailsCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (NULL_TO_NIL([actionDetails objectForKey:@"gem_title"])){
        cell.lblTitle.text = [actionDetails objectForKey:@"gem_title"];
        cell.rightConstarint.constant = 70;
        if (_shouldHideEditBtn) {
            cell.rightConstarint.constant = 10;
        }
        strTitle = [actionDetails  objectForKey:@"gem_title"];
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
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        NSDictionary *attributes = @{NSFontAttributeName:font
                                     };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[actionDetails objectForKey:@"gem_details"] attributes:attributes];
        cell.lblDescription.attributedText = attributedText;
        strDescription = [actionDetails objectForKey:@"gem_details"];
    }
    cell.delegate = self;
    cell.btnEdit.hidden = false;
    if (_shouldHideEditBtn) cell.btnEdit.hidden = true;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
    
}

-(void)showMediaDetailsWithCell:(GemDetailsCustomTableViewCell*)cell andDetails:(NSDictionary*)mediaInfo index:(NSInteger)index{
    
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
                    [cell.activityIndicator startAnimating];
                    [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                        placeholderImage:[UIImage imageNamed:@""]
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
    
    float imageHeight = 0;
    if ([heightsCache objectForKey:[NSNumber numberWithInt:index]]) {
        imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:index]] integerValue];
        cell.constraintForHeight.constant = imageHeight;
    }
    
}


-(void)resetCellVariables:(GemDetailsCustomTableViewCell*)cell{
    
    [cell.imgGemMedia setImage:[UIImage imageNamed:@""]];
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

-(void)editButtonClicked{
    
    if ([lblShare.text isEqualToString:@"Shared"]) {
        
        UINavigationController *nav =self.navigationController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EDIT GEM"
                                                                       message:@"This is a shared GEM.Do you still want to change it"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  NSString *gemType = @"goal";
                                                                  CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
                                                                  detailPage.actionType = eActionTypeGoalsAndDreams;
                                                                  detailPage.delegate = self;
                                                                  detailPage.strTitle = @"EDIT GOALS&DREAMS";
                                                                  [[self navigationController]pushViewController:detailPage animated:YES];
                                                                  [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:goalID GEMType:gemType];
                                                                  
                                                              }];
        UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         }];
        
        [alert addAction:firstAction];
        [alert addAction:second];
        [nav presentViewController:alert animated:YES completion:nil];
        
        
    }else{
        
        NSString *gemType = @"goal";
        CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
        detailPage.actionType = eActionTypeGoalsAndDreams;
        detailPage.delegate = self;
        detailPage.strTitle = @"EDIT GOALS&DREAMS";
        [[self navigationController]pushViewController:detailPage animated:YES];
        [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:goalID GEMType:gemType];
    }
    
    
}

#pragma mark - Media Creation Page Delegates

-(void)goalsAndDreamsCreatedWithGoalTitle:(NSString*)goalTitle goalID:(NSInteger)_goalID{
    
    [heightsCache removeAllObjects];
     isUpdated = true;
    [self getGoaDetailsByGoalID:goalID];
    
}

-(void)newActionCreatedWithActionTitle:(NSString*)actionTitle actionID:(NSInteger)_actionID{
    
     [heightsCache removeAllObjects];
    isUpdated = true;
    [self getGoaDetailsByGoalID:goalID];
}

-(void)refershGoalsAndDreamsAfterUpdate{
    
    [heightsCache removeAllObjects];
     isUpdated = true;
    [self getGoaDetailsByGoalID:goalID];
}


#pragma mark - Generic Methods

-(IBAction)tableScrollToActions:(id)sender{
    
    if (arrActions.count){
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
        
       
    }
   
}
-(IBAction)createNewAction{
    
    CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
    detailPage.strTitle = @"ADD ACTION";
    detailPage.actionType = eActionTypeActions;
    detailPage.strGoalID = goalID;
    detailPage.delegate = self;
    [[self navigationController]pushViewController:detailPage animated:YES];
    
}
-(void)updateStatus:(UIButton*)btnStatus{
    
    isUpdated = true;
    NSInteger index = btnStatus.tag;
    
    NSString *strMessage = @"Do you want to change this action to Complete ?";
    if (arrActions.count > index) {
        NSMutableDictionary *_actionDetails = [NSMutableDictionary dictionaryWithDictionary:arrActions[index]];
        if (_actionDetails) {
            if ([[_actionDetails objectForKey:@"action_status"] integerValue] == 1) strMessage = @"Do you want to change this action to Pending ?";
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Action"
                                                                   message:strMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              
                                                              if (arrActions.count > index) {
                                                                  NSMutableDictionary *_actionDetails = [NSMutableDictionary dictionaryWithDictionary:arrActions[index]];
                                                                  if (_actionDetails) {
                                                                      if ([[_actionDetails objectForKey:@"action_status"] integerValue] == 0)
                                                                          [_actionDetails setObject:[NSNumber numberWithInt:1] forKey:@"action_status"];
                                                                      else
                                                                          [_actionDetails setObject:[NSNumber numberWithInt:0] forKey:@"action_status"];
                                                                      
                                                                      [arrActions replaceObjectAtIndex:index withObject:_actionDetails];
                                                                      NSRange range = NSMakeRange(2, 1);
                                                                      NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
                                                                      [tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationFade];
                                                                  }
                                                                  
                                                                  NSString *actionID = [_actionDetails objectForKey:@"action_id"];
                                                                  NSString *goalActionID = [_actionDetails objectForKey:@"goalaction_id"];
                                                                  [APIMapper updateGoalActionStatusWithActionID:actionID goalID:goalID goalActionID:goalActionID andUserID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                      
                                                                  } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                                                      
                                                                  }];
                                                                  
                                                              }
                                                              
                                                              
                                                          }];
    UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                     }];
    
    [alert addAction:firstAction];
    [alert addAction:second];
    [self presentViewController:alert animated:YES completion:nil];
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
    float heightPadding = 40;
    CGFloat height = 0;
    
    float widthPadding = 10;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (strDescription) {
        constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
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
        if (_shouldHideEditBtn) widthPadding = 20;
        
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
    
    if (isUpdated) {
        if ([self.delegate respondsToSelector:@selector(refershGoalsAndDreamsListingAfterUpdate)]) {
            [self.delegate refershGoalsAndDreamsListingAfterUpdate];
        }
    }
    
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
