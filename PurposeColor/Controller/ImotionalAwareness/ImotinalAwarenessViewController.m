//
//  ImotinalAwarenessViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 12/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


typedef enum{
    
    eTypeFeel = 0,
    eTypeEmotion = 1,
    eTypeEvent = 2,
    eTypeDrive = 3,
    eTypeGoalsAndDreams = 4,
    eTypeAction = 5
    
}ESelectedMenuType;

typedef enum{
    
    eEmotionVeryHappy = 2,
    eEmotionHappy = 1,
    eEmotionNeutral = 0,
    eEmotionSad = -1,
    eEmotionVerysad = -2,
    
}EEmotionType;


#define kTagForTitle                    1
#define kCellminimumHeight              60
#define kHeightForHeader                60
#define kMenuItems                      6
#define kSectionCount                   1
#define kPadding                        70


#import "ImotinalAwarenessViewController.h"
#import "ImotionDisplayCell.h"
#import "SelectYourFeel.h"
#import "SelectYourEmotion.h"
#import "SelectYourEvent.h"
#import "SelectYourDrive.h"
#import "SelectYourGoalsAndDreams.h"
#import "SelectActions.h"
#import "Constants.h"
#import "GEMSListingsViewController.h"
#import "MenuViewController.h"
#import "JournalViewController.h"
#import "CircleProgressBar.h"
#import "GEMSWithHeaderListingsViewController.h"

@interface ImotinalAwarenessViewController () <SelectYourFeelingDelegate,SelectYourEmotionDelegate,SelectYourEventDelegate,SelectYourDriveDelegate,SelectYourGoalsAndDreamsDelegate,SelectYourActionsDelegate,JournalDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet NSLayoutConstraint *leftConstraintCircle;
    IBOutlet UIView *vwSelectionHlder;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    IBOutlet UIView *vwSubmitOverLay;
    IBOutlet UIView *vwJournalReminderOverLay;
    IBOutlet CircleProgressBar *_circleProgressBar;
    IBOutlet UIView *vwProgressOverLay;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UILabel *lblDate;
    IBOutlet UIView *vwPickerOverLay;
    IBOutlet UIDatePicker *datePicker;
    
    BOOL isLaunch;
    BOOL isCycleCompleted;
    BOOL isJournalMediaAvailable;
    BOOL shouldShowHelpScreen;
    BOOL isAnimationInProgress;
    
    SelectYourFeel *vwFeelSelection;
    NSInteger selectedFeelValue;
    
    SelectYourEmotion *vwEmotionSelection;
    NSString  *selectedEmotionTitle;
    NSInteger selectedEmotionValue;
    
    SelectYourEvent *vwEventSelection;
    NSString  *selectedEventTitle;
    NSInteger selectedEventValue;
    
    SelectYourDrive *vwDriveSelection;
    NSInteger selectedDriveValue;
    
    SelectYourGoalsAndDreams *vwGoalsSelection;
    NSString  *selectedGoalsTitle;
    NSInteger selectedGoalsValue;
    
    SelectActions *vwActions;
    NSString  *selectedActionTitle;
    NSDictionary* selectedActions;

    
    ESelectedMenuType activeMenu;
    ESelectedMenuType nextMenu;
    NSMutableDictionary *dictEmotionSelection;
    
    NSInteger height;
    NSInteger resultIDforStep1;
    
    JournalViewController *journalView;
}

@end

@implementation ImotinalAwarenessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getCurrentDate];
    [self performSelector:@selector(setUpTable) withObject:self afterDelay:.3];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    
    vwPickerOverLay.hidden = true;
    btnSubmit.hidden = true;
    vwProgressOverLay.hidden = true;
    vwProgressOverLay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    vwSubmitOverLay.alpha = 0;
    vwJournalReminderOverLay.alpha = 0;
    isLaunch = true;
    dictEmotionSelection = [NSMutableDictionary new];
    activeMenu = eTypeFeel;
    vwSelectionHlder.alpha = 0;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    NSInteger cellHeight = (self.view.frame.size.height - kPadding) / kMenuItems;
    height = (cellHeight < kCellminimumHeight) ? kCellminimumHeight : cellHeight;
    [tableView reloadData];
    
}

