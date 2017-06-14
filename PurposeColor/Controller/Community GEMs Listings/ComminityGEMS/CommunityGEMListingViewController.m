//
//  GEMListingViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 09/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eFollow = 0,
    eFollowPending = 1,
    eFollowed = 2,
    
} eFollowStatus;

static NSString *CollectionViewCellIdentifier = @"GemsListCell";
#define OneK                    1000
#define kPadding                10
#define kDefaultNumberOfCells   1
#define kSuccessCode            200
#define kUnAuthorized           403

#import "CommunityGEMListingViewController.h"
#import "GemsListCollectionViewCell.h"
#import "CommentComposeViewController.h"
#import "GEMDetailViewController.h"
#import "MyGEMListingViewController.h"
#import "GEMSListingHeaderView.h"
#import "Constants.h"
#import "ChatUserListingViewController.h"
#import "ProfilePageViewController.h"
#import "LikedAndCommentedUserListings.h"
#import "shareMedias.h"
#import "CreateActionInfoViewController.H"
#import "MenuViewController.h"
#import "FTPopOverMenu.h"
#import "ReportAbuseViewController.h"
#import "MTDURLPreview.h"

@interface CommunityGEMListingViewController ()<GemListingsDelegate,CommentActionDelegate,MediaListingPageDelegate,shareMediasDelegate,SWRevealViewControllerDelegate,UIGestureRecognizerDelegate>{
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UIView *vwPaginationPopUp;
    IBOutlet NSLayoutConstraint *paginationBottomConstraint;
             UIRefreshControl *refreshControl;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    IBOutlet UIButton *btnMyGem;
    
    NSMutableArray *arrGems;
    NSMutableDictionary *heightsCache;
    NSInteger totalPages;
    NSInteger currentPage;
    NSMutableDictionary *dictFollowers;
    eFollowStatus followStatus;
    NSString *strNoDataText;
    
    BOOL isPageRefresing;
    BOOL isDataAvailable;
    BOOL shouldShowPurposeColorGem;
    NSInteger totalGems;
    
    CommentComposeViewController *composeComment;
    shareMedias *shareMediaView; 
}

@end

@implementation CommunityGEMListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self checkUserViewStatus];
    [self getAllProductsByPagination:NO withPageNumber:currentPage];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



-(void)setUp{
  
    UINib *cellNib = [UINib nibWithNibName:@"GemsListCollectionViewCell" bundle:nil];
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    collectionView.hidden = false;
    dictFollowers = [NSMutableDictionary new];
    
    arrGems = [NSMutableArray new];
    heightsCache =  [NSMutableDictionary new];
    currentPage = 1;
    totalPages = 0;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
    collectionView.hidden = true;
    isDataAvailable = false;
    
    btnMyGem.layer.cornerRadius = 5.f;
    btnMyGem.layer.borderWidth = 1.f;
    btnMyGem.layer.borderColor = [UIColor getThemeColor].CGColor;
   
   
}

-(void)checkUserViewStatus{
    
    shouldShowPurposeColorGem = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Community_Show_Count"])
    {
        
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Community_Show_Count"] integerValue];
        if (count == 2) {
            shouldShowPurposeColorGem = false;
        }
    }

}

-(void)updateVisibilityStatus{
    
    shouldShowPurposeColorGem = true;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Community_Show_Count"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"Community_Show_Count"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Community_Show_Count"] integerValue];
        if (count == 2) {
            
            shouldShowPurposeColorGem = false;
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:2] forKey:@"Community_Show_Count"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }

}

-(void)getAllProductsByPagination:(BOOL)isPagination withPageNumber:(NSInteger)pageNumber{
    
    if (!isPagination) {
        [self showLoadingScreen];
    }
    
    [APIMapper getAllCommunityGemsByUserID:[User sharedManager].userId pageNo:pageNumber purposeGemShow:shouldShowPurposeColorGem success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        collectionView.hidden = false;
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        [self getGemsFromResponds:responseObject];
        [collectionView reloadData];
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        [self updateVisibilityStatus];

    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        collectionView.hidden = false;
        isDataAvailable = false;
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        [collectionView reloadData];
    }];
    
}

-(void)refreshData{
    
    if (isPageRefresing){
        [refreshControl endRefreshing];
        return;
    }
    [heightsCache removeAllObjects];
    [arrGems removeAllObjects];
    [dictFollowers removeAllObjects];
    [self showLoadingScreen];
    currentPage = 1;
    isPageRefresing = YES;
    [self getAllProductsByPagination:YES withPageNumber:currentPage];
        
    
}

