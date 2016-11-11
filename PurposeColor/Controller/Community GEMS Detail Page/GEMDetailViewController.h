//
//  GEMDetailViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol MediaListingPageDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "FAVOURITE" Button
 */
-(void)favouriteButtonAppliedFromMediaPage:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "LIKE" Button
 */
-(void)likeAppliedFromMediaPage:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "COMMENT" Button
 */
-(void)commentAppliedFromMediaPage:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "SHARE" Button
 */
-(void)shareAppliedFromMediaPage:(NSInteger)index ;

/*!
 *This method is invoked when user Clicks "SHARE" Button
 */
-(void)deleteAppliedFromMediaPage:(NSInteger)index ;


@end


#import <UIKit/UIKit.h>

@interface GEMDetailViewController : UIViewController

@property (nonatomic,strong) NSMutableDictionary *gemDetails;
@property (nonatomic,assign) NSInteger  clickedIndex;
@property (nonatomic,weak)  id<MediaListingPageDelegate>delegate;
@property (nonatomic,assign) BOOL canDelete;
@property (nonatomic,assign) BOOL isFromGEM;
@property (nonatomic,assign) BOOL canSave;

@end
