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
    
}EField;

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

@interface SettingsViewController () <SWRevealViewControllerDelegate>{
    
    IBOutlet UIView *vwOverLay;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UISwitch *switchCanFollow;
    IBOutlet UISwitch *switchDailyNotfction;
    
    
    BOOL canFollow;
    BOOL canSendDailyNotifications;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self setUp];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    revealViewController.delegate = self;
    if ( revealViewController )
    {
        [btnSlideMenu addTarget:self.revealViewController action:@selector(revealToggle:)forControlEvents:UIControlEventTouchUpInside];
        [vwOverLay addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
    }
    
}

-(void)setUp{
    
    btnSubmit.hidden = true;
    canFollow = [User sharedManager].follow_status;
    canSendDailyNotifications = [User sharedManager].daily_notify;
    [tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else if (section == 1) {
        return 2;
    }
    else if (section == 2) {
        return 1;
    }
    return 3;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"SettingsInfo"];
    if (indexPath.section == 1 && indexPath.row == 1) {
         cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"OtherInfo"];
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
        lblStatus.text = @"Notification";//
        return vwHeader;
    }
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return kHeightForHeader;
    }

    return 50;
    
}

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section{
    
    return kEmptyHeaderAndFooter;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self showHelpScreen];
        }
    }
    
}

-(void)configureCellWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    if (indexPath.section == 2) {
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
    else if (indexPath.section == 1) {
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
                    [switchCanFollow addTarget:self action:@selector(changeFollowStatus:) forControlEvents:UIControlEventValueChanged];
                    
                }
                break;
                
            case eFieldTwo:
                if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UILabel class]]) {
                    UILabel *lblTitle = [[cell contentView]viewWithTag:1];
                    lblTitle.text = @"Help";
                    break;
                }
                
                
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
    [APIMapper updateUserSettingsWithUserID:[User sharedManager].userId canFollow:canFollow dailyNotification:canSendDailyNotifications success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideLoadingScreen];
        if ( NULL_TO_NIL([responseObject objectForKey:@"header"])) {
            if ([[responseObject objectForKey:@"code"]integerValue] == kSuccessCode) {
                [[[UIAlertView alloc] initWithTitle:@"Profile" message:@"Successfully updated your settings!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                [User sharedManager].follow_status = canFollow;
                [User sharedManager].daily_notify  = canSendDailyNotifications;
                [Utility saveUserObject:[User sharedManager] key:@"USER"];
                btnSubmit.hidden = true;
                
            }else
                [[[UIAlertView alloc] initWithTitle:@"Profile" message:@"Failed to update Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
        
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


#pragma mark - Slider View Setup and Delegates Methods

- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position{
    UINavigationController *nav = (UINavigationController*)revealController.rearViewController;
    if ([[nav.viewControllers objectAtIndex:0] isKindOfClass:[MenuViewController class]]) {
        MenuViewController *root = (MenuViewController*)[nav.viewControllers objectAtIndex:0];
        [root resetTable];
    }
    if (position == FrontViewPositionRight) {
        [self setVisibilityForOverLayIsHide:NO];
    }else{
        [self setVisibilityForOverLayIsHide:YES];
    }
    
}
-(IBAction)hideSlider:(id)sender{
    [self.revealViewController revealToggle:nil];
}

-(void)setVisibilityForOverLayIsHide:(BOOL)isHide{
    
    if (isHide) {
        [UIView transitionWithView:vwOverLay
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            vwOverLay.alpha = 0.0;
                        }
                        completion:^(BOOL finished) {
                            
                            vwOverLay.hidden = true;
                        }];
        
        
    }else{
        
        vwOverLay.hidden = false;
        [UIView transitionWithView:vwOverLay
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            vwOverLay.alpha = 0.7;
                        }
                        completion:^(BOOL finished) {
                            
                        }];
        
    }
}


#pragma mark state preservation / restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}


- (void)applicationFinishedRestoringState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Call whatever function you need to visually restore
    [self customSetup];
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
