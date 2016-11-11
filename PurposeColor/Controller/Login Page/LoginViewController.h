//
//  ViewController.h
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForgotPasswordPopUp.h"
#import "StateListViewPopUp.h"

@protocol LoginDelegate <NSObject>
/*!
 *This method is invoked when user taps the 'Done' Button.
 @param fromDate.
 It is the date selected.
 @param toDate.
 It is the date selected.
 */
-(void)goToHomeAfterLogin;


@end



@interface LoginViewController : UIViewController <ForgotPwdDelegate,StateSelectionDelegate>

@property (nonatomic,weak)  id<LoginDelegate>delegate;


@end

