//
//  JournalListCustomCell.h
//  PurposeColor
//
//  Created by Purpose Code on 20/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalListCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblLocAndContact;
@property (nonatomic,weak) IBOutlet UILabel *lblFeel;
@property (nonatomic,weak) IBOutlet UILabel *lblGoal;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak) IBOutlet UIImageView *imgGemMedia;

@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIButton *btnGoal;
@property (nonatomic,weak) IBOutlet UIButton *btnGallery;

@end
