//
//  NotificationsListingViewController.m
//  SignSpot
//
//  Created by Purpose Code on 09/06/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kDefaultCellHeight          95
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kWidthPadding               115
#define kFollowHeightPadding        85
#define kOthersHeightPadding        20

#import "ReportAbuseViewController.h"
#import "ReportAbuseListingCell.h"
#import "Constants.h"

@interface ReportAbuseViewController (){
    
    IBOutlet UITableView *tableView;
    BOOL isDataAvailable;
    NSMutableArray *arrNotifications;
    NSInteger selectedIndex;
    NSString *strOtherReason;
    
}

@end

@implementation ReportAbuseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllReasons];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    
    tableView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    tableView.layer.borderWidth = 1.f;
    selectedIndex = -1;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.alwaysBounceVertical = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    arrNotifications = [NSMutableArray new];
    isDataAvailable = false;
    
}



-(void)getAllReasons{
    
    [self showLoadingScreen];
    [APIMapper getAllAbuseReasonsOnSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getNotificationsFromResponds:responseObject];
        [self hideLoadingScreen];

        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
    }];
        
      
}


-(void)getNotificationsFromResponds:(NSDictionary*)responseObject{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responseObject objectForKey:@"question"])){
        arrNotifications = [responseObject objectForKey:@"question"];
    }
    if (arrNotifications.count)isDataAvailable = true;
    [tableView setHidden:false];
    [tableView reloadData];
    
    
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
    return arrNotifications.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell = [self configureCellForIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) return kDefaultCellHeight;
    if (indexPath.row == arrNotifications.count) {
        return 150;
    }
    CGFloat height = [self getDynamicHeightForDecsriptionWith:indexPath.row];
    return height;
}


-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    
    if (!isDataAvailable) {
        
        /*****! No listing found , default cell !**************/
        
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:tableView withTitle:@"No Listing found"];
        return cell;
        
    }
    
    static NSString *CellIdentifier = @"Listings";
    ReportAbuseListingCell *cell = (ReportAbuseListingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row < arrNotifications.count) {
        cell.vwListBg.hidden = false;
        cell.txtView.hidden = true;
        if (indexPath.row == arrNotifications.count ) {
            cell.vwListBg.hidden = true;
            cell.txtView.hidden = false;
        }else{
            NSDictionary *details = arrNotifications[[indexPath row]];
            if (NULL_TO_NIL([details objectForKey:@"abuse_qtn"])) {
                cell.lblTitle.text = [details objectForKey:@"abuse_qtn"];
            }
        }
        cell.imgRadio.image = [UIImage imageNamed:@"Radio_InActive.png"];
        if (selectedIndex == indexPath.row) {
            cell.imgRadio.image = [UIImage imageNamed:@"Radio_Active.png"];
        }

    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == arrNotifications.count + 1) return;
    selectedIndex = indexPath.row;
    [tableView reloadData];
    
}

-(float)getDynamicHeightForDecsriptionWith:(NSInteger)index{
    if (index < arrNotifications.count) {
        CGSize size;
        NSDictionary *productInfo = arrNotifications[index];
        float widthPadding = 55;
        float height = 0;
        if (NULL_TO_NIL([productInfo objectForKey:@"abuse_qtn"])) {
            NSString *message = [productInfo objectForKey:@"abuse_qtn"];
            if (message.length) {
                size = [message boundingRectWithSize:CGSizeMake(tableView.frame.size.width - widthPadding, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
                                                       NSFontAttributeName : [UIFont fontWithName:CommonFont size:14],
                                                       }
                                             context:nil].size;
                height+= size.height;
            }
            
        }
        if (height <= 50) {
            return 50;
        }
        return height;
        
    }
    return kDefaultCellHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable) {
        return nil;
    }
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor whiteColor];
    
    UILabel *lblTitle1 = [UILabel new];
    lblTitle1.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle1];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[lblTitle1]-70-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle1)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblTitle1]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle1)]];
    lblTitle1.text = @"Report a violation of the PurposeColor Terms.";
    lblTitle1.font = [UIFont fontWithName:CommonFontBold size:13];
    lblTitle1.textColor = [UIColor blackColor];
    
    UILabel *lblTitle2 = [UILabel new];
    lblTitle2.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle2];
    lblTitle2.numberOfLines = 2;
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[lblTitle2]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle2)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblTitle2]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle2)]];
    lblTitle2.text = @"Please use this form to report violation of the PurposeColor Terms.";
    lblTitle2.font = [UIFont fontWithName:CommonFont size:12];
    lblTitle2.textColor = [UIColor blackColor];
    
    UILabel *lblTitle3 = [UILabel new];
    lblTitle3.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle3];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[lblTitle3]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle3)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblTitle3]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle3)]];
    lblTitle3.text = @"What are you trying to report?";
    lblTitle3.font = [UIFont fontWithName:CommonFontBold size:13];
    lblTitle3.textColor = [UIColor blackColor];

    return vwHeader;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (!isDataAvailable) {
        return nil;
    }
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnLogin = [UIButton new];
    btnLogin.backgroundColor = [UIColor getThemeColor];
    btnLogin.translatesAutoresizingMaskIntoConstraints = NO;
    [btnLogin setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLogin.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    [btnLogin addTarget:self action:@selector(submitReason) forControlEvents:UIControlEventTouchUpInside];
    [vwFooter addSubview:btnLogin];
    
    [btnLogin addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:45]];
    [vwFooter addConstraint:[NSLayoutConstraint constraintWithItem:btnLogin
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwFooter
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-10]];
    
    NSArray *horizontalConstraints =[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[btnLogin]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnLogin)];
    [vwFooter addConstraints:horizontalConstraints];
     return vwFooter;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (!isDataAvailable) {
        return 0.1;
    }
    return  70;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable) {
        return 0.1;
    }
    return 100;
}

#pragma mark - UITextView delegate methods


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    NSIndexPath *indexPath;
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
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
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
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
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getOtherInfoWithString:textView.text];
    }
    return YES;
}

-(void)getOtherInfoWithString:(NSString*)string{
    
    strOtherReason = string;
    
}

-(void)submitReason{
    
    [self.view endEditing:YES];
    if (selectedIndex < 0 && (!strOtherReason)) {
        [ALToastView toastInView:self.view withText:@"Please choose a Reason"];
        return;
    }
    NSInteger indexOfReason = 0;
    if (selectedIndex < arrNotifications.count) {
        NSDictionary *productInfo = arrNotifications[selectedIndex];
        indexOfReason = [[productInfo objectForKey:@"abuse_id"] integerValue];
    }
    if (_gemDetails) {
        
        [self showLoadingScreen];
        [APIMapper postReportAbuseWithUserID:[User sharedManager].userId gemUserID:[_gemDetails objectForKey:@"user_id"] gemID:[_gemDetails objectForKey:@"gem_id"] option:indexOfReason otherInfo:strOtherReason success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Abuse"
                                                                               message:[responseObject objectForKey:@"text"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                          
                                                                          
                                                                      }];
                
                [alert addAction:firstAction];
                
                UINavigationController *nav = self.navigationController;
                [nav presentViewController:alert animated:YES completion:nil];
            
        
            [self hideLoadingScreen];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
            [self hideLoadingScreen];
        }];
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
-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
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
