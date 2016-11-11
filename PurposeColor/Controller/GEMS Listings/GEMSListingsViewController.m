//
//  GEMSListingsViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 28/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//
typedef enum{
    
    eByEmotion = 0,
    eByGoals = 1,
    
} eType;


static NSString *CollectionViewCellIdentifier = @"GEMSListings";
#define OneK                    1000
#define kPadding                10
#define kDefaultNumberOfCells   1
#define kHeightForCell          250
#define kHeightForHeader        50

#import "CustomAudioPlayerView.h"
#import <AVKit/AVKit.h>
#import "GEMSListingsViewController.h"
#import "Constants.h"
#import "MenuViewController.h"
#import "GemsCustomTableViewCell.h"
#import "CustomCellWithTable.h"
#import "GEMCustomCollectionViewCell.h"
#import "PhotoBrowser.h"

@interface GEMSListingsViewController () <SWRevealViewControllerDelegate,GEMSMediaListDelegate,ActionDetailCellDelegate,CustomAudioPlayerDelegate,PhotoBrowserDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIView *vwPaginationPopUp;
    IBOutlet NSLayoutConstraint *paginationBottomConstraint;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    IBOutlet UIView *vwSegmentSelection;
    IBOutlet UIButton *btnEmotion;
    IBOutlet UIButton *btnGoal;
    
    UIRefreshControl *refreshControl;
    
    BOOL isPageRefresing;
    BOOL isDataAvailable;
    BOOL firstTime;
    NSInteger totalGems;
    
    NSInteger totalPages_Emotions;
    NSInteger totalPages_Goals;
    
    NSInteger currentPage_Emotions;
    NSInteger currentPage_Goals;
    
    NSMutableArray *arrEmotions;
    NSMutableArray *arrGoals;
    NSMutableArray *arrDataSource;
    NSArray *arrGoalColors;
    NSArray *arrEmotionColors;
    
    eType eSelectionType;
    
    CustomAudioPlayerView *vwAudioPlayer;
    PhotoBrowser *photoBrowser;
}

@end

@implementation GEMSListingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self customSetup];
    [self checkUserViewStatus];
    [self loadAllEmotionsByPagination:NO withPageNumber:currentPage_Emotions];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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


-(void)setUp{
    
    currentPage_Emotions = 1;
    currentPage_Goals = 1;
    
    totalPages_Emotions = 0;
    totalPages_Goals = 0;
    
    arrDataSource = [NSMutableArray new];
    arrEmotions = [NSMutableArray new];
    arrGoals = [NSMutableArray new];
    arrGoalColors = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:0.94 green:0.32 blue:0.19 alpha:1.0],[UIColor colorWithRed:0.09 green:0.63 blue:0.52 alpha:1.0],[UIColor colorWithRed:0.39 green:0.07 blue:0.29 alpha:1.0], nil];
    arrEmotionColors = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:0.33 green:0.68 blue:0.31 alpha:1.0],[UIColor colorWithRed:0.98 green:0.75 blue:0.20 alpha:1.0],[UIColor colorWithRed:0.31 green:0.74 blue:0.83 alpha:1.0], nil];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
    tableView.hidden = false;
    isDataAvailable = false;
    eSelectionType = eByEmotion;
    
    
    
    
}


-(void)checkUserViewStatus{
    
    firstTime = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GEMS_Show_Count"])
    {
        
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GEMS_Show_Count"] integerValue];
        if (count == 2) {
            firstTime = false;
        }
    }
    
}

-(void)updateVisibilityStatus{
    
    firstTime = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GEMS_Show_Count"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"GEMS_Show_Count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GEMS_Show_Count"] integerValue];
        if (count == 2) {
            
            firstTime = false;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"GEMS_Show_Count"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}

-(IBAction)segmentChanged:(UIButton*)sender{
    
    if (arrDataSource.count > 0) {
       [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    if (sender.tag == 1) {
        eSelectionType = eByEmotion;
        currentPage_Emotions = 1;
        totalPages_Emotions = 0;
        [self loadAllEmotionsByPagination:NO withPageNumber:currentPage_Emotions];
        [self changeAnimatedSelectionToGoal:NO];
    }
   else{
        eSelectionType = eByGoals;
        currentPage_Goals = 1;
        totalPages_Goals = 0;
        [self loadAllGoalsByPagination:NO withPageNumber:currentPage_Goals];
        [self changeAnimatedSelectionToGoal:YES];
    }
    
    [self configureDataSource];
    
}

-(void)changeAnimatedSelectionToGoal:(BOOL)toGoal{
    
    if (toGoal) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = vwSegmentSelection.frame;
            frame.origin.x = self.view.frame.size.width / 2;
            vwSegmentSelection.frame = frame;
        }completion:^(BOOL finished) {
            [btnEmotion setAlpha:0.7];
            [btnGoal setAlpha:1];
        
        }];
    }else{
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = vwSegmentSelection.frame;
            frame.origin.x = 0;
            vwSegmentSelection.frame = frame;
        }completion:^(BOOL finished) {
            [btnEmotion setAlpha:1];
            [btnGoal setAlpha:0.7];
        }];
    }
    
}


