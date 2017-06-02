//
//  ActionDetailsCustomCell.h
//  PurposeColor
//
//  Created by Purpose Code on 22/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"

@protocol ActionDetailsCustomCellDelegate <NSObject>

/*!
 *This method is invoked when user Changes  Toggle Switch
 */
-(void)updateGoalActionStatus;


/*!
 *This method is invoked when user Edit Action */
-(void)editButtonClicked;

/*!
 *This method is invoked when user Changes the Action Status */
-(void)actionStatusChanged;





@optional

@end


@interface ActionDetailsCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet KILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIButton *btnEdit;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint* rightConstarint;
@property (nonatomic,assign) BOOL isStatusPending;
@property (nonatomic,weak) IBOutlet UIView* vwLocInfo;
@property (nonatomic,weak) IBOutlet UIView* vwContactInfo;
@property (nonatomic,weak) IBOutlet UILabel *lblLocDetails;
@property (nonatomic,weak) IBOutlet UILabel *lblContactDetails;

@property (nonatomic, weak) IBOutlet UIView *vwURLPreview;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewDescription;
@property (nonatomic, weak) IBOutlet UILabel *lblPreviewDomain;
@property (nonatomic, weak) IBOutlet UIImageView *imgPreview;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *previewIndicator;
@property (nonatomic, weak) IBOutlet UIButton *btnShowPreviewURL;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint* bottomForDescription;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint* bottomForStatus;

@property (nonatomic,weak)  id<ActionDetailsCustomCellDelegate>delegate;

-(void)setUp;

@end
