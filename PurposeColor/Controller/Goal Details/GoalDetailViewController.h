//
//  MyMemmoriesViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 25/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


#import <UIKit/UIKit.h>


@protocol GoalDetailViewDelegate <NSObject>

/*!
 *This method is invoked when user Changes  Toggle Switch
 */
-(void)refershGoalsAndDreamsListingAfterUpdate;

@optional

@end
@interface GoalDetailViewController : UIViewController

-(void)getGoaDetailsByGoalID:(NSString*)_goalID;

@property (nonatomic,assign) BOOL shouldHideEditBtn;
@property (nonatomic,weak)  id<GoalDetailViewDelegate>delegate;

@end
