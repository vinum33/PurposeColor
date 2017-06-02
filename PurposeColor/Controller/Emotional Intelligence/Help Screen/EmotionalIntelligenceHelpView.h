//
//  EmotionalIntelligenceHelpView.h
//  PurposeColor
//
//  Created by Purpose Code on 31/05/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IntelligenceHelpDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)intelligenceHelpPopUpCloseAppplied;



@end


@interface EmotionalIntelligenceHelpView : UIView

@property (nonatomic,weak)  id<IntelligenceHelpDelegate>delegate;

-(void)setUp;

@end
