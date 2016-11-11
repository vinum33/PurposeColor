//
//  EmotionSessionLists.m
//  PurposeColor
//
//  Created by Purpose Code on 12/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eAll = 0,
    eMorning = 1,
    eAfterNoon = 2,
    eEvening = 3,
    eNight = 4,
    
} eSessionType;

#define kSectionCount                   1
#define kCellCount                      5
#define kDefaultCellHeight              40

#import "EmotionSessionLists.h"
#import "Constants.h"

@interface EmotionSessionLists(){
    
    IBOutlet NSLayoutConstraint *constraintForRight;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIView *vwPickerOverLay;
    IBOutlet UILabel *lblDateFrom;
    IBOutlet UILabel *lblDateTo;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UITableView *tableView;
    BOOL isFromDate;
    NSDate *dateFrom;
    NSDate *dateTo;
    
    NSInteger sessionValue;
    NSString *strStartDate;
    NSString *strEndDate;
    
}

@end

@implementation EmotionSessionLists


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    
    // Drawing code
}

-(void)setUpInitialValuesWithActiveValue:(NSInteger)_sessionValue startDate:(NSString*)strDate endDate:(NSString*)_strEndDate{
    
    if (strDate){
        strStartDate = strDate;
        lblDateFrom.text = strStartDate;
    }
    if (_strEndDate) {
        strEndDate = _strEndDate;
        lblDateTo.text = strEndDate;
    }
    sessionValue = _sessionValue;
    vwPickerOverLay.hidden = true;
    vwPickerOverLay.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.5];
    [datePicker addTarget:self action:@selector(getSelectedDate) forControlEvents:UIControlEventValueChanged];
    [datePicker setMaximumDate: [NSDate date]];
    _vwContainer.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.6];
    [tableView reloadData];
    _vwContainer.hidden = true;
    constraintForRight.constant = 0.0f;
    _vwContainer.hidden = false;
    btnSubmit.layer.cornerRadius = 5.f;
    btnSubmit.layer.borderWidth = 1.f;
    btnSubmit.layer.borderColor = [UIColor clearColor].CGColor;
    [UIView animateWithDuration:0.5f animations:^{
        [self layoutIfNeeded];
        
    }];
    
}



#pragma mark - Date Methods

-(IBAction)showDatePicker:(UIButton*)sender{
    
    isFromDate = false;
    if (sender.tag == 1) {
        isFromDate = true;
    }
    vwPickerOverLay.hidden = false;
    [self getSelectedDate];
}



-(IBAction)hidePicker:(id)sender{
    vwPickerOverLay.hidden = true;
}

-(IBAction)getSelectedDate{
    
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"yyyy-MM-dd"];
    if (isFromDate) {
        dateFrom = datePicker.date;
        lblDateFrom.text = [dateformater stringFromDate:datePicker.date];
        strStartDate = [dateformater stringFromDate:datePicker.date];
    }else{
        dateTo = datePicker.date;
        lblDateTo.text = [dateformater stringFromDate:datePicker.date];
        strEndDate = [dateformater stringFromDate:datePicker.date];
    }
    
}

-(IBAction)applyFilter:(id)sender{
    
        if ([dateFrom compare:dateTo] == NSOrderedDescending) {
            // NSLog(@"date1 is later than date2");
            [ALToastView toastInView:self withText:@"FromDate should be less than ToDate"];
            return;
            
        } else if ([dateFrom compare:dateTo] == NSOrderedAscending) {
            // NSLog(@"date1 is earlier than date2");
            [self sendSelection];
        } else {
            [self sendSelection];
            //NSLog(@"dates are the same");
        }
    
    
}

-(void)sendSelection{
    
    if ([self.delegate respondsToSelector:@selector(filterAppliedWithStartDate:endDate:sessionValue:)]) {
        [self.delegate filterAppliedWithStartDate:strStartDate endDate:strEndDate sessionValue:sessionValue];
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
       return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{

    return kCellCount;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
    cell.textLabel.textColor = [UIColor colorWithRed:0.67 green:0.67 blue:0.67 alpha:1.0];
    cell.imageView.image = [UIImage imageNamed:@"Radio_InActive.png"];
    if (indexPath.row == sessionValue)cell.imageView.image = [UIImage imageNamed:@"Radio_Active.png"];
    switch (indexPath.row) {
        case eAll:
             cell.textLabel.text = @"All";
            break;
        case eMorning:
            cell.textLabel.text = @"Morning";
            break;
        case eAfterNoon:
            cell.textLabel.text = @"Afternoon";
            break;
        case eEvening:
            cell.textLabel.text = @"Evening";
            break;
        case eNight:
            cell.textLabel.text = @"Night";
            break;
            
        default:
            break;
    }
   
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
       return  kDefaultCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    sessionValue = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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
                    [tableView reloadData];
                }
            }];
        }];
    }];

   
}


-(IBAction)closePopUp:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(closeSessionPopUp)]) {
        [self.delegate closeSessionPopUp];
    }
    
}


@end
