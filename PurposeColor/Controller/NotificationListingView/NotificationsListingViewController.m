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

#import "NotificationsListingViewController.h"
#import "NotificationListingCell.h"
#import "Constants.h"
#import "MenuViewController.h"

@interface NotificationsListingViewController ()<SWRevealViewControllerDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    BOOL isDataAvailable;
    NSInteger totalPages;
    NSInteger currentPage;
    BOOL isPageRefresing;
    NSMutableArray *arrNotifications;
}

@end

@implementation NotificationsListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self loadAllMyNotificationsWithPageNo:currentPage isByPagination:NO];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    currentPage = 1;
    totalPages = 0;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.alwaysBounceVertical = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    arrNotifications = [NSMutableArray new];
    isDataAvailable = false;
    tableView.allowsSelection = NO;
    [tableView setHidden:true];
    
}





-(void)loadAllMyNotificationsWithPageNo:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    
    if (!isPagination) {
        [self showLoadingScreen];
    }
    
    [APIMapper getAllMyNotificationsWith:[User sharedManager].userId pageNumber:pageNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getNotificationsFromResponds:responseObject];
        [self hideLoadingScreen];

        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        isPageRefresing = false;
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
    }];
        
      
}


-(void)getNotificationsFromResponds:(NSDictionary*)responseObject{
    
    isDataAvailable = false;
    isPageRefresing = false;
    [arrNotifications removeAllObjects];
    
    if (NULL_TO_NIL([responseObject objectForKey:@"resultarray"])){
        NSArray *notifications = [responseObject objectForKey:@"resultarray"];
        [arrNotifications addObjectsFromArray:notifications];
    }
    
    if (NULL_TO_NIL([[responseObject objectForKey:@"header"] objectForKey:@"pageCount"]))
        totalPages =  [[[responseObject objectForKey:@"header"] objectForKey:@"pageCount"]integerValue];
    
    if (NULL_TO_NIL([[responseObject objectForKey:@"header"] objectForKey:@"currentPage"]))
        currentPage =  [[[responseObject objectForKey:@"header"] objectForKey:@"currentPage"]integerValue];
    
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
    return arrNotifications.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Notifications Available."];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    cell = [self configureCellForIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) return kDefaultCellHeight;
    CGFloat height = [self getDynamicHeightForDecsriptionWith:indexPath.row];
    return height;
}


-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    
    if (!isDataAvailable) {
        
        /*****! No listing found , default cell !**************/
        
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:tableView withTitle:@"No Listing found"];
        return cell;
        
    }
    
    static NSString *CellIdentifier = @"NotificationListingCell";
    NotificationListingCell *cell = (NotificationListingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.vwBackground.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    [cell.btnAccept addTarget:self action:@selector(acceptClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnReject addTarget:self action:@selector(rejectClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnReject.tag = indexPath.row;
    cell.btnAccept.tag = indexPath.row;
    cell.imgTemplate.clipsToBounds = YES;
    cell.imgTemplate.layer.cornerRadius = 25.f;
    cell.imgTemplate.layer.borderColor = [UIColor clearColor].CGColor;
    cell.imgTemplate.contentMode = UIViewContentModeScaleAspectFill;
    cell.btnReject.layer.borderWidth = 1.f;
    cell.btnReject.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    cell.btnReject.layer.cornerRadius = 4.f;
    cell.btnAccept.layer.cornerRadius = 4.f;
    cell.btnReject.hidden = true;
    cell.btnAccept.hidden = true;
    if (indexPath.row < arrNotifications.count) {
        NSDictionary *productInfo = arrNotifications[[indexPath row]];
         NSString *message = [productInfo objectForKey:@"message"];
        
        if ([[productInfo objectForKey:@"type"] isEqualToString:@"follow"]) {
            if ([[productInfo objectForKey:@"follow_status"] integerValue] == 1){
                cell.btnReject.hidden = false;
                cell.btnAccept.hidden = false;
                
            }
        }
        
        if ([productInfo objectForKey:@"datetime"]) {
            cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[productInfo objectForKey:@"datetime"] doubleValue]];
            
        }
        
        UIFont *font = [UIFont fontWithName:CommonFont size:14];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        NSDictionary *attributes = @{NSFontAttributeName:font,
                                     NSParagraphStyleAttributeName:paragraphStyle,
                                     };
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:message attributes:attributes];
        cell.lblDescription.attributedText = attributedText;
        NSString *urlImage;
        
        if (NULL_TO_NIL([productInfo objectForKey:@"profileimage"]))
            urlImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"profileimage"]];
        [cell.indicator stopAnimating];
        if (urlImage.length) {
            [cell.indicator startAnimating];
            [cell.imgTemplate sd_setImageWithURL:[NSURL URLWithString:urlImage]
                                placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [cell.indicator stopAnimating];
                                        
                                       }];
        }
        
    }
    
    
    return cell;
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage ;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self loadAllMyNotificationsWithPageNo:nextPage isByPagination:YES];
            }
            
        }
    }
    
}




