//
//  EmotionalAwarenessViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 20/03/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

typedef enum{
    
    eTypeEvent = -1,
    eTypeFeel = 0,
    eTypeEmotion = 1,
    eTypeDrive = 2,
    eTypeGoalsAndDreams = 3,
    eTypeAction = 4,
    eTypeDate = 5
    
}ESelectedMenuType;

#define kSectionCount               2
#define kDefaultCellHeight          95
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kWidthPadding               115
#define kFollowHeightPadding        85
#define kOthersHeightPadding        20

#import "EmotionalAwarenessViewController.h"
#import "CellForEventDisplay.h"
#import "CellForMenus.h"
#import "SelectYourEvent.h"
#import "EventTitleCell.h"
#import "EventDescriptionCell.h"

#import "Constants.h"
#import "AudioManagerView.h"
#import "GalleryManager.h"
#import "UIView+RNActivityView.h"
#import "CustomeImagePicker.h"
#import "CustomAudioPlayerView.h"
#import <AVKit/AVKit.h>
#import "UITextView+Placeholder.h"
#import "PhotoBrowser.h"
#import "SDAVAssetExportSession.h"
#import "ContactsPickerViewController.h"
#import "ActionMediaListCell.h"
#import "SelectYourFeel.h"
#import "SelectYourEmotion.h"
#import "SelectYourDrive.h"
#import "SelectYourGoalsAndDreams.h"
#import "SelectActions.h"
#import "CellForContactAndLoc.h"
#import "AMPopTip.h"
#import "AwarenessHeader.h"
#import "SelectedValue_1.h"
#import "SelectedValue_2.h"
#import "AwarenessMediaViewController.h"

@import GooglePlacePicker;

@interface EmotionalAwarenessViewController () <SelectYourEventDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomeImagePickerDelegate,CLLocationManagerDelegate,ContactPickerDelegate,ActionInfoCellDelegate,PhotoBrowserDelegate,CustomAudioPlayerDelegate,SelectYourFeelingDelegate,SelectYourEmotionDelegate,SelectYourDriveDelegate,SelectYourGoalsAndDreamsDelegate,SelectYourActionsDelegate,UIGestureRecognizerDelegate,UITextViewDelegate,AwarenessMediaDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UITableView *tableView_Menu;
    IBOutlet NSLayoutConstraint *tableHeight;
    IBOutlet UIView *vwMediaMenuOverLay;
    IBOutlet UIButton *btnAudioRecorder;
    IBOutlet UIButton *btnPost;
    IBOutlet UILabel *lblMenuName;

    UIView *inputAccView;
    
    BOOL shouldHideMenus;
    BOOL isCycleCompleted;
    NSInteger menuCount;
    NSInteger requiredCellCount;
    NSMutableArray *arrDataSource;
    NSMutableArray *arrDeletedIDs;
    NSMutableArray *arrFeelImages;
    NSMutableArray *arrDriveImages;
    NSMutableDictionary *dictSelectedSteps;
    NSMutableDictionary *dictSuccessSteps;
    ESelectedMenuType nextActiveMenu;
    
    SelectYourEvent *vwEventSelection;
    NSString  *eventTitle;
    NSInteger eventValue;
    NSInteger selectedEventValue;
    CGPoint viewStartLocation;
    
    SelectYourFeel *vwFeelSelection;
    NSInteger selectedFeelValue;
    
    SelectYourEmotion *vwEmotionSelection;
    NSString  *selectedEmotionTitle;
    NSInteger selectedEmotionValue;
    
    SelectYourDrive *vwDriveSelection;
    NSInteger selectedDriveValue;
    
    SelectYourGoalsAndDreams *vwGoalsSelection;
    NSString  *selectedGoalsTitle;
    NSInteger selectedGoalsValue;
    
    SelectActions *vwActions;
    NSString  *selectedActionTitle;
    NSDictionary* selectedActions;

    NSString  *strDescription;
    
    CLLocationManager* locationManager;
    CLLocationCoordinate2D locationCordinates;
    NSString *strLocationAddress;
    NSString *strLocationName;
    NSMutableString *strContactName;
    
    AudioManagerView *vwRecordPopOver;
    PhotoBrowser *photoBrowser;
    CustomAudioPlayerView *vwAudioPlayer;
    AMPopTip *popTip;
    
     NSString *strDate;
    IBOutlet UIView *vwPickerOverLay;
    IBOutlet UIDatePicker *datePicker;
    
    
}

@property (nonatomic,strong) NSIndexPath *draggingCellIndexPath;
@property (nonatomic,strong) UIView *cellSnapshotView;

@end

@implementation EmotionalAwarenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getCurrentUserLocation];
    [self removeAllContentsInMediaFolder];
    [self getCurrentDate];
    [self createInputAccessoryView];
   // if (_shouldOpenFirstMenu) [self performSelector:@selector(showEventSelectionView) withObject:self afterDelay:0.7];
    
        // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated{
   
    [tableView reloadData];
}



