//
//  EmotionalIntelligenceViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 27/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    ePieChart = 0,
    eDetailed = 1,
    ePatient = 2,
    eAssertive = 3,
    eWarm = 4,
    eSupportingEmotions = 5
    
} eSectionType;


#define kSectionCount                   6
#define kMinimumSectionCount            1
#define kSuccessCode                    200
#define kMinimumCellCount               1
#define kHeaderHeight                   60
#define kCellHeightForPieChart          300
#define kDefaultCellHeight              50
#define kEmptyHeaderAndFooter           0

#define kTagForCellObject               1
#define kTagForNoDataObject             2

#import "EmotionalIntelligenceViewController.h"
#import "UIColor+HexColor.h"
#import "VBPieChart.h"
#import "Constants.h"
#import "MenuViewController.h"
#import "EmotionSessionLists.h"
#import "AMPopTip.h"
#import "ButtonWithID.h"
#import "NFXIntroViewController.h"

@interface EmotionalIntelligenceViewController () <SWRevealViewControllerDelegate,SessionPopUpDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    
    VBPieChart *pieChart;
    NSMutableArray *_chartValues;
    NSInteger selectedSection;
    
    NSMutableArray *arrAssertive;
    NSMutableArray *arrDetailed;
    NSMutableArray *arrPatient;
    NSMutableArray *arrWarm;
    NSMutableArray *arrDataSource;
    NSMutableArray *arrSupportingEmotions;
    NSDictionary *dictInfo;
    
    NSString* assertValue;
    NSString* warmValue;
    NSString* patientValue;
    NSString* detailedValue;
    NSInteger selectedSession;
    NSString *strNoDataText;
  
    NSString *strStartDate;
    NSString *strEndDate;
    NSInteger sessionValue;
    
    BOOL isDataAvailable;
    BOOL firstTime;
    EmotionSessionLists *sessionListPopUp;
    AMPopTip *popTip;

}

@end

@implementation EmotionalIntelligenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUp];

    [self loadPieChartDetails];
 
   
// Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{
    
    tableView.hidden = true;
    sessionValue = 0;
    selectedSection = -1;
    arrAssertive = [NSMutableArray new];
    arrDetailed = [NSMutableArray new];
    arrPatient = [NSMutableArray new];
    arrWarm = [NSMutableArray new];
    arrSupportingEmotions = [NSMutableArray new];
   
    
}


-(void)checkUserViewStatus{
    
    firstTime = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Intelligence_Show_Count"])
    {
        
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Intelligence_Show_Count"] integerValue];
        if (count == 2) {
            firstTime = false;
        }
    }
    
     [self updateVisibilityStatus];
    
}



