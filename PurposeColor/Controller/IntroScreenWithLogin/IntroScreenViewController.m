//
//  IntroScreenViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import "IntroScreenViewController.h"
#import "Constants.h"
#import "WebBrowserViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Google/SignIn.h>
#import "LoginViewController.h"
#import "RegistrationViewController.h"

#define StatusSucess            200

@interface IntroScreenViewController ()<FBSDKLoginButtonDelegate,GIDSignInDelegate,GIDSignInUIDelegate>{
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UITextView *txtView;
    FBSDKLoginButton *btnFBSignin;
}

@end

@implementation IntroScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self enableGoogleAndFBSignIn];
  }


-(void)setUp{
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"We don't post anything to Facebook.\nBy signing in you agree with our terms of service and privacy policy" attributes:nil];
    NSRange linkRangeOne = NSMakeRange(attributedString.length - 14, 14); // for the word "link" in the string above
    NSRange linkRangeTwo = NSMakeRange(attributedString.length - 35, 16);
   
    [attributedString addAttribute: NSLinkAttributeName value:[NSString stringWithFormat:@"%@terms.php",ExternalWebURL] range: linkRangeTwo];
    [attributedString addAttribute: NSLinkAttributeName value:[NSString stringWithFormat:@"%@privacy_policy.php",ExternalWebURL] range:linkRangeOne];
    txtView.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};

    txtView.attributedText = attributedString;
    txtView.textAlignment = NSTextAlignmentCenter;
    txtView.font = [UIFont fontWithName:CommonFont_New size:10];
    txtView.textColor = [UIColor whiteColor];

   
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)enableGoogleAndFBSignIn{
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    btnFBSignin = [[FBSDKLoginButton alloc] init];
    btnFBSignin.delegate = self;
    btnFBSignin.hidden = true;
    
}


- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    [self showBrowserWithURL:URL];
    return NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"IntroCell" forIndexPath:indexPath];
    
    UIImageView *bg;
    UIImageView *innerImg;
    UILabel *lblHeading;
    UILabel *lblText;
    
    if ([[cell contentView]viewWithTag:1])
        bg = (UIImageView*) [[cell contentView]viewWithTag:1];
    
    if ([[cell contentView]viewWithTag:2])
        innerImg = (UIImageView*) [[cell contentView]viewWithTag:2];
    
    if ([[cell contentView]viewWithTag:3])
        lblHeading = (UILabel*) [[cell contentView]viewWithTag:3];
    
    if ([[cell contentView]viewWithTag:4])
        lblText = (UILabel*) [[cell contentView]viewWithTag:4];
    
    if (indexPath.row == 0) {
        bg.image = [UIImage imageNamed:@"Intro_Theme_1"];
        innerImg.image = [UIImage imageNamed:@"Intro_Image_1"];
        lblHeading.text = @"INSPERATIONAL NETWORKING";
        lblText.text = @"Inspire and be inspired\nConnect share and learn with others";
    }
    if (indexPath.row == 1) {
        bg.image = [UIImage imageNamed:@"Intro_Theme_2"];
        innerImg.image = [UIImage imageNamed:@"Intro_Image_2"];
        lblHeading.text = @"GOALS & DREAMS";
        lblText.text = @"Know your destination\nIf it important to you make it a GOAL";
    }
    if (indexPath.row == 2) {
        bg.image = [UIImage imageNamed:@"Intro_Theme_3"];
        innerImg.image = [UIImage imageNamed:@"Intro_Image_3"];
        lblHeading.text = @"SMART JOURNAL";
        lblText.text = @"Capture and gain powerful insight into\nwhat drives you and what makes you happy";
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    float width = _collectionView.bounds.size.width;
    return CGSizeMake(width, _collectionView.frame.size.height);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = collectionView.frame.size.width;
    float currentPage = collectionView.contentOffset.x / pageWidth;
    
    if (0.0f != fmodf(currentPage, 1.0f))
        pageControl.currentPage = currentPage + 1;
    else
        pageControl.currentPage = currentPage;
    
}

