//
//  SelectYourFeel.m
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "SelectYourFeel.h"

@interface SelectYourFeel (){
    
    IBOutlet NSLayoutConstraint *rightConstraint;
}



@end

@implementation SelectYourFeel

-(void)showSelectionPopUp{
    
    [self setUp];
    [self layoutIfNeeded];
    rightConstraint.constant = 0;
    [UIView animateWithDuration:.6
                     animations:^{
                         [self layoutIfNeeded]; // Called on parent view
                     }completion:^(BOOL finished) {
                         
                     }];
}

-(void)setUp{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [tapGesture setNumberOfTapsRequired:1];
    [self addGestureRecognizer:tapGesture];
    

}

-(void)closePopUp{
    
    [self layoutIfNeeded];
    rightConstraint.constant = -200;
    [UIView animateWithDuration:.6
                         animations:^{
                             [self layoutIfNeeded];
                             // Called on parent view
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 if ([self.delegate respondsToSelector:@selector(selectYourFeelingPopUpCloseAppplied)]) {
                                     [self.delegate selectYourFeelingPopUpCloseAppplied];
                                 }
                             }
                         }];
    
}

-(IBAction)feelingSelectedBy:(UIButton*)sender{
    
    [UIView animateWithDuration:0.3/1.5 animations:^{
        sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            sender.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                sender.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (finished) {
                    if ([self.delegate respondsToSelector:@selector(feelingsSelectedWithEmotionType:)]) {
                        [self.delegate feelingsSelectedWithEmotionType:sender.tag];
                    }
                    [self closePopUp];
                    
                }
            }];
        }];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
