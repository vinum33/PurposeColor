//
//  QuickGoalViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 19/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol QuickGoalDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)closeQuickGoalViewPopUp;





@end


#import <UIKit/UIKit.h>

@interface QuickGoalViewController : UIViewController
@property (nonatomic,weak)  id<QuickGoalDelegate>delegate;

-(void)loadGoalDetailsWithGoalID:(NSString*)goalID;

@end
