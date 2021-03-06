//
//  CreateActionInfoViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



typedef enum{
    
    eTitle = 0,
    eDescription = 1,
    eGoalDescription = 2,
    
} eCellType;

typedef enum{
    
    eSectionOne = 0,
    eSectionTwo = 1,
    
} eSectionType;


#define kSectionCount                   2
#define kSuccessCode                    200
#define kMinimumCellCount               2
#define kMinimumCellCountForGoal        3
#define kHeaderHeight                   40
#define kCellHeightForDescription       205
#define kCellHeightForTtile             50
#define kCellHeightForDate              60
#define kEmptyHeaderAndFooter           0
#define kDefaultCellHeight              250
#define kMaxDescriptionLength           500
#define kHeightForFooter                0.1

#import "CreateActionInfoViewController.h"
#import "ActionMediaComposeCell.h"
#import "ActionMediaListCell.h"
#import "Constants.h"
#import "AudioManagerView.h"
#import "GalleryManager.h"
#import <AddressBookUI/AddressBookUI.h>
#import "CircleProgressBar.h"
#import "EventCreateViewController.h"
#import "UIView+RNActivityView.h"
#import "CustomeImagePicker.h"
#import "CustomAudioPlayerView.h"
#import <AVKit/AVKit.h>
#import "UITextView+Placeholder.h"
#import "PhotoBrowser.h"
#import "SDAVAssetExportSession.h"
#import "ActionMediaForGoalComposeCell.h"
#import "FTPopOverMenu.h"
#import "ContactsPickerViewController.h"
#import "MTDURLPreview.h"

@import GooglePlacePicker;


@interface CreateActionInfoViewController () <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLLocationManagerDelegate,ABPeoplePickerNavigationControllerDelegate,CustomeImagePickerDelegate,ActionInfoCellDelegate,CustomAudioPlayerDelegate,PhotoBrowserDelegate,UIGestureRecognizerDelegate,ContactPickerDelegate>{
    
    IBOutlet UITableView *tableView;
    
    BOOL isDataAvailable;
    NSMutableArray *arrDataSource;
    NSString *strTitle;
    NSString *strDescription;
    NSInteger goalActionID; // For reminder
    
    NSInteger indexForTextFieldNavigation;
    UIView *inputAccView;
    AudioManagerView *vwRecordPopOver;
    
    CLLocationManager* locationManager;
    CLLocationCoordinate2D locationCordinates;
    NSString *strLocationAddress;
    NSString *strLocationName;
    
    NSMutableString *strContactName;
    IBOutlet CircleProgressBar *_circleProgressBar;
    IBOutlet UIView *vwProgressOverLay;
    IBOutlet UIView *vwPickerOverLay;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnPost;
    CustomAudioPlayerView *vwAudioPlayer;
    NSMutableArray *arrDeletedIDs;
    PhotoBrowser *photoBrowser;
    
    NSString *gemID;
    NSString *gemType;
    NSString *strAchievementDate;
    NSString *strStatus;
    
    CGPoint viewStartLocation;
    
    IBOutlet UIView *vwURLPreview;
    IBOutlet UILabel *lblPreviewTitle;
    IBOutlet UILabel *lblPreviewDescription;
    IBOutlet UILabel *lblPreviewDomain;
    IBOutlet UIImageView *imgPreview;
    IBOutlet UIActivityIndicatorView *previewIndicator;
    IBOutlet UIButton *btnShowPreviewURL;
    NSDataDetector *detector;
    IBOutlet NSLayoutConstraint *bottomForPreview;
    BOOL showPreview;
    NSURL *alreadyPreviewdURL;
    
}

@property (nonatomic,strong) NSIndexPath *draggingCellIndexPath;
@property (nonatomic,strong) UIView *cellSnapshotView;

@end

@implementation CreateActionInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self removeAllContentsInMediaFolder];
    [self setUp];
    [self getCurrentUserLocation];
   
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyBoardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    showPreview = true;
    strLocationAddress = [NSString new];
    strLocationName = [NSString new];
    strContactName = [NSMutableString new];
    isDataAvailable = true;
    arrDataSource = [NSMutableArray new];
    vwProgressOverLay.hidden = true;
    vwProgressOverLay.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    arrDeletedIDs = [NSMutableArray new];
    lblTitle.text = _strTitle;
    vwPickerOverLay.hidden = true;
    datePicker.minimumDate = [NSDate date];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(dragCell:)];
    [longPressGestureRecognizer setDelegate:self];
    [tableView addGestureRecognizer:longPressGestureRecognizer];
    
    btnPost.layer.cornerRadius = 5;
    btnPost.layer.borderWidth = 1.f;
    btnPost.layer.borderColor = [UIColor whiteColor].CGColor;
    [btnPost setTitle:@"SAVE" forState:UIControlStateNormal];
    if (_actionType == eActionTypeCommunity)[btnPost setTitle:@"POST" forState:UIControlStateNormal];
    
    
}



#pragma mark - Get user current location

-(void)getCurrentUserLocation{
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations lastObject]) {
        
        [locationManager stopUpdatingLocation];
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellCount = kMinimumCellCount;
     if (_actionType == eActionTypeGoalsAndDreams) {
         cellCount = kMinimumCellCountForGoal;
     }
    if (section == eSectionTwo)
         cellCount = arrDataSource.count;
        return cellCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.section == eSectionOne)
        cell = [self configureCellForIndexPath:indexPath];
    
    else
        cell = [self configureCellForListAtPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat cellHeight = kDefaultCellHeight;
    if (indexPath.section == eSectionOne) {
        if (_actionType == eActionTypeCommunity) {
            
            if (indexPath.row == 0) {
                return 0;
            }
        }
        
        if (_actionType == eActionTypeGoalsAndDreams) {
            
            cellHeight = kCellHeightForTtile;
            if (indexPath.row == 1)
                cellHeight = kCellHeightForDate;
            if (indexPath.row == 2)
                cellHeight = kCellHeightForDescription;
        }else{
            
            cellHeight = kCellHeightForTtile;
            if (indexPath.row == eDescription)
                cellHeight = kCellHeightForDescription;
        }
       
    }
    return cellHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if ((section == eSectionTwo) && arrDataSource.count > 0) {
        return kHeaderHeight;
    }
    return kEmptyHeaderAndFooter;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == eSectionOne) return nil;
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor getThemeColor];
    UILabel *_lblTitle = [UILabel new];
    _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:_lblTitle];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[_lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[_lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    _lblTitle.text = @"ATTACHMENT";
    _lblTitle.font = [UIFont fontWithName:CommonFont size:14];
    _lblTitle.textColor = [UIColor whiteColor];
    
    return vwHeader;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *mediaType ;
    NSMutableArray *images = [NSMutableArray new];
    if (indexPath.section == eSectionTwo){
        if (indexPath.row < arrDataSource.count) {
            id object = arrDataSource[indexPath.row];
            if ([object isKindOfClass:[NSDictionary class]]) {
                NSDictionary *mediaInfo = arrDataSource[indexPath.row];
                mediaType = [mediaInfo objectForKey:@"media_type"];
                if ([mediaType isEqualToString:@"image"]) {
                    NSURL *url =  [NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]];
                    [images addObject:url];
                }
            }else{
                NSString *strURL = (NSString*)arrDataSource[indexPath.row];
                if ([strURL hasPrefix:@"PurposeColorImage"]) {
                    if (![images containsObject:strURL]) {
                        [images addObject:strURL];
                    }
                }
            }
            
        }
    }
    
    if (images.count) {
        for (id details in arrDataSource) {
            if ([details isKindOfClass:[NSDictionary class]]) {
                mediaType = [details objectForKey:@"media_type"];
                if ([mediaType isEqualToString:@"image"]) {
                    NSURL *url =  [NSURL URLWithString:[details objectForKey:@"gem_media"]];
                    if (![images containsObject:url]) {
                        [images addObject:url];
                    }
                }
            }else{
                NSString *strURL = (NSString*)details;
                if ([strURL hasPrefix:@"PurposeColorImage"]) {
                    if (![images containsObject:strURL]) {
                        [images addObject:strURL];
                    }
                }
            }
            
        }
    }
    
    if (images.count) {
        [self presentGalleryWithImages:images];
    }

}

