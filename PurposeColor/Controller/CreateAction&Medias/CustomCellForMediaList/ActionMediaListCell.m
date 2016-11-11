//
//  ActionMediaComposeCell.m
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "ActionMediaListCell.h"

@implementation ActionMediaListCell

- (void)awakeFromNib {
    // Initialization code
    [self setUp];
}

-(void)setUp{
    
    
    
}


-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;{
    
    self.row = row;
    self.section = section;
    
}



-(IBAction)playVideo:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(playSelectedMediaWithIndex:)]) {
        [self.delegate playSelectedMediaWithIndex:self.row];
    }
}




-(IBAction)playAudioFile:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(playSelectedMediaWithIndex:)]) {
        [self.delegate playSelectedMediaWithIndex:self.row];
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
