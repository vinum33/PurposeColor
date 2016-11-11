//
//  RegistrationViewController.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define StatusSucess 201

#import "RegistrationViewController.h"
#import "RegistrationPageCustomTableViewCell.h"
#import "Constants.h"
#import "WebBrowserViewController.h"

typedef enum{
    
    eFieldName = 0,
    eFieldEmail = 1,
    eFieldPasword = 2,
    eFieldCPasword = 3,
    eFieldTerms = 4,
    
}ERegistrationField;



#define kTotalFields   5;
#define kCellHeight   60;


@interface RegistrationViewController () <UITextViewDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIView *vwBackground;
    BOOL isTermsApplied;
    ERegistrationField registrationField;
    NSString *name;
    NSString *email;
    NSString *country;
    NSString *countryID;
    NSString *phoneNumber;
    NSString *password;
    NSString *confirmPwd;
    NSInteger indexForTextFieldNavigation;
    NSInteger totalRequiredFieldCount;
    
    CountryListView *countryListView;
    UIView *inputAccView;
}

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    
    // Do any additional setup after loading the view.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.automaticallyAdjustsScrollViewInsets = NO;
    name = [NSString new];
    email = [NSString new];
    country = [NSString new] ;
    phoneNumber = [NSString new];
    password = [NSString new];
    countryID = [NSString new];
    totalRequiredFieldCount = kTotalFields;
}

#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return kTotalFields;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    RegistrationPageCustomTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[RegistrationPageCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    cell.btnCountryDropDown.hidden = true;
    cell.dropDownIcon.hidden = true;
   [cell.btnCountryDropDown addTarget:self action:@selector(showAllCountries) forControlEvents:UIControlEventTouchUpInside];
    cell.entryField.clearButtonMode = UITextFieldViewModeWhileEditing;
    cell.entryField.keyboardType = UIKeyboardTypeDefault;
    cell.entryField.secureTextEntry = false;
    cell.txtView.hidden = true;
    cell.entryField.hidden = false;
    cell.btnCheckBox.hidden = true;
    cell.iconView.hidden = false;
    [cell.btnCheckBox addTarget:self action:@selector(privacyPolicySelected:) forControlEvents:UIControlEventTouchUpInside];
    NSInteger row = indexPath.row;
    switch (row) {
        case eFieldName:
            cell.entryField.placeholder = @"Name";
            cell.iconView.image = [UIImage imageNamed:@"UserIcon.png"];
            cell.entryField.tag = eFieldName;
            cell.entryField.text = name;
            break;
            
        case eFieldEmail:
             cell.entryField.placeholder = @"Email";
             cell.iconView.image = [UIImage imageNamed:@"EmailIcon.png"];
             cell.entryField.tag = eFieldEmail;
             cell.entryField.text = email;
             break;
            
        case eFieldPasword:
            cell.entryField.placeholder = @"Password";
            cell.iconView.image = [UIImage imageNamed:@"PasswordIcon.png"];
            cell.entryField.tag = eFieldPasword;
            cell.btnCountryDropDown.hidden = true;
            cell.dropDownIcon.hidden = true;
            cell.entryField.clearButtonMode = UITextFieldViewModeNever;
            cell.entryField.text = password;
            cell.entryField.secureTextEntry = true;
            break;
            
        case eFieldCPasword:
             cell.entryField.placeholder = @"Confirm Password";
             cell.iconView.image = [UIImage imageNamed:@"PasswordIcon.png"];
             cell.entryField.tag = eFieldCPasword;
             cell.btnCountryDropDown.hidden = true;
             cell.dropDownIcon.hidden = true;
             cell.entryField.clearButtonMode = UITextFieldViewModeNever;
             cell.entryField.text = confirmPwd;
             cell.entryField.secureTextEntry = true;
             break;

        case eFieldTerms:
            cell.txtView.hidden = false;
            cell.entryField.hidden = true;
            cell.btnCheckBox.hidden = false;
            cell.iconView.hidden = true;
            cell.txtView.dataDetectorTypes = UIDataDetectorTypeLink;
            cell.txtView.editable = NO;
            cell.txtView.delegate = self;
            NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"I agree to the terms of service and privacy policy."];
            [str addAttribute: NSLinkAttributeName value:[NSString stringWithFormat:@"%@terms.php",BaseURL] range: NSMakeRange(15, 16)];
            [str addAttribute: NSLinkAttributeName value:[NSString stringWithFormat:@"%@privacy_policy.php",BaseURL] range: NSMakeRange(36, 15)];
            [str addAttribute:NSFontAttributeName  value:[UIFont fontWithName:CommonFont size:14] range:NSMakeRange(0, str.length)];
             cell.txtView.attributedText = str;
             break;
            
       
            
       
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [self showBrowserWithURL:URL];
    return NO;
}


#pragma mark - TextField Delegates


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
        RegistrationPageCustomTableViewCell *cell = (RegistrationPageCustomTableViewCell*)textField.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:cell.entryField];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    [self createInputAccessoryView];
    [textField setInputAccessoryView:inputAccView];
    // activeTextField = textField;
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
    
//    if (indexForTextFieldNavigation == eFieldCountry) {
//        [self showAllCountries];
//    }
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    
}






- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL allowed = YES;
    // Prevent invalid character input, if keyboard is numberpad
    if (textField.keyboardType == UIKeyboardTypeNumberPad)
    {
        if ([string rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
        {
            // BasicAlert(@"", @"This field accepts only numeric entries.");
            allowed =  NO;
        }
    }
    
    return allowed;
}


-(BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Registration Methods

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
    
    RegistrationPageCustomTableViewCell *nextCell = (RegistrationPageCustomTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
    if (!nextCell) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        nextCell = (RegistrationPageCustomTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexForTextFieldNavigation inSection:0]];
        
    }
    [nextCell.entryField becomeFirstResponder];
    
}

-(void)doneTyping{
    [self.view endEditing:YES];
    
}


-(void)getTextFromField:(UITextField*)textField{
   
    NSString *string = textField.text;
    NSInteger tag = textField.tag;
    switch (tag) {
        case eFieldName:
            name = string;
            break;
        case eFieldEmail:
            email = string;
            break;
        case eFieldPasword:
            password = string;
            break;
//        case eFieldCountry:
//            //[self showAllCountries];
//            break;
        case eFieldCPasword:
            confirmPwd = string;
            break;
        default:
            break;
    }
   
}

-(IBAction)privacyPolicySelected:(UIButton*)sender{
    
    if (sender.tag == 0) {
        sender.tag = 1;
        isTermsApplied = true;
        [sender setImage:[UIImage imageNamed:@"CheckBox_Goals_Active.png"] forState:UIControlStateNormal];
    }else{
        sender.tag = 0;
        isTermsApplied = false;
        [sender setImage:[UIImage imageNamed:@"CheckBox_Goals.png"] forState:UIControlStateNormal];
    }
    
}




-(IBAction)tapToRegister:(id)sender{
    
    [self checkAllFieldsAreValid:^{
        [self showLoadingScreen];
        [APIMapper registerUserWithName:name userEmail:email phoneNumber:phoneNumber countryID:countryID userPassword:password
                                success:^(AFHTTPRequestOperation *operation, id responseObject){
            
                                    NSDictionary *responds = (NSDictionary*)responseObject;
                                    NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
                                    if (statusCode == StatusSucess)[self gotoLoginPage];
                                    if ( NULL_TO_NIL( [responds objectForKey:@"text"]))
                                         [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"SignUp"];
                                    [self hideLoadingScreen];
                           
                                }
         
                                failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                    
                                 [self showAlertWithMessage:[error localizedDescription] title:@"SignUp"];
                                 [self hideLoadingScreen];
                                    
                                }];
        
    } failure:^(NSString *error) {
        
        // Field validation error block
        [self showAlertWithMessage:error title:@"SignUp"];
        
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
-(void)checkAllFieldsAreValid:(void (^)())success failure:(void (^)(NSString *error))failure{
    
    NSString *errorMessage;
    BOOL isValid = false;
    if ((name.length) && (email.length) && (confirmPwd.length) && (password.length) > 0){
        isValid = [email isValidEmail] ? YES : NO;
        errorMessage = @"Please enter a valid Email address";
        if (isValid) {
            if (![password isEqualToString:confirmPwd]){
                errorMessage = @"Password doesn't match";
                isValid = false;
            }else{
                isValid = true;
            }
        }
        
        if (!isTermsApplied) {
            errorMessage = @"Agree terms and conditions.";
            isValid = false;
        }
        
    }else{
          errorMessage = @"Please Fill all the fields.";
    }   
   
    if (isValid)success();
    else failure(errorMessage);

}

-(void)showAlertWithMessage:(NSString*)alertMessage title:(NSString*)alertTitle{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)gotoLoginPage{
    [[self navigationController]popViewControllerAnimated:YES];
    [self.view endEditing:YES];
}

-(void)showBrowserWithURL:(NSURL*)url{
    
    WebBrowserViewController *browser = [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForWebBrowser];
    browser.strTitle = @"TERMS OF SERVICE";
    NSArray* pathComponents = [url pathComponents];
    if ([[pathComponents lastObject] isEqualToString:@"privacy_policy.php"]) {
        browser.strTitle = @"PRIVACY POLICY";
    }
    browser.strURL = [url absoluteString];
    [[self navigationController]pushViewController:browser animated:YES];
    
}

#pragma mark - Country Listing Methods

-(void)showAllCountries{
    
    if (!countryListView) {
        
         countryListView = [CountryListView new];
         [self.view addSubview:countryListView];
        countryListView.delegate = self;
        countryListView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[countryListView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(countryListView)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[countryListView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(countryListView)]];
        
        countryListView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
          // animate it to the identity transform (100% scale)
          countryListView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
    }
    
    countryListView.selectedCountryID = countryID;
    [self.view endEditing:YES];
    [countryListView setUp];
}

-(void)closeCountryPopUpAfterADelay:(float)delay{
    
    [UIView animateWithDuration:0.2 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        countryListView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [countryListView removeFromSuperview];
        countryListView = nil;
    }];
}

-(void)sendSelectedCountryDetailsToRegisterPage:(NSDictionary*)countryDetails{
    
    // CallBack when user tapped any Country from country list
    if ( NULL_TO_NIL([countryDetails objectForKey:@"name"])) {
        country = [countryDetails objectForKey:@"name"];
        countryID = [countryDetails objectForKey:@"id"];
    }
       [tableView reloadData]; 
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