-(void)updateVisibilityStatus{
    
    firstTime = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Intelligence_Show_Count"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"Intelligence_Show_Count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Intelligence_Show_Count"] integerValue];
        if (count == 2) {
            firstTime = false;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"Intelligence_Show_Count"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    if (firstTime) [self showHelpScreen];
    
    
}


-(void)loadPieChartDetails{
    
    NSString *dateString = [NSString stringWithFormat:@"%@ 23:59:59",strEndDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *endDateFromString =  [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *strtDateFromString = [dateFormatter dateFromString:strStartDate];
   
    [self showLoadingScreen];
    [APIMapper getPieChartViewWithUserID:[User sharedManager].userId startDate:[strtDateFromString timeIntervalSince1970] endDate:[endDateFromString timeIntervalSince1970] session:sessionValue isFirstTime:firstTime success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        isDataAvailable = true;
        [self showPieChartWith:responseObject];
        [self hideLoadingScreen];
        
                
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        isDataAvailable = false;
        tableView.hidden = false;
        [self hideLoadingScreen];
    }];
}

-(void)showPieChartWith:(NSDictionary*)responds{
    
    isDataAvailable = false;
  
    if ([[responds objectForKey:@"code"] integerValue] == kSuccessCode) {
        
        if ( NULL_TO_NIL([responds objectForKey:@"chartpercentage"])) {
            
            NSDictionary *chartPercentage = [responds objectForKey:@"chartpercentage"];
            
            if (NULL_TO_NIL([chartPercentage objectForKey:@"passive_percent"])){
                float value  = [[chartPercentage objectForKey:@"passive_percent"] floatValue];
                assertValue = [NSString stringWithFormat:@"%.02f", value];
            }
            if (NULL_TO_NIL([chartPercentage objectForKey:@"destructive_percent"])){
                float value  = [[chartPercentage objectForKey:@"destructive_percent"] floatValue];
                warmValue = [NSString stringWithFormat:@"%.02f", value];
            }
            if (NULL_TO_NIL([chartPercentage objectForKey:@"stressfull_percent"])){
                float value  = [[chartPercentage objectForKey:@"stressfull_percent"] floatValue];
                patientValue = [NSString stringWithFormat:@"%.02f", value];
            }
            if (NULL_TO_NIL([chartPercentage objectForKey:@"optimal_percent"])){
                float value  = [[chartPercentage objectForKey:@"optimal_percent"] floatValue];
                detailedValue = [NSString stringWithFormat:@"%.02f", value];
            }
            [pieChart setHoleRadiusPrecent:0.3]; /* hole inside of chart */
            _chartValues = [NSMutableArray new];
            
            if ([assertValue integerValue] > 0)
                [_chartValues addObject:@{@"name":[NSString stringWithFormat:@"%@%%",assertValue], @"value":assertValue, @"color":[UIColor colorWithRed:0.00 green:0.51 blue:0.78 alpha:1.0]}];
            if ([warmValue integerValue] > 0)
                [_chartValues addObject:@{@"name":[NSString stringWithFormat:@"%@%%",warmValue], @"value":warmValue, @"color":[UIColor colorWithRed:0.93 green:0.02 blue:0.02 alpha:1.0]}];
            if ([patientValue integerValue] > 0)
                [_chartValues addObject:@{@"name":[NSString stringWithFormat:@"%@%%",patientValue], @"value":patientValue, @"color":[UIColor colorWithRed:0.91 green:0.78 blue:0.14 alpha:1.0]}];
            if ([detailedValue integerValue] > 0)
                [_chartValues addObject:@{@"name":[NSString stringWithFormat:@"%@%%",detailedValue], @"value":detailedValue, @"color":[UIColor colorWithRed:0.00 green:0.60 blue:0.29 alpha:1.0]}];
            
            [pieChart setLabelsPosition:VBLabelsPositionOnChart];
            [pieChart setChartValues:[NSArray arrayWithArray:_chartValues] animation:YES duration:0.4 options:VBPieChartAnimationFanAll];
            
        }
        
        [arrDetailed removeAllObjects];
        [arrPatient removeAllObjects];
        [arrWarm removeAllObjects];
        [arrAssertive removeAllObjects];
        
        if ( NULL_TO_NIL([responds objectForKey:@"resultarray"])) {
            
            NSArray *result = [responds objectForKey:@"resultarray"];
            for (NSDictionary *details in result) {
                
                if ([[details objectForKey:@"type"] isEqualToString:@"optimal"])
                    [arrDetailed addObject:details];
                if ([[details objectForKey:@"type"] isEqualToString:@"stressfull"])
                    [arrPatient addObject:details];
                if ([[details objectForKey:@"type"] isEqualToString:@"destructive"])
                    [arrWarm addObject:details];
                if ([[details objectForKey:@"type"] isEqualToString:@"passive"])
                    [arrAssertive addObject:details];
            }
            
        }
        if ( NULL_TO_NIL([responds objectForKey:@"support_emotion"]))
            arrSupportingEmotions = [NSMutableArray arrayWithArray:[responds objectForKey:@"support_emotion"]] ;
       
        if ( NULL_TO_NIL([responds objectForKey:@"info"]))
            dictInfo = [responds objectForKey:@"info"];
        
        isDataAvailable = true;
    }else{
        if (NULL_TO_NIL([responds objectForKey:@"text"])) {
            strNoDataText = [responds objectForKey:@"text"];
        }
        
    }
    
    tableView.hidden = false;
    [tableView reloadData];
    [self performSelector:@selector(checkUserViewStatus) withObject:self afterDelay:.5];
    
}

-(IBAction)showSessionPopUp{
    
    if (popTip) {
        [popTip hide];
    }
    if (!sessionListPopUp) {
        sessionListPopUp = [[[NSBundle mainBundle] loadNibNamed:@"EmotionSessionLists" owner:self options:nil] objectAtIndex:0];
        sessionListPopUp.delegate = self;
    }
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = sessionListPopUp;
    vwPopUP.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.7];
    [app.window.rootViewController.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    sessionListPopUp.vwContainer .hidden  = true;
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [sessionListPopUp setUpInitialValuesWithActiveValue:sessionValue startDate:strStartDate endDate:strEndDate];
    }];
    
}