-(void)setUp{
    
    
    nextActiveMenu = -1;
    menuCount = 4;
    
    btnPost.layer.cornerRadius = 5.f;
    btnPost.layer.borderColor = [UIColor whiteColor].CGColor;
    btnPost.layer.borderWidth = 1.f;
    btnPost.enabled = false;
    btnPost.alpha = 0.3;
    
    isCycleCompleted = false;
    dictSelectedSteps = [NSMutableDictionary new];
    dictSuccessSteps = [NSMutableDictionary new];
    tableView.estimatedRowHeight = 100;
    shouldHideMenus = false;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    arrDataSource = [NSMutableArray new];
    arrDeletedIDs = [NSMutableArray new];
    arrFeelImages = [[NSMutableArray alloc] initWithObjects:@"Strongly_Agree_Blue",@"Agree_Blue",@"Neutral_Blue",@"Disagree_Blue",@"Strongly_DisAgree_Blue", nil];
    arrDriveImages = [[NSMutableArray alloc] initWithObjects:@"5_Star_Filled",@"4_Star_Filled",@"3_Star_Filled",@"2_Star_Filled",@"1_Star_Filled", nil];
    requiredCellCount = 4;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordMediaByView:)];
    longPress.minimumPressDuration = .5;
    [btnAudioRecorder addGestureRecognizer:longPress];
    
    

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    
    if (_tableView == tableView_Menu) {
        return 1;
    }
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tableView == tableView_Menu) {
        if (isCycleCompleted) {
            return 5;
        }
        return 4;
    }
    
    if (section == 0) {
        return requiredCellCount;
    }
    if (section == 1) {
        NSInteger count = 0;
        if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]]  || [dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]]) {
            count += 1;
            
        }
        if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]] ||  [dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]] ||[dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeAction]]) {
            count += 1;
        }
        return count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"SectionOnePlaceHolder";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (aTableView == tableView_Menu) {
        
        if (indexPath.row == 4) {
            static NSString *CellIdentifier = @"CellForDate";
            UITableViewCell *cell = (UITableViewCell*)[tableView_Menu dequeueReusableCellWithIdentifier:CellIdentifier];
            if ([[cell contentView] viewWithTag:1]) {
                UILabel *lblDate = (UILabel*)[[cell contentView] viewWithTag:1];
                lblDate.text = strDate;
            }
            if ([[cell contentView] viewWithTag:2]) {
                UIButton *_btnPost = (UIButton*)[[cell contentView] viewWithTag:2];
                _btnPost.layer.cornerRadius = 5;
                _btnPost.layer.borderWidth = 1.f;
                _btnPost.layer.borderColor = [UIColor getSeperatorColor].CGColor;
                
            }
          cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        static NSString *CellIdentifier = @"CellForMenus";
        CellForMenus *cell = (CellForMenus*)[tableView_Menu dequeueReusableCellWithIdentifier:CellIdentifier];
        [self configureMenuCell:cell indexPath:indexPath];
        cell.lblMenu.hidden = false;
        cell.backgroundColor = [UIColor clearColor];
        cell.lblMenu.textColor = [UIColor colorWithRed:0.30 green:0.33 blue:0.38 alpha:1.0];
        cell.lblMenu.alpha = 0.5;
        cell.imgIcon.alpha = 0.5;
        cell.vwTopBorder.hidden = true;
        cell.vwBotomBorder.hidden = true;
        cell.lblMenu.font = [UIFont fontWithName:CommonFont_New size:14];
        cell.btnNext.tag = indexPath.row;
        cell.btnNext.hidden = true;
        cell.imgTick.hidden = true;
        switch (indexPath.row) {
            case eTypeFeel:
                cell.lblMenu.text = @"Do you like how you're feeling now?";
                cell.vwTopBorder.hidden = false;
                cell.vwBotomBorder.hidden = false;
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]]) {
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                }
                if (nextActiveMenu == eTypeFeel) {
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                    cell.lblMenu.font = [UIFont fontWithName:CommonFontBold_New size:13];
                    cell.btnNext.hidden = false;
                    
                }
                
                if ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]] boolValue]) {
                    cell.imgTick.hidden = false;
                    cell.btnNext.hidden = true;
                }
                break;
            case eTypeEmotion:
                cell.vwBotomBorder.hidden = false;
                cell.lblMenu.text = @"What's your emotional state?";
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]]) {
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;

                }
                if (nextActiveMenu == eTypeEmotion) {
                    cell.lblMenu.font = [UIFont fontWithName:CommonFontBold_New size:13];
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                    cell.btnNext.hidden = false;
                }
               
                if ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]] boolValue]) {
                    cell.imgTick.hidden = false;
                     cell.btnNext.hidden = true;
                }
                break;
            case eTypeDrive:
                cell.vwBotomBorder.hidden = false;
                cell.lblMenu.text = @"Do you like your reaction to the situation?";
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]]) {
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;

                }
                if (nextActiveMenu == eTypeDrive) {
                    cell.lblMenu.font = [UIFont fontWithName:CommonFontBold_New size:13];
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                    cell.btnNext.hidden = false;
                }
               
                if ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]] boolValue]) {
                    cell.imgTick.hidden = false;
                     cell.btnNext.hidden = true;
                    
                }
                break;
            case eTypeGoalsAndDreams:
                cell.vwBotomBorder.hidden = false;
                cell.lblMenu.text = @"Which goal is affected by your reaction?";
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]]) {
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                }
                if (nextActiveMenu == eTypeGoalsAndDreams) {
                    cell.lblMenu.font = [UIFont fontWithName:CommonFontBold_New size:13];
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                    cell.btnNext.hidden = false;
                }
                if ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]] boolValue]) {
                    cell.imgTick.hidden = false;
                    cell.btnNext.hidden = true;
                    cell.lblMenu.alpha = 1;
                    cell.imgIcon.alpha = 1;
                }
                
                break;
           

                
            default:
                break;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else{
        
        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                
                static NSString *CellIdentifier = @"EventTitleCell";
                EventTitleCell *cell = (EventTitleCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.lblTitle.text = eventTitle;
                cell.lblTitle.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];
                if (!eventTitle) {
                    cell.lblTitle.text = @"What's the event,situation or thought?";
                    cell.lblTitle.textColor = [UIColor lightGrayColor];
                }
                cell.vwBg.layer.borderColor = [UIColor getSeperatorColor].CGColor;
                cell.vwBg.layer.borderWidth = 1.f;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                if ([[cell contentView]viewWithTag:101]) {
                    UIButton *_btnHand = [[cell contentView]viewWithTag:101];
                    [_btnHand removeFromSuperview];
                }
                if (![dictSelectedSteps objectForKey:[NSNumber numberWithInt:eTypeEvent]]) {
                    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    doneBtn.frame = CGRectMake(tableView.frame.size.width / 2.0 - 15, 25, 20, 20);
                    [doneBtn setImage:[UIImage imageNamed:@"hand"] forState:UIControlStateNormal];
                    doneBtn.tag = 101;
                    [cell.contentView addSubview:doneBtn];
                    
                    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat) animations:^{
                        [doneBtn setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
                        doneBtn.alpha = 0.2;
                    }  completion:nil];
                }
               
                
                return cell;
            }
            else if (indexPath.row == 1) {
                
                static NSString *CellIdentifier = @"EventDescription";
                EventDescriptionCell *cell = (EventDescriptionCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                cell.txtVwDescription.text = strDescription;
                cell.txtVwDescription.delegate = self;
                cell.vwBg.layer.borderColor = [UIColor getSeperatorColor].CGColor;
                cell.vwBg.layer.borderWidth = 1.f;
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else if (indexPath.row == 2) {
                
                static NSString *CellIdentifier = @"LocationCell";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if ([[cell contentView] viewWithTag:1]) {
                    UILabel *lblInfo = [[cell contentView] viewWithTag:1];
                    if (strLocationName.length) {
                        NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"At %@",strLocationName]];
                        [mutableAttString addAttribute:NSForegroundColorAttributeName
                                                 value:[UIColor getThemeColor]
                                                 range:NSMakeRange(3, strLocationName.length)];
                        lblInfo.attributedText = mutableAttString;
                        
                        
                    }
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else if (indexPath.row == 3) {
                
                static NSString *CellIdentifier = @"ContactCell";
                UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if ([[cell contentView] viewWithTag:1]) {
                    UILabel *lblInfo = [[cell contentView] viewWithTag:1];
                    NSMutableAttributedString *myString= [NSMutableAttributedString new];
                    NSInteger nextIndex = 0;
                    
                    if (strContactName.length) {
                        NSArray *names = [strContactName componentsSeparatedByString:@","];
                        NSInteger nextLength = strContactName.length;
                        NSString *strCntact = strContactName;
                        if (names.count > 1) {
                            NSString *firstName = [names firstObject];
                            nextLength = firstName.length;
                            strCntact = [NSString stringWithFormat:@"With %@ and %d other(s)",firstName,names.count - 1];
                        }else{
                            strCntact = [NSString stringWithFormat:@"With %@",strCntact];
                        }
                        NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",strCntact]];
                        [myString appendAttributedString:mutableAttString];
                        [myString addAttribute:NSForegroundColorAttributeName
                                         value:[UIColor getThemeColor]
                                         range:NSMakeRange(nextIndex + 5, nextLength)];
                    }
                    lblInfo.attributedText = myString;
                    
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        if (indexPath.section == 1) {
            // Selected values
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"EmotionCell";
                SelectedValue_1 *cell = (SelectedValue_1*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]]){
                    NSInteger index = [[dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]] integerValue];
                    cell.imgFeel.image = [UIImage imageNamed:[arrDriveImages objectAtIndex:index]];
                }
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]]){
                    NSString *strText = [NSString stringWithFormat:@"Feeling %@",selectedEmotionTitle] ;
                    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:strText];
                    [title addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor colorWithRed:0.30 green:0.33 blue:0.38 alpha:.5]
                                   range:NSMakeRange(0, 7)];
                    cell.lblEmotin.attributedText = title;
                    
                }
               cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            if (indexPath.row == 1) {
                static NSString *CellIdentifier = @"GoalsCell";
                SelectedValue_2 *cell = (SelectedValue_2*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                NSMutableString *strTtile;
                NSAttributedString *driveAtachment;
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]]){
                    NSInteger index = [[dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]] integerValue];
                    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                    UIImage *icon = [UIImage imageNamed:[arrFeelImages objectAtIndex:index]];
                    attachment.image = icon;
                    attachment.bounds = CGRectMake(0, -(20) -  cell.lblGoalsActions.font.descender, 40, 40);
                    driveAtachment = [NSAttributedString attributedStringWithAttachment:attachment];
                }

                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]]){
                    strTtile = [NSMutableString stringWithString:selectedGoalsTitle];
                }
                NSArray *actions;
                if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeAction]]){
                    if (selectedActionTitle) {
                        actions = [selectedActionTitle componentsSeparatedByString:@","];
                        if (actions.count > 2) {
                            NSMutableString *strOthers = [NSMutableString stringWithFormat:@",%@ & %d more..",[actions firstObject],[actions count] - 1] ;
                            [strTtile appendString:strOthers];
                        }else{
                             [strTtile appendString:selectedActionTitle];
                        }
                    }
                    
                }else{
                    NSMutableString *strOthers = [NSMutableString stringWithFormat:@"\n No Action"] ;
                    [strTtile appendString:strOthers];
                }
                NSMutableAttributedString *check = [NSMutableAttributedString new];
                [check appendAttributedString:driveAtachment];
                if (strTtile) {
                    NSString *strText = [NSString stringWithFormat:@"Reaction:%@",strTtile] ;
                    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:strText];
                    [title addAttribute:NSForegroundColorAttributeName
                                  value:[UIColor colorWithRed:0.30 green:0.33 blue:0.38 alpha:.5]
                                  range:NSMakeRange(0, 9)];
                    
                    NSRange range = [strText rangeOfString:@"&"];
                    if (range.location == NSNotFound) {
                    } else {
                        NSArray *myArray = [strText componentsSeparatedByString:@"&"];
                        NSString *more = [myArray lastObject];
                        [title addAttribute:NSForegroundColorAttributeName
                                      value:[UIColor getThemeColor]
                                      range:NSMakeRange(range.location + 1, more.length)];
                    }
                    
                    if (![dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeAction]]){
                        [title addAttribute:NSForegroundColorAttributeName
                                      value:[UIColor lightGrayColor]
                                      range:NSMakeRange(title.length - 9, 9)];
                        [title addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:13] range:NSMakeRange(title.length - 9, 9)];
                       
                    }
                    [check appendAttributedString:title];
                  
                }
                cell.lblGoalsActions.attributedText = check;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                 return cell;
            }
            
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
   
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView == tableView_Menu){
        if (indexPath.row == 2) {
            return 50;
        }
        return 40;
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 50;
            // Textview height
        }
            if (indexPath.row == 1) {
                 return 100;
                // Textview height
            }
            else if (indexPath.row == 2) {
                if (strLocationName) {
                    return UITableViewAutomaticDimension;
                }
                return 0;
                // Loc  height
            }
            else if (indexPath.row == 3) {
                if (strContactName) {
                    return UITableViewAutomaticDimension;
                }
                 return 0;
                // Media height
            }
            else{
                return UITableViewAutomaticDimension;
            }
             return UITableViewAutomaticDimension;
        
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 50;
            // Textview height
        }
        else if (indexPath.row == 1) {
            return UITableViewAutomaticDimension;
            
            // Loc  height
        }
        
    }
   
    return 100;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     
    if (_tableView == tableView_Menu) {
            if (indexPath.row == 0 && [[dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeEvent]] boolValue] ) {
                [self showRateSelection];
            }
            if (indexPath.row == 1 ) {
                if (!isCycleCompleted) {
                    if (nextActiveMenu == eTypeEmotion || ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]] boolValue])) {
                        if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]]) [self showEmotionSelection];
                    }
                }else{
                    [self showEmotionSelection];
                }
               
                
            }
            if (indexPath.row == 2) {
                
                if (!isCycleCompleted) {
                    if (nextActiveMenu == eTypeDrive || ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]] boolValue])) {
                        if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]]) [self showDriveSelection];
                    }
                }else{
                    [self showDriveSelection];
                }
            }
            if (indexPath.row == 3)  {
                if (!isCycleCompleted) {
                    if (nextActiveMenu == eTypeGoalsAndDreams || ([[dictSuccessSteps objectForKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]] boolValue])) {
                        if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]]) [self showGoalsAndDreamsSelection];
                    }
                }else{
                    [self showGoalsAndDreamsSelection];
                }
                
            }
            if (indexPath.row == 4) {
                [self showDatePicker:nil];
            }
    }else{
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self showEventSelectionView];
            }
        }
       
        
    }
    
}

