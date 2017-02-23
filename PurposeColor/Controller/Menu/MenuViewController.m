//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#define kTagForTitle        1
#define kCellHeight         50
#define kHeightForHeader    70


#import "MenuViewController.h"
#import "Constants.h"

@implementation SWUITableViewCell
@end

@interface MenuViewController ()

@end

@implementation MenuViewController{
    
    NSMutableArray *arrCategories;
}


- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:
    if ( [sender isKindOfClass:[UITableViewCell class]] ){
    }
}
-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self setUp];
    [self loadAllCategories];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)resetTable{
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    [_tableView reloadData];

}

-(void)setUp{
    
    arrCategories = [NSMutableArray new];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
}

-(void)loadAllCategories{
    
    [arrCategories addObject:@"Emotional Awareness"];
    [arrCategories addObject:@"Emotional Intelligence"];
    [arrCategories addObject:@"Goals & Dreams"];
    [arrCategories addObject:@"Visualization"];
    [arrCategories addObject:@"Inspiring GEMs"];
    [arrCategories addObject:@"Reminders"];
    
    [arrCategories addObject:@"Saved GEMs"];
    [arrCategories addObject:@"Notifications"];
    [arrCategories addObject:@"Privacy Policy"];
    [arrCategories addObject:@"Terms of Service"];
    [arrCategories addObject:@"App Share"];
    [arrCategories addObject:@"Logout"];
    [arrCategories addObject:@"Journal"];
    [_tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 6;
    else
        return 7;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    NSString *title;
    
    
    if (indexPath.section == 0) {
        
        if (indexPath.row < arrCategories.count) {
            title = arrCategories [indexPath.row];
        }
        
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Emotion.png"];
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Intelligence.png"];
        }
        else if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Goal.png"];
        }
        else if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Gem.png"];
        }
        
        else if (indexPath.row == 4) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_CommunityGem.png"];
        }
        
        else if (indexPath.row == 5) {
            cell.imageView.image = [UIImage imageNamed:@"Reminder_Icon.png"];
        }
        
    }else{
        if (indexPath.row < arrCategories.count) {
            title = arrCategories [indexPath.row + 6];
        }
        
        if (indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_SavedGEM.png"];
        }
        else if (indexPath.row == 1) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Notifications.png"];
        }
        else if (indexPath.row == 2) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Privacy.png"];
        }
        else if (indexPath.row == 3) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Terms.png"];
        }
        else if (indexPath.row == 4) {
            cell.imageView.image = [UIImage imageNamed:@"Menu_Share.png"];
        }
        else if (indexPath.row == 5) {
            cell.imageView.image = [UIImage imageNamed:@"LogoutIcon.png"];
        }
        else if (indexPath.row == 6) {
            cell.imageView.image = [UIImage imageNamed:@"LogoutIcon.png"];
        }
        
    }
    
    
    /*
    
    

    else if (indexPath.row == 6) {
        cell.imageView.image = [UIImage imageNamed:@"Menu_Notifications.png"];
    }
    else if (indexPath.row == 7) {
        cell.imageView.image = [UIImage imageNamed:@"Menu_Memoris.png"];
    }
    else if (indexPath.row == 8) {
        cell.imageView.image = [UIImage imageNamed:@"Menu_Help.png"];
    }
    else if (indexPath.row == 9) {
        cell.imageView.image = [UIImage imageNamed:@"Menu_Share.png"];
    }
    else if (indexPath.row == 10) {
        cell.imageView.image = [UIImage imageNamed:@"LogoutIcon.png"];
    }
    */
    
    
    if ([[cell contentView]viewWithTag:kTagForTitle]) {
        UILabel *lblTitle = (UILabel*)[[cell contentView]viewWithTag:kTagForTitle];
        lblTitle.text = title;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 1)return nil;
    
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor getThemeColor];
    //User Profile Pic
    
    /*
    
    UIView *vwLogoPanel = [UIView new];
    [vwHeader addSubview:vwLogoPanel];
    vwLogoPanel.translatesAutoresizingMaskIntoConstraints = NO;
    vwLogoPanel.backgroundColor = [UIColor whiteColor];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwLogoPanel
                                                           attribute:NSLayoutAttributeLeft
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:vwHeader
                                                           attribute:NSLayoutAttributeLeft
                                                          multiplier:1.0
                                                            constant:0.0]];
    [vwLogoPanel addConstraint:[NSLayoutConstraint constraintWithItem:vwLogoPanel
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:40.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwLogoPanel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:-0.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:vwLogoPanel
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    UILabel *lblLogoName = [UILabel new];
    lblLogoName.translatesAutoresizingMaskIntoConstraints = NO;
    [vwLogoPanel addSubview:lblLogoName];
    lblLogoName.textColor = [UIColor blackColor];;
    lblLogoName.font = [UIFont fontWithName:CommonFontBold size:15];;
    lblLogoName.text = @"Purpose Color";
    [vwLogoPanel addConstraint:[NSLayoutConstraint constraintWithItem:lblLogoName
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwLogoPanel
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:10.0]];
    
    [vwLogoPanel addConstraint:[NSLayoutConstraint constraintWithItem:lblLogoName
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwLogoPanel
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:10.0]];*/
    
    
    UIImageView *imgDisplay = [UIImageView new];
    [vwHeader addSubview:imgDisplay];
    imgDisplay.translatesAutoresizingMaskIntoConstraints = NO;
    imgDisplay.clipsToBounds = YES;
    imgDisplay.layer.cornerRadius = 25.f;
    imgDisplay.layer.borderWidth = 3.f;
    imgDisplay.backgroundColor = [UIColor blackColor];
    imgDisplay.layer.borderColor = [UIColor colorWithRed:78/255.f green:169/255.f blue:230/255.f alpha:1].CGColor;
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
                                                          constant:0.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:10.0]];
    
    if ([User sharedManager].profileurl.length) {
        
        [imgDisplay sd_setImageWithURL:[NSURL URLWithString:[User sharedManager].profileurl]
                      placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 
                             }];
    }
    
    imgDisplay.userInteractionEnabled = true;
    
    /*! User Name !*/
    
    UILabel *lblName = [UILabel new];
    lblName.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblName];
    lblName.numberOfLines = 1;
    lblName.textColor = [UIColor whiteColor];;
    lblName.font = [UIFont fontWithName:CommonFontBold size:15];;
    lblName.text = [User sharedManager].name;
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblName
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:20.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblName
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:imgDisplay
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:5.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblName
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-45.0]];
    
    
    
    /*! User Other Details !*/
    
    UILabel *lblOtherInfo = [UILabel new];
    lblOtherInfo.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblOtherInfo];
    lblOtherInfo.numberOfLines = 1;
    lblOtherInfo.font = [UIFont fontWithName:CommonFont size:13];
    lblOtherInfo.textColor = [UIColor whiteColor];;
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblOtherInfo
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:lblName
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:5.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblOtherInfo
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:imgDisplay
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:5.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:lblOtherInfo
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-45.0]];
    
    lblOtherInfo.text = [User sharedManager].email;
    
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.translatesAutoresizingMaskIntoConstraints = NO;
    [btnSettings setImage:[UIImage imageNamed:@"Settings.png"] forState:UIControlStateNormal];
    [btnSettings addTarget:self action:@selector(showSettings)forControlEvents:UIControlEventTouchUpInside];
    [vwHeader addSubview:btnSettings];
    
    
    [btnSettings addConstraint:[NSLayoutConstraint constraintWithItem:btnSettings
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:40]];
    
    [btnSettings addConstraint:[NSLayoutConstraint constraintWithItem:btnSettings
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:40]];
    
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnSettings
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnSettings
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0]];
    
    
    UIButton *btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwHeader addSubview:btnSend];
    btnSend.translatesAutoresizingMaskIntoConstraints = NO;
    [btnSend addTarget:self action:@selector(showProfilePage)
      forControlEvents:UIControlEventTouchUpInside];
    [btnSend setBackgroundColor:[UIColor clearColor]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btnSend]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btnSend]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnSend)]];
    
    
    
    
    
    return vwHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 1) return 40;
    return kHeightForHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.row;
    if (indexPath.section == 1) {
        index = indexPath.row + 6;
    }
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate changeHomePageDynamicallyWithType:index];
    [self.revealViewController rightRevealToggle:nil];
    
}

-(void)showProfilePage{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate changeHomePageDynamicallyWithType:eMenu_Profile];
    [self.revealViewController rightRevealToggle:nil];
}

-(void)showSettings{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate changeHomePageDynamicallyWithType:eMenu_Settings];
      [self.revealViewController rightRevealToggle:nil];
}


-(IBAction)closeSlider:(id)sender{
     [self.revealViewController rightRevealToggle:nil];
}



#pragma mark state preservation / restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}

- (void)applicationFinishedRestoringState {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // TODO call whatever function you need to visually restore
}

@end
