//
//  MyFavouritesListingViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 23/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

static NSString *CollectionViewCellIdentifier = @"GemsListCell";
#define OneK                    1000
#define kPadding                10
#define kDefaultNumberOfCells   1
#define kSuccessCode            200


#import "MyFavouritesListingViewController.h"
#import "GemsListCollectionViewCell.h"
#import "CommentComposeViewController.h"
#import "GEMDetailViewController.h"
#import "MyGEMListingViewController.h"
#import "GEMSListingHeaderView.h"
#import "Constants.h"
#import "ChatUserListingViewController.h"
#import "LikedAndCommentedUserListings.h"
#import "shareMedias.h"
#import "CreateActionInfoViewController.h"
#import "MenuViewController.h"

typedef enum{
    
    eFollow = 0,
    eFollowPending = 1,
    eFollowed = 2,
    
} eFollowStatus;



@interface MyFavouritesListingViewController ()<GemListingsDelegate,CommentActionDelegate,MediaListingPageDelegate,shareMediasDelegate,SWRevealViewControllerDelegate>{
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UIView *vwPaginationPopUp;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnSlideMenu;
    IBOutlet UIView *vwOverLay;
    
    IBOutlet NSLayoutConstraint *paginationBottomConstraint;
    UIRefreshControl *refreshControl;
    
    NSMutableArray *arrGems;
    NSInteger totalPages;
    NSInteger currentPage;
    NSMutableDictionary *dictFollowers;
    eFollowStatus followStatus;
    
    BOOL isPageRefresing;
    BOOL isDataAvailable;
    NSInteger totalGems;
    
    CommentComposeViewController *composeComment;
    shareMedias *shareMediaView;
}

@end

