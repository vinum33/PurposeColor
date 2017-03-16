//
//  ContactsTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 15/03/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgUser;
@property (nonatomic,weak) IBOutlet UILabel *lblName;
@property (nonatomic,weak) IBOutlet UILabel *lblPhoneNumber;
@property (nonatomic,weak) IBOutlet UILabel *lblNameIcon;
@property (nonatomic,weak) IBOutlet UIButton *btnCheckBox;

@end
