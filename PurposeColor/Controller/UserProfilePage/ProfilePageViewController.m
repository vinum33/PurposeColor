//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

typedef enum{
    
    eFieldName = 0,
    eFieldMemberShip = 1,
    eFieldEmail = 2,
    eFieldStatus = 3,
    eFieldFollowSettings = 4
    
}EField;


#define kTagForTitle            1
#define kCellHeight             50
#define kCellHeightForStatus    70
#define kHeightForHeader        300
#define kEmptyHeaderAndFooter   001
#define kSuccessCode            200


#import "ProfilePageViewController.h"
#import "Constants.h"
#import "MenuViewController.h"
#import "ChangePasswordPopUp.h"
#import "PhotoBrowser.h"



@interface ProfilePageViewController () <UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,SWRevealViewControllerDelegate,ChangePasswordPopUpDelegate,PhotoBrowserDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UIButton *btnMore;
   
    IBOutlet UIView *vwOverLay;
    
    NSString *strEmail;
    NSString *strName;
    NSString *profileURL;
    double  regDate;
    NSString *strStatusMsg;
    NSInteger verifiedStatus;
    NSInteger indexForTextFieldNavigation;
    UIView *inputAccView;
    BOOL canFollow;
    BOOL _isEditing;
    UIImage *imgProfilePic;
    ChangePasswordPopUp *changePwdPopUp;
    PhotoBrowser *photoBrowser;
}

@end

@implementation ProfilePageViewController{
    
}



-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self setUp];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.automaticallyAdjustsScrollViewInsets=NO;
   
    
}



-(void)loadUserProfileWithUserID:(NSString*)userID showBackButton:(BOOL)showBckButton{
    
    [self showLoadingScreen];
    [APIMapper getUserProfileWithUserID:userID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self parseResponds:responseObject];
        [self hideLoadingScreen];
        [self initialiseShowBackButton:showBckButton];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
        [self initialiseShowBackButton:showBckButton];
        
    }];
    
}

-(void)initialiseShowBackButton:(BOOL)showBackButton{
    
    _btnSlideMenu.hidden = true;
    _btnBack.hidden = true;
    
    if (showBackButton) {
        _btnBack.hidden = false;
    }else{
        _btnSlideMenu.hidden = false;
    }
}

