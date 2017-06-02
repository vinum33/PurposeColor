//
//  ForgotPasswordPopUp.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HideAccntPopUp : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate>{
    
    UITableView *tableView;
    UITextField *emailField;
}


-(void)setUp;

@end