-(void)closeSessionPopUp{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        sessionListPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [sessionListPopUp removeFromSuperview];
        sessionListPopUp = nil;
    }];

    
}

-(void)filterAppliedWithStartDate:(NSString*)startDate endDate:(NSString*)endDate sessionValue:(NSInteger)sessionType{
    
    strStartDate = startDate;
    strEndDate = endDate;
    sessionValue = sessionType;
    [self closeSessionPopUp];
    [self loadPieChartDetails];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!isDataAvailable)
        return kMinimumSectionCount;
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellCount = 0;
    if (!isDataAvailable)
        cellCount = kMinimumCellCount;
    else if (section == ePieChart)
        cellCount = kMinimumCellCount;
    else if (section == selectedSection)
        return arrDataSource.count;
    else cellCount = 0;
    return cellCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == ePieChart)
        cell = [self configurePieChartCellForIndexPath:indexPath];
    else
        cell = [self configureEmotionCellForIndexPath:indexPath];
   
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return  kCellHeightForPieChart;
    }
    return  kDefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable || section == ePieChart)
        return kEmptyHeaderAndFooter;
    
    return kHeaderHeight;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == eDetailed) {
        if (indexPath.row < arrDetailed.count) {
            NSDictionary *details = arrDetailed[[indexPath row]];
            if ([[details objectForKey:@"supportingemotion_status"] boolValue]) {
                return;
            }
            UIAlertController * alert=  [UIAlertController
                                         alertControllerWithTitle:@"Supporting Emotions"
                                         message:@"Add to Supporting emotions ?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self showLoadingScreen];
                                    
                                     [APIMapper addEmotionToSupportingEmotionsWithEmotionID:[details objectForKey:@"emotion_id"] userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode)
                                              [arrSupportingEmotions addObject:details];
                                         
                                         if ( NULL_TO_NIL( [responseObject objectForKey:@"text"]))
                                             [[[UIAlertView alloc] initWithTitle:@"Supporting Emotions" message:[responseObject objectForKey:@"text"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                         [self hideLoadingScreen];
                                         [self updateEmotionStatusithIndex:indexPath.row shouldEnable:YES];
                                         [tableView reloadData];
                                         
                                     } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
                                         [self hideLoadingScreen];
                                     }];
                                     
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (popTip) {
        [popTip hide];
    }
}


- (void)updateEmotionStatusithIndex:(NSInteger)index shouldEnable:(BOOL)shouldEnable{
    
    if (shouldEnable) {
        
        if ( index < arrDataSource.count ) {
            NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrDataSource[index]] ;
            [details setObject:[NSNumber numberWithBool:1] forKey:@"supportingemotion_status"];
            [arrDataSource replaceObjectAtIndex:index withObject:details];
            [arrDetailed replaceObjectAtIndex:index withObject:details];
            
        }
    }
    else{
        
        if ( index < arrDataSource.count ) {
            NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrDataSource[index]] ;
            NSInteger indexOfObj = 0;
            for (NSDictionary *dict in arrDetailed) {
                if ([dict objectForKey:@"emotion_id"] == [details objectForKey:@"emotion_id"]) {
                    break;
                    
                }
                indexOfObj ++;
            }
            if (indexOfObj < arrDetailed.count) {
                NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrDetailed[indexOfObj]] ;
                [details setObject:[NSNumber numberWithBool:0] forKey:@"supportingemotion_status"];
                [arrDetailed replaceObjectAtIndex:indexOfObj withObject:details];
            }
            
           // [arrs replaceObjectAtIndex:index withObject:details];
            
        }
       
    }
    
}

