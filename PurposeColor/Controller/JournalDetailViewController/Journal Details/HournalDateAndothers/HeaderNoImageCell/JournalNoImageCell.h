//
//  JournalNoImageCell.h
//  PurposeColor
//
//  Created by Purpose Code on 21/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalNoImageCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lbDescription;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *titleBottom;

@end
