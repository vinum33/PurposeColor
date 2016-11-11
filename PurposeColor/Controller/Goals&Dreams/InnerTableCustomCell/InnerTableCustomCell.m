//
//  GemDetailsCustomTableViewCell.m
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


#define kSectionCount               1
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeaderHeight               40
#define kCellHeight                 40
#define kEmptyHeaderAndFooter       0
#define kCellHeightForCompleted     190


#import "GoalsAndDreamsCustomCell.h"
#import "InnerTableCustomCell.h"

@interface InnerTableCustomCell () {
    
    BOOL isDataAvailable;

}

@end

@implementation InnerTableCustomCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;{
    
    self.row = row;
    self.section = section;
    
}
-(IBAction)changeActionStatus:(id)sender{
    
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