- (nullable UIView *)tableView:(UITableView *)_tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
    
    if (section == eSectionTwo) {
        return nil;
    }
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor whiteColor];
    UIButton *btnReminder = [UIButton buttonWithType:UIButtonTypeCustom];
    btnReminder.translatesAutoresizingMaskIntoConstraints = NO;
    btnReminder.hidden = true;
    [btnReminder setTitle:@"Create Reminder" forState:UIControlStateNormal];
    btnReminder.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnReminder setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
    btnReminder.backgroundColor = [UIColor clearColor];
    [btnReminder addTarget:self action:@selector(createReminder:)forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnReminder];

    
    [btnReminder addConstraint:[NSLayoutConstraint constraintWithItem:btnReminder
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:40]];
    
    [btnReminder addConstraint:[NSLayoutConstraint constraintWithItem:btnReminder
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:130]];
 
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnReminder
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnReminder
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-5]];
    
//    if (_shouldShowReminder)btnReminder.hidden = false;
//    if (goalActionID <= 0) {
//        [btnReminder setEnabled:false];
//        [btnReminder setAlpha:0.3];
//    }else{
//        [btnReminder setEnabled:true];
//        [btnReminder setAlpha:1];
//    }
    return vwFooter;
}
- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == eSectionTwo) {
        return kEmptyHeaderAndFooter;
    }
    return kHeightForFooter;
}

-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    UITableViewCell *cell;
    
    if (_actionType == eActionTypeGoalsAndDreams) {
        
        static NSString *CellIdentifier = @"CustomCellForGoalCreate";
        ActionMediaForGoalComposeCell *cell = (ActionMediaForGoalComposeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.lblLocInfo.text = @"";
        cell.lblContactInfo.text = @"";
        cell.vwFooter.hidden = true;
        cell.vwDateBG.hidden = true;
        cell.vwBg.hidden = true;
        
        if (strTitle.length) {
            cell.txtTitle.text = strTitle;
        }
        if (strDescription.length) {
            cell.txtDecsription.text = strDescription;
        }
        
        cell.txtTitle.keyboardType=UIKeyboardTypeASCIICapable;
        cell.txtDecsription.keyboardType=UIKeyboardTypeASCIICapable;
        
        cell.txtTitle.hidden = true;
        cell.txtTitle.tag = indexPath.row;
        cell.txtDecsription.tag = indexPath.row;
        cell.txtDecsription.placeholder = @"Add Description";
        if (_actionType == eActionTypeGoalsAndDreams) {
            cell.txtDecsription.placeholder = @"Reason why";
        }
        if (strAchievementDate.length) cell.txtDate.text = strAchievementDate;
        if (strStatus.length) cell.txtStatus.text = strStatus;
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        cell.txtTitle.leftView = paddingView;
        cell.txtTitle.leftViewMode = UITextFieldViewModeAlways;
        
        
        if (indexPath.row == eTitle)
            cell.txtTitle.hidden = false;
        else if (indexPath.row == 1)
            cell.vwDateBG.hidden = false;
        else{
            [self setUpFooterMenuWithView:cell.vwFooter];
            cell.vwBg.hidden = false;
            cell.vwFooter.hidden = false;
            if (strLocationName.length > 0){
                
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"- @ : %@",strLocationName]];
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(0,6)];
                cell.lblLocInfo.attributedText = string;
            }
            
            if (strContactName.length > 0){
                
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"- With : %@",strContactName]];
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(0,9)];
                cell.lblContactInfo.attributedText = string;
            }
            
        }
        
        UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetContactInfo)];
        gesture1.numberOfTapsRequired = 1;
        cell.lblContactInfo.userInteractionEnabled = true;
        [cell.lblContactInfo addGestureRecognizer:gesture1];
        
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetLocationInfo)];
        gesture2.numberOfTapsRequired = 1;
        cell.lblLocInfo.userInteractionEnabled = true;
        [cell.lblLocInfo addGestureRecognizer:gesture2];
        return cell;
        
    }else{
        
        static NSString *CellIdentifier = @"CustomCellForCompose";
        ActionMediaComposeCell *cell = (ActionMediaComposeCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.lblLocInfo.text = @"";
        cell.lblContactInfo.text = @"";
        cell.vwFooter.hidden = true;
        if (strTitle.length) {
            cell.txtTitle.text = strTitle;
        }
        if (strDescription.length) {
            cell.txtDecsription.text = strDescription;
        }
        cell.txtTitle.hidden = true;
        cell.txtTitle.tag = indexPath.row;
        cell.txtDecsription.tag = indexPath.row;
        cell.txtDecsription.placeholder = @"Add Description";
        if (_actionType == eActionTypeGoalsAndDreams) {
            cell.txtDecsription.placeholder = @"Reason why";
        }
        if (_actionType == eActionTypeCommunity)  cell.txtDecsription.placeholder = @"Inspire and be inspired";

        cell.txtTitle.keyboardType=UIKeyboardTypeASCIICapable;
        cell.txtDecsription.keyboardType=UIKeyboardTypeASCIICapable;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        cell.txtTitle.leftView = paddingView;
        cell.txtTitle.leftViewMode = UITextFieldViewModeAlways;
        
        cell.vwBg.hidden = true;
        if (indexPath.row == eTitle)
            cell.txtTitle.hidden = false;
        else{
            [self setUpFooterMenuWithView:cell.vwFooter];
            cell.vwBg.hidden = false;
            cell.vwFooter.hidden = false;
            if (strLocationName.length > 0){
                
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"- @ : %@",strLocationName]];
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(0,6)];
                cell.lblLocInfo.attributedText = string;
            }
            
            if (strContactName.length > 0){
                
                NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"- With : %@",strContactName]];
                [string addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(0,9)];
                cell.lblContactInfo.attributedText = string;
            }
            
        }
        
        UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetContactInfo)];
        gesture1.numberOfTapsRequired = 1;
        cell.lblContactInfo.userInteractionEnabled = true;
        [cell.lblContactInfo addGestureRecognizer:gesture1];
        
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetLocationInfo)];
        gesture2.numberOfTapsRequired = 1;
        cell.lblLocInfo.userInteractionEnabled = true;
        [cell.lblLocInfo addGestureRecognizer:gesture2];
        return cell;
    }
    
    

    return cell;
    
}

