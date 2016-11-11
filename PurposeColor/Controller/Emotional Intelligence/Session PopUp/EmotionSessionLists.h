//
//  EmotionSessionLists.h
//  PurposeColor
//
//  Created by Purpose Code on 12/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


@protocol SessionPopUpDelegate <NSObject>

/*!
 *This method is invoked when user selected an option .
 */

-(void)filterAppliedWithStartDate:(NSString*)startDate endDate:(NSString*)endDate sessionValue:(NSInteger)sessionType;

/*!
 *This method is invoked when user close the  view.
 */

-(void)closeSessionPopUp;



-(void)closeSessionPopUp;

@end

#import <UIKit/UIKit.h>

@interface EmotionSessionLists : UIView

@property (nonatomic,weak) IBOutlet UIView *vwContainer;
@property (nonatomic,weak)  id<SessionPopUpDelegate>delegate;

-(void)setUpInitialValuesWithActiveValue:(NSInteger)_sessionValue startDate:(NSString*)strDate endDate:(NSString*)_strEndDate;

@end