@implementation MyFavouritesListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self customSetup];
    [self getAllProductsByPagination:NO withPageNumber:currentPage];
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
    
    UINib *cellNib = [UINib nibWithNibName:@"GemsListCollectionViewCell" bundle:nil];
    [collectionView registerNib:cellNib forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    collectionView.hidden = false;
    dictFollowers = [NSMutableDictionary new];
    
    arrGems = [NSMutableArray new];
    currentPage = 1;
    totalPages = 0;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
    collectionView.hidden = true;
    isDataAvailable = false;
    if (_isInspiredGEM) {
        lblTitle.text = @"SAVED GEMS";
    }
    
    
}
-(void)getAllProductsByPagination:(BOOL)isPagination withPageNumber:(NSInteger)pageNumber{
    
    if (!isPagination) {
        [self showLoadingScreen];
    }
    
    [APIMapper getAllFavouritesByUserID:[User sharedManager].userId pageNo:pageNumber type:_isInspiredGEM success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        collectionView.hidden = false;
        isPageRefresing = NO;
        [refreshControl endRefreshing];
        [self getGemsFromResponds:responseObject];
        [collectionView reloadData];
        [self hideLoadingScreen];
        [self hidePaginationPopUp];
        
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
    [arrGems removeAllObjects];
    [dictFollowers removeAllObjects];
    [self showLoadingScreen];
    currentPage = 1;
    isPageRefresing = YES;
    [self getAllProductsByPagination:YES withPageNumber:currentPage];
    
    
}

-(void)getGemsFromResponds:(NSDictionary*)responseObject{
    
    isDataAvailable = false;
    if ( NULL_TO_NIL([responseObject objectForKey:@"resultarray"])) {
        NSArray *results = [responseObject objectForKey:@"resultarray"];
        for (NSDictionary *dict in results)
            [arrGems addObject:dict];
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
        return cell;
        
    }
    GemsListCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [self resetCellVariables:cell];
    [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
    
    if (indexPath.row < arrGems.count) {
        
        NSDictionary *details = arrGems[indexPath.row];
        [self configureTextVariables:details cell:cell];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    float padding = 10;
    float height = 410;
    float width = _collectionView.bounds.size.width;
    if (indexPath.row < arrGems.count) {
        NSDictionary *details = arrGems[indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"gem_details"])){
            float lblHeight = [Utility getSizeOfLabelWithText:[details objectForKey:@"gem_details"] width:self.view.frame.size.width - padding font:[UIFont fontWithName:CommonFont size:14]];
            if (lblHeight > 30) {
                lblHeight = 30;
            }
            if ([[details objectForKey:@"display_image"] isEqualToString:@"No"]) {
                height = 180;
            }
            float finalHeight = height + lblHeight;
            return CGSizeMake(width, finalHeight);
        }
        
    }
    
    return CGSizeMake(width, height);
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
    
    if (kind == UICollectionElementKindSectionHeader) {
        GEMSListingHeaderView *headerView = [_collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GEMSListingHeaderView" forIndexPath:indexPath];
        headerView.lblCategoryTitle.text = [NSString stringWithFormat:@"Total %lu GEMS",(unsigned long)totalGems];
        reusableview = headerView;
    }
    return reusableview;
}
- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (!isDataAvailable) return CGSizeZero;
    return CGSizeMake(_collectionView.bounds.size.width, 45);
    
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

#pragma mark - Customise Cells Method

-(void)resetCellVariables:(GemsListCollectionViewCell*)cell{
    
    cell.vwBg.layer.borderColor = [UIColor colorWithRed:193/255.f green:196/255.f blue:199/255.f alpha:1].CGColor;
    cell.vwBg.layer.borderWidth = 1.0;
    
    cell.imgProfile.layer.cornerRadius = 25.f;
    cell.imgProfile.clipsToBounds = YES;
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    [cell.activityIndicator stopAnimating];
    
    cell.btnDelete.hidden = false;
    cell.btnFollow.hidden = true;
    cell.btnMore.hidden = true;
    
}


-(void)configureTextVariables:(NSDictionary*)details cell:(GemsListCollectionViewCell*)cell{
    
    cell.lblName.text = [details objectForKey:@"firstname"];
    cell.lblTime.text = [Utility getDaysBetweenTwoDatesWith:[[details objectForKey:@"gem_datetime"] doubleValue]];
    
    if (NULL_TO_NIL([details objectForKey:@"gem_title"]))
        cell.lblTitle.text = [details objectForKey:@"gem_title"];
    
    if ([[details objectForKey:@"gem_type"] isEqualToString:@"action"]) {
        [cell.btnBanner setTitle:@"ACTION" forState:UIControlStateNormal];;
    }
    else if ([[details objectForKey:@"gem_type"] isEqualToString:@"goal"]) {
        [cell.btnBanner setTitle:@"GOAL" forState:UIControlStateNormal];;
    }
    else if ([[details objectForKey:@"gem_type"] isEqualToString:@"event"]) {
        [cell.btnBanner setTitle:@"EVENT" forState:UIControlStateNormal];;
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
    
    [cell.btnShare setImage:[UIImage imageNamed:@"Share.png"] forState:UIControlStateNormal];
    cell.lblShareOrSave.text = @"Share";
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
    
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    cell.imgGemMedia.hidden = false;
    cell.imgTransparentVideo.hidden = true;
    if ([[details objectForKey:@"display_type"] isEqualToString:@"video"])cell.imgTransparentVideo.hidden = false;
    if ([[details objectForKey:@"display_image"] isEqualToString:@"No"]) cell.imgGemMedia.hidden = true;
    if (NULL_TO_NIL([details objectForKey:@"display_image"])){
        NSString *url = [details objectForKey:@"display_image"];
        if (url.length) {
            [cell.activityIndicator startAnimating];
            [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:url]
                                placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           [UIView transitionWithView:cell.imgGemMedia
                                                             duration:.5f
                                                              options:UIViewAnimationOptionTransitionCrossDissolve
                                                           animations:^{
                                                               cell.imgGemMedia.image = image;
                                                           } completion:nil];
                                           [cell.activityIndicator stopAnimating];
                                       }];
        }
    }
    
    
}



#pragma mark - Custom Cell Delegate For Delete A Gem Method

-(void)deleteAGemWithIndex:(NSInteger)index{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete"
                                  message:@"Delete the selected GEM?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (index < arrGems.count) {
                                 NSDictionary *gemDetails = arrGems[index];
                                 NSString *fav_id;
                                 NSString *gemType;
                                 
                                 if (NULL_TO_NIL([gemDetails objectForKey:@"id"]))
                                     fav_id = [gemDetails objectForKey:@"id"];
                                 
                                 if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
                                     gemType = [gemDetails objectForKey:@"gem_type"];
                                 
                                 if (fav_id && gemType) {
                                     [self showLoadingScreen];
                                     [APIMapper removeFromFavouritesWithUserID:[User sharedManager].userId favouriteID:fav_id type:_isInspiredGEM success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         [self hideLoadingScreen];
                                         [self updateGEMWithDeleteStatus:index];
                                         
                                     } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                         
                                         [self showAlertWithMessage:[error localizedDescription] title:@"Delete"];
                                         [self hideLoadingScreen];
                                     }];
                                 }
                                 
                             }
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
}

