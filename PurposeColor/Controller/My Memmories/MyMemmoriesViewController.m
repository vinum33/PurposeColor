//
//  MyMemmoriesViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 25/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kDefaultCellHeight          95
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kWidthPadding               115
#define kHeightPadding              85
#define kCellHeightforHeaderType    340
#define kHeightForHeader            00
#define kEmptyHeaderAndFooter       00

#import "MyMemmoriesViewController.h"
#import "MemmoriesHeaderDisplayCell.h"
#import "MemmoriesDisplayCell.h"
#import "Constants.h"
#import "GoalDetailViewController.h"
#import "MenuViewController.h"

@interface MyMemmoriesViewController () <MemoriesHeaderViewDelegate,MemoriesListViewDelegate,SWRevealViewControllerDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblMemoryName;
    IBOutlet UIView *vwMemoryOverLay;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    BOOL isDataAvailable;
    NSMutableArray *arrMemmories;
    NSMutableDictionary *dictMeomories;
    NSMutableArray *arrAllKeys;
}

@end

@implementation MyMemmoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self customSetup];
    // Do any additional setup after loading the view.
}

-(void)setUp{
    
    isDataAvailable = false;
    tableView.hidden = true;
    vwMemoryOverLay.hidden = true;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM yyyy"];
    lblDate.text = [dateformater stringFromDate:[NSDate date]];
    dictMeomories = [NSMutableDictionary new];
    vwMemoryOverLay.layer.cornerRadius = 20.f;
    vwMemoryOverLay.layer.borderWidth = 1.f;
    vwMemoryOverLay.layer.borderColor = [UIColor clearColor].CGColor;
    
    [self loadAllTodaysMemories];
}
- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    revealViewController.delegate = self;
    if ( revealViewController )
    {
        [btnSlideMenu addTarget:self.revealViewController action:@selector(revealToggle:)forControlEvents:UIControlEventTouchUpInside];
        [vwOverLay addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        
    }
    
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)loadAllTodaysMemories{
    
    [self hideLoadingScreen];
    [self showLoadingScreen];
    
    [APIMapper getAllTodaysMemoryWithUserID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getMemoriesFrom:responseObject];
        [self hideLoadingScreen];
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        [self hideLoadingScreen];
        [tableView reloadData];
        tableView.hidden = false;
    }];
    
}

-(void)getMemoriesFrom:(NSDictionary*)responds{
    if (NULL_TO_NIL([responds objectForKey:@"keys"])) arrAllKeys = [NSMutableArray arrayWithArray:[responds objectForKey:@"keys"]];
    if (NULL_TO_NIL([responds objectForKey:@"memory"])) {
        NSDictionary *memory = [responds objectForKey:@"memory"];
        for (NSString *key in arrAllKeys) {
            if (NULL_TO_NIL([memory objectForKey:key])) {
                [dictMeomories setObject:[memory objectForKey:key] forKey:key];
            }
        }
    }
    tableView.hidden = false;
    if (arrAllKeys.count){
        if ( arrAllKeys.count) {
            isDataAvailable = true;
             vwMemoryOverLay.hidden = false;
            lblMemoryName.text = [arrAllKeys firstObject];
        }
    }
    [tableView reloadData];
    
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!isDataAvailable) return kSectionCount;
        return arrAllKeys.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
        if (section < arrAllKeys.count) {
            NSString *key = arrAllKeys[section];
            if (NULL_TO_NIL([dictMeomories objectForKey:key])) {
                NSArray *memories = [dictMeomories objectForKey:key];
                return memories.count;
            }
        }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Moments Available."];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor =  [UIColor clearColor];
        return cell;
    }
    cell = [self configureCellForIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) return kDefaultCellHeight;
    
    float padding = 20;
    float height = 310;
    NSDictionary *memoryInfo;
    NSArray *details;
    if (indexPath.section < arrAllKeys.count) {
        NSString *key = arrAllKeys[indexPath.section];
        details = [dictMeomories objectForKey:key];
        if (indexPath.row < details.count) {
            memoryInfo = details[indexPath.row];
        }
        
        if (NULL_TO_NIL([memoryInfo objectForKey:@"gem_title"])){
            float lblHeight = [Utility getSizeOfLabelWithText:[memoryInfo objectForKey:@"gem_title"] width:tableView.frame.size.width - padding font:[UIFont fontWithName:CommonFontBold size:14]];
            if (lblHeight > 30) {
                lblHeight = 30;
            }
          
            float finalHeight = height + lblHeight;
            return finalHeight;
        }
    }
    
    return height;
}