- (nullable UIView *)tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section{
    if (_tableView == tableView_Menu) {
        return nil;
    }
    if (section == 0) {
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"AwarenessHeader" owner:self options:nil];
        AwarenessHeader *view = [viewArray objectAtIndex:0];
        view.lblGalleryCount.text = [NSString stringWithFormat:@"%d",arrDataSource.count];
        UIImage *image = [UIImage imageNamed:@"NoImage_TopText"];
        view.imgGallery.image = image;
        float _width = image.size.width;
        float _height = image.size.height;
        float ratio = _width / _height;
        float deviceWidth = _tableView.frame.size.width;
        float imageHeight = (deviceWidth - 0) / ratio;
        float finalImgHeight = imageHeight;
        view.imgHeight.constant = finalImgHeight;
        [view layoutSubviews];
        if (arrDataSource.count) {
            id object = [arrDataSource firstObject];
            if ([object isKindOfClass:[NSString class]]) {
                
                //When Create
                NSString *fileName = [arrDataSource firstObject];
                if ([[fileName pathExtension] isEqualToString:@"jpeg"]) {
                    //This is Image File with .png Extension , Photos.
                    NSString *filePath = [Utility getMediaSaveFolderPath];
                    NSString *imagePath = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                    if (imagePath.length) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                            NSData *data = [[NSFileManager defaultManager] contentsAtPath:imagePath];
                            UIImage *image = [UIImage imageWithData:data];
                            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                                view.imgGallery.image = image;
                                float _width = image.size.width;
                                float _height = image.size.height;
                                float ratio = _width / _height;
                                float deviceWidth = _tableView.frame.size.width;
                                float imageHeight = (deviceWidth - 0) / ratio;
                                float finalImgHeight = imageHeight;
                                view.imgHeight.constant = finalImgHeight;
                                [view layoutSubviews];
                                
                            });
                        });
                        
                    }
                }
                else if ([[fileName pathExtension] isEqualToString:@"mp4"]) {
                    //This is Image File with .mp4 Extension , Video Files
                    NSString *filePath = [Utility getMediaSaveFolderPath];
                    NSString *imagePath = [[filePath stringByAppendingString:@"/"] stringByAppendingString:fileName];
                    if (imagePath.length){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                            UIImage *thumbnail = [Utility getThumbNailFromVideoURL:imagePath];
                            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                                view.imgGallery.image = thumbnail;
                                float _width = thumbnail.size.width;
                                float _height = thumbnail.size.height;
                                float ratio = _width / _height;
                                float deviceWidth = _tableView.frame.size.width;
                                float imageHeight = (deviceWidth - 0) / ratio;
                                float finalImgHeight = imageHeight;
                                view.imgHeight.constant = finalImgHeight;
                                [view layoutSubviews];
                            });
                        });
                    }
                }
                else if ([[fileName pathExtension] isEqualToString:@"aac"]){
                    // Recorded Audio
                    UIImage *image = [UIImage imageNamed:@"NoImage.png"];
                    view.imgGallery.image = image;
                    float _width = image.size.width;
                    float _height = image.size.height;
                    float ratio = _width / _height;
                    float deviceWidth = _tableView.frame.size.width;
                    float imageHeight = (deviceWidth - 0) / ratio;
                    float finalImgHeight = imageHeight;
                    view.imgHeight.constant = finalImgHeight;
                    [view layoutSubviews];
                }
                
            }
            
        }
        
        return view;
    }
   
    return nil;
    
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section{
    
    if (_tableView == tableView_Menu) {
        return 0;
    }
    
    if (section == 0) {
        return 130;
    }
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.01;
}