-(void)refreshData{
    
    if (isPageRefresing){
        [refreshControl endRefreshing];
        return;
    }
    [arrDataSource removeAllObjects];
    [arrGoals removeAllObjects];
    [arrEmotions removeAllObjects];
    currentPage_Goals = 1;
    currentPage_Emotions = 1;
    isPageRefresing = YES;
    NSInteger currentPage = 1;
    
    if (eSelectionType == eByEmotion) {
        eSelectionType = eByEmotion;
        currentPage_Emotions = 1;
        totalPages_Emotions = 0;
        [self loadAllEmotionsByPagination:NO withPageNumber:currentPage];
        
    }else{
        eSelectionType = eByGoals;
        currentPage_Goals = 1;
        totalPages_Goals = 0;
        [self loadAllGoalsByPagination:NO withPageNumber:currentPage];
    }
    
}


-(void)loadAllGoalsByPagination:(BOOL)isPagination withPageNumber:(NSInteger)pageNo{
    
    if (!isPagination) {
        [self showLoadingScreen];
        tableView.hidden = true;
    }
    
    [APIMapper getAllGoalsWith:[User sharedManager].userId pageNo:pageNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        [self getGemsFromResponds:responseObject];
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


-(void)loadAllEmotionsByPagination:(BOOL)isPagination withPageNumber:(NSInteger)pageNo{
    
    if (!isPagination) {
        [self showLoadingScreen];
        tableView.hidden = true;
    }
    
    
    [APIMapper getAllGEMEmotionsByUserID:[User sharedManager].userId pageNo:pageNo isFirstTime:firstTime success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        tableView.hidden = false;
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        [self getGemsFromResponds:responseObject];
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        [self updateVisibilityStatus];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        tableView.hidden = false;
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        isDataAvailable = false;
        [tableView reloadData];

    }];
}

-(void)getGemsFromResponds:(NSDictionary*)responds{
    
    NSArray *goals;
   
        if (eSelectionType == eByEmotion) {
            eSelectionType = eByEmotion;
            [arrEmotions removeAllObjects];
            if (NULL_TO_NIL([responds objectForKey:@"emotions"])) {
                goals = [responds objectForKey:@"emotions"];
                if (goals.count) [arrEmotions addObjectsFromArray:goals];
                if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"currentPage"]))
                    currentPage_Emotions = [[[responds objectForKey:@"header"] objectForKey:@"currentPage"] integerValue];
                if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"pageCount"]))
                    totalPages_Emotions = [[[responds objectForKey:@"header"] objectForKey:@"pageCount"] integerValue];
            }
           
        }else{
             eSelectionType = eByGoals;
            if (NULL_TO_NIL([responds objectForKey:@"goals"])) {
                goals = [responds objectForKey:@"goals"];
                [arrGoals removeAllObjects];
                if (goals.count) [arrGoals addObjectsFromArray:goals];
                if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"currentPage"]))
                    currentPage_Goals = [[[responds objectForKey:@"header"] objectForKey:@"currentPage"] integerValue];
                if (NULL_TO_NIL([[responds objectForKey:@"header"] objectForKey:@"pageCount"]))
                    totalPages_Goals = [[[responds objectForKey:@"header"] objectForKey:@"pageCount"] integerValue];
            }
            
        }
        
    [self configureDataSource];
}

-(void)configureDataSource{
    
    [arrDataSource removeAllObjects];
    if (eSelectionType == eByEmotion) {
        eSelectionType = eByEmotion;
        if (arrEmotions.count > 0) {
            arrDataSource = [NSMutableArray arrayWithArray:arrEmotions];
        }
    }else{
        
        eSelectionType = eByGoals;
        if (arrGoals.count > 0) {
            arrDataSource = [NSMutableArray arrayWithArray:arrGoals];
        }
    }
    isDataAvailable = false;
    if (arrDataSource.count) isDataAvailable = true;
    [tableView reloadData];
    
}




