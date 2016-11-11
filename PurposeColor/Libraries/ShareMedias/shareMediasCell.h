//
//  PhotoBrowserCell.h
//  PurposeColor
//
//  Created by Purpose Code on 16/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface shareMediasCell : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic,weak) IBOutlet UIButton *btnVideo;
@property (nonatomic,weak) IBOutlet UIButton *btnAudio;
@end
