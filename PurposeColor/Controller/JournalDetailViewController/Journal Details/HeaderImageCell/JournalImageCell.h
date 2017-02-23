//
//  JournalImageCell.h
//  PurposeColor
//
//  Created by Purpose Code on 21/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalImageCell : UITableViewCell

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic,weak) IBOutlet NSLayoutConstraint *aspect;
@property (nonatomic,weak) IBOutlet UIImageView *imgJournal;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
