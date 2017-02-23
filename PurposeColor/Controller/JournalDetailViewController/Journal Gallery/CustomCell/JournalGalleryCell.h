//
//  JournalGalleryCell.h
//  PurposeColor
//
//  Created by Purpose Code on 22/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalGalleryCell : UITableViewCell

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak)  IBOutlet UIImageView *imgGem;
@property (nonatomic,weak) IBOutlet UIButton *btnVideoPlay;
@property (nonatomic,weak) IBOutlet  UIButton *btnAudioPlay;

@end
