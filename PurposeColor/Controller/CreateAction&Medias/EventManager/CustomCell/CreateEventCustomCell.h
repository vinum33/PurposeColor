//
//  CreateEventCustomCell.h
//  PurposeColor
//
//  Created by Purpose Code on 26/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateEventCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UITextField *txtTitle;
@property (nonatomic,weak) IBOutlet UITextView *txtDescrption;

@property (nonatomic,weak) IBOutlet UIButton *btnStatDate;
@property (nonatomic,weak) IBOutlet UIButton *btnEndDate;
@property (nonatomic,weak) IBOutlet UIButton *btnStartTime;
@property (nonatomic,weak) IBOutlet UIButton *btnEndTime;
@property (nonatomic,weak) IBOutlet UIButton *btnReminderTime;
@property (nonatomic,weak) IBOutlet UIButton *btnRepeater;

@end