#pragma mark - UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!isDataAvailable) {
        return kDefaultNumberOfCells;
    }
    return arrDataSource.count;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalCount = 0;
    
    if (!isDataAvailable) {
        return kDefaultNumberOfCells;
    }
    
    if (eSelectionType == eByGoals) {
        // By Goals
        
        if (section < arrDataSource.count) {
            NSDictionary *details = arrDataSource[section];
            if (NULL_TO_NIL([details objectForKey:@"gem_media"])) {
                NSArray *goalMedia = [details objectForKey:@"gem_media"];
                totalCount += goalMedia.count;
                
            }
            if (NULL_TO_NIL([details objectForKey:@"action"])) {
                totalCount += 1;
                
            }
            totalCount += 1; // Info cell;
        }
        return totalCount;
    }else{
        
        // By Emotions
        
        if (section < arrDataSource.count) {
            NSDictionary *details = arrDataSource[section];
            NSArray *actions;
            if (NULL_TO_NIL([details objectForKey:@"action"])) {
                actions = [details objectForKey:@"action"];
                if (actions.count > 0) {
                    totalCount = 1;
                }
            }
            
            // Only actions;
        }
        return totalCount;
    }
    
    return totalCount;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No GEMS Available."];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }

    cell = [self configureCellForIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    
    if (eSelectionType == eByGoals) {
        
        // For Goals
        
        if (indexPath.row == 0) {
            // GEM Description
            
            static NSString *CellIdentifier = @"GoalInfo";
            UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            if (indexPath.section < arrDataSource.count) {
                NSDictionary *details = arrDataSource[indexPath.section];
                UILabel *lblInfo;
                UILabel *dateInfo;
                
                if ([[[cell contentView] viewWithTag:1] isKindOfClass:[UILabel class]])lblInfo = [[cell contentView] viewWithTag:1];
                if ([[[cell contentView] viewWithTag:2] isKindOfClass:[UILabel class]])dateInfo = [[cell contentView] viewWithTag:2];
                
                if (NULL_TO_NIL([details objectForKey:@"datetime"])) {
                    dateInfo.text = [Utility getDateStringFromSecondsWith:[[details objectForKey:@"datetime"] doubleValue] withFormat:@"d MMM,yyyy h:mm a"];
                    
                   
                }
                lblInfo.hidden = false;
                dateInfo.hidden = false;
                
                if ([details objectForKey:@"details"]) {
                    UIFont *font = [UIFont fontWithName:CommonFont size:14];
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                    paragraphStyle.lineHeightMultiple = 1.2f;
                    NSDictionary *attributes = @{NSFontAttributeName:font,
                                                 NSParagraphStyleAttributeName:paragraphStyle,
                                                 };
                    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[details objectForKey:@"details"] attributes:attributes];
                    lblInfo.attributedText = attributedText;
                    
                }
                if ([[[cell contentView] viewWithTag:3] isKindOfClass:[UIView class]]){
                    UIView *vwBg = [[cell contentView] viewWithTag:3];
                     vwBg.hidden = true;
                    if ([[vwBg viewWithTag:4] isKindOfClass:[UILabel class]]){
                        UILabel *lblAddress = (UILabel*) [vwBg viewWithTag:4];
                        lblAddress.text = @"";
                        if (NULL_TO_NIL([details objectForKey:@"location_name"])) {
                            lblAddress.text = [details objectForKey:@"location_name"];
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
                        if (NULL_TO_NIL([details objectForKey:@"contact_name"])) {
                            lblAddress.text = [details objectForKey:@"contact_name"];
                            vwBg.hidden = false;
                        }
                        
                    }
                    
                }
            }
            
            return cell;
            
        }
        
        BOOL isReached = false;
        if (indexPath.section < arrDataSource.count) {
            BOOL isActionAvailable = false;
            NSDictionary *details = arrDataSource[indexPath.section];
            NSArray *actions;
            if (NULL_TO_NIL([details objectForKey:@"action"])) {
                actions = [details objectForKey:@"action"];
                if (actions.count > 0) {
                    isActionAvailable = true;;
                }
            }
            // Check if reached Action Cell
            
            NSArray *goalMedia;
            if (NULL_TO_NIL([details objectForKey:@"gem_media"])) {
               goalMedia = [details objectForKey:@"gem_media"];
            }
            if (isActionAvailable) {
                
                if (indexPath.row  == goalMedia.count + 1) {
                    isReached = true;
                }
            }
        }
        
        if (isReached) {
            if (indexPath.section < arrDataSource.count) {
                NSDictionary *details = arrDataSource[indexPath.section];
                NSArray *actions;
                if (NULL_TO_NIL([details objectForKey:@"action"])) {
                    actions = [details objectForKey:@"action"];
                    if (actions.count > 0) {
                        static NSString *CellIdentifier = @"CustomCellWithTable";
                        CustomCellWithTable *cell = (CustomCellWithTable *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.backgroundColor = [UIColor clearColor];
                        cell.delegate = self;
                        cell.isTabEmotion = false;
                        cell.contentView.backgroundColor = [UIColor clearColor];
                        cell.topConstarintForTable.constant = 40;
                        [cell setUpActionsWithDataSource:actions];
                        [cell setUpParentSection:indexPath.section];
                        return cell;
                    }
                }
                
            }
        }
        else{
            
            static NSString *CellIdentifier = @"GemsCustomTableViewCell";
            GemsCustomTableViewCell *cell = (GemsCustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
            [cell.activityIndicator stopAnimating];
            [[cell btnVideoPlay]setHidden:YES];
            [[cell btnAudioPlay]setHidden:YES];
            cell.delegate = self;
            [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
            
            if (indexPath.section < arrDataSource.count) {
                NSDictionary *details = arrDataSource[indexPath.section];
                if (NULL_TO_NIL([details objectForKey:@"gem_media"])) {
                    NSArray *goalMedia = [details objectForKey:@"gem_media"];
                    if (indexPath.row - 1 < goalMedia.count) {
                        NSDictionary *mediaInfo = goalMedia[indexPath.row - 1];
                        if (mediaInfo) {
                            
                            NSString *mediaType ;
                            if (NULL_TO_NIL([mediaInfo objectForKey:@"media_type"])) {
                                mediaType = [mediaInfo objectForKey:@"media_type"];
                            }
                            
                            if (mediaType) {
                                
                                if ([mediaType isEqualToString:@"image"]) {
                                    
                                    // Type Image
                                    [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
                                    [cell.activityIndicator startAnimating];
                                    [cell.imgGem sd_setImageWithURL:[NSURL URLWithString:[mediaInfo objectForKey:@"gem_media"]]
                                                   placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                              [UIView transitionWithView:cell.imgGem
                                                                                duration:.5f
                                                                                 options:UIViewAnimationOptionTransitionCrossDissolve
                                                                              animations:^{
                                                                                  cell.imgGem.image = image;
                                                                              } completion:nil];
                                                              
                                                              
                                                              [cell.activityIndicator stopAnimating];
                                                          }];
                                }
                                
                                else if ([mediaType isEqualToString:@"audio"]) {
                                    
                                    // Type Audio
                                    [cell.imgGem setImage:[UIImage imageNamed:@"NoImage.png"]];
                                    if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                                        [[cell btnAudioPlay]setHidden:false];
                                        
                                    }
                                    
                                }
                                
                                else if ([mediaType isEqualToString:@"video"]) {
                                    
                                    // Type Video
                                    if (NULL_TO_NIL([mediaInfo objectForKey:@"gem_media"])) {
                                        NSString *videoURL = [mediaInfo objectForKey:@"gem_media"];
                                        if (videoURL.length){
                                            [[cell btnVideoPlay]setHidden:false];
                                        }
                                    }
                                    
                                    if (NULL_TO_NIL([mediaInfo objectForKey:@"video_thumb"])) {
                                        NSString *videoThumb = [mediaInfo objectForKey:@"video_thumb"];
                                        if (videoThumb.length) {
                                            [cell.activityIndicator startAnimating];
                                            [cell.imgGem sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                                           placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                                      [cell.activityIndicator stopAnimating];
                                                                      [UIView transitionWithView:cell.imgGem
                                                                                        duration:.5f
                                                                                         options:UIViewAnimationOptionTransitionCrossDissolve
                                                                                      animations:^{
                                                                                          cell.imgGem.image = image;
                                                                                      } completion:nil];
                                                                  }];
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
            }
            return cell;
        }

    }else{
        
        // For emotions
        
        if (indexPath.section < arrDataSource.count) {
            BOOL isActionAvailable = false;
            NSDictionary *details = arrDataSource[indexPath.section];
            NSArray *actions;
            if (NULL_TO_NIL([details objectForKey:@"action"])) {
                actions = [details objectForKey:@"action"];
                if (actions.count > 0) {
                    isActionAvailable = true;
                    NSArray *actions;
                    if (NULL_TO_NIL([details objectForKey:@"action"])) {
                        actions = [details objectForKey:@"action"];
                        if (actions.count > 0) {
                            static NSString *CellIdentifier = @"CustomCellWithTable";
                            CustomCellWithTable *cell = (CustomCellWithTable *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            cell.accessoryType = UITableViewCellAccessoryNone;
                            cell.backgroundColor = [UIColor clearColor];
                            cell.delegate = self;
                            cell.isTabEmotion = true;
                            cell.contentView.backgroundColor = [UIColor clearColor];
                            cell.topConstarintForTable.constant = 0;
                            [cell setUpActionsWithDataSource:actions];
                            [cell setUpParentSection:indexPath.section];
                            return cell;
                        }
                    }

                }
            }
            // Check if reached Action Cell
        }
        
               
    }
        return cell;

}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) return kHeightForCell;
    
    if (eSelectionType == eByGoals) {
        // By Goals
        NSDictionary *goalInfo;
        if (indexPath.row == 0) {
            if (indexPath.section < arrDataSource.count) {
                goalInfo = arrDataSource[indexPath.section];
                CGFloat padding = 40;
                NSInteger height = 0;
                if (NULL_TO_NIL([goalInfo objectForKey:@"details"])) {
                    height += [self getLabelHeightForDescription:[goalInfo objectForKey:@"details"] withFont:[UIFont fontWithName:CommonFont size:14]];
                    height += 5;
                }
                
                if (NULL_TO_NIL([goalInfo objectForKey:@"contact_name"])) {
                    height += [self getLabelHeightForOtherInfo:[goalInfo objectForKey:@"contact_name"] withFont:[UIFont fontWithName:CommonFont size:12] withPadding:45];
                    height += 5;
                }

                if (NULL_TO_NIL([goalInfo objectForKey:@"location_name"])) {
                    height += [self getLabelHeightForOtherInfo:[goalInfo objectForKey:@"location_name"] withFont:[UIFont fontWithName:CommonFontBold size:12] withPadding:45];
                }
                
                return height + padding;
            }
            
        }
        BOOL isActionAvailable = false;
        if (indexPath.section < arrDataSource.count) {
            NSDictionary *details = arrDataSource[indexPath.section];
            NSArray *actions;
            if (NULL_TO_NIL([details objectForKey:@"action"])) {
                actions = [details objectForKey:@"action"];
                if (actions.count > 0) {
                    isActionAvailable = true;;
                }
            }
            // Check if reached Action Cell
            
            if (isActionAvailable) {
                NSArray *goalMedia;
                if (NULL_TO_NIL([details objectForKey:@"gem_media"])) {
                    goalMedia = [details objectForKey:@"gem_media"];
                }
                if (indexPath.row == goalMedia.count + 1) {
                    //Reached actions
                    NSInteger height = 0;
                    for (NSDictionary *dict in actions) {
                        if (NULL_TO_NIL([dict objectForKey:@"action_media"])) {
                            NSArray *actionMedias = [dict objectForKey:@"action_media"];
                            height += (kHeightForCell * actionMedias.count );
                        }
                        if (NULL_TO_NIL([dict objectForKey:@"action_details"])) {
                            height += [self getLabelHeightForActionDescription:[dict objectForKey:@"action_details"]withFont:[UIFont fontWithName:CommonFont size:14] withPadding:30]; // Description height
                            CGFloat padding = 20;
                            height +=  padding;
                        }
                        if (NULL_TO_NIL([dict objectForKey:@"action_title"])) {
                            CGFloat minimumHeifght = 70;
                            CGFloat _height = [self getHeaderHeight:[dict objectForKey:@"action_title"] withPadding:30];
                            if (_height < minimumHeifght) {
                                height += minimumHeifght;
                            }else{
                                height += _height + 15;
                            }
                        }
                        
                    }
                    return height;
                    
                }else{
                    
                    //other cells
                    
                    return kHeightForCell;
                }
                
            }else{
                //Action Not available
                return kHeightForCell;
            }
        }

        
    }else{
        
        // By Emotions
        
            BOOL isActionAvailable = false;
            if (indexPath.section < arrDataSource.count) {
                NSDictionary *details = arrDataSource[indexPath.section];
                NSArray *actions;
                if (NULL_TO_NIL([details objectForKey:@"action"])) {
                    actions = [details objectForKey:@"action"];
                    if (actions.count > 0) {
                        isActionAvailable = true;;
                    }
                }
                // Check if reached Action Cell
                NSInteger height = 0;
                if (isActionAvailable) {
                    
                    for (NSDictionary *dict in actions) {
                        if (NULL_TO_NIL([dict objectForKey:@"action_media"])) {
                            NSArray *actionMedias = [dict objectForKey:@"action_media"];
                            height += (kHeightForCell * actionMedias.count );
                        }
                        if (NULL_TO_NIL([dict objectForKey:@"action_details"])) {
                            NSString *strDetails = [dict objectForKey:@"action_details"];
                            if (strDetails.length) {
                                height += [self getLabelHeightForActionDescription:[dict objectForKey:@"action_details"] withFont:[UIFont fontWithName:CommonFont size:14] withPadding:15]; // Description height
                                CGFloat padding = 20;
                                height +=  padding;
                            }
                            
                        }
                        
                        float padding = 0;
                        if (NULL_TO_NIL([dict objectForKey:@"contact_name"])) {
                            height += [self getLabelHeightForOtherInfo:[dict objectForKey:@"contact_name"] withFont:[UIFont fontWithName:CommonFont size:12] withPadding:30];
                            padding = 10;
                        }
                        
                        if (NULL_TO_NIL([dict objectForKey:@"location_name"])) {
                            height += [self getLabelHeightForOtherInfo:[dict objectForKey:@"location_name"] withFont:[UIFont fontWithName:CommonFontBold size:12] withPadding:30];
                            padding = 10;
                        }
                        height +=  padding;
                        
                        if (NULL_TO_NIL([dict objectForKey:@"action_title"])) {
                            CGFloat _height = [self getHeaderHeight:[dict objectForKey:@"action_title"] withPadding:15];
                            height += _height;
                            
                        }
                    }
                    return height;
                    
                }else{
                    //Action Not available
                    return kHeightForCell;
                }
            }
        }
       
    CGFloat height = kHeightForCell;
    return height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
      
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable) return Nil;
    UIView *vwHeader = [UIView new];
    UIView *vwBG = [UIView new];
    [vwHeader addSubview:vwBG];
    vwBG.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBG)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwBG]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwBG)]];
     vwBG.backgroundColor =  arrGoalColors[section % 3];
    if (eSelectionType == eByEmotion) {
        vwBG.backgroundColor =  arrEmotionColors[section % 3];
    }
    
    UILabel *_lblTitle = [UILabel new];
    _lblTitle.numberOfLines = 0;
    _lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwBG addSubview:_lblTitle];
    
    
    
    if (eSelectionType == eByGoals)
        [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:_lblTitle
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwBG
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:-8.0]];
    else
        [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:_lblTitle
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwBG
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_lblTitle]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_lblTitle)]];
    _lblTitle.font = [UIFont fontWithName:CommonFontBold size:15];
    _lblTitle.textColor = [UIColor whiteColor];
    if (section < arrDataSource.count) {
        NSDictionary *details = arrDataSource[section];
        if (NULL_TO_NIL([details objectForKey:@"title"])) {
            _lblTitle.text = [details objectForKey:@"title"];
        }
    }
    
     if (eSelectionType == eByGoals) {
         
         UILabel *lblDate= [UILabel new];
         lblDate.numberOfLines = 1;
         lblDate.translatesAutoresizingMaskIntoConstraints = NO;
         [vwBG addSubview:lblDate];
         
         [vwBG addConstraint:[NSLayoutConstraint constraintWithItem:lblDate
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_lblTitle
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:8.0]];

         
         [vwBG addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblDate]-5-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblDate)]];
         lblDate.font = [UIFont fontWithName:CommonFont size:11];
         lblDate.textColor = [UIColor whiteColor];
         if (section < arrDataSource.count) {
             NSDictionary *details = arrDataSource[section];
                 lblDate.text = [NSString stringWithFormat:@"%@ - %@ | %@",[Utility getDateStringFromSecondsWith:[[details objectForKey:@"goal_startdate"] doubleValue] withFormat:@"d MMM,yyyy"],[Utility getDateStringFromSecondsWith:[[details objectForKey:@"goal_enddate"] doubleValue] withFormat:@"d MMM,yyyy"],@"Active"]  ;
         }
     }
    
    return vwHeader;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable) return 0.01;
    if (section < arrDataSource.count) {
        NSDictionary *details = arrDataSource[section];
        if (NULL_TO_NIL([details objectForKey:@"title"])) {
            float heightPadding = 45;
            float widthPadding = 10;
            if (eSelectionType == eByEmotion) {
                heightPadding = 10;
            }
            CGFloat height =  [self getGEMSHeaderHeight:[details objectForKey:@"title"] withPadding:widthPadding];
            if (height + heightPadding < kHeightForHeader)
                return kHeightForHeader;
            else return height + heightPadding;
            
        }
        
    }
    return kHeightForHeader;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage_Emotions;
            NSInteger totalPages = totalPages_Emotions;
            if (eSelectionType == eByGoals) {
                nextPage = currentPage_Goals ;
                totalPages = totalPages_Goals;
            }
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self showPaginationPopUp];
                if (eSelectionType == eByGoals) {
                    
                    [self loadAllGoalsByPagination:YES withPageNumber:nextPage];
                }else{
                    
                     [self loadAllEmotionsByPagination:YES withPageNumber:nextPage];
                }
            }
            
        }
    }
    
}

