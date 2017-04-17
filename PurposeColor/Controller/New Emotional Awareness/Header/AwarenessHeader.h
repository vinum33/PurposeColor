//
//  AwarenessHeader.h
//  PurposeColor
//
//  Created by Purpose Code on 03/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AwarenessHeader : UIView

@property (nonatomic,weak) IBOutlet UILabel *lblGalleryCount;
 @property (nonatomic,weak) IBOutlet UIImageView *imgGallery;
 @property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
 @property (nonatomic,weak) IBOutlet NSLayoutConstraint *imgHeight;

@end