-(void)configureMenuCell:(CellForMenus*)cell indexPath:(NSIndexPath*)indexPath{
    
    switch (indexPath.row) {
        case eTypeFeel:
            cell.lblMenu.text = @"Rate how you feel";
            cell.imgIcon.image = [UIImage imageNamed:@"Rate_Feel"];
            break;
        case eTypeEmotion:
            cell.lblMenu.text = @"Select Emotion";
            cell.imgIcon.image = [UIImage imageNamed:@"Select_Emotion"];
            break;
        case eTypeDrive:
            cell.lblMenu.text = @"Rate Reaction";
            cell.imgIcon.image = [UIImage imageNamed:@"Rate_Reaction"];
            break;
        case eTypeGoalsAndDreams:
            cell.lblMenu.text = @"Select Goal";
            cell.imgIcon.image = [UIImage imageNamed:@"Select_Goal"];
            break;
        case eTypeAction:
            cell.lblMenu.text = @"Select Action";
            cell.imgIcon.image = [UIImage imageNamed:@"Select_Action"];
            break;
            
        default:
            break;
    }

}
-(IBAction)showNextMenuOptions:(UIButton*)sender{
    
    if (sender.tag == eTypeFeel) {
        [self showRateSelection];
        // next menu
        
    }
    if (sender.tag == eTypeEmotion) {
         [self showEmotionSelection];
        // next menu
       
    }
    if (sender.tag == eTypeDrive) {
        [self showDriveSelection];
        // next menu
        
    }
    if (sender.tag == eTypeGoalsAndDreams) {
        [self showGoalsAndDreamsSelection];
        // next menu
        
    }
   
}