-(void)mediaCellClickedWithSection:(NSInteger)section andIndex:(NSInteger)index{
    
    if (section < arrDataSource.count) {
        NSDictionary *details = arrDataSource[section];
        if (NULL_TO_NIL([details objectForKey:@"gem_media"])) {
            NSArray *medias = [details objectForKey:@"gem_media"];
            if (index - 1 < medias.count) {
                NSDictionary *mediaItem = medias[index - 1];
                if (NULL_TO_NIL([mediaItem objectForKey:@"media_type"])) {
                   NSString *mediaType = [mediaItem objectForKey:@"media_type"];
                    if ([mediaType isEqualToString:@"video"]) {
                        [self playVideoWithURL:[mediaItem objectForKey:@"gem_media"]];
                    }
                    else if ([mediaType isEqualToString:@"audio"]) {
                        
                        NSURL  *audioURL = [NSURL URLWithString:[mediaItem objectForKey:@"gem_media"]];
                        [self showAudioPlayerWithURL:audioURL];
                    }
                    else if ([mediaType isEqualToString:@"image"]){
                        NSMutableArray *arrImages = [NSMutableArray new];
                        [arrImages addObject:[NSURL URLWithString:[mediaItem objectForKey:@"gem_media"]]];
                        for (NSDictionary *dict in medias) {
                            NSString *mediaType = [dict objectForKey:@"media_type"];
                            if ([mediaType isEqualToString:@"image"]) {
                                if (![arrImages containsObject:[NSURL URLWithString:[dict objectForKey:@"gem_media"]]]) {
                                    [arrImages addObject:[NSURL URLWithString:[dict objectForKey:@"gem_media"]]];
                                }
                                
                            }
                            
                        }
                        if (arrImages.count) [self presentGalleryWithImages:arrImages];
                        
                    }
     
                }
            }
        }
    }
}

