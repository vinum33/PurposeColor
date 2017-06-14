//
//  SettingsViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 27/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eFieldOne = 0,
    eFieldTwo = 1,
    eFieldThree = 2,
    eFieldFour = 3,
    
}EField;

NSString * const Show_Admin_Goals = @"Show_Admin_Goals";
NSString * const Show_Admin_Emotions = @"Show_Admin_Emotions";
NSString * const Show_Admin_Journal = @"Show_Admin_Journal";

#define kTagForTitle            1
#define kCellHeight             50
#define kHeightForHeader        80
#define kEmptyHeaderAndFooter   001
#define kSuccessCode            200

#import "SettingsViewController.h"
#import "MenuViewController.h"
#import "Constants.h"
#import "NFXIntroViewController.h"
#import "ProfilePageViewController.h"
#import "DeleteAccntPopUp.h"

@interface SettingsViewController () <SWRevealViewControllerDelegate,DeleteAccntPopUpDelegate>{
    
    IBOutlet UIView *vwOverLay;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UISwitch *switchCanFollow;
    IBOutlet UISwitch *switchDailyNotfction;
    
     UISwitch *switchEmotion;
     UISwitch *switchGoal;
     UISwitch *switchJournal;
    
    NSInteger tapCount;
    
    
    BOOL canFollow;
    BOOL canSendDailyNotifications;
    NSMutableDictionary *dictAdminSettings;
    DeleteAccntPopUp *vwDeleteAccnt;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getUserInitials];
    [self setUp];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)getUserInitials{
    
    [self showLoadingScreen];
    [APIMapper checkUserHasEntryInPurposeColorOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        [self setAdminUserSettingsWithResponds:responseObject];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         [self hideLoadingScreen];
    }];
    
    
}
-(void)setAdminUserSettingsWithResponds:(NSDictionary*)responds{
    
    dictAdminSettings = [NSMutableDictionary new];
    if (NULL_TO_NIL([responds objectForKey:@"admin_emotion"])) {
          [dictAdminSettings setObject:[responds objectForKey:@"admin_emotion"] forKey:Show_Admin_Emotions];
    }
    if (NULL_TO_NIL([responds objectForKey:@"admin_goal"])) {
        [dictAdminSettings setObject:[responds objectForKey:@"admin_goal"] forKey:Show_Admin_Goals];
    }
    if (NULL_TO_NIL([responds objectForKey:@"admin_journal"])) {
        [dictAdminSettings setObject:[responds objectForKey:@"admin_journal"] forKey:Show_Admin_Journal];
    }
     [tableView reloadData];
}

