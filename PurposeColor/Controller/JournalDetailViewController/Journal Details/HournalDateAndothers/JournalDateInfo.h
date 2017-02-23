//
//  JournalDateInfo.h
//  PurposeColor
//
//  Created by Purpose Code on 22/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalDateInfo : UITableViewCell

@property (nonatomic,weak) IBOutlet UIView *vwBoxTop;
@property (nonatomic,weak) IBOutlet UIView *vwBoxBottom;
@property (nonatomic,weak) IBOutlet UILabel *lblDateAndConatct;
@property (nonatomic,weak) IBOutlet UILabel *lblOtherInfo;

@end