-(void)getGemsFromResponds:(NSDictionary*)responseObject{
    
    if ([[[responseObject objectForKey:@"header"] objectForKey:@"code"] integerValue] == kUnAuthorized) {
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

    
    isDataAvailable = false;
    if ( NULL_TO_NIL([responseObject objectForKey:@"resultarray"])) {
        NSArray *results = [responseObject objectForKey:@"resultarray"];
        for (NSDictionary *dict in results)
            [arrGems addObject:dict];
    }else{
        strNoDataText = [responseObject objectForKey:@"text"];
    }
    if (arrGems.count) isDataAvailable = true;
    if (NULL_TO_NIL([responseObject objectForKey:@"pageCount"]))
        totalPages =  [[responseObject objectForKey:@"pageCount"]integerValue];
    
    if (NULL_TO_NIL([responseObject objectForKey:@"currentPage"]))
        currentPage =  [[responseObject objectForKey:@"currentPage"]integerValue];
    
    if (NULL_TO_NIL([responseObject objectForKey:@"totalCount"]))
        totalGems =  [[responseObject objectForKey:@"totalCount"]integerValue];
    
    
    if (!isDataAvailable){
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    }else{
        
        UINib *cellNib = [UINib nibWithNibName:@"GemsListCollectionViewCell" bundle:nil];
        [collectionView registerNib:cellNib forCellWithReuseIdentifier:CollectionViewCellIdentifier];
        
    }
    
}


#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)_collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kDefaultNumberOfCells;
    return arrGems.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isDataAvailable) {
        
        UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
        if ([cell.contentView viewWithTag:1]) {
            UILabel *lblNoData =  [cell.contentView viewWithTag:1];
            lblNoData.text = strNoDataText;
        }
        return cell;
        
    }
    GemsListCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetailPage:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    cell.contentView.tag = indexPath.row;
    [cell.contentView addGestureRecognizer:singleTap];
    
    cell.delegate = self;
    [self resetCellVariables:cell];
    [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
    
    if (indexPath.row < arrGems.count) {
        
        NSDictionary *details = arrGems[indexPath.row];
        [self configureFollowButtonWithDetails:details cell:cell];
        [self configureTextVariables:details cell:cell indexPath:indexPath];
        [self setupPreviewVariables:cell tag:indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"gem_details"])){
            
            NSString *string = [details objectForKey:@"gem_details"];
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
            NSArray *matches = [detector matchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
            if (matches.count > 0) {
                cell.vwURLPreview.hidden = false;
                NSTextCheckingResult *match = [matches firstObject];
                [cell.previewIndicator startAnimating];
                [MTDURLPreview loadPreviewWithURL:[match URL] completion:^(MTDURLPreview *preview, NSError *error) {
                    [cell.previewIndicator stopAnimating];
                    cell.lblPreviewTitle.text = preview.title;
                    cell.lblPreviewDescription.text = preview.content;
                    cell.lblPreviewTitle.text = preview.title;
                    cell.lblPreviewDomain.text = preview.domain;
                    [cell.imgPreview sd_setImageWithURL:preview.imageURL
                                       placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                              }];
                    
                }];
            }
            
        }
    }
    cell.imgProfile.tag = indexPath.row;
    cell.imgProfile.userInteractionEnabled = true;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfilePage:)];
    [cell.imgProfile addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float padding = 10;
    float defaultHeight = 165;
    float width = _collectionView.bounds.size.width;
    float finalHeight = 0;
    float imageHeight = 0;
    if (indexPath.row < arrGems.count) {
        NSDictionary *details = arrGems[indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"gem_title"])){
            defaultHeight = 185;
        }
        if (NULL_TO_NIL([details objectForKey:@"gem_details"])){
            float lblHeight = [Utility getSizeOfLabelWithText:[details objectForKey:@"gem_details"] width:self.view.frame.size.width - padding font:[UIFont fontWithName:CommonFont size:14]];
            if (lblHeight > 30) {
                lblHeight = 30;
            }
            finalHeight = defaultHeight + lblHeight;
            if ([heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
                imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]] floatValue];
            }else{
                if ([details objectForKey:@"display_image"]) {
                    float width = [[details objectForKey:@"image_width"] floatValue];
                    float height = [[details objectForKey:@"image_height"] floatValue];
                    if ((width && height) > 0) {
                        float ratio = width / height;
                        imageHeight = (collectionView.frame.size.width - padding) / ratio;
                    }
                }
                [heightsCache setObject:[NSNumber numberWithInteger:imageHeight] forKey:[NSNumber numberWithInteger:indexPath.row]];
                
            }
            BOOL checkIsURLAvailable = [Utility isStringContainsURLInString:[details objectForKey:@"gem_details"]];
            float previewHeight = (checkIsURLAvailable) ? 90 : 0;
            finalHeight += previewHeight;
            finalHeight += imageHeight;
            return CGSizeMake(width, finalHeight);
           
        }
        
       
        
    }
    
    return CGSizeMake(width, 400);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage ;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self showPaginationPopUp];
                [self getAllProductsByPagination:YES withPageNumber:nextPage];
            }
            
        }
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)_collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    return reusableview;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GEMSListingHeaderView *headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GEMSListingHeaderView" forIndexPath:indexPath];
        headerView.lblCategoryTitle.text = [NSString stringWithFormat:@"Total %lu GEMS",(unsigned long)totalGems];
        reusableview = headerView;
    }
    return reusableview;
}
- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeZero;
   // if (!isDataAvailable) return CGSizeZero;
  //  return CGSizeMake(_collectionView.bounds.size.width, 45);
    
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    /*
    NSInteger index = indexPath.row;
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        GEMDetailViewController *gemDetailVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMDetailPage];
        gemDetailVC.gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemDetails];
        gemDetailVC.delegate = self;
        gemDetailVC.clickedIndex = index;
        gemDetailVC.canSave = YES;
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.navGeneral = [[UINavigationController alloc] initWithRootViewController:gemDetailVC];
        app.navGeneral.navigationBarHidden = true;
        [UIView transitionWithView:app.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{  app.window.rootViewController = app.navGeneral; }
                        completion:nil];
        
        
    }*/

   
}

