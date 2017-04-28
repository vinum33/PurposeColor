//
//  MyGEMListingViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 20/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "GemsListCollectionViewCell.h"
#import "Constants.h"
#import "CommentComposeViewController.h"
#import "GEMDetailViewController.h"
#import "MyGEMListingViewController.h"
#import "GEMSListingHeaderView.h"
#import "LikedAndCommentedUserListings.h"
#import "shareMedias.h"
#import "CreateActionInfoViewController.h"
#import "FTPopOverMenu.h"

static NSString *CollectionViewCellIdentifier = @"GemsListCell";
#define OneK                    1000
#define kPadding                10
#define kDefaultNumberOfCells   1
#define kSuccessCode            200

@interface MyGEMListingViewController ()<GemListingsDelegate,CommentActionDelegate,MediaListingPageDelegate,shareMediasDelegate>{
    
    
    IBOutlet UICollectionView *collectionView;
    IBOutlet UIView *vwPaginationPopUp;
    IBOutlet NSLayoutConstraint *paginationBottomConstraint;
    UIRefreshControl *refreshControl;
    
    NSMutableArray *arrGems;
    NSInteger totalPages;
    NSInteger currentPage;
    NSMutableDictionary *dictFollowers;
    
    BOOL isPageRefresing;
    BOOL isDataAvailable;
    NSInteger totalGems;
    NSString *strNoDataText;
    
    CommentComposeViewController *composeComment;
    shareMedias *shareMediaView;
    NSMutableDictionary *heightsCache;

}



@end

@implementation MyGEMListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUp];
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
    currentPage = 1;
    totalPages = 0;
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refreshControl];
    collectionView.alwaysBounceVertical = YES;
    collectionView.hidden = true;
    isDataAvailable = false;
    heightsCache =  [NSMutableDictionary new];
    
}
-(void)getAllProductsByPagination:(BOOL)isPagination withPageNumber:(NSInteger)pageNumber{
    
    if (!isPagination) {
        [self showLoadingScreen];
    }
    
    [APIMapper getMyGemsByUserID:[User sharedManager].userId pageNo:pageNumber success:^(AFHTTPRequestOperation *operation, id responseObject){
        
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
    cell.delegate = self;
    [self resetCellVariables:cell];
    [cell setUpIndexPathWithRow:indexPath.row section:indexPath.section];
    if (indexPath.row < arrGems.count) {
        NSDictionary *details = arrGems[indexPath.row];
        [self configureTextVariables:details cell:cell indexPath:indexPath];
    }
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
    NSInteger index = indexPath.row;
    if (index < arrGems.count) {
        NSDictionary *gemDetails = arrGems[index];
        GEMDetailViewController *gemDetailVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMDetailPage];
        gemDetailVC.gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemDetails];;
        gemDetailVC.delegate = self;
        gemDetailVC.clickedIndex = index;
        gemDetailVC.canDelete = true;
        gemDetailVC.canSave = YES;
        [[self navigationController]pushViewController:gemDetailVC animated:YES];
        
    }

}

#pragma mark - Customise Cells Method

-(void)resetCellVariables:(GemsListCollectionViewCell*)cell{
    
    cell.lblShareCaption.text = @"Community";
    cell.vwBg.layer.borderColor = [UIColor colorWithRed:193/255.f green:196/255.f blue:199/255.f alpha:0.5].CGColor;
    cell.vwBg.layer.borderWidth = 1.0;
    
    cell.imgProfile.layer.cornerRadius = 25.f;
    cell.imgProfile.clipsToBounds = YES;
    [cell.imgGemMedia setImage:[UIImage imageNamed:@"NoImage.png"]];
    [cell.activityIndicator stopAnimating];
    
}


