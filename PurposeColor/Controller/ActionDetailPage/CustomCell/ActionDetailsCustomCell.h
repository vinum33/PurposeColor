//
//  ActionDetailsCustomCell.h
//  PurposeColor
//
//  Created by Purpose Code on 22/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


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

@property (nonatomic,weak) IBOutlet UILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIButton *btnEdit;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint* rightConstarint;
@property (nonatomic,assign) BOOL isStatusPending;
@property (nonatomic,weak) IBOutlet UIView* vwLocInfo;
@property (nonatomic,weak) IBOutlet UIView* vwContactInfo;
@property (nonatomic,weak) IBOutlet UILabel *lblLocDetails;
@property (nonatomic,weak) IBOutlet UILabel *lblContactDetails;

@property (nonatomic,weak)  id<ActionDetailsCustomCellDelegate>delegate;

-(void)setUp;

@end
