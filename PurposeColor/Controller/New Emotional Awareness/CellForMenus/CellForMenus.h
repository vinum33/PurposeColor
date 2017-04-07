//
//  CellForMenus.h
//  PurposeColor
//
//  Created by Purpose Code on 20/03/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellForMenus : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblMenu;
@property (nonatomic,weak) IBOutlet UIImageView *imgIcon;
@property (nonatomic,weak) IBOutlet UIView *vwTopBorder;
@property (nonatomic,weak) IBOutlet UIView *vwBotomBorder;
@property (nonatomic,weak) IBOutlet UIButton *btnNext;
@property (nonatomic,weak) IBOutlet UIImageView *imgTick;
@property (nonatomic,weak) IBOutlet UIButton *btnPost;

@end
