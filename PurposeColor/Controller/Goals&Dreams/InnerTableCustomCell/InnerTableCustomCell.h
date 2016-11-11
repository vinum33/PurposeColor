//
//  GemDetailsCustomTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface InnerTableCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIButton *btnStatus;
@property (nonatomic,weak) IBOutlet UIImageView *imgMore;
@property (nonatomic,weak) IBOutlet UIView  *vwBg;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;


@property (nonatomic,assign) NSInteger section;
@property (nonatomic,assign) NSInteger row;


-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;

@end