-(void)setUpTable{
    
    [self.view layoutIfNeeded];
    leftConstraintCircle.constant = 0;
    [UIView animateWithDuration:.5
                     animations:^{
                         vwSelectionHlder.alpha = 1.f;
                         [self.view layoutIfNeeded]; // Called on parent view
                     }completion:^(BOOL finished) {
                         
                         [self showRateSelection];
                     }];

}

-(void)updateVisibilityStatus{
    
    shouldShowHelpScreen = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Emotion_Awareness_Show_Count"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"Emotion_Awareness_Show_Count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Emotion_Awareness_Show_Count"] integerValue];
        if (count == 2) {
             shouldShowHelpScreen = false;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"Emotion_Awareness_Show_Count"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kMenuItems;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    ImotionDisplayCell *cell = (ImotionDisplayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    singleTap.numberOfTapsRequired = 1;
    cell.imgIcon.tag = indexPath.row;
    cell.imgIcon.userInteractionEnabled = true;
    [cell.imgIcon addGestureRecognizer:singleTap];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imgSelection.hidden = true;
    cell.backgroundColor = [UIColor clearColor];
    NSInteger constant = self.view.frame.size.width;
    
    switch (indexPath.row) {
            
        case eTypeFeel:
            cell.vwRightConstraint.constant = constant / 2;
            cell.imgIcon.image = [UIImage imageNamed:@"Rate.png"];
            break;
            
        case eTypeEmotion:
            cell.vwRightConstraint.constant = constant / 5;
            cell.imgIcon.image = [UIImage imageNamed:@"Emotion.png"];
            break;
            
        case eTypeEvent:
            cell.vwRightConstraint.constant = constant / 12;
            cell.imgIcon.image = [UIImage imageNamed:@"Event.png"];
            break;
            
        case eTypeDrive:
            cell.vwRightConstraint.constant = constant / 11;
            cell.imgIcon.image = [UIImage imageNamed:@"Drive.png"];
            break;
            
        case eTypeGoalsAndDreams:
            cell.vwRightConstraint.constant = constant / 5;
            cell.imgIcon.image = [UIImage imageNamed:@"Goals.png"];
            break;
            
        case eTypeAction:
            cell.vwRightConstraint.constant = constant / 2;
            cell.imgIcon.image = [UIImage imageNamed:@"Actions.png"];
            break;
            
        default:
            break;
    }
    
    [self configureCellWithSelection:indexPath.row iconView:cell.imgIcon selectedIconView:cell.imgSelection selectionTitle:cell.lblSeletionTitle];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    [self menuTapped:[NSNumber numberWithInteger:indexPath.row]];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(ImotionDisplayCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!isLaunch) {
        if (indexPath.row == activeMenu) {
            double delayInSeconds =0.5f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:0.3/1.5 animations:^{
                    cell.imgIcon.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                        cell.imgIcon.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.3/2 animations:^{
                            cell.imgIcon.transform = CGAffineTransformIdentity;
                        } completion:^(BOOL finished) {
                            id tag = [NSNumber numberWithInteger:activeMenu];
                            if (!isCycleCompleted) {
                                 [self menuTapped:tag];
                            }
                            
                                //Reached Last
                        }];
                    }];
                }];
            });
         }
        
        return;
    }
    if (indexPath.row == eTypeAction)isLaunch = false;
    //1. Setup the CATransform3D structure
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;
    
    //2. Define the initial state (Before the animation)
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //3. Define the final state (After the animation) and commit the animation
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    [UIView commitAnimations];
    
}