-(void)showDetailPage:(UITapGestureRecognizer*)gesture{
    
    if (gesture.view.tag < arrGems.count) {
        NSInteger index = gesture.view.tag;
        if (index < arrGems.count) {
            
            NSDictionary *gemDetails = arrGems[index];
            GEMDetailViewController *gemDetailVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMDetailPage];
            gemDetailVC.gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemDetails];
            gemDetailVC.delegate = self;
            gemDetailVC.clickedIndex = index;
            gemDetailVC.canSave = YES;
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            app.navGeneral = [[UINavigationController alloc] initWithRootViewController:gemDetailVC];
            app.navGeneral.navigationBarHidden = true;
            [UIView transitionWithView:app.window
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{  app.window.rootViewController = app.navGeneral; }
                            completion:nil];
            
            
        }

    }
    
}

-(void)showDetailPageWithIndex:(NSInteger)index{
    
    // When clicked from desscrption
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        GEMDetailViewController *gemDetailVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMDetailPage];
        gemDetailVC.gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemDetails];
        gemDetailVC.delegate = self;
        gemDetailVC.clickedIndex = index;
        gemDetailVC.canSave = YES;
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.navGeneral = [[UINavigationController alloc] initWithRootViewController:gemDetailVC];
        app.navGeneral.navigationBarHidden = true;
        [UIView transitionWithView:app.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{  app.window.rootViewController = app.navGeneral; }
                        completion:nil];
        
        
    }

    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    if ([[touch view] isKindOfClass:[KILabel class]]) {
        return NO;
    }
    
    return YES;
}



#pragma mark - Customise Cells Method

-(void)previewClickedWithGesture:(UIButton*)btn{
    
    if (btn.tag < arrGems.count) {
        
        NSDictionary *details = arrGems[btn.tag];
        if (NULL_TO_NIL([details objectForKey:@"gem_details"])){
            
            NSString *string = [details objectForKey:@"gem_details"];
            NSError *error = nil;
            NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                       error:&error];
            NSArray *matches = [detector matchesInString:string
                                                 options:0
                                                   range:NSMakeRange(0, [string length])];
            if (matches.count > 0) {
                NSTextCheckingResult *match = [matches firstObject];
                [[UIApplication sharedApplication] openURL:[match URL]];
                
            }
        }
        
    }
}

