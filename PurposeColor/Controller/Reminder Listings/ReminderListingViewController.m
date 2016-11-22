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

#import "ReminderListingViewController.h"
#import "ReminderListingCell.h"
#import "Constants.h"
#import "MenuViewController.h"
#import "EventCreateViewController.h"

@interface ReminderListingViewController (){
    
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

@implementation ReminderListingViewController

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
    [tableView setHidden:true];
    
}



-(void)loadAllMyNotificationsWithPageNo:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    
    if (!isPagination) {
        [self showLoadingScreen];
    }
    
    [APIMapper getAllMyRemindersWith:[User sharedManager].userId pageNumber:pageNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Reminders Available."];
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
    
    static NSString *CellIdentifier = @"ReminderListingCell";
    ReminderListingCell *cell = (ReminderListingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row < arrNotifications.count) {
        NSDictionary *productInfo = arrNotifications[[indexPath row]];
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_title"])) {
            cell.lblTitle.text = [productInfo objectForKey:@"reminder_title"];
        }
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_desc"])) {
            
            UIFont *font = [UIFont fontWithName:CommonFont size:14];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.2f;
            NSDictionary *attributes = @{NSFontAttributeName:font,
                                         NSParagraphStyleAttributeName:paragraphStyle,
                                         };
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[productInfo objectForKey:@"reminder_desc"] attributes:attributes];
            cell.lblDescription.attributedText = attributedText;
            
        }
        
        cell.lblDate.text = [NSString stringWithFormat:@"%@ - %@",[self getDateStringFromSecondsWith:[[productInfo objectForKey:@"reminder_startdate"] doubleValue]],[self getDateStringFromSecondsWith:[[productInfo objectForKey:@"reminder_enddate"] doubleValue]]] ;
        

    }
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UINavigationController *nav = self.navigationController;
    EventCreateViewController *eventCreate =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForEventManager];
    if (indexPath.row < arrNotifications.count) {
        NSDictionary *productInfo = arrNotifications[[indexPath row]];
        if (NULL_TO_NIL([productInfo objectForKey:@"goalaction_id"])) {
            eventCreate.goalID = [[productInfo objectForKey:@"goalaction_id"] integerValue];
        }
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_title"])) {
            eventCreate.strGoalTitle = [productInfo objectForKey:@"reminder_title"];
        }
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_desc"])) {
            eventCreate.strGoalDescription = [productInfo objectForKey:@"reminder_desc"];
        }
        
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_repeat"])) {
            eventCreate.strRepeatValue = [productInfo objectForKey:@"reminder_repeat"];
        }
        
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_alert"])) {
            eventCreate.reminderTime = [[productInfo objectForKey:@"reminder_alert"] integerValue];
        }
        
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_startdate"])) {
            eventCreate.startDate =[NSDate dateWithTimeIntervalSince1970:[[productInfo objectForKey:@"reminder_startdate"] doubleValue]];
        }
        
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_startdate"])) {
            eventCreate.startTime =[NSDate dateWithTimeIntervalSince1970:[[productInfo objectForKey:@"reminder_startdate"] doubleValue]];
        }
        
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_enddate"])) {
            eventCreate.endTime =[NSDate dateWithTimeIntervalSince1970:[[productInfo objectForKey:@"reminder_enddate"] doubleValue]];
        }
        
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_enddate"])) {
            eventCreate.endDate =[NSDate dateWithTimeIntervalSince1970:[[productInfo objectForKey:@"reminder_enddate"] doubleValue]];
        }
        
        
        
        [nav pushViewController:eventCreate animated:YES];
    }
    
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
        float widthPadding = 20;
        float heightPadding = 50;
        float height = 0;
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_title"])) {
            NSString *message = [productInfo objectForKey:@"reminder_title"];
            if (message.length) {
                size = [message boundingRectWithSize:CGSizeMake(tableView.frame.size.width - widthPadding, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
                                                       NSFontAttributeName : [UIFont fontWithName:CommonFontBold size:14],
                                                       }
                                             context:nil].size;
                height+= size.height;
            }
            
        }
        if (NULL_TO_NIL([productInfo objectForKey:@"reminder_desc"])) {
            NSString *message = [productInfo objectForKey:@"reminder_desc"];
            if (message.length) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineHeightMultiple = 1.2f;
                size = [message boundingRectWithSize:CGSizeMake(tableView.frame.size.width - widthPadding, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{
                                                       NSFontAttributeName : [UIFont fontWithName:CommonFont size:14],
                                                       NSParagraphStyleAttributeName:paragraphStyle,
                                                       }
                                             context:nil].size;
                
                height+= size.height;
            }
            
            
        }
        height += heightPadding;
        return height;
        
    }
    return kDefaultCellHeight;
}


-(NSString*)getDateStringFromSecondsWith:(double)timeInSeconds{
    
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM,yyyy"];
    return [dateformater stringFromDate:refDate];;
    
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