-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    
    if (!isDataAvailable) {
        /*****! No listing found , default cell !**************/
        UITableViewCell *cell;
        cell = [Utility getNoDataCustomCellWith:tableView withTitle:@"No Memmories found"];
        return cell;
    }
    NSArray *details;
    NSDictionary *memoryInfo;
    if (indexPath.section < arrAllKeys.count) {
        NSString *key = arrAllKeys[indexPath.section];
        details = [dictMeomories objectForKey:key];
        if (indexPath.row < details.count) {
            memoryInfo = details[indexPath.row];
        }
    }
    
    MemmoriesHeaderDisplayCell *cell = (MemmoriesHeaderDisplayCell*)[tableView dequeueReusableCellWithIdentifier:@"MemmoriesDisplayHeader"];
    cell.delegate = self;
    [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
    [cell.activityIndicator stopAnimating];
    if (NULL_TO_NIL([memoryInfo objectForKey:@"gem_title"])) {
        cell.lblTitle.text = [memoryInfo objectForKey:@"gem_title"];
    }
    if (NULL_TO_NIL([memoryInfo objectForKey:@"gem_date"])) {
        cell.lblTitleDate.text = [Utility getDaysBetweenTwoDatesWith:[[memoryInfo objectForKey:@"gem_date"] doubleValue]] ;
    }
       
    if (NULL_TO_NIL([memoryInfo objectForKey:@"gem_media"])) {
    [cell.activityIndicator startAnimating];
        NSString *mediaURL = [memoryInfo objectForKey:@"gem_media"];
        [cell.imgHeader sd_setImageWithURL:[NSURL URLWithString:mediaURL]
                              placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                         [cell.activityIndicator stopAnimating];
                                     }];
    }
    return cell;
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (!isDataAvailable) return kEmptyHeaderAndFooter;
    return kHeightForHeader;
}


#pragma mark - Custom Cell Delegates


-(void)shareButtonClickedWithSection:(NSInteger)section WithIndex:(NSInteger)index{
    
    if (section < arrAllKeys.count) {
        NSString *key = arrAllKeys[section];
        if (NULL_TO_NIL([dictMeomories objectForKey:key])) {
            NSArray *goals = [dictMeomories objectForKey:key];
            if (index < goals.count) {
                NSDictionary *gemDetails = goals[index];
                
                
                UIAlertController * alert=  [UIAlertController
                                             alertControllerWithTitle:@"Share"
                                             message:@"You are going to inspire someone by sharing this GEM to community."
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         NSString *gemID;
                                         NSString *gemType;
                                         
                                         if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
                                             gemID = [gemDetails objectForKey:@"gem_id"];
                                         
                                         if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
                                             gemType = [gemDetails objectForKey:@"gem_type"];
                                         
                                         if (gemID && gemType) {
                                             
                                             [APIMapper shareAGEMToCommunityWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 
                                                 if ([[responseObject objectForKey:@"code"]integerValue] == kSuccessCode){
                                                     
                                                     [[[UIAlertView alloc] initWithTitle:@"Share" message:@"Shared to community gems." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                                                 }
                                                 
                                             } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                                 
                                             }];
                                         }
                                         
                                         
                                     }];
                
                UIAlertAction* cancel = [UIAlertAction
                                         actionWithTitle:@"CANCEL"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                             
                                         }];
                [alert addAction:ok];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
                
                
            }
        }
    }
}


-(void)detailViewClickedWithSection:(NSInteger)section WithIndex:(NSInteger)index{
    
    if (section < arrAllKeys.count) {
        NSString *key = arrAllKeys[section];
        if (NULL_TO_NIL([dictMeomories objectForKey:key])) {
            NSArray *goals = [dictMeomories objectForKey:key];
            if (index < goals.count) {
                NSDictionary *details = goals[index];
                [self getMomentDetailswithDetails:details];
            }
        }
    }
    
}

-(void)getMomentDetailswithDetails:(NSDictionary*)details{
    
    GoalDetailViewController *goalDetailsVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForGoalDetails];
    [[self navigationController]pushViewController:goalDetailsVC animated:YES];
    goalDetailsVC.shouldHideEditBtn = TRUE;
    [goalDetailsVC getGoaDetailsByGoalID:[details objectForKey:@"gem_id"]];
        
    
}


#pragma mark - Generic Methods

-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(IBAction)shareFromList:(id)sender{
    
}

-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([tableView visibleCells].count > 0) {
        NSUInteger sectionNumber = [[tableView indexPathForCell:[[tableView visibleCells] objectAtIndex:0]] section];
        if (sectionNumber < arrAllKeys.count) {
            lblMemoryName.text = [arrAllKeys objectAtIndex:sectionNumber];
        }
    }

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


#pragma mark state preservation / restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}


- (void)applicationFinishedRestoringState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Call whatever function you need to visually restore
    [self customSetup];
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