-(float)getDynamicHeightForDecsriptionWith:(NSInteger)index{
    if (index < arrNotifications.count) {
        CGSize size;
        NSDictionary *productInfo = arrNotifications[index];
        NSString *message = [productInfo objectForKey:@"message"];
        if (message.length) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.2f;
            size = [message boundingRectWithSize:CGSizeMake(tableView.frame.size.width - kWidthPadding, MAXFLOAT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{
                                                   NSFontAttributeName : [UIFont fontWithName:CommonFont size:14],
                                                   NSParagraphStyleAttributeName:paragraphStyle,
                                                   }
                                         context:nil].size;
        }
        
    float minimumHeight = 110;
    float padding = 30;
       if ([[productInfo objectForKey:@"type"] isEqualToString:@"follow"])  {
           if ([[productInfo objectForKey:@"follow_status"] integerValue] == 1){
               float calculatedHeight = size.height + padding;
               // Without button
               if (calculatedHeight < minimumHeight ) {
                   return  minimumHeight;
               }
               return size.height + padding;
               
           }else{
               minimumHeight = 65;
               float calculatedHeight = size.height + padding;
               // with button
               if (calculatedHeight < minimumHeight ) {
                   return  minimumHeight;
               }
               return size.height + padding;
           }
           
       }else{
           float calculatedHeight = size.height;
           minimumHeight = 65;
           if (calculatedHeight < minimumHeight) {
               return minimumHeight;
           }
           return  calculatedHeight;
       }
       
    }
    return kDefaultCellHeight;
}

-(IBAction)acceptClicked:(UIButton*)btn{
    
    if (btn.tag < arrNotifications.count) {
        NSDictionary *productInfo = arrNotifications[btn.tag];
        if (productInfo && [productInfo objectForKey:@"follow_id"]){
            NSString *status = @"2";
            NSInteger follow_id =  [[productInfo objectForKey:@"follow_id"] integerValue];
            [self updateFollowStatusWithFollowID:follow_id status:status];
        }

    }
    
}

-(IBAction)rejectClicked:(UIButton*)btn{
    
    if (btn.tag < arrNotifications.count) {
        NSDictionary *productInfo = arrNotifications[btn.tag];
        if (productInfo && [productInfo objectForKey:@"follow_id"]){
            NSString *status = @"0";
            NSInteger follow_id =  [[productInfo objectForKey:@"follow_id"] integerValue];
            [self updateFollowStatusWithFollowID:follow_id status:status];
        }
        
    }
}

-(void)updateFollowStatusWithFollowID:(NSInteger)followID status:(NSString*)status{
    
    [self showLoadingScreen];
    [APIMapper updateFollowRequestByUserID:[User sharedManager].userId followRequestID:followID status:status success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        [self loadAllMyNotificationsWithPageNo:currentPage isByPagination:NO];
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self showErrorMessage];
         [self hideLoadingScreen];
    }];
}

-(void)showErrorMessage{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Follow"
                                                                   message:@"Failed to update"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"OK"
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   
                                               }];
    [alert addAction:firstAction];

}

-(IBAction)goBack:(id)sender{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.navGeneral willMoveToParentViewController:nil];
    [app.navGeneral.view removeFromSuperview];
    [app.navGeneral removeFromParentViewController];
    app.navGeneral = nil;
    [app showLauchPage];
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