-(IBAction)deleteEmotion:(ButtonWithID*)sender{
    
        if (sender.index < arrSupportingEmotions.count){
            NSDictionary *details = arrSupportingEmotions [sender.index];
            //                GEMSEventListingViewController *gemListingsPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMSEventListings];
            //                gemListingsPage.sortType = 0;
            //                if (NULL_TO_NIL([details objectForKey:@"emotion_id"]))
            //                    gemListingsPage.groupID = [details objectForKey:@"emotion_id"];
            //                if (NULL_TO_NIL([details objectForKey:@"emotion_title"]))
            //                    gemListingsPage.eventTitle = [details objectForKey:@"emotion_title"];
            //                [[self navigationController]pushViewController:gemListingsPage animated:YES];
            
            UIAlertController * alert=  [UIAlertController
                                         alertControllerWithTitle:@"Supporting Emotions"
                                         message:@"Delete from Supporting emotions ?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"YES"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self showLoadingScreen];
                                     
                                     [APIMapper deleteEmotionFromSupportingEmotionsWithEmotionID:[details objectForKey:@"emotion_id"] userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode){
                                             
                                             [self updateEmotionStatusithIndex:sender.index shouldEnable:NO];
                                              [arrSupportingEmotions removeObjectAtIndex:sender.index];
                                         }
                                         
                                         arrDataSource = [NSMutableArray arrayWithArray:arrSupportingEmotions];
                                         NSRange range = NSMakeRange(5, 1);
                                         NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
                                         [tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationRight];
                                         
                                         if ( NULL_TO_NIL( [responseObject objectForKey:@"text"]))
                                             [[[UIAlertView alloc] initWithTitle:@"Supporting Emotions" message:[responseObject objectForKey:@"text"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                                         [self hideLoadingScreen];
                                         
                                         [tableView reloadData];
                                         
                                     } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                         if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
                                         [self hideLoadingScreen];
                                     }];
                                     
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"NO"
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

-(UITableViewCell*)configurePieChartCellForIndexPath:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"PieChartCell";
    UILabel *lblNoData;
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell.contentView viewWithTag:kTagForCellObject]) {
        if (!pieChart)
            pieChart = (VBPieChart*)[cell.contentView viewWithTag:kTagForCellObject];
         pieChart.hidden = true;
    }
    if ([cell.contentView viewWithTag:kTagForNoDataObject]) {
        lblNoData = (UILabel*)[cell.contentView viewWithTag:kTagForNoDataObject];
        lblNoData.hidden = false;
        lblNoData.text = strNoDataText;
    }
    pieChart.hidden = false;
    lblNoData.hidden = true;
    if (!isDataAvailable) {
        pieChart.hidden = true;
        lblNoData.hidden = false;
    }
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
    
}

