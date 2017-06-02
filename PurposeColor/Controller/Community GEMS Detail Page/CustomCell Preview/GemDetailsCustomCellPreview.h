//
//  GemDetailsCustomTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>


@interface GemDetailsCustomCellPreview: UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDomain;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet UIImageView *imgPreview;

@end