-(void)mediaCellClickedWithSection:(NSInteger)section andIndex:(NSInteger)index parentSection:(NSInteger)parentSection{
    
    if (parentSection < arrDataSource.count) {
        NSDictionary *details = arrDataSource[parentSection];
        if (NULL_TO_NIL([details objectForKey:@"action"])) {
            NSArray *actions = [details objectForKey:@"action"];
            if (section < actions.count) {
                NSDictionary *mediaInfo = actions[section];
                if ([mediaInfo objectForKey:@"action_media"]) {
                    NSArray *medias = [mediaInfo objectForKey:@"action_media"];
                    if (index - 1 < medias.count) {
                        NSDictionary *mediaItem = medias[index - 1];
                        
                        if (NULL_TO_NIL([mediaItem objectForKey:@"media_type"])) {
                            NSString *mediaType = [mediaItem objectForKey:@"media_type"];
                            if ([mediaType isEqualToString:@"video"]) {
                                [self playVideoWithURL:[mediaItem objectForKey:@"gem_media"]];
                            }
                            else if ([mediaType isEqualToString:@"audio"]) {
                                
                                NSURL  *audioURL = [NSURL URLWithString:[mediaItem objectForKey:@"gem_media"]];
                                [self showAudioPlayerWithURL:audioURL];
                            }
                            else if ([mediaType isEqualToString:@"image"]){
                                NSMutableArray *arrImages = [NSMutableArray new];
                                [arrImages addObject:[NSURL URLWithString:[mediaItem objectForKey:@"gem_media"]]];
                                for (NSDictionary *dict in medias) {
                                    NSString *mediaType = [dict objectForKey:@"media_type"];
                                    if ([mediaType isEqualToString:@"image"]) {
                                        if (![arrImages containsObject:[NSURL URLWithString:[dict objectForKey:@"gem_media"]]]) {
                                            [arrImages addObject:[NSURL URLWithString:[dict objectForKey:@"gem_media"]]];
                                        }
                                        
                                    }
                                    
                                }
                                if (arrImages.count) [self presentGalleryWithImages:arrImages];
                                
                            }
                            
                        }
                        
                    }
                }
                
            }
        }
    }
}
-(void)playSelectedMediaWithIndex:(NSDictionary*)item {
    
    NSString *mediaURL;
    NSString *mediaType;
    if (NULL_TO_NIL([item objectForKey:@"gem_media"])) {
        mediaURL = [item objectForKey:@"gem_media"];
    }
    
    if (NULL_TO_NIL([item objectForKey:@"media_type"])) {
        mediaType = [item objectForKey:@"media_type"];
    }
    if ([mediaType isEqualToString:@"video"]) {
        
        NSError* error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:mediaURL]];
         [playerViewController.player play];
        [self presentViewController:playerViewController animated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(videoDidFinish:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[playerViewController.player currentItem]];
    }
    else if ([mediaType isEqualToString:@"audio"]) {
        
        NSURL  *audioURL = [NSURL URLWithString:mediaURL];
        [self showAudioPlayerWithURL:audioURL];
    }
    

}