-(UITableViewCell*)configureEmotionCellForIndexPath:(NSIndexPath*)indexPath{
    
    static NSString *CellIdentifier = @"EmotionCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([cell.contentView viewWithTag:kTagForCellObject]) {
        UILabel *lblTitle = (UILabel*)[cell.contentView viewWithTag:kTagForCellObject];
        if (indexPath.row < arrDataSource.count) {
            NSDictionary *details = arrDataSource[indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryNone;
            lblTitle.text = [NSString stringWithFormat:@"%@ (%ld)",[details objectForKey:@"emotion_title"],[[details objectForKey:@"count"] integerValue]];
            UIImageView* imgArrow;
            if ([[cell contentView] viewWithTag:2]) {
                imgArrow = [[cell contentView] viewWithTag:2];
                imgArrow.hidden = true;
                [imgArrow setImage:[UIImage imageNamed:@"Right_Arrow.png"]];
                if (selectedSection == eDetailed && ![[details objectForKey:@"supportingemotion_status"] boolValue]){
                    imgArrow.hidden = false;
                }
                
            }
            
            if ([[cell contentView] viewWithTag:5]) {
               ButtonWithID *btnDelete = (ButtonWithID*)[[cell contentView] viewWithTag:5];
                btnDelete.index = indexPath.row;
                btnDelete.hidden = true;
                if (selectedSection == eSupportingEmotions){
                    btnDelete.hidden = false;
                    [btnDelete addTarget:self action:@selector(deleteEmotion:) forControlEvents:UIControlEventTouchUpInside];
                    
                }
            }
            
            if (selectedSection == eSupportingEmotions) {
                [imgArrow setImage:[UIImage imageNamed:@"Delete_Icon.png"]];
            }
            
            if (selectedSection == eSupportingEmotions)
               lblTitle.text = [details objectForKey:@"emotion_title"];
            
        }
    }
    cell.contentView.backgroundColor = [UIColor getBackgroundOffWhiteColor];
    return cell;
    
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable)
        return nil;
    
    if (section == ePieChart) {
        return nil;
        
    }else{
        
        
        UILabel *title;
        NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"EmotionalIntelligenceHeader" owner:self options:nil];
        UIView *view = [viewArray objectAtIndex:0];
        view.tag = 100 + section;
        UIImageView *imgIcon;
        UIImageView *imgArrow;
        UIButton *btnClick;
        UIButton *btnInfo;
        UIView *bgView;
        if ([view viewWithTag:1]) {
            imgIcon = [view viewWithTag:1];
            imgIcon.backgroundColor = [UIColor clearColor];
        }
        if ([view viewWithTag:5]) {
            bgView = [view viewWithTag:5];
        }
        if ([view viewWithTag:2]) {
            title = [view viewWithTag:2];
            title.text = @"Title";
        }
        if ([view viewWithTag:3]) {
            imgArrow = [view viewWithTag:3];
            [imgArrow setImage:[UIImage imageNamed:@"Arrow_Up.png"]];
            imgArrow.hidden = false;
            if (selectedSection == section) {
                 [imgArrow setImage:[UIImage imageNamed:@"Arrow_Bottom.png"]];
            }
        }
        if ([view viewWithTag:4]) {
            btnClick = (UIButton*) [view viewWithTag:4];
            [btnClick addTarget:self action:@selector(expandOrCollapseTable:) forControlEvents:UIControlEventTouchUpInside];
            btnClick.tag = section;
            btnClick.userInteractionEnabled = true;
        }
        
        if ([view viewWithTag:6]) {
            btnInfo = (UIButton*) [view viewWithTag:6];
            [btnInfo addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
            btnInfo.tag = section;
            btnInfo.userInteractionEnabled = true;
            btnInfo.hidden = false;
        }
        switch (section) {
            case eDetailed:
                title.text = [NSString stringWithFormat:@"Optimal (%lu) %@%%",(unsigned long)arrDetailed.count,detailedValue];
                [imgIcon setImage:[UIImage imageNamed:@"Optimal_Icon.png"]];
                if (arrDetailed.count <= 0) {
                    btnClick.userInteractionEnabled = false;imgArrow.hidden = true;}
                break;
                
            case ePatient:
                title.text = [NSString stringWithFormat:@"Productive (%lu) %@%%",(unsigned long)arrPatient.count,patientValue];
                [imgIcon setImage:[UIImage imageNamed:@"Productive_Icon.png"]];
                if (arrPatient.count <= 0) {
                    btnClick.userInteractionEnabled = false;imgArrow.hidden = true;}
                break;
                
            case eAssertive:
                title.text = [NSString stringWithFormat:@"Pleasure (%lu) %@%%",(unsigned long)arrAssertive.count,assertValue];
                [imgIcon setImage:[UIImage imageNamed:@"Pleasure_Icon.png"]];
                if (arrAssertive.count <= 0)  {
                    btnClick.userInteractionEnabled = false;imgArrow.hidden = true;}
                break;
                
            case eWarm:
                title.text = [NSString stringWithFormat:@"Destructive (%lu) %@%%",(unsigned long)arrWarm.count,warmValue];
                [imgIcon setImage:[UIImage imageNamed:@"Destructive_Icon.png"]];
                if (arrWarm.count <= 0)  {
                    btnClick.userInteractionEnabled = false;imgArrow.hidden = true;}
                break;
               
            case eSupportingEmotions:
                title.text = @"Supporting Emotions";
                title.textAlignment = NSTextAlignmentCenter;
                [imgIcon setImage:nil];
                btnClick.userInteractionEnabled = false;
                if (arrSupportingEmotions.count > 0) btnClick.userInteractionEnabled = true;
                imgArrow.hidden = true;
                btnInfo.hidden = true;
                title.textColor = [UIColor whiteColor];
                bgView.backgroundColor = [UIColor getThemeColor];
                break;
                
            default:
                break;
        }
        return view;
    }
    
    return nil;
    
}