-(void)showOtherContactsIfAny:(CGRect)myRect{
    
    popTip = [AMPopTip popTip];
    [popTip showText:@"AMPopTipDirectionUp AMPopTipDirectionUp AMPopTipDirectionUpAMPopTipDirectionUpAMPopTipDirectionUpAMPopTipDirectionUpAMPopTipDirectionUp AMPopTipDirectionUpAMPopTipDirectionUp AMPopTipDirectionUp" direction:AMPopTipDirectionUp maxWidth:(self.view.frame.size.width) inView:self.view fromFrame:CGRectMake(myRect.origin.x, myRect.origin.y, self.view.frame.size.width, 50) duration:2];
}

-(IBAction)showFeelsListFromSelection:(id)sender{
  if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeFeel]]) [self showRateSelection];
    
}
-(IBAction)showEmotionListFromSelection:(id)sender{
    if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeEmotion]]) [self showEmotionSelection];
}

-(IBAction)showDriveListFromSelection:(id)sender{
      if ([dictSelectedSteps objectForKey:[NSNumber numberWithInteger:eTypeDrive]]) [self showDriveSelection];
}




-(IBAction)showUploadingMedias:(id)sender{
    
    if (arrDataSource.count) {
        AwarenessMediaViewController *medias =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForImotionalAwarenessMedia];
        medias.delegate = self;
        medias.arrMedias = arrDataSource;
        [[self navigationController]pushViewController:medias animated:YES];
    }
   
}
-(void)closeButtonAppliedWithChangedArray:(NSMutableArray*)array{
    arrDataSource = [NSMutableArray arrayWithArray:array];
    [tableView reloadData];
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



#pragma mark - Media Drag and Drop Methods

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

-(IBAction)moveCellImage:(UIPanGestureRecognizer *)panner {
    if (! self.cellSnapshotView) {
        CGPoint loc = [panner locationInView:tableView];
        self.draggingCellIndexPath = [tableView indexPathForRowAtPoint:loc];
        if (self.draggingCellIndexPath.section == 2) return;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.draggingCellIndexPath];
        if (cell){
            
            self.cellSnapshotView = [cell snapshotViewAfterScreenUpdates:YES];
            self.cellSnapshotView.alpha = 0.8;
            self.cellSnapshotView.layer.borderColor = [UIColor redColor].CGColor;
            self.cellSnapshotView.layer.borderWidth = 1;
            self.cellSnapshotView.frame =  cell.frame;
            [tableView addSubview:self.cellSnapshotView];
            tableView.scrollEnabled = NO;
            [tableView reloadRowsAtIndexPaths:@[self.draggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        // replace the cell with a blank one until the drag is over
    }
    
    CGPoint translation = [panner translationInView:self.view];
    CGPoint cvCenter = self.cellSnapshotView.center;
    cvCenter.x += translation.x;
    cvCenter.y += translation.y;
    self.cellSnapshotView.center = cvCenter;
    [panner setTranslation:CGPointZero inView:self.view];
    if (panner.state == UIGestureRecognizerStateEnded) {
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
        if (droppedOnCellIndexPath.section == 2 ) {
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
            if (![self.draggingCellIndexPath isEqual:droppedOnCellIndexPath]) {
                self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                [arrDataSource exchangeObjectAtIndex:savedDraggingCellIndexPath.row withObjectAtIndex:droppedOnCellIndexPath.row];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath, droppedOnCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:0];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
    }
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
            if ((self.draggingCellIndexPath.section == 0) || (self.draggingCellIndexPath.section == 1)) return;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.draggingCellIndexPath];
            if (cell){
                
                UIGraphicsBeginImageContextWithOptions(cell.bounds.size, NO, 0);
                [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                // create and image view that we will drag around the screen
                self.cellSnapshotView = [[UIImageView alloc] initWithImage:cellImage];
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
        //  NSIndexPath *current =  [tableView indexPathForRowAtPoint:location];
        //        if (current.row  < arrDataSource.count) {
        //            NSIndexPath *next =  [NSIndexPath indexPathForRow:current.row inSection:eSectionTwo];
        //            [tableView scrollToRowAtIndexPath:next atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        //        }
        
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
         if ((droppedOnCellIndexPath.section == 0) || (droppedOnCellIndexPath.section == 1)) {
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
            if (![self.draggingCellIndexPath isEqual:droppedOnCellIndexPath]) {
                //self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:1];
                [arrDataSource exchangeObjectAtIndex:savedDraggingCellIndexPath.row withObjectAtIndex:droppedOnCellIndexPath.row];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath, droppedOnCellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
               // self.draggingCellIndexPath = [NSIndexPath indexPathForRow:-1 inSection:1];
                [tableView reloadRowsAtIndexPaths:@[savedDraggingCellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }];
        
    }
}


#pragma mark - Journal Media Picker Menus

-(IBAction)showCamera:(id)sender{
    
    [self hideJournalMediaMenus:nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"CAPTURE"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Video", @"Image", nil];
    actionSheet.tag = 1;
    
    [actionSheet showInView:self.view];
    [self.view endEditing:YES];

}

-(IBAction)showGallery:(id)sender{
    
    [self hideJournalMediaMenus:nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"UPLOAD"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Video", @"Image", nil];
    actionSheet.tag = 0;
    
    [actionSheet showInView:self.view];
    [self.view endEditing:YES];
}

-(IBAction)showLocation:(id)sender{
    
    [self hideJournalMediaMenus:nil];
    [self getNearBYLocations];
    [self.view endEditing:YES];
}

-(IBAction)showContacts:(id)sender{
    
    [self hideJournalMediaMenus:nil];
    [self getAllContacts];
    [self.view endEditing:YES];
}

-(IBAction)recordAudio:(UIButton*)sender{
    
    [self showToast];
   
}


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
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideActivityView];
            [self.view showActivityView];
        });
        [self compressVideoWithURL:[info objectForKey:UIImagePickerControllerMediaURL] onComplete:^(bool completed) {
            if (completed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideActivityView];
                    [self reloadMediaLibraryTable];
                });
            }
        }];
    }else{
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
            [self hideJournalMediaMenus:nil];
            
        }
        
    }
    
}

