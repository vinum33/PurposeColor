//
//  CreateActionInfoViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CreateMediaInfoDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Created A New Event
 */
-(void)eventCreatedWithEvenTitle:(NSString*)eventTitle eventID:(NSInteger)eventID;

/*!
 *This method is invoked when user Created A New Goal And Dream
 */
-(void)goalsAndDreamsCreatedWithGoalTitle:(NSString*)goalTitle goalID:(NSInteger)goalID;

/*!
 *This method is invoked when user Created A New Action
 */
-(void)newActionCreatedWithActionTitle:(NSString*)actionTitle actionID:(NSInteger)actionID;


@end



typedef enum{
    
    eActionTypeEvent = 0,
    eActionTypeGoalsAndDreams = 1,
    eActionTypeActions = 2,
    eActionTypeShare = 3,
    
}ActionType;




@interface CreateActionInfoViewController : UIViewController

@property (nonatomic,weak)  id<CreateMediaInfoDelegate>delegate;
@property (nonatomic,assign)ActionType actionType;
@property (nonatomic,assign)BOOL shouldShowReminder;
@property (nonatomic,strong)NSString *strTitle;
@property (nonatomic,strong)NSString *strGoalID;
@property (nonatomic,assign)BOOL isPurposeColorGEM;

-(void)getMediaDetailsForGemsToBeEditedWithGEMID:(NSString*)gemID GEMType:(NSString*)gemType;

@end
