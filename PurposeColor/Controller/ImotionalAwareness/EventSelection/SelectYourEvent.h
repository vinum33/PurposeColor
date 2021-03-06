//
//  SelectYourFeel.h
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectYourEventDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)selectYourEventPopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)eventSelectedWithEventTitle:(NSString*)eventTitle eventID:(NSInteger)eventID;


@end

@interface SelectYourEvent : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,weak)  id<SelectYourEventDelegate>delegate;
@property (nonatomic,assign) NSInteger eventID;

-(void)showSelectionPopUp;
-(void)closePopUp;

@end
