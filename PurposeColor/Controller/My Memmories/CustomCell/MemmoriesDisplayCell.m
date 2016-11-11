//
//  MemmoriesDisplayCell.m
//  PurposeColor
//
//  Created by Purpose Code on 26/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "MemmoriesDisplayCell.h"

@implementation MemmoriesDisplayCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)sharebuttonClicked:(UIButton*)sender{
    
    if ([self.delegate respondsToSelector:@selector(shareButtonClickedWithSection:WithIndex:)]) {
        [self.delegate shareButtonClickedWithSection:self.section WithIndex:self.row];
    }
}

-(IBAction)detailViewClicked:(UIButton*)sender{
    
    if ([self.delegate respondsToSelector:@selector(detailViewClickedWithSection:WithIndex:)]) {
        [self.delegate detailViewClickedWithSection:self.section WithIndex:self.row];
    }
}



-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;{
    
    self.row = row;
    self.section = section;
    
    
}

@end
