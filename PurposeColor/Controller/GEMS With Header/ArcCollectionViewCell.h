//
//  ArcCollectionViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 19/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArcCollectionViewCell : UICollectionViewCell

 @property (nonatomic,weak) IBOutlet NSLayoutConstraint *imgHeight;
 @property (nonatomic,weak) IBOutlet UIImageView *imgGallery;

@end