//
//  RegistrationPageCustomTableViewCell.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistrationPageCustomTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UITextField *entryField;
@property (nonatomic,weak) IBOutlet UIImageView *iconView;
@property (nonatomic,weak) IBOutlet UIImageView *dropDownIcon;
@property (nonatomic,weak) IBOutlet UIButton *btnCountryDropDown;

@property (nonatomic,weak) IBOutlet UIButton *btnCheckBox;
@property (nonatomic,weak) IBOutlet UITextView *txtView;

@end