-(void)configureCellWithSelection:(NSInteger)index iconView:(UIImageView*)icnonView selectedIconView:(UIImageView*)selectionIcon selectionTitle:(UILabel*)selectionTitle{
    
    selectionTitle.textColor= [UIColor colorWithRed:0.22 green:0.64 blue:0.86 alpha:1.0];
    selectionTitle.hidden = FALSE;
    switch (index) {
        case eTypeFeel:
            selectionTitle.text = @"Rate how you feel";
            break;
            
        case eTypeEmotion:
            selectionTitle.text = @"Select Emotion";
            break;
            
        case eTypeEvent:
            selectionTitle.text = @"Select Event";
            break;
            
        case eTypeDrive:
            selectionTitle.text = @"Rate Reaction";
            break;
            
        case eTypeGoalsAndDreams:
            selectionTitle.text = @"Select Goals & Dreams";
            break;
            
        case eTypeAction:
            selectionTitle.text = @"Select Actions";
            break;
            
        default:
            break;
    }
    
    
    if (index == eTypeFeel){
        
            selectionIcon.hidden = false;
        
            if ([dictEmotionSelection objectForKey:[NSNumber numberWithInteger:index]]) {
                selectionTitle.hidden = TRUE;
                icnonView.image = [UIImage imageNamed:@"Rate_Result.png"];
                NSInteger emotionType = [[dictEmotionSelection objectForKey:[NSNumber numberWithInteger:eTypeFeel]] integerValue];
                switch (emotionType) {
                        
                    case eEmotionVeryHappy:
                        selectionIcon.image = [UIImage imageNamed:@"Smiley_Very_Happy.png"];
                        break;
                        
                    case eEmotionHappy:
                        selectionIcon.image = [UIImage imageNamed:@"Smiley_Happy.png"];
                        break;
                        
                    case eEmotionNeutral:
                        selectionIcon.image = [UIImage imageNamed:@"Smiley_Neutral.png"];
                        break;
                        
                    case eEmotionSad:
                        selectionIcon.image = [UIImage imageNamed:@"Smiley_Sad.png"];
                        break;
                        
                    case eEmotionVerysad:
                        selectionIcon.image = [UIImage imageNamed:@"Smiley_Very_Sad.png"];
                        break;
                        
                    default:
                        break;
                }
                
                
            }
            else if (activeMenu == eTypeFeel) {
                selectionIcon.hidden = true;
                selectionTitle.text = @"Rate how you feel";
                icnonView.image = [UIImage imageNamed:@"Rate_Active.png"];
                selectionTitle.textColor= [UIColor whiteColor];
            }
        
    }
   
    else if (index == eTypeEmotion) {
        
        selectionIcon.hidden = true;
        
        if (selectedEmotionTitle.length) {
            selectionIcon.hidden = true;
            selectionTitle.text = selectedEmotionTitle;
            icnonView.image = [UIImage imageNamed:@"Emotion_Result.png"];
        }
        else if(activeMenu == eTypeEmotion) {
            selectionIcon.hidden = true;
            icnonView.image = [UIImage imageNamed:@"Emotion_Active.png"];
            selectionTitle.text = @"Select Emotion";
            selectionTitle.textColor= [UIColor whiteColor];
           
        }
    }
    
    else if (index == eTypeEvent) {
        
        selectionIcon.hidden = true;
        
        if (selectedEventTitle.length) {
            selectionIcon.hidden = true;
            selectionTitle.text = selectedEventTitle;
            icnonView.image = [UIImage imageNamed:@"Event_Result.png"];
        }
        else if(activeMenu == eTypeEvent) {
            selectionIcon.hidden = true;
            icnonView.image = [UIImage imageNamed:@"Event_Active.png"];
            selectionTitle.text = @"Select Event";
            selectionTitle.textColor= [UIColor whiteColor];
            
        }
    }
    
    else if (index == eTypeDrive) {
        
        selectionIcon.hidden = true;
        
        if ([dictEmotionSelection objectForKey:[NSNumber numberWithInteger:index]]) {
            icnonView.image = [UIImage imageNamed:@"Drive_Result.png"];
            selectionIcon.hidden = false;
            selectionTitle.hidden = TRUE;
            NSInteger emotionType = [[dictEmotionSelection objectForKey:[NSNumber numberWithInteger:eTypeDrive]] integerValue];
            switch (emotionType) {
                    
                case eEmotionVeryHappy:
                    selectionIcon.image = [UIImage imageNamed:@"Smiley_Very_Happy.png"];
                    break;
                    
                case eEmotionHappy:
                    selectionIcon.image = [UIImage imageNamed:@"Smiley_Happy.png"];
                    break;
                    
                case eEmotionNeutral:
                    selectionIcon.image = [UIImage imageNamed:@"Smiley_Neutral.png"];
                    break;
                    
                case eEmotionSad:
                    selectionIcon.image = [UIImage imageNamed:@"Smiley_Sad.png"];
                    break;
                    
                case eEmotionVerysad:
                    selectionIcon.image = [UIImage imageNamed:@"Smiley_Very_Sad.png"];
                    break;
                    
                default:
                    break;
            }
        }
         else if(activeMenu == eTypeDrive) {
            selectionIcon.hidden = false;
            icnonView.image = [UIImage imageNamed:@"Drive_Active.png"];
            selectionTitle.text = @"Rate Reaction";
            selectionTitle.textColor= [UIColor whiteColor];
            
        }
    }
    
    else if (index == eTypeGoalsAndDreams) {
        
        selectionIcon.hidden = true;
        
        if (selectedGoalsTitle.length) {
            selectionIcon.hidden = true;
            selectionTitle.text = selectedGoalsTitle;
            icnonView.image = [UIImage imageNamed:@"Goals_Result.png"];
        }
        else if(activeMenu == eTypeGoalsAndDreams) {
            selectionIcon.hidden = true;
            icnonView.image = [UIImage imageNamed:@"Goals_Active.png"];
            selectionTitle.text = @"Select Goals & Dreams";
            selectionTitle.textColor= [UIColor whiteColor];
            
        }
    }
    
    else if (index == eTypeAction) {
        
        selectionIcon.hidden = true;
        
        if (selectedActionTitle.length) {
            selectionIcon.hidden = true;
            selectionTitle.text = selectedActionTitle;
            icnonView.image = [UIImage imageNamed:@"Actions_Result.png"];
            
            double delayInSeconds = 0.5f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:0.3/1.5 animations:^{
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3/2 animations:^{
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.3/2 animations:^{
                        } completion:^(BOOL finished) {
                            
                        }];
                    }];
                }];
            });

          
            
        }
        else if(activeMenu == eTypeAction) {
            selectionIcon.hidden = true;
            icnonView.image = [UIImage imageNamed:@"Actions_Active.png"];
            selectionTitle.text = @"Select Actions";
            selectionTitle.textColor= [UIColor whiteColor];
            
        }
    }
    
    
}