-(UITableViewCell*)configureCellForListAtPath:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"MediaList";
    ActionMediaListCell *cell = (ActionMediaListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [[cell btnVideoPlay]setHidden:true];
    [[cell btnAudioPlay]setHidden:true];
     cell.delegate = self;
    [cell.indicator stopAnimating];
    [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
    
    if (indexPath.row < arrDataSource.count) {
        id object = arrDataSource[indexPath.row];
        NSString *strFile;
        NSDictionary *mediaInfo;
        if ([object isKindOfClass:[NSString class]]) {
            
            //When Create
            
            strFile = (NSString*)arrDataSource[indexPath.row];
            cell.lblTitle.text = strFile;
            cell.imgMediaThumbnail.backgroundColor = [UIColor clearColor];
            NSString *fileName = arrDataSource[indexPath.row];
            if ([[fileName pathExtension] isEqualToString:@"jpeg"]) {
                //This is Image File with .png Extension , Photos.
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *imagePath = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                if (imagePath.length) {
                     [cell.indicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:imagePath];
                        UIImage *image = [UIImage imageWithData:data];
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            cell.imgMediaThumbnail.image = image;
                             [cell.indicator stopAnimating];
                        });
                    });
                    
                }
            }
            else if ([[fileName pathExtension] isEqualToString:@"mp4"]) {
                //This is Image File with .mp4 Extension , Video Files
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *imagePath = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                [[cell btnVideoPlay]setHidden:false];
                if (imagePath.length){
                    [cell.indicator startAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                        UIImage *thumbnail = [Utility getThumbNailFromVideoURL:imagePath];
                        dispatch_sync(dispatch_get_main_queue(), ^(void) {
                            cell.imgMediaThumbnail.image = thumbnail;
                              [cell.indicator stopAnimating];
                        });
                    });
                    cell.imgMediaThumbnail.image = [UIImage imageNamed:@"Video_Play_Button.png"];
                }
            }
            else if ([[fileName pathExtension] isEqualToString:@"aac"]){
                // Recorded Audio
                [cell.indicator startAnimating];
                [[cell btnAudioPlay]setHidden:false];
                cell.imgMediaThumbnail.image = [UIImage imageNamed:@"NoImage.png"];
                [cell.indicator stopAnimating];
            }

        }else{
            
            // When Edit
            
            mediaInfo = (NSDictionary*)arrDataSource[indexPath.row];
            cell.imgMediaThumbnail.backgroundColor = [UIColor clearColor];
            NSString *fileName;
            NSString *mediaType;
            if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                fileName = [mediaInfo objectForKey:@"gem_media"];
                cell.lblTitle.text = [fileName lastPathComponent];
            }
            if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                mediaType = [mediaInfo objectForKey:@"media_type"];
            }
            if ([mediaType isEqualToString:@"video"]) {
                [[cell btnVideoPlay]setHidden:false];
                if (NULL_TO_NIL([mediaInfo objectForKey:@"video_thumb"])) {
                    [cell.indicator startAnimating];
                    NSString *thumb = [mediaInfo objectForKey:@"video_thumb"];
                    [cell.imgMediaThumbnail sd_setImageWithURL:[NSURL URLWithString:thumb]
                                       placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                  [cell.indicator stopAnimating];
                                              }];
                }
                //This is Image File with .png Extension , Photos.
            }
            else if ([mediaType isEqualToString:@"audio"]) {
                 [cell.indicator startAnimating];
                [[cell btnAudioPlay]setHidden:false];
                 cell.imgMediaThumbnail.image = [UIImage imageNamed:@"NoImage.png"];
                 [cell.indicator stopAnimating];
                
            }
            else if ([mediaType isEqualToString:@"image"]){
               
                if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                    [cell.indicator startAnimating];
                    NSString *imageURL = [mediaInfo objectForKey:@"gem_media"];
                    [cell.imgMediaThumbnail sd_setImageWithURL:[NSURL URLWithString:imageURL]
                                              placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                         [cell.indicator stopAnimating];
                                                     }];
                }
                
            }
            
        }
        
        
    }
    
    cell.btnDelete.tag = indexPath.row;
    [cell.btnDelete addTarget:self action:@selector(deleteSelectedMedia:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}


-(void)playSelectedMediaWithIndex:(NSInteger)tag {
    
    if (tag < arrDataSource.count){
        
        // When Create
        
        id object = arrDataSource[tag];
        if ([object isKindOfClass:[NSString class]]) {
            NSString *fileName = arrDataSource[tag];
            if ([[fileName pathExtension] isEqualToString:@"jpeg"]) {
                //This is Image File with .png Extension , Photos.
                //NSString *filePath = [Utility getMediaSaveFolderPath];
                
            }
            else if ([[fileName pathExtension] isEqualToString:@"mp4"]) {
                //This is Image File with .mp4 Extension , Video Files
                NSError* error;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                [[AVAudioSession sharedInstance] setActive:NO error:&error];
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *path = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                NSURL  *videourl =[NSURL fileURLWithPath:path];
                AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                playerViewController.player = [AVPlayer playerWithURL:videourl];
                [playerViewController.player play];
                [self presentViewController:playerViewController animated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoDidFinish:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:[playerViewController.player currentItem]];
                
            }
            else if ([[fileName pathExtension] isEqualToString:@"aac"]){
                // Recorded Audio
                
                NSString *filePath = [Utility getMediaSaveFolderPath];
                NSString *path = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                NSURL  *audioURL = [NSURL fileURLWithPath:path];
                [self showAudioPlayerWithURL:audioURL];
                
            }

        }else{
            
             // When Edit
      
            
            NSDictionary *mediaInfo = (NSDictionary*)arrDataSource[tag];
            NSString *mediaURL;
            NSString *mediaType;
            if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                mediaURL = [mediaInfo objectForKey:@"gem_media"];
            }
            
            if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                mediaType = [mediaInfo objectForKey:@"media_type"];
            }
            if ([mediaType isEqualToString:@"video"]) {
                
                NSError* error;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                [[AVAudioSession sharedInstance] setActive:NO error:&error];
                AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
                 playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:mediaURL]];
                 [playerViewController.player play];
                [self presentViewController:playerViewController animated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(videoDidFinish:)
                                                             name:AVPlayerItemDidPlayToEndTimeNotification
                                                           object:[playerViewController.player currentItem]];
            }
            else if ([mediaType isEqualToString:@"audio"]) {
                
                NSURL  *audioURL = [NSURL URLWithString:mediaURL];
                [self showAudioPlayerWithURL:audioURL];
            }
            else if ([mediaType isEqualToString:@"image"]){
                
                
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



#pragma mark - UITextfield delegate methods


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero
                                                  toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero
                                                  toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        ActionMediaComposeCell *cell = (ActionMediaComposeCell*)textField.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:cell.txtTitle.tag data:textField.text];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height );
    
    [tableView setContentOffset:contentOffset animated:YES];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    
    indexForTextFieldNavigation = indexPath.row;
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    //[self createInputAccessoryView];
    //[textField setInputAccessoryView:inputAccView];
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height );
    [tableView setContentOffset:contentOffset animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return true;
}



#pragma mark - UITextView delegate methods


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    
    [self createInputAccessoryView];
    [textView setInputAccessoryView:inputAccView];
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    NSIndexPath *indexPath;
    if ([textView.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    indexForTextFieldNavigation = indexPath.row;
    contentOffset.y = (pointInTable.y - textView.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textView.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    if ([textView.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
    if ([textView.superview.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        ActionMediaComposeCell *cell = (ActionMediaComposeCell*)textView.superview.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:cell.txtDecsription.tag data:textView.text];
    }
    return YES;
}



- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!detector) {
        NSError *error = nil;
        detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                   error:&error];
    }
    /*
    if ([text isEqualToString:@" "] || [text isEqualToString:@""]) {
        NSArray *matches = [detector matchesInString:textView.text
                                             options:0
                                               range:NSMakeRange(0, [textView.text length])];
        if (matches.count > 0) {
            NSTextCheckingResult *match = [matches firstObject];
            [previewIndicator startAnimating];
            [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                if (error) {
                    vwURLPreview.hidden = true;
                    [previewIndicator stopAnimating];
                    lblPreviewTitle.text = @"";
                    lblPreviewDescription.text = @"";
                    lblPreviewTitle.text = @"";
                    lblPreviewDomain.text = @"";
                    imgPreview.image = nil;
                }else{
                    vwURLPreview.hidden = false;
                    [previewIndicator stopAnimating];
                    lblPreviewTitle.text = preview.title;
                    lblPreviewDescription.text = preview.content;
                    lblPreviewTitle.text = preview.title;
                    lblPreviewDomain.text = preview.domain;
                    [imgPreview sd_setImageWithURL:preview.imageURL
                                  placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         }];
                }
               
                
            }];
        }else{
            
            vwURLPreview.hidden = true;
            [previewIndicator stopAnimating];
            lblPreviewTitle.text = @"";
            lblPreviewDescription.text = @"";
            lblPreviewTitle.text = @"";
            lblPreviewDomain.text = @"";
            imgPreview.image = nil;
        }

    }*/
    if (textView.text) {
        
        NSArray *matches = [detector matchesInString:textView.text
                                             options:0
                                               range:NSMakeRange(0, [textView.text length])];
        if (matches.count > 0) {
            NSTextCheckingResult *match = [matches firstObject];
            if (![Utility isEquivalentURLOne:alreadyPreviewdURL URLTwo:[match URL]])showPreview = true;
            else showPreview = false;
            if (showPreview) {
                [previewIndicator startAnimating];
                [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                    if (error) {
                        vwURLPreview.hidden = true;
                        [previewIndicator stopAnimating];
                        lblPreviewTitle.text = @"";
                        lblPreviewDescription.text = @"";
                        lblPreviewTitle.text = @"";
                        lblPreviewDomain.text = @"";
                        imgPreview.image = nil;
                    }else{
                        alreadyPreviewdURL = [match URL];
                        vwURLPreview.hidden = false;
                        [previewIndicator stopAnimating];
                        lblPreviewTitle.text = preview.title;
                        lblPreviewDescription.text = preview.content;
                        lblPreviewTitle.text = preview.title;
                        lblPreviewDomain.text = preview.domain;
                        [imgPreview sd_setImageWithURL:preview.imageURL
                                      placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             }];
                    }
                    
                    
                }];
                
            }
            
        }else{
            
            vwURLPreview.hidden = true;
            [previewIndicator stopAnimating];
            lblPreviewTitle.text = @"";
            lblPreviewDescription.text = @"";
            lblPreviewDomain.text = @"";
            imgPreview.image = nil;
        }

    }
    
    
  
    if([text length] == 0)
    {
        if([textView.text length] != 0)
        {
            return YES;
        }
    }
    else if([[textView text] length] >= kMaxDescriptionLength)
    {
        return NO;
    }
    return YES;
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] || [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Common Methods

-(IBAction)hidePreviewPopUp:(id)sender{
    
    showPreview = false;
    vwURLPreview.hidden = true;
    [previewIndicator stopAnimating];
    lblPreviewTitle.text = @"";
    lblPreviewDescription.text = @"";
    lblPreviewTitle.text = @"";
    lblPreviewDomain.text = @"";
    imgPreview.image = nil;
}

-(IBAction)showPreviewDetailPage:(id)sender{
    if (lblPreviewDomain.text) {
        NSString *myURLString = lblPreviewDomain.text;
        NSURL *myURL;
        if ([myURLString.lowercaseString hasPrefix:@"http://"]) {
            myURL = [NSURL URLWithString:myURLString];
        } else {
            myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",myURLString]];
        }
        
        [[UIApplication sharedApplication] openURL:myURL];
    }
   
}

- (void)keyBoardShown:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    bottomForPreview.constant = keyboardFrameBeginRect.size.height;
}

