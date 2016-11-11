//
//  MemmoriesDisplayCell.h
//  PurposeColor
//
//  Created by Purpose Code on 26/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


@protocol MemoriesListViewDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)shareButtonClickedWithSection:(NSInteger)section WithIndex:(NSInteger)index;

/*!
 *This method is invoked when user Clicks "DETAIL PAGE" Button
 */
-(void)detailViewClickedWithSection:(NSInteger)section WithIndex:(NSInteger)index;

@end




#import <UIKit/UIKit.h>

@interface MemmoriesDisplayCell : UITableViewCell


@property (nonatomic,weak) IBOutlet UIImageView *imgMemory;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblTitleDate;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak) IBOutlet UIView *vwBg;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;

@property (nonatomic,weak)  id<MemoriesListViewDelegate>delegate;
-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;

@end