-(void)updateGEMWithDeleteStatus:(NSInteger)index{
    
    isDataAvailable = true;
    if (index < arrGems.count)
        [arrGems removeObjectAtIndex:index];
    totalGems -= 1;
    if (arrGems.count <= 0) isDataAvailable = false;
    [collectionView reloadData];
    
}



#pragma mark - Custom Cell Delegate For Follow Method


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
    
    // ! Share Button Action!
    NSMutableString *shareText = [NSMutableString new];
    if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_title"]))
            [shareText appendString:[NSString stringWithFormat:@"%@",[gemDetails objectForKey:@"gem_title"]]];
        
        if (NULL_TO_NIL([gemDetails objectForKey:@"gem_details"]))
            [shareText appendString:[NSString stringWithFormat:@"\n %@",[gemDetails objectForKey:@"gem_details"]]];
        
        [self shareGEMToPublicWith:shareText items:[gemDetails objectForKey:@"gem_media"]];
        
    }*/
    
    if (_isInspiredGEM) {
        
        UIAlertController * alert=  [UIAlertController
                                     alertControllerWithTitle:@"Share"
                                     message:@"You are going to inspire someone by sharing this GEM to community."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if (index < arrGems.count) {
                                     
                                     NSDictionary *gemDetails = arrGems[index];
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
                                     
                                 }
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
        
    }else{
        
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
            }
            [[self navigationController]pushViewController:detailPage animated:YES];
            [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:gemID GEMType:gemType];
            
            
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
        gemDetailVC.canSave = false;
        [[self navigationController]pushViewController:gemDetailVC animated:YES];
        
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




#pragma mark - Custom Cell Delegate For Get Liked and Commented Users

-(void)showAllLikedUsers:(NSInteger)index{
    
    if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        if ([[gemDetails objectForKey:@"likecount"]integerValue ] > 0) {
            LikedAndCommentedUserListings *userListings =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForLikedAndCommentedUsers];
            [userListings loadUserListingsForType:@"like" gemID:[gemDetails objectForKey:@"gem_id"]];
            [[self navigationController]pushViewController:userListings animated:YES];
        }
    }
    
}

-(void)showAllCommentedUsers:(NSInteger)index{
    
    if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        if ([[gemDetails objectForKey:@"comment_count"]integerValue ] > 0) {
            LikedAndCommentedUserListings *userListings =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForLikedAndCommentedUsers];
            [userListings loadUserListingsForType:@"comment" gemID:[gemDetails objectForKey:@"gem_id"]];
            [[self navigationController]pushViewController:userListings animated:YES];
        }
    }
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

-(IBAction)showChatUser:(id)sender{
    
    ChatUserListingViewController *chatUser =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatUserListings];
    [[self navigationController]pushViewController:chatUser animated:YES];
    
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

-(void)showAlertWithMessage:(NSString*)alertMessage title:(NSString*)alertTitle{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:alertTitle
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
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
    [[self navigationController]pushViewController:gemListingVC animated:YES];
    
}


-(IBAction)goBack:(id)sender{
    
    [[self navigationController]popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