-(void)playVideoWithURL:(NSString*)mediaURL{
    
    NSError* error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
    playerViewController.player = [AVPlayer playerWithURL:[NSURL URLWithString:mediaURL]];
    [playerViewController.player play];
    [self presentViewController:playerViewController animated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[playerViewController.player currentItem]];
}

- (void)videoDidFinish:(id)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //fade out / remove subview
}

-(void)showAudioPlayerWithURL:(NSURL*)url{
    
    if (!vwAudioPlayer) {
        vwAudioPlayer = [[[NSBundle mainBundle] loadNibNamed:@"CustomAudioPlayerView" owner:self options:nil] objectAtIndex:0];
        vwAudioPlayer.delegate = self;
    }
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = vwAudioPlayer;
    [app.window.rootViewController.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwAudioPlayer setupAVPlayerForURL:url];
    }];
    
}

-(void)closeAudioPlayerView{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwAudioPlayer.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [vwAudioPlayer removeFromSuperview];
        vwAudioPlayer = nil;
        NSError* error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:NO error:&error];
    }];
    

}
- (void)presentGalleryWithImages:(NSArray*)images
{
    [self.view endEditing:YES];
    if (!photoBrowser) {
        photoBrowser = [[[NSBundle mainBundle] loadNibNamed:@"PhotoBrowser" owner:self options:nil] objectAtIndex:0];
        photoBrowser.delegate = self;
    }
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = photoBrowser;
    [app.window.rootViewController.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser setUpWithImages:images];
    }];
    
}