- (void)keyboardDidHide:(NSNotification*)notification
{
   
    bottomForPreview.constant = -100;
    vwURLPreview.hidden = true;
    [previewIndicator stopAnimating];
    lblPreviewTitle.text = @"";
    lblPreviewDescription.text = @"";
    lblPreviewTitle.text = @"";
    lblPreviewDomain.text = @"";
    imgPreview.image = nil;
}




-(void)dragCell:(UILongPressGestureRecognizer *)panner
{
    if(panner.state == UIGestureRecognizerStateBegan)
    {
        viewStartLocation = [panner locationInView:tableView];
        tableView.scrollEnabled = NO;
        
        //if needed do some initial setup or init of views here
    }
    else if(panner.state == UIGestureRecognizerStateChanged)
    {
        //move your views here.
        if (! self.cellSnapshotView) {
            CGPoint loc = [panner locationInView:tableView];
            self.draggingCellIndexPath = [tableView indexPathForRowAtPoint:loc];
            if (self.draggingCellIndexPath.section == eSectionOne) return;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.draggingCellIndexPath];
            if (cell){
                
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
                [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                // create and image view that we will drag around the screen
                self.cellSnapshotView = [[UIImageView alloc] initWithImage:cellImage];
                
                //self.cellSnapshotView = [cell snapshotViewAfterScreenUpdates:YES];
                self.cellSnapshotView.alpha = 0.8;
                self.cellSnapshotView.layer.borderColor = [UIColor redColor].CGColor;
                self.cellSnapshotView.layer.borderWidth = 1;
                self.cellSnapshotView.frame =  cell.frame;
                [tableView addSubview:self.cellSnapshotView];
                
                //[tableView reloadRowsAtIndexPaths:@[self.draggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            // replace the cell with a blank one until the drag is over
        }
        
        CGPoint location = [panner locationInView:tableView];
        CGPoint translation;
        translation.x = location.x - viewStartLocation.x;
        translation.y = location.y - viewStartLocation.y;
        CGPoint cvCenter = self.cellSnapshotView.center;
        cvCenter.x = location.x;
        cvCenter.y = location.y;
        self.cellSnapshotView.center = cvCenter;
        
        
        
    }
    else if(panner.state == UIGestureRecognizerStateEnded || (panner.state == UIGestureRecognizerStateCancelled) || (panner.state == UIGestureRecognizerStateFailed))
    {
        tableView.scrollEnabled = YES;
        UITableViewCell *droppedOnCell;
        CGRect largestRect = CGRectZero;
        for (UITableViewCell *cell in tableView.visibleCells) {
            CGRect intersection = CGRectIntersection(cell.frame, self.cellSnapshotView.frame);
            if (intersection.size.width * intersection.size.height >= largestRect.size.width * largestRect.size.height) {
                largestRect = intersection;
                droppedOnCell =  cell;
            }
        }
        
        NSIndexPath *droppedOnCellIndexPath = [tableView indexPathForCell:droppedOnCell];
        if (droppedOnCellIndexPath.section == eSectionOne ) {
            [self.cellSnapshotView removeFromSuperview];
            self.cellSnapshotView = nil;
            return;
        }
        [UIView animateWithDuration:.2 animations:^{
            self.cellSnapshotView.center = droppedOnCell.center;
        } completion:^(BOOL finished) {
            [self.cellSnapshotView removeFromSuperview];
            self.cellSnapshotView = nil;
            NSIndexPath *savedDraggingCellIndexPath = self.draggingCellIndexPath;
            
            if (droppedOnCellIndexPath.section == eSectionOne ) return;
            if (savedDraggingCellIndexPath.section == eSectionOne ) return;
            
            if (![self.draggingCellIndexPath isEqual:droppedOnCellIndexPath]) {
                self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                [arrDataSource exchangeObjectAtIndex:savedDraggingCellIndexPath.row withObjectAtIndex:droppedOnCellIndexPath.row];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath, droppedOnCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
        tableView.scrollEnabled = YES;
        
    }
}

-(IBAction)showDatePicker:(id)sender{
    
    [self.view endEditing:YES];
    vwPickerOverLay.hidden = false;
    datePicker.date = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"yyyy-MM-dd"];
    strAchievementDate = [dateformater stringFromDate:datePicker.date];
}

-(IBAction)getSelectedDate{
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"yyyy-MM-dd"];
    strAchievementDate = [dateformater stringFromDate:datePicker.date];
}

-(IBAction)hidePicker:(id)sender{
    
    vwPickerOverLay.hidden = true;
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
}



-(IBAction)showStatusPicker:(id)sender{
    
    [self.view endEditing:YES];
    NSArray *options = @[@"Active",@"Completed"];
    [FTPopOverMenu showForSender:sender
                        withMenu:options
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           strStatus = @"Active";
                           if (selectedIndex == 1)strStatus = @"Completed";
                           dispatch_async(dispatch_get_main_queue(), ^{
                               NSRange range = NSMakeRange(0, 1);
                               NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
                               [tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
                           });
                           
                       } dismissBlock:^{
                           
                           
                       }];
}



-(void)setUpFooterMenuWithView:(UIView*)vwFooter{
    
    if (vwFooter) {
        vwFooter.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0];
        UIImageView *btnAudio = [UIImageView new];
        btnAudio.translatesAutoresizingMaskIntoConstraints = NO;
        [vwFooter addSubview:btnAudio];
       
        
        btnAudio.contentMode = UIViewContentModeScaleAspectFit;
        [btnAudio setImage:[UIImage imageNamed:@"Media_Audio.png"]];
        btnAudio.userInteractionEnabled = true;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(recordAudio:)];
        longPress.minimumPressDuration = .5;
        [btnAudio addGestureRecognizer:longPress];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToast)];
        gesture.numberOfTapsRequired = 1;
        [btnAudio addGestureRecognizer:gesture];
        
        
        UIButton *btnGallery = [UIButton buttonWithType:UIButtonTypeCustom];
        btnGallery.translatesAutoresizingMaskIntoConstraints = NO;
        [btnGallery setImage:[UIImage imageNamed:@"Media_Gallery.png"] forState:UIControlStateNormal];
        [btnGallery addTarget:self action:@selector(showGallery:) forControlEvents:UIControlEventTouchUpInside];
        [vwFooter addSubview:btnGallery];
        btnGallery.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIButton *btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCamera.translatesAutoresizingMaskIntoConstraints = NO;
        [btnCamera setImage:[UIImage imageNamed:@"Media_Camera.png"] forState:UIControlStateNormal];
        [btnCamera addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
        [vwFooter addSubview:btnCamera];
        btnCamera.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIButton *btnLoc = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLoc.translatesAutoresizingMaskIntoConstraints = NO;
        [btnLoc setImage:[UIImage imageNamed:@"Media_Location.png"] forState:UIControlStateNormal];
        [btnLoc addTarget:self action:@selector(showLocation:) forControlEvents:UIControlEventTouchUpInside];
        [vwFooter addSubview:btnLoc];
        btnLoc.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        
        UIButton *btnContact = [UIButton buttonWithType:UIButtonTypeCustom];
        btnContact.translatesAutoresizingMaskIntoConstraints = NO;
        [btnContact setImage:[UIImage imageNamed:@"Media_Contact.png"] forState:UIControlStateNormal];
        [btnContact addTarget:self action:@selector(showContacts:) forControlEvents:UIControlEventTouchUpInside];
        [vwFooter addSubview:btnContact];
        btnContact.imageView.contentMode = UIViewContentModeScaleAspectFit;

        [btnAudio addConstraint:[NSLayoutConstraint constraintWithItem:btnAudio
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0
                                                              constant:40]];
        
        [btnGallery addConstraint:[NSLayoutConstraint constraintWithItem:btnGallery
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:40]];
        
        [btnCamera addConstraint:[NSLayoutConstraint constraintWithItem:btnCamera
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:40]];
        
        [btnLoc addConstraint:[NSLayoutConstraint constraintWithItem:btnLoc
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1.0
                                                            constant:40]];
        
        [btnContact addConstraint:[NSLayoutConstraint constraintWithItem:btnContact
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1.0
                                                                constant:40]];
        
        [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnAudio attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:vwFooter attribute:NSLayoutAttributeBottom multiplier:1 constant:-5]];
        NSDictionary *views = NSDictionaryOfVariableBindings(btnAudio, btnGallery, btnCamera, btnLoc, btnContact);
        [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btnAudio][btnGallery(==btnAudio)][btnCamera(==btnAudio)][btnLoc(==btnAudio)][btnContact(==btnAudio)]|" options:NSLayoutFormatAlignAllBottom metrics:nil views:views]];
        
        
    }
    
    
}
-(void)getTextFromField:(NSInteger)type data:(NSString*)string{
    
    switch (type) {
        case eTitle:
            strTitle = string;
            break;
        case eDescription:
            strDescription = string;
            break;
        case eGoalDescription:
            strDescription = string;
            break;
        default:
            break;
    }
    
    
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha: 1];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(inputAccView.frame.size.width - 85, 1.0f, 80.0f, 38.0f)];
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor getThemeColor]];
     [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    btnDone.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [inputAccView addSubview:btnDone];
}

