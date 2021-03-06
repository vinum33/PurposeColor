//
//  SelectYourFeel.m
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "SelectYourFeel.h"
#import "Constants.h"

@interface SelectYourFeel (){
    
    IBOutlet NSLayoutConstraint *rightConstraint;
        IBOutlet UITableView *tableView;
}



@end

@implementation SelectYourFeel

-(void)showSelectionPopUp{
    
    [self setUp];
    [self layoutIfNeeded];
    rightConstraint.constant = 0;
    [UIView animateWithDuration:.8
                     animations:^{
                         [self layoutIfNeeded]; // Called on parent view
                     }completion:^(BOOL finished) {
                         
                     }];
}

-(void)setUp{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [tapGesture setNumberOfTapsRequired:1];
    //[self addGestureRecognizer:tapGesture];
    

}

-(IBAction)closePopUp{
    
    [self layoutIfNeeded];
    rightConstraint.constant = 500;
    [UIView animateWithDuration:.8
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:CommonFont_New size:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = true;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;

    if (indexPath.row == 4) {
        cell.textLabel.text = @"Strongly Disagree";
        cell.imageView.image = [UIImage imageNamed:@"1_Star"];
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = @"Dis Agree";
        cell.imageView.image = [UIImage imageNamed:@"2_Star"];
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"Neutral";
        cell.imageView.image = [UIImage imageNamed:@"3_Star"];
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"Agree";
        cell.imageView.image = [UIImage imageNamed:@"4_Star"];
    }
    else if (indexPath.row == 0) {
        cell.textLabel.text = @"Strongly Agree";
        cell.imageView.image = [UIImage imageNamed:@"5_Star"];
    }

    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return tableView.frame.size.height / 5;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3/1.5 animations:^{
        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                cell.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                if (finished) {
                    if ([self.delegate respondsToSelector:@selector(feelingsSelectedWithEmotionType:)]) {
                        [self.delegate feelingsSelectedWithEmotionType:indexPath.row];
                    }
                    [self closePopUp];
                }
            }];
        }];
    }];

    
    
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
