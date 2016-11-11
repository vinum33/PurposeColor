//
//  ImotionDisplayCell.h
//  PurposeColor
//
//  Created by Purpose Code on 12/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImotionDisplayCell : UITableViewCell

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *vwRightConstraint;
@property (nonatomic,weak) IBOutlet UIImageView *imgIcon;
@property (nonatomic,weak) IBOutlet UIImageView *imgSelection;
@property (nonatomic,weak) IBOutlet UILabel *lblSeletionTitle;

@end