#pragma mark - Get All Contact Details

- (void)getAllContacts {
    
    ContactsPickerViewController *picker =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForContactsPickerVC];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:NULL];
    
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

#pragma mark - Get NearBy Location actions

-(void)getNearBYLocations{
    [self hideJournalMediaMenus:nil];
    
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

#pragma mark - UITextView delegate methods


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    [textView setInputAccessoryView:inputAccView];
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    NSIndexPath *indexPath;
    CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
    indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
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
    CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];

    
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
    CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    EventDescriptionCell *cell = (EventDescriptionCell*)textView.superview.superview.superview;
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    [self getTextFromField:cell.txtVwDescription.tag data:textView.text];
    return YES;
}

-(void)getTextFromField:(NSInteger)type data:(NSString*)string{
    
    strDescription = string;
    
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
    btnDone.titleLabel.font = [UIFont fontWithName:CommonFont_New size:14];
    [inputAccView addSubview:btnDone];
}
-(void)doneTyping{
    [self.view endEditing:YES];
}

#pragma mark - SELECT YOUR EVENT Actions

-(IBAction)showEventSelectionView{
    
    [self.view endEditing:YES];
    vwEventSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourEvent" owner:self options:nil] objectAtIndex:0];
    vwEventSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwEventSelection.delegate = self;
    vwEventSelection.eventID = eventValue;
    [self.view addSubview:vwEventSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[vwEventSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEventSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwEventSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEventSelection)]];
    [vwEventSelection showSelectionPopUp];
    
}


-(void)selectYourEventPopUpCloseAppplied{
    
    [vwEventSelection removeFromSuperview];
    vwEventSelection.delegate = nil;
    vwEventSelection = nil;
}


-(void)eventSelectedWithEventTitle:(NSString*)_eventTitle eventID:(NSInteger)eventID;{
    nextActiveMenu = eTypeFeel;
    eventValue = eventID;
    selectedEventValue = eventID;
    eventTitle = _eventTitle;
    [dictSelectedSteps setObject:[NSNumber numberWithInteger:eventID] forKey:[NSNumber numberWithInteger:eTypeEvent]];
    [self collapseAllSectionMenus];
    [tableView_Menu reloadData];
    [tableView reloadData];
    [self shouldeablePostButton:YES];
    

}

#pragma mark - RATE YOUR FEEL Actions


-(void)showRateSelection{
    
    vwFeelSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourFeel" owner:self options:nil] objectAtIndex:0];
    vwFeelSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwFeelSelection.delegate = self;
    [self.view addSubview:vwFeelSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[vwFeelSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwFeelSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwFeelSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwFeelSelection)]];
    [vwFeelSelection showSelectionPopUp];
    
    
}

-(void)selectYourFeelingPopUpCloseAppplied{
    
    [vwFeelSelection removeFromSuperview];
    vwFeelSelection.delegate = nil;
    vwFeelSelection = nil;
}

-(void)feelingsSelectedWithEmotionType:(NSInteger)emotionType{
    
    selectedFeelValue = emotionType;
    [dictSelectedSteps setObject:[NSNumber numberWithInteger:emotionType] forKey:[NSNumber numberWithInteger:eTypeFeel]];
    [self collapseAllSectionMenus];
    if (menuCount > 1) {
        
    }else{
        menuCount = 1;
    }
    
   [tableView reloadData];
    nextActiveMenu = eTypeEmotion;
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeFeel]];
    [tableView_Menu reloadData];
   // [self performSelector:@selector(showEmotionSelection) withObject:self afterDelay:0.5];
    
}

#pragma mark - SELECT YOUR EMOTIONS Actions


-(void)showEmotionSelection{
    
    vwEmotionSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourEmotion" owner:self options:nil] objectAtIndex:0];
    vwEmotionSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwEmotionSelection.delegate = self;
    vwEmotionSelection.selectedEmotionID = selectedEmotionValue;
   // vwEmotionSelection.emotionaValue = selectedFeelValue;
    [self.view addSubview:vwEmotionSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[vwEmotionSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEmotionSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwEmotionSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEmotionSelection)]];
    [vwEmotionSelection showSelectionPopUp];
    
}


-(void)SelectYourEmotionPopUpCloseAppplied{
    
    [vwEmotionSelection removeFromSuperview];
    vwEmotionSelection.delegate = nil;
    vwEmotionSelection = nil;
}


-(void)emotionSelectedWithEmotionTitle:(NSString*)emotionTitle emotionID:(NSInteger)emotionID;{
    if (menuCount > 2) {
        
    }else{
        menuCount = 2;
    }
    selectedEmotionValue = emotionID;
    selectedEmotionTitle = emotionTitle;
    [dictSelectedSteps setObject:[NSNumber numberWithInteger:emotionID] forKey:[NSNumber numberWithInteger:eTypeEmotion]];
    [self collapseAllSectionMenus];
    [tableView reloadData];
    nextActiveMenu = eTypeDrive;
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeEmotion]];
    [tableView_Menu reloadData];
   // [self performSelector:@selector(showDriveSelection) withObject:self afterDelay:0.5];
}

#pragma mark - SELECT YOUR DRIVE Actions