-(void)setUp{
    
    btnSubmit.hidden = true;
    canFollow = [User sharedManager].follow_status;
    canSendDailyNotifications = [User sharedManager].daily_notify;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1;
    }
    else if (section == 3) {
        return 1;
    }
    
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"SettingsInfo"];
    cell.userInteractionEnabled = true;
    if ((indexPath.section == 1 && indexPath.row == 1) || (indexPath.section == 3)) {
         cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"OtherInfo"];
         cell.userInteractionEnabled = true;
         [self configureCellWithCell:cell indexPath:indexPath];
    }else{
         [self configureCellWithCell:cell indexPath:indexPath];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return kCellHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        UIView *vwHeader = [UIView new];
        vwHeader.backgroundColor = [UIColor whiteColor];
        //User Profile Pic
        
        UIImageView *imgDisplay = [UIImageView new];
        [vwHeader addSubview:imgDisplay];
        imgDisplay.translatesAutoresizingMaskIntoConstraints = NO;
        imgDisplay.clipsToBounds = YES;
        imgDisplay.layer.cornerRadius = 25.f;
        imgDisplay.backgroundColor = [UIColor blackColor];
        imgDisplay.contentMode = UIViewContentModeScaleAspectFill;
        [imgDisplay addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0
                                                                constant:50.0]];
        [imgDisplay addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0
                                                                constant:50.0]];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:10.0]];
        
        NSString *profileURL = [User sharedManager].profileurl;
        if (profileURL.length) {
            [imgDisplay sd_setImageWithURL:[NSURL URLWithString:profileURL]
                          placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                 }];
            
            
        }
        
        
        UILabel *lblName= [UILabel new];
        lblName.numberOfLines = 1;
        lblName.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:lblName];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[lblName]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblName)]];
        lblName.font = [UIFont fontWithName:CommonFont size:17];
        lblName.textColor = [UIColor blackColor];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblName
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:-12.0]];
        lblName.text = [User sharedManager].name;
        
        UILabel *lblStatus= [UILabel new];
        lblStatus.numberOfLines = 1;
        lblStatus.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:lblStatus];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-70-[lblStatus]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblStatus)]];
        lblStatus.font = [UIFont fontWithName:CommonFont size:14];
        lblStatus.textColor = [UIColor blackColor];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:12.0]];
        lblStatus.text = [User sharedManager].email;
        
        UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
        [vwHeader addSubview:btnSend];
         btnSend.translatesAutoresizingMaskIntoConstraints = NO;
        [btnSend addTarget:self action:@selector(showProfilePage)
          forControlEvents:UIControlEventTouchUpInside];
        [btnSend setBackgroundColor:[UIColor clearColor]];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btnSend]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btnSend]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];

        
        return vwHeader;
    }
    
    else if (section == 1){
        
        UIView *vwHeader = [UIView new];
        vwHeader.backgroundColor = [UIColor getBackgroundOffWhiteColor];
        UILabel *lblStatus= [UILabel new];
        lblStatus.numberOfLines = 1;
        lblStatus.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:lblStatus];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblStatus]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblStatus)]];
        lblStatus.font = [UIFont fontWithName:CommonFontBold size:14];
        lblStatus.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToast)];
        gesture.numberOfTapsRequired = 1;
        [vwHeader addGestureRecognizer:gesture];
        
        lblStatus.text = @"General";//
        return vwHeader;
    }
    else if (section == 2){
        
        UIView *vwHeader = [UIView new];
        vwHeader.backgroundColor = [UIColor getBackgroundOffWhiteColor];
        UILabel *lblStatus= [UILabel new];
        lblStatus.numberOfLines = 1;
        lblStatus.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:lblStatus];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblStatus]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblStatus)]];
        lblStatus.font = [UIFont fontWithName:CommonFontBold size:14];
        lblStatus.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];
        lblStatus.text = @"Notification";
        return vwHeader;
    }
    else if (section == 4){
        
        UIView *vwHeader = [UIView new];
        vwHeader.backgroundColor = [UIColor getBackgroundOffWhiteColor];
        UILabel *lblStatus= [UILabel new];
        lblStatus.numberOfLines = 1;
        lblStatus.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:lblStatus];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblStatus]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblStatus)]];
        lblStatus.font = [UIFont fontWithName:CommonFontBold size:14];
        lblStatus.textColor = [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:vwHeader
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];
        lblStatus.text = @"General";
        
        UILabel *lblInfo= [UILabel new];
        lblInfo.hidden = true;
        lblInfo.numberOfLines = 0;
        lblInfo.translatesAutoresizingMaskIntoConstraints = NO;
        [vwHeader addSubview:lblInfo];
        [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblInfo]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblInfo)]];
        lblInfo.font = [UIFont fontWithName:CommonFont size:12];
        lblInfo.textColor = [UIColor lightGrayColor];
        [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblInfo
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:lblStatus
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:10]];
        lblInfo.text = @"User can disable these settings only if user has created goals/journals etc.";
        
        
        return vwHeader;
    }
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return kHeightForHeader;
    }
    if (section == 3) {
        return 50;
    }

    return 50;
    
}

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section{
    
    return kEmptyHeaderAndFooter;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self showDeleteAccountPopUp];
        }
    }
    
}

