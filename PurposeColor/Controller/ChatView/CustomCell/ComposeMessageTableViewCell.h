//
//  ComposeMessageTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeMessageTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblTime;
@property (nonatomic,weak) IBOutlet UILabel *lblMessage;
@property (nonatomic,weak) IBOutlet UIImageView *imgBg;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *leftForBg;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *leftForMessage;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *leftForDate;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *leftForDelete;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *rightForBg;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *rightMessage;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *rightForDate;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *widthForImage;





@end