-(void)configureTextVariables:(NSDictionary*)details cell:(GemsListCollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    cell.lblName.text = @"";
    if (NULL_TO_NIL([details objectForKey:@"gem_title"]))
        cell.lblName.text = [details objectForKey:@"gem_title"];
    if (NULL_TO_NIL([details objectForKey:@"gem_datetime"]))
        cell.lblTime.text = [Utility getDaysBetweenTwoDatesWith:[[details objectForKey:@"gem_datetime"] doubleValue]];
    cell.lblTitle.text = @"";
    cell.constraintDateTop.constant = 10;
    if (NULL_TO_NIL([details objectForKey:@"gem_title"])){
        cell.constraintDescTopOne.priority = 999;
        cell.constraintDescTopTwo.priority = 998;
        cell.lblTitle.text = [details objectForKey:@"gem_title"];
        cell.constraintDateTop.constant = 5;
    }
    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineHeightMultiple = 1.2f;
//    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,
//                                 };
//    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[details objectForKey:@"gem_details"] attributes:attributes];
//    cell.lblTitle.attributedText = attributedText;
//    cell.lblTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    if (NULL_TO_NIL([details objectForKey:@"gem_details"]))
        cell.lblDescription.text = [details objectForKey:@"gem_details"];

    cell.btnFollow.hidden = true;
    cell.btnDelete.hidden = false;
    cell.btnMore.hidden = ![[details objectForKey:@"hide_status"] boolValue];
    
    [cell.btnLike setImage:[UIImage imageNamed:@"Like_Buton"] forState:UIControlStateNormal];
    if ([[details objectForKey:@"like_status"] boolValue])
        [cell.btnLike setImage:[UIImage imageNamed:@"Like_Active"] forState:UIControlStateNormal];
    
    if (NULL_TO_NIL([details objectForKey:@"likecount"])){
        NSInteger count = [[details objectForKey:@"likecount"] integerValue];
        if (count >= OneK) cell.lblLikeCnt.text = [NSString stringWithFormat:@"%@",[self getCountInTermsOfThousand:count]];
        else cell.lblLikeCnt.text = [NSString stringWithFormat:@"%d",[[details objectForKey:@"likecount"] integerValue]];
    }
    if (NULL_TO_NIL([details objectForKey:@"comment_count"])){
        NSInteger count =  [[details objectForKey:@"comment_count"] integerValue];
        if (count >= OneK) cell.lblCmntCount.text = [NSString stringWithFormat:@"%@",[self getCountInTermsOfThousand:count]];
        else cell.lblCmntCount.text = [NSString stringWithFormat:@"%d",[[details objectForKey:@"comment_count"] integerValue]];
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
        if ([heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]]) {
            imageHeight = [[heightsCache objectForKey:[NSNumber numberWithInt:indexPath.row]] integerValue];
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



#pragma mark - Custom Cell Delegate For Delete Method



-(void)deleteAGemWithIndex:(NSInteger)index{
    
    UINavigationController *nav = self.navigationController;
    
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
                                if ([[nav.viewControllers lastObject] isKindOfClass:[GEMDetailViewController class]])
                                /*! If the user standing in the  Detail page page !*/
                                [nav popViewControllerAnimated:YES];
                                 NSDictionary *gemDetails = arrGems[index];
                                 NSString *gemID;
                                 NSString *gemType;
                                 
                                 if (NULL_TO_NIL([gemDetails objectForKey:@"gem_id"]))
                                     gemID = [gemDetails objectForKey:@"gem_id"];
                                 
                                 if (NULL_TO_NIL([gemDetails objectForKey:@"gem_type"]))
                                     gemType = [gemDetails objectForKey:@"gem_type"];
                                 
                                 [self updateGEMWithDeleteStatus:index];
                                                                
                                 if (gemID && gemType) {
                                     [APIMapper deleteAGEMWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         
                                         
                                     } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                         
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
    [nav presentViewController:alert animated:YES completion:nil];
    

}

-(void)updateGEMWithDeleteStatus:(NSInteger)index{
    
    if (index < arrGems.count)
        [arrGems removeObjectAtIndex:index];
    totalGems -= 1;
    [collectionView reloadData];

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

#pragma mark - Custom Cell Delegate For Show Method

#pragma mark - Custom Cell Delegate For More Action Method

-(void)moreButtonClickedWithIndex:(NSInteger)index view:(UIView*)sender{
    
    if (index < arrGems.count) {
        
        UIAlertController * alert =  [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* hide;
        hide = [UIAlertAction actionWithTitle:@"Show" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            
            [self showGEMSInCommunity:index];
                
        [alert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
       
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
        
        // [self updateGEMWithVisibilityStatus:index];
        
        //        if (gemID && gemType) {
        //            [APIMapper hideAGEMWith:[User sharedManager].userId gemID:gemID gemType:gemType success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        //
        //            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        //
        //            }];
        //        }
        
    }
}


-(void)showGEMSInCommunity:(NSInteger)index;{
    
    UIAlertController * alert=  [UIAlertController
                                 alertControllerWithTitle:@"Share"
                                 message:@"You are going to inspire someone by sharing this GEM."
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
                                             
                                             [[[UIAlertView alloc] initWithTitle:@"Share" message:@"Shared to Inspiring gems." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
                                         }
                                         
                                     } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                         
                                     }];
                                 }
                                 [self updateGEMWithShareStatus:index];
                                 
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

-(void)updateGEMWithShareStatus:(NSInteger)index{
    
    if (index < arrGems.count) {
        NSDictionary *gemsInfo = arrGems[index];
        BOOL isHidden = 0;
        if ([[gemsInfo objectForKey:@"hide_status"] boolValue])
            isHidden = [[gemsInfo objectForKey:@"hide_status"] boolValue];
        NSMutableDictionary *gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemsInfo];
        [gemDetails setValue:[NSNumber numberWithBool:!isHidden] forKey:@"hide_status"];
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
        
    }
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
        AppDelegate *deleagte = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if (!deleagte.navGeneral) {
            
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            app.navGeneral = [[UINavigationController alloc] initWithRootViewController:detailPage];
            app.navGeneral.navigationBarHidden = true;
            [UIView transitionWithView:app.window
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{  app.window.rootViewController = app.navGeneral; }
                            completion:nil];
            deleagte.navGeneral = app.navGeneral;
            
        }else{
            [deleagte.navGeneral pushViewController:detailPage animated:YES];
        }
        [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:gemID GEMType:gemType];
        
        
    }
    
    
}

#pragma mark - Share Medias & Delegtes


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

#pragma mark - Media Listing Page Delegates Like / Share / Comment


-(void)moreGalleryPageClicked:(NSInteger)index {
    
    if (index < arrGems.count) {
        
        NSDictionary *gemDetails = arrGems[index];
        GEMDetailViewController *gemDetailVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMDetailPage];
        gemDetailVC.gemDetails = [NSMutableDictionary dictionaryWithDictionary:gemDetails];;
        gemDetailVC.delegate = self;
        gemDetailVC.clickedIndex = index;
        gemDetailVC.canDelete = true;
        gemDetailVC.canSave = YES;
        [[self navigationController]pushViewController:gemDetailVC animated:YES];
        
    }
    
}

/*!
 *This method is invoked when user Clicks "DELETE" Button
 */
-(void)deleteAppliedFromMediaPage:(NSInteger)index{
    
    [self deleteAGemWithIndex:index];
    
}

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


#pragma mark - Custom Cell Delegate For Get Liked and Commented Users

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


#pragma mark - Generic Methods

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


-(IBAction)goBack:(id)sender{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.navGeneral willMoveToParentViewController:nil];
    [app.navGeneral.view removeFromSuperview];
    [app.navGeneral removeFromParentViewController];
    app.navGeneral = nil;
    [app showLauchPage];
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
