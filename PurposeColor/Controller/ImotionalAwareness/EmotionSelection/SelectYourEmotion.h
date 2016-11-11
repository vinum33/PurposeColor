//
//  SelectYourFeel.h
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectYourEmotionDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)SelectYourEmotionPopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)emotionSelectedWithEmotionTitle:(NSString*)emotionTitle emotionID:(NSInteger)emotionID;




@end

@interface SelectYourEmotion : UIView <UIGestureRecognizerDelegate>

@property (nonatomic,weak)  id<SelectYourEmotionDelegate>delegate;
@property (nonatomic,assign) NSInteger emotionaValue;

-(void)showSelectionPopUp;
-(void)closePopUp;

@end