-(void)gotoPrevTextfield{
    
    if (indexForTextFieldNavigation - 1 < 0) indexForTextFieldNavigation = 0;
    else indexForTextFieldNavigation -= 1;
    [self gotoTextField];
    
}

-(void)gotoNextTextfield{
    
    if (indexForTextFieldNavigation + 1 < 2) indexForTextFieldNavigation += 1;
    [self gotoTextField];
}

-(void)gotoTextField{
    
    ActionMediaComposeCell *nextCell = (ActionMediaComposeCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
    if (!nextCell) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        nextCell = (ActionMediaComposeCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
        
    }
    if (indexForTextFieldNavigation == 0) {
        [nextCell.txtTitle becomeFirstResponder];
    }else{
        [nextCell.txtDecsription becomeFirstResponder];
    }
}

-(void)doneTyping{
    [self.view endEditing:YES];
    
}


#pragma mark - MENU actions




-(IBAction)recordAudio:(UILongPressGestureRecognizer*)gesture{
   if (gesture && gesture.view)
        [self recordMediaByView:gesture];
}


-(IBAction)showGallery:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"UPLOAD"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Video", @"Image", nil];
    actionSheet.tag = 0;
    
    [actionSheet showInView:self.view];
    [self.view endEditing:YES];
}


-(IBAction)showCamera:(id)sender{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"CAPTURE"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Video", @"Image", nil];
    actionSheet.tag = 1;
    
    [actionSheet showInView:self.view];
    [self.view endEditing:YES];
}


-(IBAction)showLocation:(id)sender{
    
    [self getNearBYLocations];
    [self.view endEditing:YES];
}


-(IBAction)showContacts:(id)sender{
    
    [self getAllContacts];
    [self.view endEditing:YES];
}

-(IBAction)createReminderWithGoalEndDate:(double)endDate{
    
    [self.view endEditing:YES];
    UINavigationController *nav = self.navigationController;
    EventCreateViewController *eventCreate =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForEventManager];
    eventCreate.goalID = goalActionID;
    eventCreate.strGoalTitle = strTitle;
    //eventCreate.achievementDate = endDate;
    eventCreate.strGoalDescription = strDescription;
    eventCreate.strRepeatValue = @"Never";
    
    [nav pushViewController:eventCreate animated:YES];
    NSArray* tempVCA = [self.navigationController viewControllers];
    for(UIViewController *tempVC in tempVCA)
    {
        if([tempVC isKindOfClass:[CreateActionInfoViewController class]])
            [tempVC removeFromParentViewController];
    }

}

#pragma mark - Record Audio actions

-(void)showToast{
    
    [self.view endEditing:YES];
    [ALToastView toastInView:self.view withText:@"Hold to record , Release to save."];
}

-(void)recordMediaByView:(UILongPressGestureRecognizer*)gesture{
    
    if (gesture.view) {
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            
            if (!vwRecordPopOver) {
                
                float xPadding = 10;
                float yPadding = 70;
                
                CGPoint point = [gesture.view.superview convertPoint:gesture.view.center toView:self.view];
                CGRect rect = CGRectMake(point.x - xPadding, point.y - yPadding, 100, 40);
                vwRecordPopOver = [AudioManagerView new];
                vwRecordPopOver.frame = rect;
                [self.view addSubview:vwRecordPopOver];
                [vwRecordPopOver setUp];
                [vwRecordPopOver startRecording];
                
            }
        }
        
        if ((gesture.state == UIGestureRecognizerStateCancelled) || (gesture.state == UIGestureRecognizerStateFailed) || (gesture.state ==UIGestureRecognizerStateEnded)) {
            
            [vwRecordPopOver stopRecording];
            [vwRecordPopOver removeFromSuperview];
            vwRecordPopOver = nil;
            [self reloadMediaLibraryTable];
            
        }
        
    }
    
}

#pragma mark - Gallery Video / Image actions

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 0) {
        
        // Show Gallery
        
        if (buttonIndex == 2)
            return;
        if (buttonIndex == 0){
           [self showPhotoGallery:NO];
        }else{
            [self showPhotoGallery:YES];
        }
    }else{
        
        // Show Video & Image Capture
        
        if (buttonIndex == 2)
            return;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera ]) {
            
            UIImagePickerController *picker= [[UIImagePickerController alloc] init];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage,nil];
            [picker setDelegate:self];
            if (buttonIndex == 0){
                picker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,nil];
            }
            [self presentViewController:picker animated:YES completion:nil];
        }
        
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
     [self.view showActivityView];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        [self compressVideoWithURL:[info objectForKey:UIImagePickerControllerMediaURL] onComplete:^(bool completed) {
            if (completed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideActivityView];
                    [self reloadMediaLibraryTable];
                });
            }
        }];
    }else{
        [self.view hideActivityView];
        UIImage *image =[Utility fixrotation:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
        [GalleryManager saveSelectedImageFileToFolderWithImage:image];
        [self reloadMediaLibraryTable];
        
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}



-(void)compressVideoWithURL:(NSURL*)videoURL onComplete:(void (^)(bool completed))completed{
   
//    AVAssetTrack *videoTrack = nil;
//    AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
//    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
//    CMFormatDescriptionRef formatDescription = NULL;
//    NSArray *formatDescriptions = [videoTrack formatDescriptions];
//    if ([formatDescriptions count] > 0)
//        formatDescription = (__bridge CMFormatDescriptionRef)[formatDescriptions objectAtIndex:0];
//    
//    if ([videoTracks count] > 0)
//        videoTrack = [videoTracks objectAtIndex:0];
//    
//    CGSize trackDimensions = {
//        .width = 0.0,
//        .height = 0.0,
//    };
//    trackDimensions = [videoTrack naturalSize];
//    int width = trackDimensions.width;
//    int height = trackDimensions.height;
//    NSLog(@"Resolution = %d X %d",width ,height);
//    float bps = [videoTrack estimatedDataRate];
//    NSString *bitRate = [NSString stringWithFormat:@"%f",bps];
//    if (bps > 500000) {
//       // bitRate = [NSString stringWithFormat:@"%d",500000];
//    }
    
   
    
    NSURL *outputURL = [NSURL fileURLWithPath:[GalleryManager getPathWhereVideoNeedsToBeSaved]];
    SDAVAssetExportSession *encoder = [SDAVAssetExportSession.alloc initWithAsset:[AVAsset assetWithURL:videoURL]];
    NSURL *url = outputURL;
    encoder.outputURL=url;
    encoder.outputFileType = AVFileTypeMPEG4;
    encoder.shouldOptimizeForNetworkUse = YES;
    encoder.videoSettings = @
    {
    AVVideoCodecKey: AVVideoCodecH264,
    AVVideoWidthKey:[NSNumber numberWithInteger:360], // required
    AVVideoHeightKey:[NSNumber numberWithInteger:480], // required
    AVVideoCompressionPropertiesKey: @
        {
        AVVideoAverageBitRateKey: @500000, // Lower bit rate here
        AVVideoProfileLevelKey: AVVideoProfileLevelH264High40,
        },
    };
    
    encoder.audioSettings = @
    {
    AVFormatIDKey: @(kAudioFormatMPEG4AAC),
    AVNumberOfChannelsKey: @2,
    AVSampleRateKey: @44100,
    AVEncoderBitRateKey: @128000,
    };
    
    [encoder exportAsynchronouslyWithCompletionHandler:^
     {
         int status = encoder.status;
         if (status == AVAssetExportSessionStatusCompleted)
         {
             
             
         }
         else if (status == AVAssetExportSessionStatusCancelled)
         {
             NSLog(@"Video export cancelled");
         }
         else
         {
         }
         
         completed(YES);
     }];
}

- (void)convertVideoToLowQuailtyWithInputURL:(NSURL*)inputURL
                                   outputURL:(NSURL*)outputURL
                                     handler:(void (^)(AVAssetExportSession*))handler
{
    [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetLowQuality];
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
         handler(exportSession);
     }];
}

