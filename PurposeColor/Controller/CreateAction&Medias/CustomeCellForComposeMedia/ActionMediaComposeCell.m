//
//  ActionMediaComposeCell.m
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "ActionMediaComposeCell.h"

@implementation ActionMediaComposeCell

- (void)awakeFromNib {
    // Initialization code
    [self setUp];
}

-(void)setUp{
    
    _vwBg.layer.borderWidth = 1.f;
    _vwBg.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
    _txtTitle.layer.borderWidth = 1.f;
    _txtTitle.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