-(void)configureCellWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case eFieldOne:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Let others follow you";
                    
                }
                if ([[[cell contentView]viewWithTag:2] isKindOfClass:[UISwitch class]]) {
                    UISwitch *switchBtn = (UISwitch*)[[cell contentView]viewWithTag:2];
                    [switchBtn setOn:canFollow];
                    switchCanFollow = switchBtn;
                    [switchCanFollow removeTarget:nil  action:NULL forControlEvents:UIControlEventAllEvents];
                    [switchCanFollow addTarget:self action:@selector(changeFollowStatus:) forControlEvents:UIControlEventValueChanged];
                    
                }
                break;
                
            case eFieldTwo:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Delete Account";
                    break;
                }
                
                
            default:
                break;
        }
    }
    else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case eFieldOne:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Daily Notifications";
                   
                }
                
                if ([[[cell contentView]viewWithTag:2] isKindOfClass:[UISwitch class]]) {
                    UISwitch *switchBtn = (UISwitch*)[[cell contentView]viewWithTag:2];
                    [switchBtn setOn:canSendDailyNotifications];
                    switchDailyNotfction = switchBtn;
                    [switchDailyNotfction removeTarget:nil  action:NULL forControlEvents:UIControlEventAllEvents];
                    [switchDailyNotfction addTarget:self action:@selector(changeDailyNotification:) forControlEvents:UIControlEventValueChanged];
                   
                }
                break;
                
            case eFieldTwo:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Activity Notifications";
                   
                }
                 break;
                
            default:
                break;
        }
    }
   
    else if (indexPath.section == 3) {
        
        switch (indexPath.row) {
            case eFieldOne:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Delete Account";
                    lblTitle.textColor = [UIColor colorWithRed:0.96 green:0.32 blue:0.29 alpha:1.0];
                }
                if ([[[cell contentView]viewWithTag:2] isKindOfClass:[UISwitch class]]) {
                    UISwitch *switchBtn = (UISwitch*)[[cell contentView]viewWithTag:2];
                    switchBtn.hidden = true;
                }
                break;
                
                default:
                break;
        }
    }
    else if (indexPath.section == 4) {
        
        switch (indexPath.row) {
            case eFieldOne:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Show admin goals";
                    
                }
                
                if ([[[cell contentView]viewWithTag:2] isKindOfClass:[UISwitch class]]) {
                    UISwitch *switchBtn = (UISwitch*)[[cell contentView]viewWithTag:2];
                    if ([dictAdminSettings objectForKey:Show_Admin_Goals]) {
                        if ([[dictAdminSettings objectForKey:Show_Admin_Goals] integerValue] < 0)
                            cell.userInteractionEnabled = false;
                        BOOL isEnabled = [[dictAdminSettings objectForKey:Show_Admin_Goals] boolValue];
                        [switchBtn setOn:isEnabled];
                    }
                    [switchBtn removeTarget:nil  action:NULL forControlEvents:UIControlEventAllEvents];
                    [switchBtn addTarget:self action:@selector(changeDefaultAdminGoals:) forControlEvents:UIControlEventValueChanged];
                    
                }
                break;
                
            case eFieldTwo:
                
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Show admin supporting emotions";
                    
                }
                
                if ([[[cell contentView]viewWithTag:2] isKindOfClass:[UISwitch class]]) {
                    UISwitch *switchBtn = (UISwitch*)[[cell contentView]viewWithTag:2];
                    
                    if ([dictAdminSettings objectForKey:Show_Admin_Emotions]) {
                        
                        if ([[dictAdminSettings objectForKey:Show_Admin_Emotions] integerValue] < 0)
                            cell.userInteractionEnabled = false;
                        BOOL isEnabled = [[dictAdminSettings objectForKey:Show_Admin_Emotions] boolValue];
                        [switchBtn setOn:isEnabled];
                    }
                  
                    [switchBtn removeTarget:nil  action:NULL forControlEvents:UIControlEventAllEvents];
                    [switchBtn addTarget:self action:@selector(changeDefaultSupportingEmotions:) forControlEvents:UIControlEventValueChanged];
                    
                }
                break;
                
            case eFieldThree:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Show admin journal / moments";
                }
                
                if ([[[cell contentView]viewWithTag:2] isKindOfClass:[UISwitch class]]) {
                    UISwitch *switchBtn = (UISwitch*)[[cell contentView]viewWithTag:2];
                    
                    if ([dictAdminSettings objectForKey:Show_Admin_Journal]) {
                        
                        if ([[dictAdminSettings objectForKey:Show_Admin_Journal] integerValue] < 0)
                            cell.userInteractionEnabled = false;
                        
                        BOOL isEnabled = [[dictAdminSettings objectForKey:Show_Admin_Journal] boolValue];
                        [switchBtn setOn:isEnabled];
                    }
                
                    [switchBtn removeTarget:nil  action:NULL forControlEvents:UIControlEventAllEvents];
                    [switchBtn addTarget:self action:@selector(changeDefaultJourals:) forControlEvents:UIControlEventValueChanged];
                    
                }
                break;
            default:
                break;
        }
    }
    
    
    
    
}

-(IBAction)showProfilePage{
    
    ProfilePageViewController *profilePage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForProfilePage];
    [[self navigationController]pushViewController:profilePage animated:YES];
    profilePage.canEdit = true;
    [profilePage loadUserProfileWithUserID:[User sharedManager].userId showBackButton:YES];
    
}

-(IBAction)changeDefaultAdminGoals:(UISwitch*)_switch{
    
    if ([dictAdminSettings objectForKey:Show_Admin_Goals]) {
        BOOL isEnabled = [[dictAdminSettings objectForKey:Show_Admin_Goals] boolValue];
        [dictAdminSettings setObject:[NSNumber numberWithBool:!isEnabled] forKey:Show_Admin_Goals];
         [_switch setOn:!isEnabled];
    }
    btnSubmit.hidden = false;
}

-(IBAction)changeDefaultSupportingEmotions:(UISwitch*)_switch{
    
    if ([dictAdminSettings objectForKey:Show_Admin_Emotions]) {
        BOOL isEnabled = [[dictAdminSettings objectForKey:Show_Admin_Emotions] boolValue];
        [dictAdminSettings setObject:[NSNumber numberWithBool:!isEnabled] forKey:Show_Admin_Emotions];
         [_switch setOn:!isEnabled];
    }
    btnSubmit.hidden = false;
}


