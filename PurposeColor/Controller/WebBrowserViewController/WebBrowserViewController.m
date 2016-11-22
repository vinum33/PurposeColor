//
//  WebBrowserViewController.m
//  SignPost
//
//  Created by Purpose Code on 11/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

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
    [self loadWebPage];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)loadWebPage{
    
    NSString *urlString = _strURL;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [webView loadRequest:urlRequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showLoadingScreen];
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
    
    [self.navigationController popViewControllerAnimated:YES];
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
