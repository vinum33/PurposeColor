//
//  WebBrowserViewController.m
//  SignPost
//
//  Created by Purpose Code on 11/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kHelp                       @"HELP"
#define kPrivacyPolicy              @"PRIVACY POLICY"
#define kTermsOfService             @"TERMS OF SERVICE"


#import "WebBrowserViewController.h"
#import "MenuViewController.h"

@interface WebBrowserViewController () <SWRevealViewControllerDelegate>{
    
    IBOutlet UILabel *lblTitle;
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
}



@end

@implementation WebBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    lblTitle.text = _strTitle;
    
    if ([_strTitle isEqualToString:kHelp]) {
        [self loadContentWithType:@"Help"];
    }
    else if ([_strTitle isEqualToString:kPrivacyPolicy]) {
        [self loadContentWithType:@"Privacy"];
    }
    else if ([_strTitle isEqualToString:kTermsOfService]) {
        [self loadContentWithType:@"Terms"];
    }
    
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideLoadingScreen];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:_strTitle message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self hideLoadingScreen];
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


-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading..";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}


#pragma mark - Cashing Methods

-(void)loadContentWithType:(NSString*)type{
    
    [self showLoadingScreen];
    [APIMapper getWebContentWithType:type success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        if ([responseObject objectForKey:@"text"]) {
            [self saveDetailsToFlder:[responseObject objectForKey:@"text"] type:type];
        }
        [self showContentFromFolder];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        
        [self showContentFromFolder];
        [self hideLoadingScreen];
    }];
    
    
    
    
    
}

-(void)saveDetailsToFlder:(NSString*)content type:(NSString*)type{
    
    NSString *fileName = [NSString stringWithFormat:@"%@.txt",type];
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:fileName];
    [content writeToFile:path atomically:YES
                encoding:NSUTF8StringEncoding error:nil];
    
}


- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

-(void)showContentFromFolder{
    
    NSString *type;
    
    if ([_strTitle isEqualToString:kHelp]) {
        type = @"Help";
    }
    else if ([_strTitle isEqualToString:kPrivacyPolicy]) {
        type = @"Privacy";
    }
    else if ([_strTitle isEqualToString:kTermsOfService]) {
        type = @"Terms";
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",type]];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        [webView loadHTMLString:content baseURL:nil];
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