-(void)parseResponds:(NSDictionary*)details{
    
    if ([[details objectForKey:@"code"] integerValue] == kSuccessCode) {
        
        if (NULL_TO_NIL([details objectForKey:@"email"])) {
            strEmail = [details objectForKey:@"email"];
        }
        if (NULL_TO_NIL([details objectForKey:@"firstname"])) {
            strName = [details objectForKey:@"firstname"];
        }
        if (NULL_TO_NIL([details objectForKey:@"regdate"])) {
            regDate = [[details objectForKey:@"regdate"] doubleValue];
        }
        if (NULL_TO_NIL([details objectForKey:@"status"])) {
            strStatusMsg = [details objectForKey:@"status"];
        }
        if (NULL_TO_NIL([details objectForKey:@"profileurl"])) {
            profileURL = [details objectForKey:@"profileurl"];
        }
        if (NULL_TO_NIL([details objectForKey:@"follow_status"])) {
            canFollow = [[details objectForKey:@"follow_status"] boolValue];
        }
    }
    [tableView reloadData];
     btnSubmit.hidden = true;
     btnMore.hidden = true;
    if (_canEdit) {
        btnSubmit.hidden = false;
        btnMore.hidden = false;
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_canEdit) {
        //return 5;
    }
    return 4;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == eFieldName) {
        cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"BasicInfo"];
        
        if ([cell.contentView viewWithTag:2]) {
            UIButton *btnPwdChange = (UIButton*)[cell.contentView viewWithTag:2];
            btnPwdChange.hidden = true;
        }

    }
    else if (indexPath.row == eFieldMemberShip) {
        cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"BasicInfo"];
        if ([cell.contentView viewWithTag:2]) {
            UIButton *btnPwdChange = (UIButton*)[cell.contentView viewWithTag:2];
            btnPwdChange.hidden = true;
        }

    }
    else if (indexPath.row == eFieldEmail) {
        cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"BasicInfo"];
        
        if ([cell.contentView viewWithTag:2]) {
            UIButton *btnPwdChange = (UIButton*)[cell.contentView viewWithTag:2];
            btnPwdChange.hidden = true;
            if (_canEdit) {
                btnPwdChange.hidden = false;
            }
        }
        
    }
    else if (indexPath.row == eFieldStatus) {
        cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"StatusInfo"];
    }
   
    else if (indexPath.row == eFieldFollowSettings) {
        cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"SettingsInfo"];
    }
    
    [self configureCellWithCell:cell indexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.93 green:0.95 blue:1.00 alpha:1.0];

   
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == eFieldName) {
        return kCellHeight;
    }
    else if (indexPath.row == eFieldEmail) {
        if (_canEdit) {
            return 80;
        }
        return 30;
        
    }
    else if (indexPath.row == eFieldMemberShip) {
        return 30;
    }
    else if (indexPath.row == eFieldStatus) {
        return kCellHeightForStatus;
    }
    return kCellHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor clearColor];
    //User Profile Pic
    
    UIImageView *imgBG = [UIImageView new];
    [vwHeader addSubview:imgBG];
    imgBG.translatesAutoresizingMaskIntoConstraints = NO;
    imgBG.contentMode = UIViewContentModeScaleAspectFill;
    imgBG.image = [UIImage imageNamed:@"Profile_BG.png"];
    
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imgBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imgBG)]];
    [imgBG addConstraint:[NSLayoutConstraint constraintWithItem:imgBG
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:200.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgBG
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:vwHeader
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:0.0]];
    
   
    
    UIImageView *imgDisplay = [UIImageView new];
    [vwHeader addSubview:imgDisplay];
    imgDisplay.translatesAutoresizingMaskIntoConstraints = NO;
    imgDisplay.clipsToBounds = YES;
    imgDisplay.layer.cornerRadius = 50.f;
    imgDisplay.layer.borderWidth = 7.f;
    imgDisplay.backgroundColor = [UIColor blackColor];
    imgDisplay.layer.borderColor = [UIColor whiteColor].CGColor;
    imgDisplay.userInteractionEnabled = true;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserPhotoGallery)];
    [imgDisplay addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    imgDisplay.userInteractionEnabled = true;
    imgDisplay.contentMode = UIViewContentModeScaleAspectFill;
    [imgDisplay addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:100.0]];
    [imgDisplay addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:100.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-50]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
    
       
    if (profileURL.length) {
        
        if (imgProfilePic) {
            [imgDisplay setImage:imgProfilePic];
        }else{
            [imgDisplay sd_setImageWithURL:[NSURL URLWithString:profileURL]
                          placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                     
                                 }];
        }
        
    }
    
    UIButton* btnCamera = [UIButton new];
    btnCamera.backgroundColor = [UIColor clearColor];
    btnCamera.translatesAutoresizingMaskIntoConstraints = NO;
    [btnCamera setImage:[UIImage imageNamed:@"Camera_Button.png"] forState:UIControlStateNormal];
    [btnCamera addTarget:self action:@selector(showCamera:) forControlEvents:UIControlEventTouchUpInside];
    [vwHeader addSubview:btnCamera];
    
    [btnCamera addConstraint:[NSLayoutConstraint constraintWithItem:btnCamera
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:50]];
    [btnCamera addConstraint:[NSLayoutConstraint constraintWithItem:btnCamera
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:50]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnCamera
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-50]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:btnCamera
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0]];
    if (!_isEditing) btnCamera.hidden = true;
    return vwHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section{
    
    return kEmptyHeaderAndFooter;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

-(void)configureCellWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    switch (indexPath.row) {
        case eFieldName:
            if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UITextField class]]) {
                UITextField *txtField = [[cell contentView]viewWithTag:1];
                txtField.font = [UIFont fontWithName:CommonFont size:25];
                txtField.textAlignment = NSTextAlignmentCenter;
                txtField.text = strName;
                [txtField setBorderStyle:UITextBorderStyleNone];
                txtField.layer.borderColor = [UIColor clearColor].CGColor;
                txtField.backgroundColor = [UIColor clearColor];
                txtField.delegate = self;
                txtField.userInteractionEnabled = false;
                if (_isEditing) {
                    txtField.layer.borderWidth = 1.f;
                    txtField.layer.borderColor = [UIColor getSeperatorColor].CGColor;
                    txtField.userInteractionEnabled = true;
                }
                break;
            }
        case eFieldEmail:
            if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UITextField class]]) {
                UITextField *txtField = [[cell contentView]viewWithTag:1];
                txtField.font = [UIFont fontWithName:CommonFont size:18];
                txtField.textAlignment = NSTextAlignmentCenter;
                txtField.text = strEmail;
                txtField.delegate = nil;
                txtField.userInteractionEnabled = false;
                [txtField setBorderStyle:UITextBorderStyleNone];
                break;
            }
        case eFieldMemberShip:
            if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UITextField class]]){
                UITextField *txtField = [[cell contentView]viewWithTag:1];
                txtField.text = [NSString stringWithFormat:@"Member since %@",[self getDaysBetweenTwoDatesWith:regDate]];
                txtField.font = [UIFont fontWithName:CommonFont size:15];
                txtField.textAlignment = NSTextAlignmentCenter;
                txtField.delegate = nil;
                txtField.userInteractionEnabled = false;
                [txtField setBorderStyle:UITextBorderStyleNone];
                break;
            }
        case eFieldStatus:
            if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UITextView class]]){
                UITextView *txtField = [[cell contentView]viewWithTag:1];
                txtField.text = strStatusMsg;
                txtField.font = [UIFont fontWithName:CommonFont size:17];
                txtField.textAlignment = NSTextAlignmentCenter;
                txtField.layer.borderWidth = 0.f;
                txtField.layer.borderColor = [UIColor clearColor].CGColor;
                txtField.backgroundColor = [UIColor clearColor];
                if (_isEditing) {
                    txtField.layer.borderWidth = 1.f;
                    txtField.layer.borderColor = [UIColor getSeperatorColor].CGColor;
                    
                }
                break;
            }
       
        case eFieldFollowSettings:
            if ([[cell contentView]viewWithTag:1]) {
                UILabel *lblSettings = [[cell contentView]viewWithTag:1];
                lblSettings.text = @"Can be followed";
                lblSettings.font = [UIFont fontWithName:CommonFont size:16];
            }
            if ([[cell contentView]viewWithTag:2]) {
                UISwitch *_switch = [[cell contentView]viewWithTag:2];
                [_switch setOn:canFollow];
                _switch.userInteractionEnabled = true;
                 if (!_isEditing) _switch.userInteractionEnabled = false;
                
            }
           
            break;
        default:
            break;
    }
    
}

