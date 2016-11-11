//
//  GemDetailsCustomTableViewCell.m
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "GemDetailsCustomTableViewCell.h"


@interface GemDetailsCustomTableViewCell (){
    
}

@end

@implementation GemDetailsCustomTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
   
}

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;{
    
    self.row = row;
    self.section = section;
    
    
}

-(IBAction)playVideo:(id)sender{
   
    if ([self.delegate respondsToSelector:@selector(resetPlayerVaiablesForIndex:)]) {
        [self.delegate resetPlayerVaiablesForIndex:self.row];
    }
}


-(IBAction)playAudioFile:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(resetPlayerVaiablesForIndex:)]) {
        [self.delegate resetPlayerVaiablesForIndex:self.row];
    }
 
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


