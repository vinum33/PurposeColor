//
//  SelectYourFeel.h
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectYourActionsDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)selectYourActionsPopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)actionsSelectedWithTitle:(NSString*)title actionIDs:(NSDictionary*)actionIDs;




@end

@interface SelectActions : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,weak)  id<SelectYourActionsDelegate>delegate;
@property (nonatomic,assign)  NSInteger goalID;

-(void)showSelectionPopUp;
-(void)closePopUp;

@end
