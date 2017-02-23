//
//  ViewController.m
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eUserName = 0,
    ePasword = 1,
    
    
}eLogInfo;


#define StatusSucess            200

#define kCellHeight             75;
#define kHeightForHeader        150;
#define kHeightForFooter        125;
#define kMaxReviewLength        150
#define kMaxReviewTitleLength   50
#define kSuccessCode            200

#import "LoginViewController.h"
#import "RegistrationViewController.h"
#import "ForgotPasswordPopUp.h"
#import "Constants.h"
#import "CustomCellForLogin.h"

@interface LoginViewController (){
    
    IBOutlet UITableView *tableView;
    
    UIView *inputAccView;
    NSInteger indexForTextFieldNavigation;
    NSString *password;
    NSString *userName;
    NSInteger totalRequiredFieldCount;
    
    ForgotPasswordPopUp *forgotPwdPopUp;
    StateListViewPopUp  *stateListingPopUp;
   
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
   
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}
-(void)setUp{
    
    totalRequiredFieldCount = 2;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.allowsSelection = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return totalRequiredFieldCount;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"reuseIdentifier";
    CustomCellForLogin *cell = (CustomCellForLogin *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.txtField.keyboardType = UIKeyboardTypeDefault;
    cell.txtField.tag = indexPath.row;
    cell.backgroundColor = [UIColor whiteColor];
    cell = [self configureCellWithCaseValue:indexPath.row cell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return  kHeightForFooter;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor clearColor];
    
    UIImageView *imgLogo = [UIImageView new];
    imgLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:imgLogo];
    imgLogo.image = [UIImage imageNamed:@"Logo.png"];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgLogo
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgLogo
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    
    [imgLogo addConstraint:[NSLayoutConstraint constraintWithItem:imgLogo
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:80]];
    
    [imgLogo addConstraint:[NSLayoutConstraint constraintWithItem:imgLogo
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:80]];
    
    
    
    return vwHeader;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnLogin = [UIButton new];
    btnLogin.backgroundColor = [UIColor getThemeColor];
    btnLogin.translatesAutoresizingMaskIntoConstraints = NO;
    [btnLogin setTitle:@"LOGIN" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnLogin addTarget:self action:@selector(tapToLogin:) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnLogin];
    
    [btnLogin addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeHeight
                                                       multiplier:1.0
                                                         constant:45]];
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:25]];
    
     NSArray *horizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[btnLogin]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnLogin)];
    [vwFooter addConstraints:horizontalConstraints];
    
    

    UIButton* btnForgotPwd = [UIButton new];
    btnForgotPwd.backgroundColor = [UIColor clearColor];
    btnForgotPwd.translatesAutoresizingMaskIntoConstraints = NO;
    [btnForgotPwd setTitle:@"Forgot Password" forState:UIControlStateNormal];
    [btnForgotPwd setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnForgotPwd.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnForgotPwd addTarget:self action:@selector(tappedForgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    [btnForgotPwd setTitleEdgeInsets:UIEdgeInsetsMake(0, -16, 0, 0)];//set ur title insects
    [vwFooter addSubview:btnForgotPwd];
    
    [btnForgotPwd addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:40]];
    
    [btnForgotPwd addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:120]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:btnLogin
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:5]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnForgotPwd
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:10]];
    
    
    UIButton* btnRegister = [UIButton new];
    btnRegister.backgroundColor = [UIColor clearColor];
    btnRegister.translatesAutoresizingMaskIntoConstraints = NO;
    [btnRegister setTitle:@"Sign Up" forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:CommonFontBold size:14];
    [btnRegister addTarget:self action:@selector(tappedRegisterAccount:) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnRegister];
    [btnRegister setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -5)];//set ur title insects
    
    [btnRegister addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:40]];
    [btnRegister addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:60]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:btnLogin
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:5]];
    
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnRegister
                                                         attribute:NSLayoutAttributeRight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:-10]];

    
   

    
    
    
    return vwFooter;
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
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:textField];
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



-(CustomCellForLogin*)configureCellWithCaseValue:(NSInteger)position cell:(CustomCellForLogin*)cell{
    cell.txtField.secureTextEntry = YES;
     cell.txtField.placeholder = @"Password";
    cell.imgIcon.image = [UIImage imageNamed:@"PasswordIcon.png"];
    if(position == eUserName){
        cell.txtField.secureTextEntry = NO;
        cell.imgIcon.image = [UIImage imageNamed:@"UserIcon.png"];
        cell.txtField.placeholder = @"Email";
    }
    return cell;
    
}

#pragma mark - Login Actions


