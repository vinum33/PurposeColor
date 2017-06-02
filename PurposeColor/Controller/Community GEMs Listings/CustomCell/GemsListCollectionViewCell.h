//
//  ProductCollectionViewCell.h
//  SignSpot
//
//  Created by Purpose Code on 12/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "KILabel.h"

@protocol GemListingsDelegate <NSObject>


@optional

/*!
 *This method is invoked when user Clicks "LIKE" Button
 */
-(void)likeGemsClicked:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "SHARE" Button
 */
-(void)shareButtonClickedWithIndex:(NSInteger)index button:(UIButton*)btn ;

/*!
 *This method is invoked when user Clicks "COMMENT" Button
 */
-(void)commentComposeViewClickedBy:(NSInteger)index ;


/*!
 *This method is invoked when user Clicks "+02" Button
 */
-(void)moreGalleryPageClicked:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "Follow" Button
 */
-(void)followButtonClickedWith:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "Delete" Button
 */
-(void)deleteAGemWithIndex:(NSInteger)index ;


/*!
 *This method is invoked when user Clicks "Hide" Button
 */
-(void)moreButtonClickedWithIndex:(NSInteger)index view:(UIView*)sender;


/*!
 *This method is invoked when user Clicks "Edit" Button
 */
-(void)editAGemWithIndex:(NSInteger)index;

/*!
 *This method is invoked when user Clicks "Show" Button
 */
-(void)showGEMSInCommunity:(NSInteger)index;


/*!
 *This method is invoked when user Clicks "Show Liked Users" Button
 */
-(void)showAllLikedUsers:(NSInteger)index;

/*!
 *This method is invoked when user Clicks "Show Commeneted Users" Button
 */
-(void)showAllCommentedUsers:(NSInteger)index;

/*!
 *This method is invoked when user Clicks "Show Commeneted Users" Button
 */
-(void)showDetailPageWithIndex:(NSInteger)index;




@end



@interface GemsListCollectionViewCell : UICollectionViewCell{
    
}

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic,weak)  id<GemListingsDelegate>delegate;

@property (nonatomic,weak) IBOutlet UIButton *btnBanner;
@property (nonatomic,weak) IBOutlet UIImageView *imgGemMedia;
@property (nonatomic,weak) IBOutlet UIImageView *imgTransparentVideo;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIView *vwBg;
@property (nonatomic, weak) IBOutlet UIButton *btnMore;

@property (nonatomic, weak) IBOutlet UIButton *btnLike;
@property (nonatomic, weak) IBOutlet UIButton *btnComment;
@property (nonatomic, weak) IBOutlet UIButton *btnShare;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet  UIButton *btnFollow;
@property (nonatomic,weak) IBOutlet  UIButton *btnEdit;

@property (nonatomic, weak) IBOutlet KILabel *lblDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblShareOrSave;
@property (nonatomic, weak) IBOutlet UILabel *lblShareCaption;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblLikeCnt;
@property (nonatomic, weak) IBOutlet UILabel *lblCmntCount;
@property (nonatomic,weak) IBOutlet  UIImageView *imgProfile;
@property (nonatomic, weak) IBOutlet UILabel *lblMediaCount;
@property (nonatomic, weak) IBOutlet UIButton *bnExpandGallery;
@property (nonatomic, weak) IBOutlet UIButton *btnShowInCommunity;

@property (nonatomic, weak) IBOutlet UIView *vwURLPreview;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewDomain;
@property (nonatomic, weak) IBOutlet UIImageView *imgPreview;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *previewIndicator;
@property (nonatomic, weak) IBOutlet UIButton *btnShowPreviewURL;


@property (nonatomic,weak) IBOutlet  UIButton *btnVideoPlay;
@property (nonatomic,weak) IBOutlet  UIButton *btnAudioPlay;

@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForTitle;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForDate;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForTitleTop;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForHeight;

@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintDateTop;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintDescTopOne;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintDescTopTwo;


@property (nonatomic,strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic,strong) NSString *strURL;

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;



@end
