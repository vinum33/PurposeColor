//
//  GoalsAndDreamsListingViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 21/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eCompleted = 1,
    ePending = 0,
    
} eStatus;


#define kSectionCount               1
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeaderHeight               0
#define kCellHeight                 395
#define kEmptyHeaderAndFooter       0

#import "GoalsAndDreamsListingViewController.h"
#import "GoalsAndDreamsCustomCell.h"
#import "CreateActionInfoViewController.h"
#import "GoalDetailViewController.h"
#import "MenuViewController.h"

@interface GoalsAndDreamsListingViewController ()<GoalsAndDreamsCustomCellDelegate,GoalDetailViewDelegate,SWRevealViewControllerDelegate,CreateMediaInfoDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIView *vwPaginationPopUp;
    IBOutlet NSLayoutConstraint *paginationBottomConstraint;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    IBOutlet UIView *vwSegmentSelection;
    IBOutlet UIButton *btnPending;
    IBOutlet UIButton *btnCompleted;

    
    UIRefreshControl *refreshControl;
    BOOL isDataAvailable;
    BOOL isPageRefresing;
    NSInteger totalPages_pending;
    NSInteger totalPages_completed;
    
    NSInteger currentPage_completed;
    NSInteger currentPage_pending;
    
    NSMutableArray *arrCompleted;
    NSMutableArray *arrPending;
    NSMutableArray *arrDataSource;
    
    eStatus EStatus;
    NSMutableDictionary *heightsCache;

}

@end

@implementation GoalsAndDreamsListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self loadAllGoalsAndDreamsByPagination:NO withPageNumber:currentPage_pending];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{

    arrPending         = [NSMutableArray new];
    arrCompleted       = [NSMutableArray new];
    arrDataSource      = [NSMutableArray new];
    
    currentPage_pending = 1;
    currentPage_completed = 1;
    
    totalPages_pending = 0;
    totalPages_completed = 0;
    
    EStatus = ePending;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    isDataAvailable = false;
    tableView.hidden = true;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
    heightsCache =  [NSMutableDictionary new];
    
}

-(IBAction)segmentChanged:(UIButton*)sender{
    
    [arrDataSource removeAllObjects];
    [heightsCache removeAllObjects];
    
    if (sender.tag == 1) {
        EStatus = ePending;
        if (arrPending.count <= 0) {
            currentPage_pending = 1;
            totalPages_pending = 0;
            [self loadAllGoalsAndDreamsByPagination:NO withPageNumber:currentPage_pending];
           
        }
         [self changeAnimatedSelectionToCompleted:NO];
    }else{
        
        EStatus = eCompleted;
        if (arrCompleted.count <= 0) {
            currentPage_completed = 1;
            totalPages_completed = 0;
            [self loadAllGoalsAndDreamsByPagination:NO withPageNumber:currentPage_completed];
           
        }
         [self changeAnimatedSelectionToCompleted:YES];
    }
    
    [self configureDataSource];
    
  }

-(void)changeAnimatedSelectionToCompleted:(BOOL)toCompeleted{
    
    if (toCompeleted) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = vwSegmentSelection.frame;
            frame.origin.x = self.view.frame.size.width / 2;
            vwSegmentSelection.frame = frame;
        }completion:^(BOOL finished) {
            [btnPending setAlpha:0.7];
            [btnCompleted setAlpha:1];
            
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = vwSegmentSelection.frame;
            frame.origin.x = 0;
            vwSegmentSelection.frame = frame;
        }completion:^(BOOL finished) {
            [btnCompleted setAlpha:0.7];
            [btnPending setAlpha:1];
        }];
    }
    
}


#pragma mark - API Integration

-(void)loadAllGoalsAndDreamsByPagination:(BOOL)isPagination withPageNumber:(NSInteger)pageNo {
    
    if (!isPagination) {
        [self showLoadingScreen];
        tableView.hidden = true;
    }
    
    [APIMapper loadAllMyGoalsAndDreamsWith:[User sharedManager].userId pageNo:pageNo status:EStatus success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        [self getGoalsAndDreamsFrom:responseObject];
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        tableView.hidden = false;
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        [tableView reloadData];
    }];
}

-(void)refreshData{
    
    if (isPageRefresing){
        [refreshControl endRefreshing];
        return;
    }
    [heightsCache removeAllObjects];
    [arrCompleted removeAllObjects];
    [arrPending removeAllObjects];
    [arrDataSource removeAllObjects];
    [self showLoadingScreen];
    currentPage_completed = 1;
    currentPage_pending = 1;
    isPageRefresing = YES;
    NSInteger currentPage = 1;
    [self loadAllGoalsAndDreamsByPagination:YES withPageNumber:currentPage];
    
    
}

