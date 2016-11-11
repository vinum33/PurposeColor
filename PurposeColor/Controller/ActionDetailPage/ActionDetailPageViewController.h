//
//  GoalsAndDreamsDetailViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 21/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol ActionDetailsDelegate <NSObject>

/*!
 *This method is invoked when user Changes  Toggle Switch
 */
-(void)refershGoalsAndDreamsAfterUpdate;

@optional

@end


#import <UIKit/UIKit.h>

@interface ActionDetailPageViewController : UIViewController

-(void)getActionDetailsByGoalActionID:(NSString*)goalActionID actionID:(NSString*)actionID goalID:(NSString*)goalID;

@property (nonatomic,weak)  id<ActionDetailsDelegate>delegate;

@end