-(void)menuTapped:(id)sender{
    
    if (isAnimationInProgress ) return;
    UITapGestureRecognizer *gesture;
    NSInteger tag = 0;
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        gesture  =(UITapGestureRecognizer*)sender;
        tag = gesture.view.tag;

    }else{
        tag = [sender integerValue];
    }
    
        switch (tag) {
        case eTypeFeel:
            [self showRateSelection];
            break;
                
        case eTypeEmotion:
            if (![dictEmotionSelection objectForKey:[NSNumber numberWithInteger:eTypeFeel]]) return;
            [self showEmotionSelection];
            break;
                
        case eTypeEvent:
            if (selectedEmotionTitle.length <= 0) return;
            [self showEventSelection];
            break;
                
        case eTypeDrive:
            if (selectedEventTitle.length <= 0) return;
            [self showDriveSelection];
            break;
                
        case eTypeGoalsAndDreams:
            if (![dictEmotionSelection objectForKey:[NSNumber numberWithInteger:eTypeDrive]]) return;
                [self showGoalsAndDreamsSelection];
            break;
                
        case eTypeAction:
            if (selectedGoalsTitle.length <= 0) return;
                [self showActionSelection];
            break;
                
            default:
                break;
        }

}

#pragma mark - RATE YOUR FEEL Actions


-(void)showRateSelection{
    
    isAnimationInProgress = true;
    activeMenu = eTypeFeel;
    vwFeelSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourFeel" owner:self options:nil] objectAtIndex:0];
    vwFeelSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwFeelSelection.delegate = self;
    [self.view addSubview:vwFeelSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwFeelSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwFeelSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwFeelSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwFeelSelection)]];
    [vwFeelSelection showSelectionPopUp];
    
   
}

-(void)selectYourFeelingPopUpCloseAppplied{
    
    [vwFeelSelection removeFromSuperview];
    vwFeelSelection.delegate = nil;
    vwFeelSelection = nil;
    isAnimationInProgress = false;
}