-(void)setupPreviewVariables:(GemsListCollectionViewCell*)cell tag:(NSInteger)tag{
    
    cell.lblPreviewDescription.text = @"";
    cell.lblPreviewTitle.text = @"";
    cell.lblPreviewDomain.text = @"";
    cell.vwURLPreview.hidden = true;
    cell.btnShowPreviewURL.tag = tag;
    [cell.btnShowPreviewURL addTarget:self action:@selector(previewClickedWithGesture:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)resetCellVariables:(GemsListCollectionViewCell*)cell{
    
    cell.vwBg.layer.borderColor = [UIColor colorWithRed:193/255.f green:196/255.f blue:199/255.f alpha:0.5].CGColor;
    cell.vwBg.layer.borderWidth = 1.0;
    
    cell.imgProfile.layer.cornerRadius = 25.f;
    cell.imgProfile.clipsToBounds = YES;
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    [cell.activityIndicator stopAnimating];
    
    
    cell.btnDelete.hidden = true;
    cell.btnFollow.hidden = true;
   // cell.btnHide.hidden = true;

}

-(void)configureFollowButtonWithDetails:(NSDictionary*)details cell:(GemsListCollectionViewCell*)cell{
    
    BOOL canFollow = true;
    if (NULL_TO_NIL([details objectForKey:@"can_follow"]))
        canFollow = [[details objectForKey:@"can_follow"] boolValue];
    if ([[User sharedManager].userId isEqualToString:[details objectForKey:@"user_id"]]) {
        canFollow = false;
    }
    cell.btnFollow.hidden = (canFollow) ? false : true;
   // cell.btnHide.hidden = [[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId] ? false : true;
    
    cell.btnFollow.layer.borderWidth = 1.f;
    cell.btnFollow.layer.borderColor = [UIColor getThemeColor].CGColor;
    cell.btnFollow.layer.cornerRadius = 5.f;
    
    if (NULL_TO_NIL([details objectForKey:@"follow_status"]))
        followStatus =  [[details objectForKey:@"follow_status"] intValue];
    
    if (NULL_TO_NIL([details objectForKey:@"user_id"])) {
        NSString *followerID = [details objectForKey:@"user_id"];
        if (NULL_TO_NIL([dictFollowers objectForKey:followerID])){
            int follow = (int)[[dictFollowers objectForKey:followerID] integerValue];
            followStatus = follow;
        }
    }
    
    switch (followStatus) {
        case eFollowed:
            [cell.btnFollow setEnabled:true];
            [cell.btnFollow setTitle:@"UnFollow" forState:UIControlStateNormal];
            [cell.btnFollow setBackgroundColor:[UIColor clearColor]];
            [cell.btnFollow setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
            break;
            
        case eFollowPending:
            [cell.btnFollow setEnabled:false];
            [cell.btnFollow setTitle:@"Follow" forState:UIControlStateDisabled];
            [cell.btnFollow setBackgroundColor:[UIColor lightGrayColor]];
            [cell.btnFollow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cell.btnFollow.layer.borderColor = [UIColor clearColor].CGColor;
            break;
            
        case eFollow:
            [cell.btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
            [cell.btnFollow setBackgroundColor:[UIColor clearColor]];
            [cell.btnFollow setEnabled:true];
            [cell.btnFollow setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

-(void)configureTextVariables:(NSDictionary*)details cell:(GemsListCollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    cell.vwURLPreview.hidden = true;
    cell.lblName.text = [details objectForKey:@"firstname"];
    cell.lblTime.text = [Utility getDaysBetweenTwoDatesWith:[[details objectForKey:@"gem_datetime"] doubleValue]];
    cell.lblTitle.text = @"";
    cell.lblDescription.text = @"";
    cell.constraintDescTopOne.priority = 998;
    cell.constraintDescTopTwo.priority = 999;
    if (NULL_TO_NIL([details objectForKey:@"gem_title"])){
        cell.constraintDescTopOne.priority = 999;
        cell.constraintDescTopTwo.priority = 998;
        cell.lblTitle.text = [details objectForKey:@"gem_title"];
    }

    
    if ([[details objectForKey:@"gem_type"] isEqualToString:@"action"]) {
        [cell.btnBanner setTitle:@"ACTION" forState:UIControlStateNormal];;
    }
    else if ([[details objectForKey:@"gem_type"] isEqualToString:@"goal"]) {
        [cell.btnBanner setTitle:@"GOAL" forState:UIControlStateNormal];;
    }
    else if ([[details objectForKey:@"gem_type"] isEqualToString:@"event"]) {
        [cell.btnBanner setTitle:@"MOMENT" forState:UIControlStateNormal];;
    }
    else if ([[details objectForKey:@"gem_type"] isEqualToString:@"community"]) {
        [cell.btnBanner setTitle:@"COMMUNITY" forState:UIControlStateNormal];;
    }
    if (NULL_TO_NIL([details objectForKey:@"gem_details"]))
        cell.lblDescription.text = [details objectForKey:@"gem_details"];
    
    [cell.btnLike setImage:[UIImage imageNamed:@"Like_Buton"] forState:UIControlStateNormal];
    if ([[details objectForKey:@"like_status"] boolValue])
        [cell.btnLike setImage:[UIImage imageNamed:@"Like_Active"] forState:UIControlStateNormal];
    
    NSInteger count = [[details objectForKey:@"likecount"] integerValue];
    if (count >= OneK) cell.lblLikeCnt.text = [NSString stringWithFormat:@"%@",[self getCountInTermsOfThousand:count]];
    else cell.lblLikeCnt.text = [NSString stringWithFormat:@"%d",[[details objectForKey:@"likecount"] integerValue]];
    
    count =  [[details objectForKey:@"comment_count"] integerValue];
    if (count >= OneK) cell.lblCmntCount.text = [NSString stringWithFormat:@"%@",[self getCountInTermsOfThousand:count]];
    else cell.lblCmntCount.text = [NSString stringWithFormat:@"%d",[[details objectForKey:@"comment_count"] integerValue]];
    
    cell.btnMore.hidden = false;
    if ([[details objectForKey:@"type"] isEqualToString:@"purposecolor"]) cell.btnMore.hidden = true;
    
    cell.bnExpandGallery.hidden = TRUE;
    cell.lblMediaCount.hidden = TRUE;
    if (NULL_TO_NIL([details objectForKey:@"gem_media"])){
        NSArray *gallery =  [details objectForKey:@"gem_media"];
        if (gallery.count > 1) {
            cell.bnExpandGallery.hidden = FALSE;
            cell.lblMediaCount.hidden = FALSE;
            cell.lblMediaCount.text = [NSString stringWithFormat:@"+%02lu",(unsigned long)(gallery.count) - 1];
            
        }
    }
    
    if (NULL_TO_NIL ([details objectForKey:@"profileimg"]) && [[details objectForKey:@"profileimg"] length]){
        [cell.imgProfile sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"profileimg"]]
                           placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                  }];
    }
    cell.imgGemMedia.hidden = false;
    cell.imgTransparentVideo.hidden = true;
    if ([[details objectForKey:@"display_type"] isEqualToString:@"video"])cell.imgTransparentVideo.hidden = false;
    if ([[details objectForKey:@"display_image"] isEqualToString:@"No"]) cell.imgGemMedia.hidden = true;
    cell.imgGemMedia.image = nil;
    float imageHeight = 0;
    if (NULL_TO_NIL([details objectForKey:@"display_image"])){
        NSString *url = [details objectForKey:@"display_image"];
        if ([heightsCache objectForKey:[NSNumber numberWithInteger:indexPath.row]]) {
            imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInteger:indexPath.row]] integerValue];
        }
        if (url.length) {
            [cell.activityIndicator startAnimating];
            [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:url]
                                placeholderImage:[UIImage imageNamed:@""]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           
                                           [cell.activityIndicator stopAnimating];
                                       }];
        }
    }
    cell.constraintForHeight.constant = imageHeight;


}