-(void)getTextFromField:(UITextField*)textField{
    
    NSString *string = textField.text;
    NSInteger tag = textField.tag;
    switch (tag) {
        case eUserName:
            userName = string;
            break;
        case ePasword:
            password = string;
            break;
            
            default:
            break;
    }
    
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha: 1];
    
    UIButton *btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnPrev setFrame: CGRectMake(0.0, 1.0, 80.0, 38.0)];
    [btnPrev setTitle: @"Previous" forState: UIControlStateNormal];
    [btnPrev setBackgroundColor: [UIColor blueColor]];
    btnPrev.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    btnPrev.layer.cornerRadius = 5.f;
    btnPrev.layer.borderWidth = 1.f;
    btnPrev.layer.borderColor = [UIColor clearColor].CGColor;
    [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(85.0f, 1.0f, 80.0f, 38.0f)];
    [btnNext setTitle:@"Next" forState:UIControlStateNormal];
    [btnNext setBackgroundColor:[UIColor blueColor]];
    btnNext.layer.cornerRadius = 5.f;
    btnNext.layer.borderWidth = 1.f;
    btnNext.layer.borderColor = [UIColor clearColor].CGColor;
    btnNext.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    [inputAccView addSubview:btnPrev];
    [inputAccView addSubview:btnNext];
    [inputAccView addSubview:btnDone];
}

-(void)gotoPrevTextfield{
    
    if (indexForTextFieldNavigation - 1 < 0) indexForTextFieldNavigation = 0;
    else indexForTextFieldNavigation -= 1;
    [self gotoTextField];
    
}

-(void)gotoNextTextfield{
    
    if (indexForTextFieldNavigation + 1 < totalRequiredFieldCount) indexForTextFieldNavigation += 1;
    [self gotoTextField];
}

