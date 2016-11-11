//
//  SelectYourFeel.h
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectYourGoalsAndDreamsDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)selectYourGoalsAndDreamsPopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)goalsAndDreamsSelectedWithTitle:(NSString*)title goalId:(NSInteger)goalsId;


/*!
 *This method is invoked when user Clicks "SKIP" Button
 */
-(void)skipButtonApplied;




@end

@interface SelectYourGoalsAndDreams : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,weak)  id<SelectYourGoalsAndDreamsDelegate>delegate;
@property (nonatomic,assign) NSInteger selectedGoalID;

-(void)showSelectionPopUp;
-(void)closePopUp;

@end
