//
//  SelectYourFeel.h
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SelectYourDriveDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)selectYourDrivePopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)driveSelectedWithEmotionType:(NSInteger)emotionType;




@end

@interface SelectYourDrive : UIView

@property (nonatomic,weak)  id<SelectYourDriveDelegate>delegate;

-(void)showSelectionPopUp;
-(void)closePopUp;

@end