-(void)feelingsSelectedWithEmotionType:(NSInteger)emotionType{
    
    isAnimationInProgress = false;
    selectedFeelValue = 0;
    if (emotionType < 0) {
        selectedFeelValue = -1;
    }else if (emotionType >= 0){
        selectedFeelValue =1;
    }
    [dictEmotionSelection setObject:[NSNumber numberWithInteger:emotionType] forKey:[NSNumber numberWithInteger:eTypeFeel]];
    activeMenu = eTypeEmotion;
    [tableView reloadData];
   
}

#pragma mark - SELECT YOUR EMOTIONS Actions


-(void)showEmotionSelection{
    
    isAnimationInProgress = true;
    activeMenu = eTypeEmotion;
    vwEmotionSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourEmotion" owner:self options:nil] objectAtIndex:0];
    vwEmotionSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwEmotionSelection.delegate = self;
    vwEmotionSelection.emotionaValue = selectedFeelValue;
    [self.view addSubview:vwEmotionSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwEmotionSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEmotionSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwEmotionSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEmotionSelection)]];
    [vwEmotionSelection showSelectionPopUp];

}


-(void)SelectYourEmotionPopUpCloseAppplied{
    
    [vwEmotionSelection removeFromSuperview];
    vwEmotionSelection.delegate = nil;
    vwEmotionSelection = nil;
    isAnimationInProgress = false;
}


-(void)emotionSelectedWithEmotionTitle:(NSString*)emotionTitle emotionID:(NSInteger)emotionID;{
    selectedEmotionValue = emotionID;
    selectedEmotionTitle = emotionTitle;
    activeMenu = eTypeEvent;
    [tableView reloadData];
    isAnimationInProgress = false;
}

#pragma mark - SELECT YOUR EVENT Actions

-(void)showEventSelection{
    
    isAnimationInProgress = true;
    activeMenu = eTypeEvent;
    vwEventSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourEvent" owner:self options:nil] objectAtIndex:0];
    vwEventSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwEventSelection.delegate = self;
    vwEventSelection.eventID = selectedEventValue;
    [self.view addSubview:vwEventSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwEventSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEventSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwEventSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwEventSelection)]];
    [vwEventSelection showSelectionPopUp];
    
}


-(void)selectYourEventPopUpCloseAppplied{
    
    [vwEventSelection removeFromSuperview];
    vwEventSelection.delegate = nil;
    vwEventSelection = nil;
    isAnimationInProgress = false;
}


-(void)eventSelectedWithEventTitle:(NSString*)eventTitle eventID:(NSInteger)eventID;{
    selectedEventValue = eventID;
    selectedEventTitle = eventTitle;
    activeMenu = eTypeDrive;
    [tableView reloadData];
    isAnimationInProgress = false;
    
}

#pragma mark - SELECT YOUR DRIVE Actions

-(void)showDriveSelection{
    
    isAnimationInProgress = true;
    activeMenu = eTypeDrive;
    vwDriveSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourDrive" owner:self options:nil] objectAtIndex:0];
    vwDriveSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwDriveSelection.delegate = self;
    [self.view addSubview:vwDriveSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwDriveSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwDriveSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwDriveSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwDriveSelection)]];
    [vwDriveSelection showSelectionPopUp];
    
    
}

-(void)selectYourDrivePopUpCloseAppplied{
    
    isAnimationInProgress = false;
    [vwDriveSelection removeFromSuperview];
    vwDriveSelection.delegate = nil;
    vwDriveSelection = nil;
}

-(void)driveSelectedWithEmotionType:(NSInteger)emotionType{
    
    isAnimationInProgress = false;
    selectedDriveValue = 0;
    if (emotionType < 0) {
        selectedDriveValue = -1;
    }else if (emotionType >= 0){
        selectedDriveValue =1;
    }
    [dictEmotionSelection setObject:[NSNumber numberWithInteger:emotionType] forKey:[NSNumber numberWithInteger:eTypeDrive]];
    activeMenu = eTypeGoalsAndDreams;
    [tableView reloadData];
    
    
}

#pragma mark - SELECT YOUR GOALS and DREAMS Actions