-(void)closePhotoBrowserView{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        photoBrowser.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [photoBrowser removeFromSuperview];
        photoBrowser = nil;
    }];
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
-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (CGFloat)getLabelHeightForDescription:(NSString*)description withFont:(UIFont*)font
{
    CGFloat height = 0;
    float widthPadding = 15;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.2f;
    CGSize boundingBox = [description boundingRectWithSize:constraint
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:font,
                                                                     NSParagraphStyleAttributeName:paragraphStyle}
                                                           context:context].size;
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    height = size.height;

    return height;
    
}

- (CGFloat)getLabelHeightForActionDescription:(NSString*)description withFont:(UIFont*)font withPadding:(float)padding
{
    CGFloat height = 10;
    float widthPadding = padding;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.2f;
    CGSize boundingBox = [description boundingRectWithSize:constraint
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:font,
                                                             NSParagraphStyleAttributeName:paragraphStyle}
                                                   context:context].size;
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    height = size.height;
    
    return height;
    
}

- (CGFloat)getHeaderHeight:(NSString*)description withPadding:(float)widthPadding
{
    float heightPadding = 50;
    CGFloat height = 0;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (description) {
        constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        CGSize boundingBox = [description boundingRectWithSize:constraint
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                                 }
                                                       context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height = size.height + heightPadding;
    }
    
    
    return height;
    
}

- (CGFloat)getGEMSHeaderHeight:(NSString*)description withPadding:(float)widthPadding
{
    float heightPadding = 0;
    CGFloat height = 0;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    
    if (description) {
        constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        CGSize boundingBox = [description boundingRectWithSize:constraint
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],
                                                                 }
                                                       context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        height = size.height + heightPadding;
    }
    
    
    return height;
    
}

- (CGFloat)getLabelHeightForOtherInfo:(NSString*)description withFont:(UIFont*)font withPadding:(float)padding
{
    CGFloat height = 0;
    float widthPadding = padding;
    CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
    CGSize boundingBox = [description boundingRectWithSize:constraint
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:font
                                                             }
                                                   context:context].size;
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    height = size.height;
//    if (height < 15) {
//        height = 15;
//    }
    
    return height;
    
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
