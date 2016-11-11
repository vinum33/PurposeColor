//
//  GemsCustomTableViewCell.m
//  PurposeColor
//
//  Created by Purpose Code on 06/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "GemsCustomTableViewCell.h"

@implementation GemsCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;{
    
    self.row = row;
    self.section = section;
    
}

-(IBAction)mediaClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(mediaCellClickedWithSection:andIndex:)]) {
        [self.delegate mediaCellClickedWithSection:self.section andIndex:self.row];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
