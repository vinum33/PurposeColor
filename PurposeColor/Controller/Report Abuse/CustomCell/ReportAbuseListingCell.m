//
//  CustomCellForType.m
//  SignSpot
//
//  Created by Purpose Code on 18/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "ReportAbuseListingCell.h"

@implementation ReportAbuseListingCell

- (void)awakeFromNib {
    // Initialization code
    [self setUp];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUp{
    
    _txtView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    _txtView.layer.borderWidth = 1.f;

}






@end