-(IBAction)changeDefaultJourals:(UISwitch*)_switch{
    
    if ([dictAdminSettings objectForKey:Show_Admin_Journal]) {
        BOOL isEnabled = [[dictAdminSettings objectForKey:Show_Admin_Journal] boolValue];
        [dictAdminSettings setObject:[NSNumber numberWithBool:!isEnabled] forKey:Show_Admin_Journal];
        [_switch setOn:!isEnabled];
    }
    btnSubmit.hidden = false;
}


-(IBAction)changeFollowStatus:(UISwitch*)sender{
    
    canFollow = sender.isOn;
    btnSubmit.hidden = false;
}
-(IBAction)changeDailyNotification:(UISwitch*)sender{
    
    canSendDailyNotifications = sender.isOn;
    btnSubmit.hidden = false;
}


-(IBAction)submitDetails:(UIButton*)sender{
    [self showLoadingScreen];
    [APIMapper updateUserSettingsWithUserID:[User sharedManager].userId canFollow:canFollow dailyNotification:canSendDailyNotifications adminListSuggestions:dictAdminSettings success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideLoadingScreen];
        if ([[responseObject objectForKey:@"code"]integerValue] == kSuccessCode) {
            if (NULL_TO_NIL([responseObject objectForKey:@"text"])){
                [[[UIAlertView alloc] initWithTitle:@"Settings" message:[responseObject objectForKey:@"text"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            [User sharedManager].follow_status = canFollow;
            [User sharedManager].daily_notify  = canSendDailyNotifications;
            [Utility saveUserObject:[User sharedManager] key:@"USER"];
            
            if (NULL_TO_NIL([responseObject objectForKey:@"admin_emotion"])) {
                [dictAdminSettings setObject:[responseObject objectForKey:@"admin_emotion"] forKey:Show_Admin_Emotions];
            }
            
            if (NULL_TO_NIL([responseObject objectForKey:@"admin_goal"])) {
                [dictAdminSettings setObject:[responseObject objectForKey:@"admin_goal"] forKey:Show_Admin_Goals];
            }
            
            if (NULL_TO_NIL([responseObject objectForKey:@"admin_journal"])) {
                [dictAdminSettings setObject:[responseObject objectForKey:@"admin_journal"] forKey:Show_Admin_Journal];
            }
            
            [tableView reloadData];
            btnSubmit.hidden = true;
            
        }else
            [[[UIAlertView alloc] initWithTitle:@"Profile" message:@"Failed to update Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
        
    }];}

-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}


-(void)showHelpScreen{
    
    UIImage*i1 = [UIImage imageNamed:@"Intelligence_Intro_1.png"];
    UIImage*i2 = [UIImage imageNamed:@"Intelligence_Intro_2.png"];
    UIImage*i3 = [UIImage imageNamed:@"Intelligence_Intro_3.png"];
    
    NFXIntroViewController*vc = [[NFXIntroViewController alloc] initWithViews:@[i1,i2,i3]];
    [self.navigationController pushViewController:vc animated:YES];
  
    
}

#pragma mark - Forgot Password Methods and Delegates


-(IBAction)showDeleteAccountPopUp{
    
    if (!vwDeleteAccnt) {
        
        vwDeleteAccnt = [DeleteAccntPopUp new];
        [self.view addSubview:vwDeleteAccnt];
        vwDeleteAccnt.delegate = self;
        vwDeleteAccnt.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwDeleteAccnt]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwDeleteAccnt)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwDeleteAccnt]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwDeleteAccnt)]];
        vwDeleteAccnt.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            vwDeleteAccnt.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [vwDeleteAccnt setUp];
}



-(void)closeForgotPwdPopUp{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwDeleteAccnt.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwDeleteAccnt removeFromSuperview];
        vwDeleteAccnt = nil;
    }];
}




-(void)showToast{
    
    tapCount ++;
    if (tapCount == 1) {
        [self performSelector:@selector(resetTapTimer) withObject:nil afterDelay:5.0f];
    }
    if (tapCount == 7){
        tapCount = 0;
        [ALToastView toastInView:self.view withText:@"That's the key to success"];
    }
    
}
-(void)resetTapTimer{
    
    tapCount = 0;
}

-(IBAction)goBack:(id)sender{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.navGeneral willMoveToParentViewController:nil];
    [app.navGeneral.view removeFromSuperview];
    [app.navGeneral removeFromParentViewController];
    app.navGeneral = nil;
    app.window.rootViewController = nil;
    [app showLauchPage];
    
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