-(void)getGoalsAndDreamsFrom:(NSDictionary*)responds{
    
    NSArray *goals;
    if (EStatus == ePending) {
        EStatus = ePending;
        if (NULL_TO_NIL([responds objectForKey:@"goalsanddreams"])) {
            goals = [responds objectForKey:@"goalsanddreams"];
            if (goals.count) [arrPending addObjectsFromArray:goals];
            if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"currentPage"]))
                currentPage_pending = [[[responds objectForKey:@"header"] objectForKey:@"currentPage"] integerValue];
            if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"pageCount"]))
                totalPages_pending = [[[responds objectForKey:@"header"] objectForKey:@"pageCount"] integerValue];
            if (arrPending.count > 0) {
                arrDataSource = [NSMutableArray arrayWithArray:arrPending];
            }
        }
    }else{
        EStatus = eCompleted;
        if (NULL_TO_NIL([responds objectForKey:@"goalsanddreams"])) {
            goals = [responds objectForKey:@"goalsanddreams"];
            if (goals.count) [arrCompleted addObjectsFromArray:goals];
            if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"currentPage"]))
                currentPage_completed = [[[responds objectForKey:@"header"] objectForKey:@"currentPage"] integerValue];
            if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"pageCount"]))
                totalPages_completed = [[[responds objectForKey:@"header"] objectForKey:@"pageCount"] integerValue];
            if (arrCompleted.count > 0) {
                arrDataSource = [NSMutableArray arrayWithArray:arrCompleted];
            }

        }
    }
    [self configureDataSource];
}

-(void)configureDataSource{
    
    if (EStatus == ePending) {
        EStatus = ePending;
        if (arrPending.count > 0) {
            arrDataSource = [NSMutableArray arrayWithArray:arrPending];
        }
    }else{
        
        EStatus = eCompleted;
        if (arrCompleted.count > 0) {
            arrDataSource = [NSMutableArray arrayWithArray:arrCompleted];
        }
    }
    isDataAvailable = false;
    if (arrDataSource.count) isDataAvailable = true;
   [tableView reloadData];

}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
    return arrDataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Goals Available."];
        cell.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0];
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0];
        return cell;
    }
    cell = [self configureCellForIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float finalHeight = 0;
    float defaultHeight = 130;
    float imageHeight = 0;
    float padding = 20;
    
    if (indexPath.row < arrDataSource.count){
        
        NSInteger height = 0;
        NSDictionary *goalInfo = arrDataSource[indexPath.row];
        
        if (NULL_TO_NIL([goalInfo objectForKey:@"contact_name"])) {
            height += 20;
        }
        
        if (NULL_TO_NIL([goalInfo objectForKey:@"location_name"])) {
            height += 15;
        }
        
        finalHeight = defaultHeight + height;
        if ([heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
            imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]] floatValue];
        }else{
            float width = [[goalInfo objectForKey:@"image_width"] floatValue];
            float height = [[goalInfo objectForKey:@"image_height"] floatValue];
            float ratio = width / height;
            imageHeight = (_tableView.frame.size.width - padding) / ratio;
            [heightsCache setObject:[NSNumber numberWithInteger:imageHeight] forKey:[NSNumber numberWithInteger:indexPath.row]];
            
        }

        finalHeight += imageHeight;
        return finalHeight;

    }
    
    
    return kCellHeight;
}