-(void)showDriveSelection{
    
    vwDriveSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourDrive" owner:self options:nil] objectAtIndex:0];
    vwDriveSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwDriveSelection.delegate = self;
    [self.view addSubview:vwDriveSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[vwDriveSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwDriveSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwDriveSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwDriveSelection)]];
    [vwDriveSelection showSelectionPopUp];
    
    
}

-(void)selectYourDrivePopUpCloseAppplied{
    
    [vwDriveSelection removeFromSuperview];
    vwDriveSelection.delegate = nil;
    vwDriveSelection = nil;
}

-(void)driveSelectedWithEmotionType:(NSInteger)emotionType{
    
    if (menuCount > 3) {
        
    }else{
        menuCount = 3;
    }
    selectedDriveValue = emotionType;
    [dictSelectedSteps setObject:[NSNumber numberWithInteger:emotionType] forKey:[NSNumber numberWithInteger:eTypeDrive]];
     [self collapseAllSectionMenus];
    [tableView reloadData];
    nextActiveMenu = eTypeGoalsAndDreams;
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeDrive]];
    [tableView_Menu reloadData];
    //[self performSelector:@selector(showGoalsAndDreamsSelection) withObject:self afterDelay:0.5];
    
    
}

#pragma mark - SELECT YOUR GOALS and DREAMS Actions

-(void)showGoalsAndDreamsSelection{
    
     isCycleCompleted = false;
    [self shouldeablePostButton:NO];
    vwGoalsSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourGoalsAndDreams" owner:self options:nil] objectAtIndex:0];
    vwGoalsSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwGoalsSelection.delegate = self;
    vwGoalsSelection.selectedGoalID = selectedGoalsValue;
    [self.view addSubview:vwGoalsSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[vwGoalsSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwGoalsSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwGoalsSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwGoalsSelection)]];
    [vwGoalsSelection showSelectionPopUp];
    
}

-(void)selectYourGoalsAndDreamsPopUpCloseAppplied{
    
    [vwGoalsSelection removeFromSuperview];
    vwGoalsSelection.delegate = nil;
    vwGoalsSelection = nil;
}

-(void)goalsAndDreamsSelectedWithTitle:(NSString*)title goalId:(NSInteger)goalsId{
    
    if (menuCount > 4) {
        
    }else{
        menuCount = 4;
    }
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]];
     isCycleCompleted = false;
    selectedActionTitle = @"";
    selectedGoalsTitle = title;
    selectedGoalsValue = goalsId;
    [dictSelectedSteps setObject:[NSNumber numberWithInteger:goalsId] forKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]];
    selectedActionTitle = @"";
    [dictSelectedSteps removeObjectForKey:[NSNumber numberWithInt:eTypeAction]];
    
    [self collapseAllSectionMenus];
    [tableView reloadData];
    nextActiveMenu = eTypeAction;
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]];
    [tableView_Menu reloadData];
    
     [self performSelector:@selector(showActionSelection) withObject:self afterDelay:0.5];
    
}

-(void)skipButtonApplied{
    
    if (menuCount > 4) {
        
    }else{
        menuCount = 4;
    }
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]];
    isCycleCompleted = true;
    selectedActionTitle = @"";
    selectedGoalsTitle = @"";
    [dictSelectedSteps removeObjectForKey:[NSNumber numberWithInt:eTypeAction]];
    [dictSelectedSteps removeObjectForKey:[NSNumber numberWithInt:eTypeGoalsAndDreams]];
    selectedGoalsValue = -1;
    selectedActions = nil;
   // vwDateView.hidden = false;
    tableHeight.constant = 210;
    [tableView setNeedsUpdateConstraints];
    [tableView reloadData];
     nextActiveMenu = eTypeAction;
    [tableView_Menu reloadData];
   [self shouldeablePostButton:YES];
    //[self showSubmitOverLay];
    //[self createJournalClicked];
}


#pragma mark - SELECT YOUR ACTIONS methods


-(void)showActionSelection{
    
    vwActions = [[[NSBundle mainBundle] loadNibNamed:@"SelectActions" owner:self options:nil] objectAtIndex:0];
    vwActions.translatesAutoresizingMaskIntoConstraints = NO;
    vwActions.delegate = self;
    vwActions.goalID = selectedGoalsValue;
    vwActions.selectedActions = selectedActions;
    [self.view addSubview:vwActions];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[vwActions]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwActions)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwActions]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwActions)]];
    [vwActions showSelectionPopUp];
    
    
}

-(void)selectYourActionsPopUpCloseAppplied{
    
    [vwActions removeFromSuperview];
    vwActions.delegate = nil;
    vwActions = nil;
}

-(void)actionsSelectedWithTitle:(NSString*)title actionIDs:(NSDictionary*)selectedAcitons{
    
    if (menuCount > 5) {
        
    }else{
        menuCount = 5;
    }
    [dictSuccessSteps setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:eTypeGoalsAndDreams]];
    nextActiveMenu = -1;
    isCycleCompleted = true;
    selectedActionTitle = title;
    selectedActions = selectedAcitons;
     [dictSelectedSteps setObject:selectedAcitons forKey:[NSNumber numberWithInteger:eTypeAction]];
    [tableView reloadData];
     nextActiveMenu = eTypeAction;
     [tableView_Menu reloadData];
   // vwDateView.hidden = false;
   tableHeight.constant = 210;
    [tableView setNeedsUpdateConstraints];
    [self shouldeablePostButton:YES];
    
}

-(void)shouldeablePostButton:(BOOL)shouldEnable{
    
    if (!isCycleCompleted) {
        btnPost.alpha = 0.3;
        btnPost.enabled = false;
        return;
    }
    if (shouldEnable) {
        btnPost.alpha = 0.3;
        btnPost.enabled = false;
        if ([dictSelectedSteps objectForKey:[NSNumber numberWithInt:eTypeEvent]]) {
            btnPost.alpha = 1;
            btnPost.enabled = true;
        }
    }else{
        btnPost.alpha = 0.3;
        btnPost.enabled = false;
    }
}

#pragma mark - Date Methods

