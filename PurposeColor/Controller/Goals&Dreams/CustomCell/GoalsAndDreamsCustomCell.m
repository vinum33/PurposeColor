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
#define kHeaderHeight               0
#define kCellHeight                 45
#define kEmptyHeaderAndFooter       0
#define kCellHeightForCompleted     190


#import "GoalsAndDreamsCustomCell.h"
#import "InnerTableCustomCell.h"

@interface GoalsAndDreamsCustomCell (){
    
    BOOL isDataAvailable;
}

@end

@implementation GoalsAndDreamsCustomCell

- (void)awakeFromNib {
    // Initialization code
    
 }







-(void)updateStatus:(UIButton*)btnStatus{
    
    if ([self.delegate respondsToSelector:@selector(updatePendingStatusByIndex:actionIndex:)]) {
        [self.delegate updatePendingStatusByIndex:self.row actionIndex:btnStatus.tag];
    }
    
}

-(IBAction)goalDetailButtonClicked:(UIButton*)btnStatus{
    
    if ([self.delegate respondsToSelector:@selector(goalDetailsClickedWith:)]) {
        [self.delegate goalDetailsClickedWith:self.row];
    }
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end