-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"CustomCell";
    GoalsAndDreamsCustomCell *cell = (GoalsAndDreamsCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    if (indexPath.row < arrDataSource.count){
        
        NSDictionary *goalsDetails = arrDataSource[indexPath.row];
        cell.row = indexPath.row;
        cell.vwBg.layer.borderColor = [UIColor getSeperatorColor].CGColor;
        cell.vwBg.layer.cornerRadius = 5.f;
        cell.vwBg.layer.borderWidth = 1.f;
        
        cell.btnShareStatus.layer.borderWidth = 1.f;
        cell.btnShareStatus.layer.borderColor = [UIColor colorWithRed:0.83 green:0.83 blue:0.83 alpha:0.5].CGColor;
        cell.btnShareStatus.layer.cornerRadius = 3.f;
        cell.btnShareStatus.hidden = [[goalsDetails objectForKey:@"share_status"] boolValue] ? false : true;
        cell.imgTransparentVideo.hidden = true;
        NSString *status = EStatus == eCompleted ? @"Completed" : @"Active";
        if (EStatus == eCompleted)
        cell.lblActionCount.text = @"0 ACTION(S)";
        if (NULL_TO_NIL([goalsDetails objectForKey:@"action_count"])) {
            NSInteger count = [[goalsDetails objectForKey:@"action_count"] integerValue];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu ACTION(S)",(long)count]];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(0, str.length - 10)];
            cell.lblActionCount.attributedText = str;
        }
        
        if ([[goalsDetails objectForKey:@"display_type"] isEqualToString:@"video"])cell.imgTransparentVideo.hidden = false;
        
        if (NULL_TO_NIL([goalsDetails objectForKey:@"goal_datetime"]))
            cell.lblGoalDate.text = [Utility getDaysBetweenTwoDatesWith:[[goalsDetails objectForKey:@"goal_datetime"] doubleValue]];
        if (NULL_TO_NIL([goalsDetails objectForKey:@"goal_title"]))
            cell.lblTitle.text = [goalsDetails objectForKey:@"goal_title"];
        if (NULL_TO_NIL([goalsDetails objectForKey:@"goal_details"]))
            cell.lblDescription.text = [goalsDetails objectForKey:@"goal_details"];
        if (NULL_TO_NIL([goalsDetails objectForKey:@"goal_details"])){
            cell.lblDate.text = [NSString stringWithFormat:@"%@ - %@ | %@",[Utility getDateStringFromSecondsWith:[[goalsDetails objectForKey:@"goal_startdate"] doubleValue] withFormat:@"dd-MM-yyyy"],[Utility getDateStringFromSecondsWith:[[goalsDetails objectForKey:@"goal_enddate"] doubleValue] withFormat:@"dd-MM-yyyy"],status]  ;
        }
        if (NULL_TO_NIL([goalsDetails objectForKey:@"goal_media"])){
            NSString *url = [goalsDetails objectForKey:@"goal_media"];
            if (url.length) {
                [cell.activityIndicator startAnimating];
                float imageHeight = 0;
                if ([heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
                    imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]] integerValue];
                    cell.constraintForHeight.constant = imageHeight;
                }
                [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:url]
                                    placeholderImage:[UIImage imageNamed:@""]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               [cell.activityIndicator stopAnimating];
                                           }];
            }
        }
        
        if ([[[cell contentView] viewWithTag:3] isKindOfClass:[UIView class]]){
            UIView *vwBg = [[cell contentView] viewWithTag:3];
            vwBg.hidden = true;
            if ([[vwBg viewWithTag:4] isKindOfClass:[UILabel class]]){
                UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:4];
                lblAddress.text = @"";
                if (NULL_TO_NIL([goalsDetails objectForKey:@"location_name"])) {
                    lblAddress.text = [goalsDetails objectForKey:@"location_name"];
                    vwBg.hidden = false;
                }
                
            }
            
        }
        
        if ([[[cell contentView] viewWithTag:5] isKindOfClass:[UIView class]]){
            UIView *vwBg = [[cell contentView] viewWithTag:5];
            vwBg.hidden = true;
            if ([[vwBg viewWithTag:6] isKindOfClass:[UILabel class]]){
                UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:6];
                lblAddress.text = @"";
                if (NULL_TO_NIL([goalsDetails objectForKey:@"contact_name"])) {
                    lblAddress.text = [goalsDetails objectForKey:@"contact_name"];
                    vwBg.hidden = false;
                }
                
            }
            
        }

   }
    
    return cell;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage_completed;
            NSInteger totalPages = totalPages_completed;
            if (EStatus == ePending) {
                nextPage = currentPage_pending ;
                totalPages = totalPages_pending;
            }
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self showPaginationPopUp];
                [self loadAllGoalsAndDreamsByPagination:YES withPageNumber:nextPage];
            }
            
        }
    }
    
}

#pragma mark - CustomCell Delegte Methods

-(void)goalsAndDreamsCreatedWithGoalTitle:(NSString*)goalTitle goalID:(NSInteger)goalID{
    // Delegate call back from Goal created
    [self refreshData];
}

-(void)refershGoalsAndDreamsListingAfterUpdate{
    
    // Delegate call back from Goal details when something has been updated
    
      [self refreshData];
}

-(void)goalDetailsClickedWith:(NSInteger)index {
    
    if (index < arrDataSource.count) {
        NSDictionary *gemDetails = arrDataSource[index];
        GoalDetailViewController *goalDetailsVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForGoalDetails];
        goalDetailsVC.delegate = self;
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.navGeneral = [[UINavigationController alloc] initWithRootViewController:goalDetailsVC];
        app.navGeneral.navigationBarHidden = true;
        [UIView transitionWithView:app.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{  app.window.rootViewController = app.navGeneral; }
                        completion:nil];
        [goalDetailsVC getGoaDetailsByGoalID:[gemDetails objectForKey:@"goal_id"]];
        
    }
    
}



#pragma mark - Generic Methods


-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(void)showPaginationPopUp{
    
    [self.view layoutIfNeeded];
    paginationBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)hidePaginationPopUp{
    
    [self.view layoutIfNeeded];
    paginationBottomConstraint.constant = -40;
    [UIView animateWithDuration:0.3f animations:^{
        [self.view layoutIfNeeded];
    }];
}

// "+" Button Action

-(IBAction)composeNewActionAndMedias:(id)sender{
    
    CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
    detailPage.strTitle = @"ADD GOAL";
    detailPage.delegate = self;
    detailPage.actionType = eActionTypeGoalsAndDreams;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:detailPage];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];

   
    
   
}


-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
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