-(IBAction)showDatePicker:(id)sender{
    
    datePicker.maximumDate = [NSDate date];
    vwPickerOverLay.hidden = false;
    datePicker.date = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
    strDate = [dateformater stringFromDate:datePicker.date];
}

-(IBAction)getSelectedDate{
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
    strDate = [dateformater stringFromDate:datePicker.date];
}

-(IBAction)hidePicker:(id)sender{
    
    vwPickerOverLay.hidden = true;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
    strDate = [dateformater stringFromDate:datePicker.date];
    [tableView_Menu reloadData];
}

-(void)getCurrentDate{
    
    datePicker.date = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
   strDate = [dateformater stringFromDate:[NSDate date]];
}

#pragma mark - GENERIC Actions

-(void)emotionalIntelligencePage{
    
    [self goBack:nil];
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegate emotionalIntelligencePage];
    
}

-(IBAction)showJournalMediaMenus:(id)sender{
    
    [self.view endEditing:YES];
    
    NSMutableArray *attButons  = [NSMutableArray new];
    float delay = .1;
    if ([vwMediaMenuOverLay viewWithTag:1]) {
        UIView *nextView = [vwMediaMenuOverLay viewWithTag:1];
        if ([nextView viewWithTag:2]) {
            UIView *_nextView = [nextView viewWithTag:2];
            for (UIButton *btn in [_nextView subviews]) {
                btn.alpha = 0;
                [attButons addObject:btn];
            }
        }
    }
    vwMediaMenuOverLay.hidden = false;
    
    for (UIButton *btn in attButons) {
        
        [UIView animateWithDuration:0.5
                              delay:delay
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             btn.alpha = 1.0;
                         } 
                         completion:^(BOOL finished){
                         }];
        delay += .1;
    }
    
}

-(IBAction)hideJournalMediaMenus:(id)sender{
   
    NSMutableArray *attButons  = [NSMutableArray new];
    float delay = .1;
    if ([vwMediaMenuOverLay viewWithTag:1]) {
        UIView *nextView = [vwMediaMenuOverLay viewWithTag:1];
        if ([nextView viewWithTag:2]) {
            UIView *_nextView = [nextView viewWithTag:2];
            for (UIButton *btn in [_nextView subviews]) {
                btn.alpha = 1;
                [attButons addObject:btn];
            }
        }
    }
    
    int count = 0;
    for (int i = [attButons count] - 1; i >= 0; i --) {
        UIButton *btn = attButons[i];
        count ++;
        [UIView animateWithDuration:0.5
                              delay:delay
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             btn.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             if (count == 5) {
                                 vwMediaMenuOverLay.hidden = true;
                             }
                         }];
        delay += .1;
    }
   
    
    
}



-(void)collapseAllSectionMenus{
    
    shouldHideMenus = true;
     requiredCellCount = 1;
    if ([dictSelectedSteps objectForKey:[NSNumber numberWithInt:eTypeEvent]]) {
         requiredCellCount = 4;
    }
    tableHeight.constant = 170;
    if (isCycleCompleted) {
       // vwDateView.hidden = false;
        tableHeight.constant = 210;;
    }
    
    [tableView setNeedsUpdateConstraints];
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

-(IBAction)submitJournals:(id)sender{
    
    [self showLoadingScreen];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMM,yyyy h:mm a"];
    NSDate *dateFromString = [dateFormatter dateFromString:strDate];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSInteger feelValue = 0;
    switch (selectedFeelValue) {
        case 0:
            feelValue = 2;
            break;
        case 1:
            feelValue = 1;
            break;
        case 2:
            feelValue = 0;
            break;
        case 3:
            feelValue = -1;
            break;
        case 4:
            feelValue = -2;
            break;
            
        default:
            break;
    }
    
    NSInteger driveValue = 0;
    switch (selectedDriveValue) {
        case 0:
            driveValue = 2;
            break;
        case 1:
            driveValue = 1;
            break;
        case 2:
            driveValue = 0;
            break;
        case 3:
            driveValue = -1;
            break;
        case 4:
            driveValue = -2;
            break;
            
        default:
            break;
    }
    
    [params setObject:[NSNumber numberWithInteger:feelValue] forKey:@"emotion_value"];
    [params setObject:[NSNumber numberWithInteger:selectedEmotionValue] forKey:@"emotion_id"];
    [params setObject:[NSNumber numberWithInteger:selectedEventValue] forKey:@"event_id"];
    [params setObject:[NSNumber numberWithInteger:driveValue] forKey:@"drive_value"];
    [params setObject:[User sharedManager].userId forKey:@"user_id"];
    [params setObject:[NSNumber numberWithDouble:[dateFromString timeIntervalSince1970] ] forKey:@"journal_date"];
    if (selectedGoalsValue > 0) [params setObject:[NSNumber numberWithInteger:selectedGoalsValue] forKey:@"goal_id"];
    if ([selectedActions allKeys].count > 0) [params setObject:[NSNumber numberWithInteger:[[selectedActions allKeys] count]] forKey:@"action_count"];
    if ([selectedActions allKeys].count > 0){
        NSString * result = [[selectedActions allKeys] componentsJoinedByString:@","];
        [params setObject:result forKey:@"goalaction_id"];
    }
    
    [APIMapper createAJournelWith:arrDataSource description:strDescription latitude:locationCordinates.latitude longitude:locationCordinates.longitude locName:strLocationName address:strLocationAddress contactName:strContactName emotionAwarenssValues:params OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        
        if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
            
            if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"EMOTIONAL AWARENESS"
                                                                    message:[responseObject objectForKey:@"text"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [delegate clearUserSessions];
                
            }
            
        }else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EMOTIONAL AWARENESS"
                                                                           message:[responseObject objectForKey:@"text"]
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                      
                                                                      [self emotionalIntelligencePage];
                                                                      
                                                                  }];
            [alert addAction:firstAction];
            [[self navigationController] presentViewController:alert animated:YES completion:nil];
        }
        
        
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EMOTIONAL AWARENESS"
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                              }];
        
        [alert addAction:firstAction];
        [[self navigationController] presentViewController:alert animated:YES completion:nil];
        
    } progress:^(long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
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