#pragma mark - Get NearBy Location actions

-(void)getNearBYLocations{
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001,
                                                                  center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001,
                                                                  center.longitude - 0.001);
    
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    GMSPlacePicker * _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        float latitude = place.coordinate.latitude;
        float longitude = place.coordinate.longitude;
        locationCordinates = CLLocationCoordinate2DMake(latitude, longitude);
        
        if (place != nil) {
            strLocationName = place.name;
//            strLocationAddress = [[place.formattedAddress
//                                       componentsSeparatedByString:@", "] componentsJoinedByString:@"\n"];
            
            strLocationAddress = place.formattedAddress ;
        } else {
           // self.nameLabel.text = @"No place selected";
           // self.addressLabel.text = @"";
        }
        
        [tableView reloadData];
    }];
    
}

#pragma mark - Get All Contact Details

- (void)getAllContacts {
    
    ContactsPickerViewController *picker =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForContactsPickerVC];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person{
    
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty) ;
    
    [strContactName appendString:[NSString stringWithFormat:@"%@,",firstName]] ;
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        [tableView reloadData];
    }];
}

-(void)pickedContactsList:(NSMutableArray*)lists{
    NSMutableArray *names = [NSMutableArray new];
    for (NSDictionary *dict in lists) {
        if ([[dict objectForKey:@"isSelected"] boolValue]) {
            if ([dict objectForKey:@"name"]) {
                [names addObject:[dict objectForKey:@"name"]];
            }
        }
    }
    if (names.count) strContactName = [NSMutableString stringWithString:[names componentsJoinedByString:@","]];
    
   
    [tableView reloadData];
}

#pragma mark -  Edit A Gem or Add Action under A Goal

-(void)getMediaDetailsForGemsToBeEditedWithGEMID:(NSString*)_gemID GEMType:(NSString*)_gemType{
        
    gemID = _gemID;
    gemType = _gemType;
    [self showLoadingScreen];
    [APIMapper getGemDetailsForEditWithGEMID:_gemID gemType:_gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        [self parseResponds:responseObject];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
    }];
}

-(void)parseResponds:(NSDictionary*)responds{
    
    if (responds) {
        
        if (NULL_TO_NIL([responds objectForKey:@"resultarray"])) {
            
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"contact_name"])) {
                [strContactName appendString:[NSString stringWithFormat:@"%@,",[[responds objectForKey:@"resultarray"] objectForKey:@"contact_name"]]];
            }
            
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"details"])) {
                strDescription = [[responds objectForKey:@"resultarray"] objectForKey:@"details"];
            }
            
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"goal_enddate"])) {
                double date = [[[responds objectForKey:@"resultarray"] objectForKey:@"goal_enddate"] doubleValue];
                if (date > 0) {
                     strAchievementDate = [Utility getDateStringFromSecondsWith:[[[responds objectForKey:@"resultarray"] objectForKey:@"goal_enddate"] doubleValue] withFormat:@"yyyy-MM-dd"] ;
                }
                
               
            }
            
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"goal_status"])) {
                strStatus = @"Active";
                if ([[[responds objectForKey:@"resultarray"] objectForKey:@"goal_status"] integerValue] == 1) {
                    strStatus = @"Completed";
                }
            }
                        
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"location_address"])) {
                strLocationAddress = [[responds objectForKey:@"resultarray"] objectForKey:@"location_address"];
            }
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"location_name"])) {
                strLocationName = [[responds objectForKey:@"resultarray"] objectForKey:@"location_name"];
            }
            
            float latitude = 0;
            float longitude = 0;
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"location_latitude"])) {
                latitude = [[[responds objectForKey:@"resultarray"] objectForKey:@"location_latitude"] floatValue];
            }
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"location_longitude"])) {
                longitude = [[[responds objectForKey:@"resultarray"] objectForKey:@"location_longitude"] floatValue];
            }
            locationCordinates = CLLocationCoordinate2DMake(latitude, longitude);
            
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"title"])) {
                strTitle = [[responds objectForKey:@"resultarray"] objectForKey:@"title"];
            }
            
            if (NULL_TO_NIL([[responds objectForKey:@"resultarray"] objectForKey:@"goal_media"])) {
                NSArray *medias = [[responds objectForKey:@"resultarray"] objectForKey:@"goal_media"];
                for (NSDictionary *dict in medias) {
                    [arrDataSource addObject:dict];
                }
            }
        }
        
    }
    
    [tableView reloadData];
    
   
}




#pragma mark - GENERIC actions

#pragma mark - Photo Browser & Deleagtes

- (void)presentGalleryWithImages:(NSArray*)images
{
    [self.view endEditing:YES];
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


-(void)reloadMediaLibraryTable{
    
    NSMutableArray *mediaForEdit = [NSMutableArray new];
    for (id object in arrDataSource) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [mediaForEdit addObject:object];
        }
        
    }
    [arrDataSource removeAllObjects];
    for (NSDictionary *dict in mediaForEdit) {
        [arrDataSource addObject:dict];
    }
    [self getAllMediaFiles];
    [tableView reloadData];
    [self.view hideActivityView];
}


-(void)getAllMediaFiles{

    NSString *dataPath = [Utility getMediaSaveFolderPath];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:NULL];
    NSError* error = nil;
    // sort by creation date
    NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[directoryContent count]];
    for(NSString* file in directoryContent) {
        
        if (![file isEqualToString:@".DS_Store"]) {
            NSString* filePath = [dataPath stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                        attributesOfItemAtPath:filePath
                                        error:&error];
            NSDate* modDate = [properties objectForKey:NSFileCreationDate];
            
            [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           file, @"path",
                                           modDate, @"lastModDate",
                                           nil]];
            
        }
    }
    // sort using a block
    // order inverted as we want latest date first
    NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                            ^(id path1, id path2)
                            {
                                // compare
                                NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                           [path2 objectForKey:@"lastModDate"]];
                                // invert ordering
                                if (comp == NSOrderedDescending) {
                                    comp = NSOrderedAscending;
                                }
                                else if(comp == NSOrderedAscending){
                                    comp = NSOrderedDescending;
                                }
                                return comp;
                            }];
    
    for (NSInteger i = sortedFiles.count - 1; i >= 0; i --) {
        NSDictionary *dict = sortedFiles[i];
        [arrDataSource insertObject:[dict objectForKey:@"path" ] atIndex:0];
    }

}