-(IBAction)expandOrCollapseTable:(UIButton*)sender{
    
    if (popTip) {
        [popTip hide];
    }
    if (sender.tag == selectedSection)
        selectedSection = -1;
    else{
        selectedSection = sender.tag;
        switch (selectedSection) {
            case eWarm:
                arrDataSource = [NSMutableArray arrayWithArray:arrWarm];
                break;
                
            case eDetailed:
                arrDataSource = [NSMutableArray arrayWithArray:arrDetailed];
                break;
                
            case eAssertive:
                arrDataSource = [NSMutableArray arrayWithArray:arrAssertive];
                break;
                
            case ePatient:
                arrDataSource = [NSMutableArray arrayWithArray:arrPatient];
                break;
                
            case eSupportingEmotions:
                arrDataSource = [NSMutableArray arrayWithArray:arrSupportingEmotions];
                break;
                
            default:
                break;
        }
    }
    
    
    NSRange range = NSMakeRange(1, 5);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationRight];
    if (selectedSection >= 0)
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:selectedSection]
                         atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
}


-(IBAction)showInfo:(UIButton*)sender{
    if (popTip) {
        [popTip hide];
    }
    NSString  *title;
    NSInteger index = sender.tag;
    switch (index) {
        case eDetailed:
            if  (NULL_TO_NIL([dictInfo objectForKey:@"optimal_text"]))
                title = [dictInfo objectForKey:@"optimal_text"];
            break;
        case ePatient:
            if  (NULL_TO_NIL([dictInfo objectForKey:@"stressful_text"]))
                title = [dictInfo objectForKey:@"stressful_text"];
            break;
        case eAssertive:
            if  (NULL_TO_NIL([dictInfo objectForKey:@"passive_text"]))
                title = [dictInfo objectForKey:@"passive_text"];
            break;
        case eWarm:
            if  (NULL_TO_NIL([dictInfo objectForKey:@"destructive_text"]))
                title = [dictInfo objectForKey:@"destructive_text"];
            break;
            
        default:
            break;
    }
    
    UIView *vwTest = [tableView viewWithTag:100 + sender.tag];
    UILabel *lblTitle;
    for (UIView *vw in vwTest.subviews) {
        
        if ((vw.tag == 2) && [vw isKindOfClass:[UILabel class]]) {
            lblTitle = (UILabel*)vw;
            break;
        }
    }
    CGPoint point = CGPointMake(lblTitle.center.x + (lblTitle.frame.size.width / 2), vwTest.center.y - 20);
    CGPoint p = [vwTest.superview convertPoint:point toView:self.view];
    popTip = [AMPopTip popTip];
    [popTip showText:title direction:AMPopTipDirectionUp maxWidth:(self.view.frame.size.width - p.x) inView:self.view fromFrame:CGRectMake(p.x + 5, p.y, 50, 50) duration:2];
    
}

#pragma mark - Generic Methods

-(void)showHelpScreen{
    
    UIImage*i1 = [UIImage imageNamed:@"Intelligence_Intro_1.png"];
    UIImage*i2 = [UIImage imageNamed:@"Intelligence_Intro_2.png"];
    UIImage*i3 = [UIImage imageNamed:@"Intelligence_Intro_3.png"];
    
    NFXIntroViewController*vc = [[NFXIntroViewController alloc] initWithViews:@[i1,i2,i3]];
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!app.navGeneral) {
        app.navGeneral = [[UINavigationController alloc] initWithRootViewController:vc];
        app.navGeneral.navigationBarHidden = true;
        [UIView transitionWithView:app.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{  app.window.rootViewController = app.navGeneral; }
                        completion:nil];
    }
    else{
        [app.navGeneral pushViewController:vc animated:YES];
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

-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
}

-(IBAction)showJournalPage:(UIButton*)sender{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app showJournalListView];
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