-(void)showGoalsAndDreamsSelection{
    
    isAnimationInProgress = true;
    activeMenu = eTypeGoalsAndDreams;
    vwGoalsSelection = [[[NSBundle mainBundle] loadNibNamed:@"SelectYourGoalsAndDreams" owner:self options:nil] objectAtIndex:0];
    vwGoalsSelection.translatesAutoresizingMaskIntoConstraints = NO;
    vwGoalsSelection.delegate = self;
    vwGoalsSelection.selectedGoalID = selectedGoalsValue;
    [self.view addSubview:vwGoalsSelection];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwGoalsSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwGoalsSelection)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwGoalsSelection]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwGoalsSelection)]];
    [vwGoalsSelection showSelectionPopUp];
    
}

-(void)selectYourGoalsAndDreamsPopUpCloseAppplied{
    
    isAnimationInProgress = false;
    [vwGoalsSelection removeFromSuperview];
    vwGoalsSelection.delegate = nil;
    vwGoalsSelection = nil;
}

-(void)goalsAndDreamsSelectedWithTitle:(NSString*)title goalId:(NSInteger)goalsId{
    
    isAnimationInProgress = false;
    isCycleCompleted = false;
    selectedActionTitle = @"";
    selectedGoalsTitle = title;
    selectedGoalsValue = goalsId;
    activeMenu = eTypeAction;
    [tableView reloadData];
}

-(void)skipButtonApplied{
    
    isAnimationInProgress = false;
    isCycleCompleted = YES;
    selectedActionTitle = @"";
    selectedGoalsTitle = @"";
    selectedGoalsValue = -1;
    selectedActions = nil;
    [tableView reloadData];
    //[self showSubmitOverLay];
    [self createJournalClicked];
}

#pragma mark - SELECT YOUR ACTIONS methods


-(void)showActionSelection{
    
    isAnimationInProgress = true;
    activeMenu = eTypeAction;
    vwActions = [[[NSBundle mainBundle] loadNibNamed:@"SelectActions" owner:self options:nil] objectAtIndex:0];
    vwActions.translatesAutoresizingMaskIntoConstraints = NO;
    vwActions.delegate = self;
    vwActions.goalID = selectedGoalsValue;
    [self.view addSubview:vwActions];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwActions]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwActions)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwActions]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwActions)]];
    [vwActions showSelectionPopUp];
    
    
}

-(void)selectYourActionsPopUpCloseAppplied{
    
    isAnimationInProgress = false;
    [vwActions removeFromSuperview];
    vwActions.delegate = nil;
    vwActions = nil;
}

-(void)actionsSelectedWithTitle:(NSString*)title actionIDs:(NSDictionary*)selectedAcitons{
    
    isAnimationInProgress = false;
    selectedActionTitle = title;
    selectedActions = selectedAcitons;
    activeMenu = eTypeAction;
    isCycleCompleted = TRUE;
    [tableView reloadData];
    //[self showSubmitOverLay];
    [self createJournalClicked];
    
}



#pragma mark - Journal Showing and its Delegate

-(IBAction)createJournalClicked{
    
    isAnimationInProgress = false;
    
    if (!journalView) {
        journalView =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForJournal];
        journalView.delegate = self;
    }
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window.rootViewController addChildViewController:journalView];
    UIView *vwPopUP = journalView.view;
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

-(void)closePopUpWithJournalIsAvailable:(BOOL)_isMediaAvailabe{
    
    isJournalMediaAvailable = _isMediaAvailabe;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        journalView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [journalView.view removeFromSuperview];
        [journalView removeFromParentViewController];
        if (isCycleCompleted) {
            [self showSubmitOverLay];
        }else{
            [self continueEmotionListingAftrJournal];
        }
        
        
    }];
    
}

-(void)continueEmotionListingAftrJournal{
    
    switch (activeMenu) {
        case eTypeFeel:
            [self showRateSelection];
            break;
            
        case eTypeEmotion:
            if (![dictEmotionSelection objectForKey:[NSNumber numberWithInteger:eTypeFeel]]) return;
            [self showEmotionSelection];
            break;
            
        case eTypeEvent:
            if (selectedEmotionTitle.length <= 0) return;
            [self showEventSelection];
            break;
            
        case eTypeDrive:
            if (selectedEventTitle.length <= 0) return;
            [self showDriveSelection];
            break;
            
        case eTypeGoalsAndDreams:
            if (![dictEmotionSelection objectForKey:[NSNumber numberWithInteger:eTypeDrive]]) return;
            [self showGoalsAndDreamsSelection];
            break;
            
        case eTypeAction:
            if (selectedGoalsTitle.length <= 0) return;
            [self showActionSelection];
            break;
            
        default:
            break;
    }

}