-(void)deleteSelectedMedia:(UIButton*)btnDelete{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete"
                                  message:@"Delete the selected media ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (btnDelete.tag < arrDataSource.count) {
                                 id object = arrDataSource[btnDelete.tag];
                                 if ([object isKindOfClass:[NSString class]]) {
                                     // Created medias
                                     NSString *fileName = arrDataSource[btnDelete.tag];
                                     [self removeAMediaFileWithName:fileName];
                                 }else{
                                     //Editing medias
                                     NSDictionary *media = [arrDataSource objectAtIndex:btnDelete.tag];
                                     if ([media objectForKey:@"media_id"])
                                         [arrDeletedIDs addObject:[media objectForKey:@"media_id"]];
                                     [arrDataSource removeObjectAtIndex:btnDelete.tag];
                                     [self reloadMediaLibraryTable];
                                     
                                 }
                                 
                             }
      
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)removeAMediaFileWithName:(NSString *)filename
{
    NSString *dataPath = [Utility getMediaSaveFolderPath];
    NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success){
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    [self reloadMediaLibraryTable];
}

-(void)removeAllContentsInMediaFolder{
    
    NSString *dataPath = [Utility getMediaSaveFolderPath];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager removeItemAtPath:dataPath error:&error];
    if (success){
        
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }

}

-(IBAction)resetContactInfo{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                   message:@"Delete Contact Info ?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [strContactName setString:@""];
                                                              NSRange range = NSMakeRange(0, 1);
                                                              NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                                                              [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
                                                          }];
    UIAlertAction *second = [UIAlertAction actionWithTitle:@"CANCEL"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                        }];
    
    [alert addAction:firstAction];
    [alert addAction:second];
    
    UINavigationController *nav =self.navigationController;;
    [nav presentViewController:alert animated:YES completion:nil];
    
    
}

-(IBAction)resetLocationInfo{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                   message:@"Delete Location Info ?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              strLocationName = @"";
                                                              NSRange range = NSMakeRange(0, 1);
                                                              NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                                                              [tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
                                                              }];
    
    UIAlertAction *second = [UIAlertAction actionWithTitle:@"CANCEL"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         
                                                     }];
    
    [alert addAction:firstAction];
    [alert addAction:second];
    
   UINavigationController *nav = self.navigationController;;
    [nav presentViewController:alert animated:YES completion:nil];
    
    
}

-(IBAction)submit:(id)sender{
    
    [self.view endEditing:YES];
    [self checkAllFieldsAreValid:^{
        
        NSInteger actionType = 0;
        actionType = _actionType;
        switch (actionType) {
            case eActionTypeEvent:
                [self createOrUpdateAnEvent];
                break;
                
            case eActionTypeGoalsAndDreams:
                [self createOrUpdateGoalsAndDreams];
                break;
                
            case eActionTypeActions:
                [self createNewActions];
                break;
                
            case eActionTypeShare:
                [self shareGEMToPurposeColor];
                break;
                
            case eActionTypeCommunity:
                [self createOrUpdateAGenericPost];
                break;
                
                
            default:
                break;
        }
        
    } failure:^(NSString *errorMsg) {
        [ALToastView toastInView:self.view withText:@"Please fill all the Fields"];
    }];
  
   
    
}

-(void)checkAllFieldsAreValid:(void (^)())success failure:(void (^)())failure{
    
    BOOL isValid = false;
    NSString *errorMsg;
    if (_actionType == eActionTypeCommunity) {
        
        if (([strDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) > 0) {
            isValid = true;
        }else{
            
            isValid = false;
        }
    }else{
        
        if (([strTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) && ([strDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) > 0) {
            isValid = true;
            if (_actionType == eActionTypeGoalsAndDreams) {
                isValid = false;
                if (([strAchievementDate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) && ([strStatus stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)){
                    isValid = true;
                }
            }
            
        }else{
            
            isValid = false;
        }
    }
   
    if (isValid)success();
    else failure(errorMsg);
    
}


#pragma mark - Submit Medias for Event , Goals , Actions Etc..

-(void)createOrUpdateAnEvent{
    
    [APIMapper createOrEditAGemWith:arrDataSource eventTitle:strTitle description:strDescription latitude:locationCordinates.latitude longitude:locationCordinates.longitude locName:strLocationName address:strLocationAddress contactName:strContactName gemID:gemID goalID:_strGoalID deletedIDs:arrDeletedIDs gemType:@"event" OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        vwProgressOverLay.hidden = true;
        [_circleProgressBar setProgress:0 animated:YES];
        if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode ){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                           message:[responseObject objectForKey:@"text"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      if ([self.delegate respondsToSelector:@selector(eventCreatedWithEvenTitle:eventID:)]) {
                                                                          [self.delegate eventCreatedWithEvenTitle:strTitle eventID:[[responseObject objectForKey:@"id"] integerValue]];
                                                                      }
                                                                      [self goBack:nil];
                                                                      
                                                                  }];
            
            [alert addAction:firstAction];
            
            UINavigationController *nav = self.navigationController;
            [nav presentViewController:alert animated:YES completion:nil];
        }else{
            
            if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                
                if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lblTitle.text
                                                                        message:[responseObject objectForKey:@"text"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegate clearUserSessions];
                    
                }
                
            }else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                               message:[responseObject objectForKey:@"text"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          
                                                                          
                                                                      }];
                
                [alert addAction:firstAction];
                UINavigationController *nav = self.navigationController;
                [nav presentViewController:alert animated:YES completion:nil];

            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  vwProgressOverLay.hidden = true;
                                                                  [_circleProgressBar setProgress:0 animated:YES];
                                                                  
                                                              }];
        
        [alert addAction:firstAction];
        UINavigationController *nav = self.navigationController;
        [nav presentViewController:alert animated:YES completion:nil];
        
    } progress:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        vwProgressOverLay.hidden = false;
        float percentage = (totalBytesWritten * 100)/totalBytesExpectedToWrite;
        float progress = percentage/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_circleProgressBar setProgress:progress animated:YES];
        });
        
    }];
}

-(void)createOrUpdateAGenericPost{
    
    [APIMapper createOrEditAGemWith:arrDataSource eventTitle:strTitle description:strDescription latitude:locationCordinates.latitude longitude:locationCordinates.longitude locName:strLocationName address:strLocationAddress contactName:strContactName gemID:gemID goalID:_strGoalID deletedIDs:arrDeletedIDs gemType:@"community" OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        vwProgressOverLay.hidden = true;
        [_circleProgressBar setProgress:0 animated:YES];
        if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode ){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                           message:[responseObject objectForKey:@"text"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      if ([self.delegate respondsToSelector:@selector(newPostCreatedWithPostTitle:postID:)]) {
                                                                          [self.delegate newPostCreatedWithPostTitle:strTitle postID:[[responseObject objectForKey:@"id"] integerValue]];
                                                                         
                                                                      }
                                                                      [self goBack:nil];
                                                                      
                                                                  }];
            
            [alert addAction:firstAction];
            
            UINavigationController *nav = self.navigationController;
            [nav presentViewController:alert animated:YES completion:nil];
        }else{
            
            if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                
                if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lblTitle.text
                                                                        message:[responseObject objectForKey:@"text"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegate clearUserSessions];
                    
                }
                
            }else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                               message:[responseObject objectForKey:@"text"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          
                                                                          
                                                                      }];
                
                [alert addAction:firstAction];
                UINavigationController *nav = self.navigationController;
                [nav presentViewController:alert animated:YES completion:nil];
                
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  vwProgressOverLay.hidden = true;
                                                                  [_circleProgressBar setProgress:0 animated:YES];
                                                                  
                                                              }];
        
        [alert addAction:firstAction];
        UINavigationController *nav = self.navigationController;
        [nav presentViewController:alert animated:YES completion:nil];
        
    } progress:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        vwProgressOverLay.hidden = false;
        float percentage = (totalBytesWritten * 100)/totalBytesExpectedToWrite;
        float progress = percentage/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_circleProgressBar setProgress:progress animated:YES];
        });
        
    }];
}

