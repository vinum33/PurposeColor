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
#define kUnAuthorized           403

#import "CustomAudioPlayerView.h"
#import <AVKit/AVKit.h>
#import "GEMSWithHeaderListingsViewController.h"
#import "Constants.h"
#import "MenuViewController.h"
#import "GemsCustomTableViewCell.h"
#import "CustomCellWithTable.h"
#import "PhotoBrowser.h"
#import "KILabel.h"

@interface GEMSWithHeaderListingsViewController () <SWRevealViewControllerDelegate,GEMSMediaListDelegate,ActionDetailCellDelegate,CustomAudioPlayerDelegate,PhotoBrowserDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIView *vwPaginationPopUp;
    IBOutlet NSLayoutConstraint *paginationBottomConstraint;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    IBOutlet UIView *vwSegmentSelection;
    IBOutlet UIButton *btnEmotion;
    IBOutlet UIButton *btnGoal;
    UIButton *btnHand;
    UIImage *headerImage;
    float heightForImageCell;
    
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
    NSMutableDictionary *heightsCache;
}

@end

@implementation GEMSWithHeaderListingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self loadAllEmotionsByPagination:NO withPageNumber:currentPage_Emotions];

    // Do any additional setup after loading the view.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{
    
       
    currentPage_Emotions = 1;
    currentPage_Goals = 1;
    
    totalPages_Emotions = 0;
    totalPages_Goals = 0;
    
    arrDataSource = [NSMutableArray new];
    arrEmotions = [NSMutableArray new];
    arrGoals = [NSMutableArray new];
    arrGoalColors = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:0.08 green:0.40 blue:0.75 alpha:1.0],[UIColor colorWithRed:0.10 green:0.46 blue:0.82 alpha:1.0],[UIColor colorWithRed:0.12 green:0.53 blue:0.90 alpha:1.0], nil];
    arrEmotionColors = [[NSArray alloc] initWithObjects:[UIColor colorWithRed:0.26 green:0.65 blue:0.96 alpha:1.0],[UIColor colorWithRed:0.13 green:0.59 blue:0.95 alpha:1.0],[UIColor colorWithRed:0.12 green:0.53 blue:0.90 alpha:1.0], nil];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
    tableView.hidden = false;
    isDataAvailable = false;
    eSelectionType = eByEmotion;
    heightsCache = [NSMutableDictionary new];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [tableView reloadData];
}

-(void)refreshData{
    
    [heightsCache removeAllObjects];
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
    
    if ([[[responds objectForKey:@"header"] objectForKey:@"code"] integerValue] == kUnAuthorized) {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app clearUserSessions];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Invalid"
                                                        message:@"Please login to continue.."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
        
    }

    
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
    return arrDataSource.count + 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger totalCount = 0;
    
    if (!isDataAvailable) {
        return kDefaultNumberOfCells;
    }
    
    if (section == 0) {
        
        //Static image at top
        return 1;
    }
    
    if (section - 1 < arrDataSource.count) {
        NSDictionary *details = arrDataSource[section - 1];
        NSArray *actions;
        if (NULL_TO_NIL([details objectForKey:@"action"])) {
            actions = [details objectForKey:@"action"];
            if (actions.count > 0) {
                totalCount = 1;
            }
            
            // Only actions so count is One always,since its showing like a table insdie a single cell;
        }
        return totalCount;
    }
    
    return totalCount;
}

-(void)checking{
    
}

-(void) tableView:(UITableView *) tableView willDisplayCell:(UITableViewCell *) cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //row number on which you want to animate your view
    //row number could be either 0 or 1 as you are creating two cells
    //suppose you want to animate view on cell at 0 index
    if (indexPath.section == 0 && indexPath.row == 0) { //check for the 0th index cell
    {
           }
        
}

    
        // access the view which you want to animate from it's tag
        
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *CellIdentifier = @"HeaderImage";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        if ([[cell contentView]viewWithTag:101]) {
            UIButton *_btnHand = [[cell contentView]viewWithTag:101];
            [_btnHand removeFromSuperview];
        }
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(aTableView.frame.size.width / 2.0 - 15, 150, 20, 20);
        [doneBtn setImage:[UIImage imageNamed:@"hand"] forState:UIControlStateNormal];
        doneBtn.tag = 101;
        [cell.contentView addSubview:doneBtn];
        
        [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationCurveLinear | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat) animations:^{
            [doneBtn setTransform:CGAffineTransformMakeScale(1.5, 1.5)];
            doneBtn.alpha = 0.2;
        }  completion:nil];
        
        
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
    
        // For emotions
        
        if (indexPath.section - 1 < arrDataSource.count) {
            BOOL isActionAvailable = false;
            NSDictionary *details = arrDataSource[indexPath.section - 1];
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
                            cell.placeHolderText = [NSString stringWithFormat:@" %@ ",[details objectForKey:@"title"]];
                            cell.deviceWidth = tableView.frame.size.width;
                            [cell setUpActionsWithDataSource:actions];
                            [cell setUpParentSection:indexPath.section - 1];
                            return cell;
                        }
                    }
                    
                }
            }
            // Check if reached Action Cell
        }
        
        
    
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 260;
    }
    
        // By Emotions
        
        BOOL isActionAvailable = false;
        if (indexPath.section  -1 < arrDataSource.count) {
            NSDictionary *details = arrDataSource[indexPath.section  -1];
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
                        float finalImgHeight = 0;
                        float padding = 15;
                        for (NSDictionary *dict in actionMedias) {
                            float _width = [[dict objectForKey:@"image_width"] floatValue];
                            float _height = [[dict objectForKey:@"image_height"] floatValue];
                            float ratio = _width / _height;
                            float deviceWidth = _tableView.frame.size.width;
                            float imageHeight = (deviceWidth - padding) / ratio;
                            finalImgHeight += imageHeight;
                        }
                        height += finalImgHeight;
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
    
    
    CGFloat height = kHeightForCell;
    return height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app showEmotionalAwarenessPageIsFromVisualization:YES];
        
    }
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
    if (section - 1 < arrDataSource.count) {
        NSDictionary *details = arrDataSource[section - 1];
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
    
    if (!isDataAvailable || section == 0) return 0.01;
    return kHeightForHeader;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage_Emotions;
            NSInteger totalPages = totalPages_Emotions;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self showPaginationPopUp];
                [self loadAllEmotionsByPagination:YES withPageNumber:nextPage];
                
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

-(IBAction)showCommunityGems:(id)sender{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showCommubityGEMS];
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


- (void)attemptOpenURL:(NSURL *)url
{
    
    
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (!safariCompatible) {
        
        NSString *urlString = url.absoluteString;
        urlString = [NSString stringWithFormat:@"http://%@",url.absoluteString];
        url = [NSURL URLWithString:urlString];
        
    }
    safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem"
                                                        message:@"The selected link cannot be opened."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (CGFloat)getLabelHeightForOtherInfo:(NSString*)description withFont:(UIFont*)font
{
    CGFloat height = 0;
    float widthPadding = 30;
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

- (CGFloat)getLabelHeightForActionDescription:(NSString*)description withFont:(UIFont*)font
{
    CGFloat height = 10;
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