#pragma mark - Custom Cell Delegate For More Action Method

-(void)moreButtonClickedWithIndex:(NSInteger)index view:(UIView*)sender{
    
  if (index < arrGems.count) {
        NSDictionary *details = arrGems[index];
        BOOL isOthers = [[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId] ? false : true;
        UIAlertController * alert=  [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* hide;
        if (isOthers) {
            hide = [UIAlertAction actionWithTitle:@"Report Abuse" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                
                [alert dismissViewControllerAnimated:YES completion:nil];
                 [self reportAbuseWithIndex:index];
                
            }];
            
        }else{
            hide = [UIAlertAction actionWithTitle:@"Hide" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                
                [alert dismissViewControllerAnimated:YES completion:nil];
                [self hideAGemWithIndex:index];
                
            }];
        }
        
    
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                                 {
                                     
                                 }];
        [alert addAction:hide];
        [alert addAction:cancel];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
      
        
    }
    
    
    
}

#pragma mark - Custom Cell Delegate For Repoer Abuse Gem Method

-(void)reportAbuseWithIndex:(NSInteger)index{
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        NSString *gemID;
        NSString *gemType;
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
            gemID = [gemDetails objectForKey:@"gem_id"];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
            gemType = [gemDetails objectForKey:@"gem_type"];
        
        AppDelegate *deleagte = (AppDelegate*)[UIApplication sharedApplication].delegate;
        ReportAbuseViewController *reportAbuseVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForReportAbuse];
        reportAbuseVC.gemDetails = gemDetails;
        if (!deleagte.navGeneral) {
            
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            app.navGeneral = [[UINavigationController alloc] initWithRootViewController:reportAbuseVC];
            app.navGeneral.navigationBarHidden = true;
            [UIView transitionWithView:app.window
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{  app.window.rootViewController = app.navGeneral; }
                            completion:nil];
            
        }else{
            [deleagte.navGeneral pushViewController:reportAbuseVC animated:YES];
        }
    }

}

#pragma mark - Custom Cell Delegate For Hide A Gem Method

-(void)hideAGemWithIndex:(NSInteger)index{
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        NSString *gemID;
        NSString *gemType;
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
            gemID = [gemDetails objectForKey:@"gem_id"];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
            gemType = [gemDetails objectForKey:@"gem_type"];
        
        [self updateGEMWithVisibilityStatus:index];
        
        if (gemID && gemType) {
            [APIMapper hideAGEMWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
            }];
        }
        
    }

}

-(void)updateGEMWithVisibilityStatus:(NSInteger)index{
    
    if (index < arrGems.count)
        [arrGems removeObjectAtIndex:index];
    totalGems -= 1;
    [heightsCache removeAllObjects];
    [collectionView reloadData];
}

#pragma mark - Custom Cell Delegate For Follow Method


-(void)followButtonClickedWith:(NSInteger)index{
    
    if (index < arrGems.count) {
        NSDictionary *details = arrGems[index];
        if (NULL_TO_NIL([details objectForKey:@"user_id"])) {
            NSString *followerID = [details objectForKey:@"user_id"];
            [self showLoadingScreen];
            [APIMapper sendFollowRequestWithUserID:[User sharedManager].userId followerID:followerID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [self hideLoadingScreen];
                if ([[responseObject objectForKey:@"code"] integerValue] == 401) {
                    UIAlertController * alert=  [UIAlertController alertControllerWithTitle:@"Follow" message:[responseObject objectForKey:@"text"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* copy = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                        
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction:copy];
                    [self.navigationController presentViewController:alert animated:YES completion:nil];
                    [self updateGemsWithFollowStatusWithIndex:index latestFollowStatus:false];
                }else{
                    [self updateGemsWithFollowStatusWithIndex:index latestFollowStatus:true];
                }
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                [self hideLoadingScreen];
            }];
        }
    }
    
}

