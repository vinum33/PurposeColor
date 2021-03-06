//
//  GemDetailsCustomTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "KILabel.h"

@protocol GoalsAndDreamsCustomCellDelegate <NSObject>

/*!
 *This method is invoked when user Clicks A CELL Button
 */
-(void)showActionDetailByGoalIndex:(NSInteger)index actionIndex:(NSInteger)index;


/*!
 *This method is invoked when user Clicks "Update Statsu Check Box" Button
 */
-(void)updatePendingStatusByIndex:(NSInteger)index actionIndex:(NSInteger)index;

/*!
 *This method is invoked when user Clicks "Goal Details" Button
 */
-(void)goalDetailsClickedWith:(NSInteger)index;


@optional



@end


@interface GoalsAndDreamsCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgGemMedia;
@property (nonatomic,weak) IBOutlet UIImageView *imgStatus;

@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak) IBOutlet UIView  *vwBg;
@property (nonatomic,weak) IBOutlet UILabel *lblStatus;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UILabel *lblGoalDate;
@property (nonatomic,weak) IBOutlet UIButton *btnShareStatus;
@property (nonatomic,weak) IBOutlet UIImageView *imgTransparentVideo;

@property (nonatomic,weak) IBOutlet KILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblActionCount;
@property (nonatomic,assign) NSInteger section;
@property (nonatomic,assign) NSInteger row;

@property (nonatomic, weak) IBOutlet UIView *vwURLPreview;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewDomain;
@property (nonatomic, weak) IBOutlet UIImageView *imgPreview;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *previewIndicator;
@property (nonatomic, weak) IBOutlet UIButton *btnShowPreviewURL;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottmForDescription;

@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForHeight;
@property (nonatomic,weak)  id<GoalsAndDreamsCustomCellDelegate>delegate;


@end