-(void)gotoTextField{
    
    CustomCellForLogin *nextCell = (CustomCellForLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
    if (!nextCell) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        nextCell = (CustomCellForLogin *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
        
    }
    [nextCell.txtField becomeFirstResponder];
    
}

-(void)doneTyping{
    [self.view endEditing:YES];
    
}

-(IBAction)tapToLogin:(id)sender{
    [self bypasslogin];
    return;
    
    [self checkAllFieldsAreValid:^{
        [self showLoadingScreen];
        [APIMapper loginUserWithUserName:userName userPassword:password
                                success:^(AFHTTPRequestOperation *operation, id responseObject){
                                    NSDictionary *responds = (NSDictionary*)responseObject;
                                    if ( NULL_TO_NIL([responds objectForKey:@"code"])) {
                                        NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
                                        if (statusCode == StatusSucess) {
                                            [self createUserWithInfo:responseObject];
                                            [[self delegate]goToHomeAfterLogin];
                                        }
                                        else{
                                            if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                                                [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
                                        }
                                    }
                                    [self hideLoadingScreen];
                                }
                                 failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                     
                                     [self showAlertWithMessage:[error localizedDescription] title:@"Login"];
                                     [self hideLoadingScreen];
                                     
                                 }];
        
        
    }failure:^(NSString *errorMsg) {
        
        [self showAlertWithMessage:errorMsg title:@"Login"];
        
    }];
    
}

-(void)bypasslogin{
    
    [APIMapper loginUserWithUserName:@"nadeer@purposecodes.com" userPassword:@"123456"
                             success:^(AFHTTPRequestOperation *operation, id responseObject){
                                 NSDictionary *responds = (NSDictionary*)responseObject;
                                 if ( NULL_TO_NIL([responds objectForKey:@"code"])) {
                                     NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
                                     if (statusCode == StatusSucess) {
                                         [self createUserWithInfo:responseObject];
                                         [[self delegate]goToHomeAfterLogin];
                                     }
                                     else{
                                         if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                                             [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
                                     }
                                 }
                                 [self hideLoadingScreen];
                             }
                             failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                 
                                 [self showAlertWithMessage:[error localizedDescription] title:@"Login"];
                                 [self hideLoadingScreen];
                                 
                             }];
}


-(void)checkAllFieldsAreValid:(void (^)())success failure:(void (^)(NSString *errorMsg))failure{
    
    [self.view endEditing:YES];
    BOOL isValid = false;
    NSString *errorMsg;
    if ((userName.length) && (password.length) > 0) {
        isValid = true;
        if (![userName isValidEmail]) {
            
            errorMsg = @"Enter a valid Email address.";
            isValid = false;
        }
    }else{
        
          errorMsg = @"Enter Email and Password.";
    }
    if (isValid)success();
    else failure(errorMsg);
    
}

-(void)showAlertWithMessage:(NSString*)alertMessage title:(NSString*)alertTitle{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:alertTitle
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
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

-(void)createUserWithInfo:(NSDictionary*)userDetails{
    
     if ([[userDetails objectForKey:@"code"] integerValue] == kSuccessCode) {
         
         if ([userDetails objectForKey:@"user_id"]) {
             [User sharedManager].userId = [userDetails objectForKey:@"user_id"];
         }
         if ([userDetails objectForKey:@"usertype_id"]) {
             [User sharedManager].userTypeId  = [userDetails objectForKey:@"usertype_id"];
         }
         if ([userDetails objectForKey:@"firstname"]) {
             [User sharedManager].name  = [userDetails objectForKey:@"firstname"];
         }
         if ([userDetails objectForKey:@"email"]) {
             [User sharedManager].email  = [userDetails objectForKey:@"email"];
         }
         if ([userDetails objectForKey:@"regdate"]) {
             [User sharedManager].regDate  = [userDetails objectForKey:@"regdate"];
         }
         if ([userDetails objectForKey:@"logged_status"]) {
             [User sharedManager].loggedStatus  = [userDetails objectForKey:@"logged_status"];
         }
         if ([userDetails objectForKey:@"verified_status"]) {
             [User sharedManager].verifiedStatus  = [userDetails objectForKey:@"verified_status"];
         }
         if ([userDetails objectForKey:@"profileurl"]) {
             [User sharedManager].profileurl  = [userDetails objectForKey:@"profileurl"];
         }
         if ([userDetails objectForKey:@"cartcount"]) {
             [User sharedManager].cartCount  = [[userDetails objectForKey:@"cartcount"] integerValue];
         }
         if ([userDetails objectForKey:@"notificationcount"]) {
             [User sharedManager].notificationCount  = [[userDetails objectForKey:@"notificationcount"] integerValue];
         }
         if ([userDetails objectForKey:@"company_id"]) {
             [User sharedManager].companyID  = [userDetails objectForKey:@"company_id"];
         }
         if ([userDetails objectForKey:@"status"]) {
             [User sharedManager].statusMsg  = [userDetails objectForKey:@"status"];
         }
         if ([userDetails objectForKey:@"follow_status"]) {
             [User sharedManager].follow_status  = [[userDetails objectForKey:@"follow_status"] boolValue];
         }
         if ([userDetails objectForKey:@"daily_notify"]) {
             [User sharedManager].daily_notify  = [[userDetails objectForKey:@"daily_notify"] boolValue];
         }
         
         
         
         /*!............ Saving user to NSUserDefaults.............!*/
         
         [Utility saveUserObject:[User sharedManager] key:@"USER"];
     }
    
 
}





-(IBAction)tappedRegisterAccount:(id)sender{
    
    RegistrationViewController *registerPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForRegistrationPage];
    if (registerPage) {
        
        [[self navigationController]pushViewController:registerPage animated:YES];
    }
    
}


#pragma mark - Forgot Password Methods and Delegates


-(IBAction)tappedForgetPassword:(id)sender{
    
    if (!forgotPwdPopUp) {
        
        forgotPwdPopUp = [ForgotPasswordPopUp new];
        [self.view addSubview:forgotPwdPopUp];
        forgotPwdPopUp.delegate = self;
        forgotPwdPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[forgotPwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(forgotPwdPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[forgotPwdPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(forgotPwdPopUp)]];
        
        forgotPwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            forgotPwdPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [self.view endEditing:YES];
    [forgotPwdPopUp setUp];
}



-(void)closeForgotPwdPopUpAfterADelay:(float)delay{
    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        forgotPwdPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [forgotPwdPopUp removeFromSuperview];
        forgotPwdPopUp = nil;
    }];
}





#pragma mark - State Listing Methods and Delegates

/*!.... Listing all the states to choose the user state, because all listing of templates are based on these States.Only one company is registered under one state.     ..........!*/

-(void)showAllStatesWhichHoldsTheCompaniesWithResponds:(NSDictionary*)responds{
    
    if (!stateListingPopUp) {
        
        stateListingPopUp = [StateListViewPopUp new];
        [self.view addSubview:stateListingPopUp];
        stateListingPopUp.delegate = self;
        if ([responds objectForKey:@"company"]) {
            stateListingPopUp.arrStates = [responds objectForKey:@"company"];
        }
        if ([[responds objectForKey:@"header"] objectForKey:@"user_id"]) {
            stateListingPopUp.userID = [[responds objectForKey:@"header"] objectForKey:@"user_id"];
        }
        
        stateListingPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[stateListingPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(stateListingPopUp)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[stateListingPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(stateListingPopUp)]];
        
        stateListingPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            stateListingPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
    }
    
    [self.view endEditing:YES];
    [stateListingPopUp setUp];
}

-(void)closeStateListingPopUpAfterADelay:(float)delay{
    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        stateListingPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [stateListingPopUp removeFromSuperview];
        stateListingPopUp = nil;
    }];
}

-(void)updateStateDetailsToBackEnd:(NSDictionary*)stateDetails withUserID:(NSString*)userID{
    
  }

-(IBAction)goBack:(id)sender{
    
    [[self navigationController]popViewControllerAnimated:YES];
}


#pragma mark - Textfield Delegates


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
   [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




@end