-(void)updateGemsWithFollowStatusWithIndex:(NSInteger)index latestFollowStatus:(BOOL)latestFollowStatus{
    
    if (index < arrGems.count) {
        NSMutableDictionary *gemsInfo = [NSMutableDictionary dictionaryWithDictionary:arrGems[index]];
        if (NULL_TO_NIL([gemsInfo objectForKey:@"user_id"])) {
            NSString *followerID = [gemsInfo objectForKey:@"user_id"];
            if ([gemsInfo objectForKey:@"follow_status"]) {
                if (!latestFollowStatus) {
                    [gemsInfo setValue:[NSNumber numberWithBool:false] forKey:@"can_follow"];
                    [arrGems replaceObjectAtIndex:index withObject:gemsInfo];
                }else{
                    int status = (int)[[gemsInfo objectForKey:@"follow_status"] integerValue];
                    if (NULL_TO_NIL([dictFollowers objectForKey:followerID]))
                        status = (int) [[dictFollowers objectForKey:followerID] integerValue];
                    status += 1;
                    if (status + 1 > eFollowed)
                        status = eFollow;
                    [dictFollowers setObject:[NSNumber numberWithInteger:status] forKey:followerID];
                }
                
            }
        }
        [collectionView reloadData];
    }
}


#pragma mark - Custom Cell Delegate For Like Method

-(void)likeGemsClicked:(NSInteger)index{
    
    /*! Like Button Action!*/
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        NSString *gemID;
        NSString *gemType;
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
            gemID = [gemDetails objectForKey:@"gem_id"];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
             gemType = [gemDetails objectForKey:@"gem_type"];
        
        [self updateGEMWithLikeStatus:index];
        
        if (gemID && gemType) {
            [APIMapper likeAGEMWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
            }];
        }
        
        
    }
    
}

-(void)updateGEMWithLikeStatus:(NSInteger)index{
    
    if (index < arrGems.count) {
        NSDictionary *gemsInfo = arrGems[index];
        NSString *gemID;
        NSInteger count = 0;
        BOOL isAlreadyLiked = 0;
        
        if (NULL_TO_NIL([gemsInfo objectForKey:@"gem_id"]))
            gemID = [gemsInfo objectForKey:@"gem_id"];
        if (NULL_TO_NIL([gemsInfo objectForKey:@"likecount"]))
            count = [[gemsInfo objectForKey:@"likecount"] integerValue];
        if ([[gemsInfo objectForKey:@"like_status"] boolValue])
            isAlreadyLiked = [[gemsInfo objectForKey:@"like_status"] boolValue];
            NSMutableDictionary *gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemsInfo];
            if (isAlreadyLiked) {
                count --;
                if (count < 0)count = 0;
                [gemDetails setValue:[NSNumber numberWithBool:0] forKey:@"like_status"];
            }
            else{
                count ++;
                [gemDetails setValue:[NSNumber numberWithBool:1] forKey:@"like_status"];
            }
            [gemDetails setValue:[NSNumber numberWithInteger:count] forKey:@"likecount"];
            [arrGems replaceObjectAtIndex:index withObject:gemDetails];
    }
    
    [collectionView reloadData];
}


#pragma mark - Custom Cell Delegate For Favourite Method


-(void)favouriteButtonApplied:(NSInteger)index{
    
    /*! Favourite Button Action!*/
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        NSString *gemID;
        NSString *gemType;
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
            gemID = [gemDetails objectForKey:@"gem_id"];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
            gemType = [gemDetails objectForKey:@"gem_type"];
        
        [self updateGEMWithFavouriteStatus:index];
        
        if (gemID && gemType) {
            [APIMapper addGemToFavouritesWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
            }];
        }
        
        
    }
    
}

-(void)updateGEMWithFavouriteStatus:(NSInteger)index{
    
    if (index < arrGems.count) {
        
        NSDictionary *gemsInfo = arrGems[index];
        NSString *gemID;
        BOOL isAlreadyLiked = 0;
        
        if (NULL_TO_NIL([gemsInfo objectForKey:@"gem_id"]))
            gemID = [gemsInfo objectForKey:@"gem_id"];
        if ([[gemsInfo objectForKey:@"favourite_status"] boolValue])
            isAlreadyLiked = [[gemsInfo objectForKey:@"favourite_status"] boolValue];
        NSMutableDictionary *gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemsInfo];
        [gemDetails setValue:[NSNumber numberWithBool:1] forKey:@"favourite_status"];
        [arrGems replaceObjectAtIndex:index withObject:gemDetails];
        
    }
    
    [collectionView reloadData];
}

#pragma mark - Custom Cell Delegate For Share Method

