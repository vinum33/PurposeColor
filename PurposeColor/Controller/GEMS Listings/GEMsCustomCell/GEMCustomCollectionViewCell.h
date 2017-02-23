//
//  GEMCustomCollectionViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 28/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GEMCustomCollectionViewCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIView* vwBg;
@property (nonatomic,weak) IBOutlet UILabel* lblTitle;
@property (nonatomic,weak) IBOutlet UIImageView* imgDisplay;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView* indicator;
@property (nonatomic,weak) IBOutlet  NSLayoutConstraint *constraintForHeight;

@end