#pragma mark - SUBMIT Activities

-(IBAction)showSubmitOverLay{
    
    btnSubmit.hidden = false;
    [UIView animateWithDuration:0.5
                          delay:0.5
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         vwSubmitOverLay.alpha = 1.0;
                     } 
                     completion:^(BOOL finished){
                     }];
    
    
    
   
   
}

-(IBAction)hideSubmitOverLay:(id)sender{

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         vwSubmitOverLay.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                     }];
 
}

-(IBAction)submtJournal:(id)sender{
    
    [self hideSubmitOverLay:nil];
    isJournalMediaAvailable = true;
    
    if (isJournalMediaAvailable) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"d MMM,yyyy h:mm a"];
        NSDate *dateFromString = [dateFormatter dateFromString:lblDate.text];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:[NSNumber numberWithInteger:selectedFeelValue] forKey:@"emotion_value"];
        [params setObject:[NSNumber numberWithInteger:selectedEmotionValue] forKey:@"emotion_id"];
        [params setObject:[NSNumber numberWithInteger:selectedEventValue] forKey:@"event_id"];
        [params setObject:[NSNumber numberWithInteger:selectedDriveValue] forKey:@"drive_value"];
        [params setObject:[User sharedManager].userId forKey:@"user_id"];
        [params setObject:[NSNumber numberWithDouble:[dateFromString timeIntervalSince1970] ] forKey:@"journal_date"];
        if (selectedGoalsValue > 0) [params setObject:[NSNumber numberWithInteger:selectedGoalsValue] forKey:@"goal_id"];
        if ([selectedActions allKeys].count > 0) [params setObject:[NSNumber numberWithInteger:[[selectedActions allKeys] count]] forKey:@"action_count"];
        if ([selectedActions allKeys].count > 0){
            NSString * result = [[selectedActions allKeys] componentsJoinedByString:@","];
            [params setObject:result forKey:@"goalaction_id"];
        }
        if (journalView) {
            [journalView createAJournelWitEmotionValues:params];
        }else{
            [self showLoadingScreen];
            [APIMapper createAJournelWith:nil description:nil latitude:0 longitude:0 locName:nil address:nil contactName:nil emotionAwarenssValues:params OnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
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
                                                                              
                                                                              [self showGEMSWithHeadingPage];
                                                                              
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
        
    }else{
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             vwJournalReminderOverLay.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
    
}

-(void)startProgressViewWithProgerss:(float)progress;{
    
    vwProgressOverLay.hidden = false;
    [_circleProgressBar setProgress:progress animated:YES];
}

-(void)hideProgressView;{
    
    vwProgressOverLay.hidden = true;
    [_circleProgressBar setProgress:0 animated:false];
    
}


-(IBAction)noButtonClickedFromJournalOverLay:(id)sender{
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         vwJournalReminderOverLay.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self createJournalClicked];
}

-(IBAction)yesButtonClickedFromJournalOverLay:(id)sender{
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         vwJournalReminderOverLay.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                     }];
    
    isJournalMediaAvailable = TRUE;
    [self submtJournal:nil];
}

#pragma mark - Date Methods

-(IBAction)showDatePicker:(id)sender{
    
    datePicker.maximumDate = [NSDate date];
    vwPickerOverLay.hidden = false;
    datePicker.date = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
    lblDate.text = [dateformater stringFromDate:datePicker.date];
}

-(IBAction)getSelectedDate{
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
    lblDate.text = [dateformater stringFromDate:datePicker.date];
}

-(IBAction)hidePicker:(id)sender{
    
    vwPickerOverLay.hidden = true;
}

-(void)getCurrentDate{
    
    datePicker.date = [NSDate date];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy h:mm a"];
    lblDate.text = [dateformater stringFromDate:[NSDate date]];
}



-(void)showGEMSWithHeadingPage{
    
    AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdelegate goToHomeAfterLogin];
    
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
    
    [[self navigationController]popViewControllerAnimated:YES];
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
