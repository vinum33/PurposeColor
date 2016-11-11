//
//  JournalViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 18/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol JournalDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)closePopUpWithJournalIsAvailable:(BOOL)isJournalMediaAvailabe;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */
-(void)driveSelectedWithEmotionType:(NSInteger)emotionType;

/*!
 *This method is invoked when user Clicks "SUBMIT" Button and shows progress view
 */
-(void)startProgressViewWithProgerss:(float)progress;

/*!
 *This method is invoked when user Clicks "SUBMIT" Button and removes progress view
 */
-(void)hideProgressView;




@end


#import <UIKit/UIKit.h>

@interface JournalViewController : UIViewController

@property (nonatomic,weak)  id<JournalDelegate>delegate;

- (void)createAJournelWitEmotionValues:(NSDictionary*)emoitonalValues;

@end
