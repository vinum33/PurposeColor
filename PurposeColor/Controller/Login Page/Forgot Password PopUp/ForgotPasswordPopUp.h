//
//  ForgotPasswordPopUp.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ForgotPwdDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeForgotPwdPopUpAfterADelay:(float)delay;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */

@end

@interface ForgotPasswordPopUp : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>{
    
    UITableView *tableView;
    UITextField *emailField;
}

@property (nonatomic,weak)  id<ForgotPwdDelegate>delegate;

-(void)setUp;

@end
