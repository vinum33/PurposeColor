//
//  CreateEventCustomCell.m
//  PurposeColor
//
//  Created by Purpose Code on 26/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "CreateEventCustomCell.h"

@implementation CreateEventCustomCell


- (void)awakeFromNib {
    // Initialization code
    [self setUp];
}



-(void)setUp{
    
    _txtTitle.layer.borderWidth = 1.f;
    _txtTitle.layer.borderColor = [UIColor clearColor].CGColor;
    
    _txtDescrption.layer.borderWidth = 1.f;
    _txtDescrption.layer.borderColor = [UIColor clearColor].CGColor;
    
    [_txtTitle.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_txtTitle.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_txtTitle.layer setShadowOpacity:1.0];
    [_txtTitle.layer setShadowRadius:1];
    _txtTitle.layer.masksToBounds = NO;
    
    [_txtDescrption.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_txtDescrption.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_txtDescrption.layer setShadowOpacity:1.0];
    [_txtDescrption.layer setShadowRadius:1];
    _txtDescrption.layer.masksToBounds = NO;
    
    [_btnRepeater.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_btnRepeater.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_btnRepeater.layer setShadowOpacity:1.0];
    [_btnRepeater.layer setShadowRadius:1];
    _btnRepeater.layer.masksToBounds = NO;
    
    [_btnReminderTime.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_btnReminderTime.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_btnReminderTime.layer setShadowOpacity:1.0];
    [_btnReminderTime.layer setShadowRadius:1];
    _btnReminderTime.layer.masksToBounds = NO;
    
    [_btnEndTime.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_btnEndTime.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_btnEndTime.layer setShadowOpacity:1.0];
    [_btnEndTime.layer setShadowRadius:1];
    _btnEndTime.layer.masksToBounds = NO;
    
    [_btnEndDate.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_btnEndDate.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_btnEndDate.layer setShadowOpacity:1.0];
    [_btnEndDate.layer setShadowRadius:1];
    _btnEndDate.layer.masksToBounds = NO;
    
    [_btnStartTime.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_btnStartTime.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_btnStartTime.layer setShadowOpacity:1.0];
    [_btnStartTime.layer setShadowRadius:1];
    _btnStartTime.layer.masksToBounds = NO;
    
    [_btnStatDate.layer setShadowColor:[[UIColor lightGrayColor] CGColor]];
    [_btnStatDate.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    [_btnStatDate.layer setShadowOpacity:1.0];
    [_btnStatDate.layer setShadowRadius:1];
    _btnStatDate.layer.masksToBounds = NO;
    
    
    
    
    
    
    
   
    
}

@end
