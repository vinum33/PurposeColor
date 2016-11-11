//
//  ActionMediaComposeCell.h
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionMediaComposeCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UITextField *txtTitle;
@property (nonatomic,weak) IBOutlet UITextView *txtDecsription;
@property (nonatomic,weak) IBOutlet UIView *vwBg;
@property (nonatomic,weak) IBOutlet UILabel *lblContactInfo;
@property (nonatomic,weak) IBOutlet UILabel *lblLocInfo;
@property (nonatomic,weak) IBOutlet UIView *vwFooter;
@property (nonatomic,weak) IBOutlet UIView *vwTitleBG;

@end