#pragma mark - UITextfield delegate methods


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        UITableViewCell *cell = (UITableViewCell*)textField.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UITextField class]]){
            UITextField *txtField = [[cell contentView]viewWithTag:1];
        [self getTextFromField:txtField];
    }
}
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self createInputAccessoryView];
    [textField setInputAccessoryView:inputAccView];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        indexForTextFieldNavigation = indexPath.row;
    }
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height );
    [tableView setContentOffset:contentOffset animated:YES];
    
   
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}

#pragma mark - UITextView delegate methods


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if (!_isEditing) return false;
    [self createInputAccessoryView];
    [textView setInputAccessoryView:inputAccView];
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
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
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        UITableViewCell *cell = (UITableViewCell*)textView.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        if ([[[cell contentView]viewWithTag:1] isKindOfClass:[UITextView class]]){
            UITextView *txtField = [[cell contentView]viewWithTag:1];
            [self getTextFromField:txtField];
        }
    }
    
    return YES;
}


-(void)getTextFromField:(id)obj{
    if ([obj isKindOfClass:[UITextView class]]) {
        UITextView *txtField = (UITextView*)obj;
        NSString *string = txtField.text;
        strStatusMsg = string;
        
    }else{
        UITextField *txtField = (UITextField*)obj;
        NSString *string = txtField.text;
        strName = string;
    }
    
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha: 1];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(inputAccView.frame.size.width - 85, 1.0f, 85.0f, 38.0f)];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor getThemeColor]];
     [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDone.layer.cornerRadius = 5.f;
    btnDone.layer.borderWidth = 1.f;
    btnDone.layer.borderColor = [UIColor clearColor].CGColor;
    btnDone.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    [inputAccView addSubview:btnDone];
}