-(IBAction)doFBSignIn:(id)sender{
    
    [btnFBSignin sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(IBAction)doGoogleSignIn:(id)sender{
    
     [[GIDSignIn sharedInstance] signIn];
}
-(IBAction)doPurposeColorSignIn:(id)sender{
    
    LoginViewController *loginPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForLoginPage];
    [[self navigationController]pushViewController:loginPage animated:YES];
}


-(IBAction)doRegisterNewUser:(id)sender{
    RegistrationViewController *registerPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:StoryboardForLogin Identifier:StoryBoardIdentifierForRegistrationPage];
    registerPage.isFromIntroPage = YES;
    [[self navigationController]pushViewController:registerPage animated:YES];


}

#pragma mark - FB Signin Process

- (void)  loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error;{
    [self getFacebookData];
}

- (void)getFacebookData{
    if ([FBSDKAccessToken currentAccessToken]) {
        [self showLoadingScreen];
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, picture.type(large), email, name, id, gender"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             [self hideLoadingScreen];
             if (!error) {
                 NSString *email;
                 NSString *fname;
                 NSString *fbID;
                 NSString *googleID;
                 NSString *profileImg;
                 
                 if (NULL_TO_NIL([result objectForKey:@"email"])) {
                     email = [result objectForKey:@"email"];
                 }
                 if (NULL_TO_NIL([result objectForKey:@"first_name"])) {
                     fname = [result objectForKey:@"first_name"];
                 }
                 if (NULL_TO_NIL([result objectForKey:@"id"])) {
                     fbID = [result objectForKey:@"id"];
                 }
                 [self showLoadingScreen];
                 
                 [APIMapper socialMediaRegistrationnWithFirstName:fname profileImage:profileImg fbID:fbID googleID:googleID email:email success:^(AFHTTPRequestOperation *operation, id responds) {
                     if ( NULL_TO_NIL([responds objectForKey:@"code"])) {
                         NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
                         if (statusCode == StatusSucess) {
                             [self createUserWithInfo:responds];
                             AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                             [appdelegate goToHomeAfterLogin];
                         }
                         else{
                             if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                                 [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
                         }
                     }
                     
                    [self hideLoadingScreen];
                     
                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                     
                     [self hideLoadingScreen];
                 }];
             }
         }];
    }
}
/**
 Sent to the delegate when the button was used to logout.
 - Parameter loginButton: The button that was clicked.
 */
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton;{
    
}

#pragma mark - Google Signin Process


- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (error) return;
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *name = user.profile.name;
    NSString *email = user.profile.email;
    NSURL *profileurl;
    if ([user.profile hasImage]) profileurl = [user.profile imageURLWithDimension:200];
    [self showLoadingScreen];
    
    [APIMapper socialMediaRegistrationnWithFirstName:name profileImage:[profileurl absoluteString] fbID:nil googleID:userId email:email success:^(AFHTTPRequestOperation *operation, id responds) {
        if ( NULL_TO_NIL([responds objectForKey:@"code"])) {
            NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
            if (statusCode == StatusSucess) {
                [self createUserWithInfo:responds];
                AppDelegate *appdelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [appdelegate goToHomeAfterLogin];
            }
            else{
                if ( NULL_TO_NIL( [responds  objectForKey:@"text"]))
                    [self showAlertWithMessage:[responds objectForKey:@"text"] title:@"Login"];
            }
        }
       
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
    }];

    
    
    // ...
}

-(void)createUserWithInfo:(NSDictionary*)userDetails{
    
    if ([[userDetails objectForKey:@"code"] integerValue] == StatusSucess) {
        
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
        if ([userDetails objectForKey:@"token_id"]) {
            [User sharedManager].token  = [userDetails objectForKey:@"token_id"];
        }
        
        /*!............ Saving user to NSUserDefaults.............!*/
        
        [Utility saveUserObject:[User sharedManager] key:@"USER"];
    }
    
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
