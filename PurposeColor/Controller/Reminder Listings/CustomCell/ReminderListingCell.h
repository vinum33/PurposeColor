//
//  CustomCellForType.h
//  SignSpot
//
//  Created by Purpose Code on 18/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ReminderListingCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIView *vwBackground;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;



@end