-(void)shareButtonClickedWithIndex:(NSInteger)index button:(UIButton*)button{
    
    /*
    
    UIAlertController * alert=  [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* copy = [UIAlertAction actionWithTitle:@"Copy GEM" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        if (index < arrGems.count) {
            NSDictionary *gemDetails = arrGems[index];
            [self showLoadingScreen];
            [APIMapper copyAGEMToNewGEMWithGEMID:[gemDetails objectForKey:@"gem_id"] userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject){
                if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode) {
                    if ([responseObject objectForKey:@"resultarray"]) {
                        [arrGems insertObject:[responseObject objectForKey:@"resultarray"] atIndex:0];
                    }
                }
                [collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
                [self hideLoadingScreen];
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
                [self hideLoadingScreen];
            }];
        }
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction* share = [UIAlertAction actionWithTitle:@"Share GEM" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        //! Share Button Action!*
        NSMutableString *shareText = [NSMutableString new];
        if (index < arrGems.count) {
            NSDictionary *gemDetails = arrGems[index];
            if (NULL_TO_NIL([gemDetails objectForKey:@"gem_title"]))
                [shareText appendString:[NSString stringWithFormat:@"%@",[gemDetails objectForKey:@"gem_title"]]];
            if (NULL_TO_NIL([gemDetails objectForKey:@"gem_details"]))
                [shareText appendString:[NSString stringWithFormat:@"\n %@",[gemDetails objectForKey:@"gem_details"]]];
            [self shareGEMToPublicWith:shareText items:[gemDetails objectForKey:@"gem_media"]];
            
        }
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    [alert addAction:copy];
    [alert addAction:share];
    [alert addAction:cancel];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
     
     */
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        NSString *gemID;
        NSString *gemType;
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
            gemID = [gemDetails objectForKey:@"gem_id"];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
            gemType = [gemDetails objectForKey:@"gem_type"];
        
        CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
        detailPage.actionType = eActionTypeShare;
        if ([gemDetails objectForKey:@"gem_type"]) {
            detailPage.strTitle =[[NSString stringWithFormat:@"SAVE AS %@",[gemDetails objectForKey:@"gem_type"]] uppercaseString] ;
            if ([[gemDetails objectForKey:@"gem_type"] isEqualToString:@"community"]) {
                detailPage.strTitle = @"SAVE GEM";
            }
            
        }
        [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:gemID GEMType:gemType];
        
        AppDelegate *deleagte = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if (!deleagte.navGeneral) {
            
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            app.navGeneral = [[UINavigationController alloc] initWithRootViewController:detailPage];
            app.navGeneral.navigationBarHidden = true;
            [UIView transitionWithView:app.window
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                app.window.rootViewController = app.navGeneral;
                            }
                            completion:nil];
            deleagte.navGeneral = app.navGeneral;
            
        }else{
            [deleagte.navGeneral pushViewController:detailPage animated:YES];
        }
    }
}


#pragma mark - Custom Cell Delegate For Get Liked and Commented Users

-(void)showAllLikedUsers:(NSInteger)index{
    
    if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        if ([[gemDetails objectForKey:@"likecount"]integerValue ] > 0) {
            AppDelegate *deleagte = (AppDelegate*)[UIApplication sharedApplication].delegate;
            LikedAndCommentedUserListings *userListings =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForLikedAndCommentedUsers];
            [userListings loadUserListingsForType:@"like" gemID:[gemDetails objectForKey:@"gem_id"]];
            if (!deleagte.navGeneral) {
                
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                app.navGeneral = [[UINavigationController alloc] initWithRootViewController:userListings];
                app.navGeneral.navigationBarHidden = true;
                [UIView transitionWithView:app.window
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{  app.window.rootViewController = app.navGeneral; }
                                completion:nil];
                deleagte.navGeneral = app.navGeneral;
                
            }else{
                [deleagte.navGeneral pushViewController:userListings animated:YES];
            }

        }
        
    }
    
}


-(void)showAllCommentedUsers:(NSInteger)index{
    
    
    if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        if ([[gemDetails objectForKey:@"comment_count"]integerValue ] > 0) {
            
            AppDelegate *deleagte = (AppDelegate*)[UIApplication sharedApplication].delegate;
            LikedAndCommentedUserListings *userListings =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForLikedAndCommentedUsers];
            [userListings loadUserListingsForType:@"comment" gemID:[gemDetails objectForKey:@"gem_id"]];
            if (!deleagte.navGeneral) {
                
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                app.navGeneral = [[UINavigationController alloc] initWithRootViewController:userListings];
                app.navGeneral.navigationBarHidden = true;
                [UIView transitionWithView:app.window
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{  app.window.rootViewController = app.navGeneral; }
                                completion:nil];
                
            }else{
                [deleagte.navGeneral pushViewController:userListings animated:YES];
            }
        }
    }
 
}




#pragma mark - Custom Cell Delegate For Generic Method


-(void)moreGalleryPageClicked:(NSInteger)index {
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        GEMDetailViewController *gemDetailVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMDetailPage];
        gemDetailVC.gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemDetails];
        gemDetailVC.delegate = self;
        gemDetailVC.clickedIndex = index;
        gemDetailVC.canSave = YES;
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.navGeneral = [[UINavigationController alloc] initWithRootViewController:gemDetailVC];
        app.navGeneral.navigationBarHidden = true;
        [UIView transitionWithView:app.window
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{  app.window.rootViewController = app.navGeneral; }
                        completion:nil];
        

    }

}

#pragma mark - Share Medias & Deleagtes


