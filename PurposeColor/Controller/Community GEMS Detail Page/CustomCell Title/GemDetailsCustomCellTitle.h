//
//  GemDetailsCustomTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>


@interface GemDetailsCustomCellTitle : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lbltTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIButton *btnEdit;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *titleRightConstraint;



@end
