//
//  PhotoBrowserCell.h
//  PurposeColor
//
//  Created by Purpose Code on 16/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (strong, nonatomic) UIImage  *image;

- (void)setup;
-(void)resetCell;

@end
