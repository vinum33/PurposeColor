//
//  SelectYourFeel.h
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectYourFeelingDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)selectYourFeelingPopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)feelingsSelectedWithEmotionType:(NSInteger)emotionType;




@end

@interface SelectYourFeel : UIView

@property (nonatomic,weak)  id<SelectYourFeelingDelegate>delegate;

-(void)showSelectionPopUp;
-(void)closePopUp;

@end