- (void)shareGEMToPublicWith:(NSString *)text items:(NSArray*)items
{
    if (items.count <= 0)return;
    if (!shareMediaView) {
        shareMediaView = [[[NSBundle mainBundle] loadNibNamed:@"shareMedias" owner:self options:nil] objectAtIndex:0];
        shareMediaView.delegate = self;
    }
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIView *vwPopUP = shareMediaView;
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
        [shareMediaView setUpWithShareItems:items text:text];
    }];
    
    
}
-(void)closeShareMediasView{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        shareMediaView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [shareMediaView removeFromSuperview];
        shareMediaView = nil;
    }];
}
#pragma mark - Comment Showing and its Delegate

-(void)commentComposeViewClickedBy:(NSInteger)index{
    
    if (!composeComment) {
       composeComment =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCommentCompose];
       composeComment.delegate = self;
    }
       if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        composeComment.dictGemDetails = gemDetails;
        composeComment.selectedIndex = index;
    }
    composeComment.isFromCommunityGem = true;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window.rootViewController addChildViewController:composeComment];
    UIView *vwPopUP = composeComment.view;
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
    }];
    
}

-(void)commentPopUpCloseAppplied{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        composeComment.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [composeComment.view removeFromSuperview];
        [composeComment removeFromParentViewController];
        composeComment = nil;
       
    }];
    
}

-(void)commentPostedSuccessfullyWithGemID:(NSString*)gemID commentCount:(NSInteger)count index:(NSInteger)index isAddComment:(BOOL)isAddComment{
    
    if (index < arrGems.count) {
        
        NSDictionary *gemsInfo = arrGems[index];
        NSMutableDictionary *gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemsInfo];
        if (isAddComment) {
            [gemDetails setValue:[NSNumber numberWithInteger:count] forKey:@"comment_count"];
            [arrGems replaceObjectAtIndex:index withObject:gemDetails];
        }
        else{
            if (NULL_TO_NIL([gemDetails objectForKey:@"comment_count"])) {
                NSInteger count = [[gemDetails objectForKey:@"comment_count"] integerValue];
                count --;
                if (count  < 0)
                    count = 0;
                    [gemDetails setValue:[NSNumber numberWithInteger:count] forKey:@"comment_count"];
                    [arrGems replaceObjectAtIndex:index withObject:gemDetails];
                }
            
            }
        }
        
    [collectionView reloadData];
    
}

#pragma mark - Media Listing Page Delegates Like / Share / Comment


/*!
 *This method is invoked when user Clicks "FAVOURITE" Button
 */
-(void)favouriteButtonAppliedFromMediaPage:(NSInteger)index{
    
    [self favouriteButtonApplied:index];
    
}


/*!
 *This method is invoked when user Clicks "LIKE" Button
 */
-(void)likeAppliedFromMediaPage:(NSInteger)index{
    
    [self likeGemsClicked:index];
    
}

/*!
 *This method is invoked when user Clicks "COMMENT" Button
 */
-(void)commentAppliedFromMediaPage:(NSInteger)index{
    
    [self commentComposeViewClickedBy:index];
}

/*!
 *This method is invoked when user Clicks "SHARE" Button
 */
-(void)shareAppliedFromMediaPage:(NSInteger)index{
    
     [self shareButtonClickedWithIndex:index button:nil];
}


#pragma mark - Generic Methods


-(IBAction)showUserProfilePage:(UITapGestureRecognizer*)gesture{
    
    NSInteger tag = gesture.view.tag;
    if (tag < arrGems.count) {
        NSDictionary *details = arrGems[tag];
        if (NULL_TO_NIL([details objectForKey:@"user_id"])) {
        ProfilePageViewController *profilePage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForProfilePage];
           
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (!app.navGeneral) {
                app.navGeneral = [[UINavigationController alloc] initWithRootViewController:profilePage];
                app.navGeneral.navigationBarHidden = true;
                [UIView transitionWithView:app.window
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{  app.window.rootViewController = app.navGeneral; }
                                completion:nil];
            }else{
                [app.navGeneral pushViewController:profilePage animated:YES];
            }
           
            
            
            profilePage.canEdit = false;
            if ([[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) {
                profilePage.canEdit = true;
            }
            [profilePage loadUserProfileWithUserID:[details objectForKey:@"user_id"]showBackButton:YES];
            
        }
    }
}

-(IBAction)showChatUser:(id)sender{
    
    ChatUserListingViewController *chatUser =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatUserListings];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:chatUser];
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    app.navGeneral.navigationBarHidden = true;
    
}

-(NSString*)getCountInTermsOfThousand:(NSInteger)_count{
    NSString *countText;
    NSInteger count = _count / OneK;
    NSInteger reminder = _count % OneK;
    countText = [NSString stringWithFormat:@"%ldK",(long)count];
    if (reminder > 0) {
        countText = [NSString stringWithFormat:@"%ldK+",(long)count];
    }
    return countText;
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

-(IBAction)showMyGemsApplied:(id)sender{
    
    MyGEMListingViewController *gemListingVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForMyGEMS];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:gemListingVC];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];

}


-(IBAction)goBack:(id)sender{
    
    [[self navigationController]popViewControllerAnimated:YES];
}

-(void)dealloc{
    
    collectionView = nil;
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