-(void)doneTyping{
    [self.view endEditing:YES];
}

-(IBAction)changeFolloStatus:(UISwitch*)mySwitch{
    
    if ([mySwitch isOn]) {
        canFollow = true;
    } else {
        canFollow = false;
    }
}


-(IBAction)showCamera:(id)sender{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    UIImage *image =[Utility fixrotation:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    imgProfilePic = image;
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
    [tableView reloadData];
}



#pragma mark - Change Password Methods and Delegates


-(IBAction)showChangePwdPopUp:(id)sender{
    
    if (!changePwdPopUp) {
        
        changePwdPopUp = [ChangePasswordPopUp new];
        [self.view addSubview:changePwdPopUp];
        changePwdPopUp.delegate = self;
        changePwdPopUp.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.7];;
        changePwdPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[changePwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(changePwdPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[changePwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(changePwdPopUp)]];
        
        changePwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            changePwdPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [changePwdPopUp setUp];
}



-(void)closeForgotPwdPopUpAfterADelay:(float)delay{
    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        changePwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [changePwdPopUp removeFromSuperview];
        changePwdPopUp = nil;
    }];
}



-(IBAction)editOrSubmitDetails:(UIButton*)sender{
    
    [self.view endEditing:YES];
    
    if (sender.tag == 0) {
        sender.tag = 1;
        [sender setImage:[UIImage imageNamed:@"Profile_Submit.png"] forState:UIControlStateNormal];
        _isEditing = true;
        [tableView reloadData];
        // Edit
    }else{
        sender.tag = 0;
        if (strName.length > 0 && strStatusMsg.length > 0) {
            [self showLoadingScreen];
            [APIMapper updateUserProfileWithUserID:[User sharedManager].userId firstName:strName statusMsg:strStatusMsg image:imgProfilePic canFollow:canFollow success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self hideLoadingScreen];
                if ( NULL_TO_NIL([responseObject objectForKey:@"header"])) {
                    if ([[[responseObject objectForKey:@"header"] objectForKey:@"code"]integerValue] == kSuccessCode) {
                        [[[UIAlertView alloc] initWithTitle:@"Profile" message:@"Successfully updated your profile!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                        _isEditing = false;
                        [tableView reloadData];
                        [self updateUserInfoWithDetails:responseObject];
                        [self goBack:nil];
                        [btnSubmit setImage:[UIImage imageNamed:@"Edit_White_Icon.png"] forState:UIControlStateNormal];
                        
                    }else
                        
                        if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                            
                            if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"PROFILE"
                                                                                    message:[responseObject objectForKey:@"text"]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                [delegate clearUserSessions];
                                
                            }
                            
                        }else{
                             [[[UIAlertView alloc] initWithTitle:@"Profile" message:@"Failed to Update Profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                        }
                        
                    
                }
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                [self hideLoadingScreen];
                
            }];
        }else{
            [ALToastView toastInView:self.view withText:@"Please fill the Fields"];
        }
    }
   
    
}

-(void)updateUserInfoWithDetails:(NSDictionary*)userInfo{
    
    if ( NULL_TO_NIL([userInfo objectForKey:@"header"])) {
        
        NSDictionary *userDetails = [userInfo objectForKey:@"header"];
        
        if (NULL_TO_NIL([userDetails objectForKey:@"firstname"])) {
            [User sharedManager].name  = [userDetails objectForKey:@"firstname"];
        }
        
        if (NULL_TO_NIL([userDetails objectForKey:@"profile_url"])) {
            [User sharedManager].profileurl  = [userDetails objectForKey:@"profile_url"];
        }
       
        /*!............ Saving user to NSUserDefaults.............!*/
        
        [Utility saveUserObject:[User sharedManager] key:@"USER"];
    }
    
    
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

-(IBAction)closeSlider:(id)sender{
    
}

-(NSString*)getDaysBetweenTwoDatesWith:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
        NSString *msgDate;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM yyyy"];
    msgDate = [dateformater stringFromDate:refDate];
    return msgDate;
    
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


#pragma mark - Photo Browser & Deleagtes

-(void)showUserPhotoGallery{
    
    NSArray *images = [NSArray arrayWithObject:[NSURL URLWithString:profileURL]];
    [self presentGalleryWithImages:images];
}


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







@end