-(void)createOrUpdateGoalsAndDreams{
    
    NSString *dateString = strAchievementDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    dateFromString = [dateFormatter dateFromString:dateString];
    double achievementDate = [dateFromString timeIntervalSince1970];
    
    [APIMapper createOrEditAGoalWith:arrDataSource eventTitle:strTitle description:strDescription latitude:locationCordinates.latitude longitude:locationCordinates.longitude locName:strLocationName address:strLocationAddress contactName:strContactName gemID:gemID goalID:_strGoalID deletedIDs:arrDeletedIDs gemType:@"goal" achievementDate:achievementDate status:strStatus isPurposeColor:_isPurposeColorGEM OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            vwProgressOverLay.hidden = true;
            [_circleProgressBar setProgress:0 animated:YES];
            if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode ){
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                               message:[responseObject objectForKey:@"text"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          if ([self.delegate respondsToSelector:@selector(goalsAndDreamsCreatedWithGoalTitle:goalID:)]) {
                                                                              [self.delegate goalsAndDreamsCreatedWithGoalTitle:strTitle goalID:[[responseObject objectForKey:@"id"] integerValue]];
                                                                          }
                                                                          [self goBack:nil];
                                                                          
                                                                      }];
                
                [alert addAction:firstAction];
                UINavigationController *nav = self.navigationController;
                [nav presentViewController:alert animated:YES completion:nil];
            }else{
                
                if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                    
                    if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lblTitle.text
                                                                            message:[responseObject objectForKey:@"text"]
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        [delegate clearUserSessions];
                        
                    }
                    
                }else{
                    
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                                   message:[responseObject objectForKey:@"text"]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                              
                                                                              
                                                                          }];
                    
                    [alert addAction:firstAction];
                    UINavigationController *nav = self.navigationController;
                    [nav presentViewController:alert animated:YES completion:nil];
                }
               
            }
            
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                           message:[error localizedDescription]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      vwProgressOverLay.hidden = true;
                                                                      [_circleProgressBar setProgress:0 animated:YES];
                                                                      
                                                                  }];
            
            [alert addAction:firstAction];
            UINavigationController *nav = self.navigationController;
            [nav presentViewController:alert animated:YES completion:nil];
            
            
        } progress:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            vwProgressOverLay.hidden = false;
            float percentage = (totalBytesWritten * 100)/totalBytesExpectedToWrite;
            float progress = percentage/100;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_circleProgressBar setProgress:progress animated:YES];
            });
            
        }];
        
    
}

-(void)createNewActions{
    
    [APIMapper createOrEditAGemWith:arrDataSource eventTitle:strTitle description:strDescription latitude:locationCordinates.latitude longitude:locationCordinates.longitude locName:strLocationName address:strLocationAddress contactName:strContactName gemID:gemID goalID:_strGoalID deletedIDs:arrDeletedIDs gemType:@"action" OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        vwProgressOverLay.hidden = true;
        [_circleProgressBar setProgress:0 animated:YES];
        if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode ){
            
            UINavigationController *nav = self.navigationController;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                           message:[NSString stringWithFormat:@"%@ Create a Reminder for this Action?",[responseObject objectForKey:@"text"]]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"NO"
                                                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                       if ([self.delegate respondsToSelector:@selector(newActionCreatedWithActionTitle:actionID:)]) {
                                                                           [self.delegate newActionCreatedWithActionTitle:strTitle actionID:[[responseObject objectForKey:@"id"] integerValue]];
                                                                       }
                                                                       [self goBack:nil];
                                                                       
                                                                   }];
            
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      
                                                                      if ([self.delegate respondsToSelector:@selector(newActionCreatedWithActionTitle:actionID:)]) {
                                                                          [self.delegate newActionCreatedWithActionTitle:strTitle actionID:[[responseObject objectForKey:@"id"] integerValue]];
                                                                      }
                                                                      goalActionID = [[responseObject objectForKey:@"id"] integerValue];
                                                                      
                                                                     // if (NULL_TO_NIL([responseObject objectForKey:@"goal_enddate"])) {
                                                                          [self createReminderWithGoalEndDate:0];
                                                                     // }
                                                                      
                                                                     
                                                                      
                                                                  }];
            
           
            
            
            [alert addAction:secondAction];
            [alert addAction:firstAction];
            [nav presentViewController:alert animated:YES completion:nil];
            
        }else{
            
            if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                
                if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lblTitle.text
                                                                        message:[responseObject objectForKey:@"text"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegate clearUserSessions];
                    
                }
                
            }else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                               message:[responseObject objectForKey:@"text"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          
                                                                          
                                                                      }];
                
                [alert addAction:firstAction];
                UINavigationController *nav = self.navigationController;
                [nav presentViewController:alert animated:YES completion:nil];
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  vwProgressOverLay.hidden = true;
                                                                  [_circleProgressBar setProgress:0 animated:YES];
                                                                  
                                                              }];
        
        [alert addAction:firstAction];
        UINavigationController *nav = self.navigationController;
        [nav presentViewController:alert animated:YES completion:nil];
        
        
    } progress:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        vwProgressOverLay.hidden = false;
        float percentage = (totalBytesWritten * 100)/totalBytesExpectedToWrite;
        float progress = percentage/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_circleProgressBar setProgress:progress animated:YES];
        });
        
    }];
}

-(void)shareGEMToPurposeColor{
    
    [APIMapper shareGEMToPurposeColorWith:arrDataSource eventTitle:strTitle description:strDescription latitude:locationCordinates.latitude longitude:locationCordinates.longitude locName:strLocationName address:strLocationAddress contactName:strContactName gemID:gemID deletedIDs:arrDeletedIDs gemType:gemType OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        vwProgressOverLay.hidden = true;
        [_circleProgressBar setProgress:0 animated:YES];
        if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode ){
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SHARE"
                                                                           message:[responseObject objectForKey:@"text"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                     
                                                                      [self goBack:nil];
                                                                      
                                                                  }];
            
            [alert addAction:firstAction];
            UINavigationController *nav = self.navigationController;
            [nav presentViewController:alert animated:YES completion:nil];
        }
        else{
            
            if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                
                if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:lblTitle.text
                                                                        message:[responseObject objectForKey:@"text"]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delegate clearUserSessions];
                    
                }
                
            }
        }
        
        

        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:lblTitle.text
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  vwProgressOverLay.hidden = true;
                                                                  [_circleProgressBar setProgress:0 animated:YES];
                                                              }];
        
        [alert addAction:firstAction];
        UINavigationController *nav = self.navigationController;
        [nav presentViewController:alert animated:YES completion:nil];
        
        
    } progress:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        vwProgressOverLay.hidden = false;
        float percentage = (totalBytesWritten * 100)/totalBytesExpectedToWrite;
        float progress = percentage/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_circleProgressBar setProgress:progress animated:YES];
        });
        
    }];
}


#pragma mark - Photo Gallery

-(IBAction)showPhotoGallery:(BOOL)isPhoto
{
    CustomeImagePicker *cip = [[CustomeImagePicker alloc] init];
    cip.delegate = self;
    cip.isPhotos = isPhoto;
    [cip setHideSkipButton:NO];
    [cip setHideNextButton:NO];
    [cip setMaxPhotos:MAX_ALLOWED_PICK];
    
    [self presentViewController:cip animated:YES completion:^{
    }];
}

-(void)imageSelected:(NSArray*)arrayOfGallery isPhoto:(BOOL)isPhoto;
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view showActivityView];
        }); // Main Queue to Display the Activity View
        __block NSInteger imageCount = 0;
        __block NSInteger videoCount = 0;
        
        for(NSString *imageURLString in arrayOfGallery)
        {
            // Asset URLs
            ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
            [assetsLibrary assetForURL:[NSURL URLWithString:imageURLString] resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                if (isPhoto) {
                    
                    // IMAGE
                    
                    CGImageRef imageRef = [representation fullScreenImage];
                    UIImage *image = [UIImage imageWithCGImage:imageRef];
                    if (imageRef) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [GalleryManager saveSelectedImageFileToFolderWithImage:image];
                        });
                        imageCount ++;
                        
                        if (imageCount + videoCount == arrayOfGallery.count) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self performSelector:@selector(reloadMediaLibraryTable) withObject:self afterDelay:1];
                            });
                        }
                    }
                }else{
                    
                    //VIDEO
                    
                        [self compressVideoWithURL:[NSURL URLWithString:imageURLString] onComplete:^(bool completed) {
                        
                        if (completed) {
                            
                            videoCount ++;
                            
                            if (imageCount + videoCount == arrayOfGallery.count) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self performSelector:@selector(reloadMediaLibraryTable) withObject:self afterDelay:1];
                                });
                            }
                        }
                    }];
                    
                    
                }
                
                
                // Valid Image URL
            } failureBlock:^(NSError *error) {
            }];
        } // All Images I got
        
       
    });
    
   
}
-(void) imageSelectionCancelled
{
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeAllContentsInMediaFolder];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

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
