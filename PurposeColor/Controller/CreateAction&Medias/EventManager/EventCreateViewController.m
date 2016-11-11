//
//  EventCreateViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 26/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eTitle = 0,
    eDescription = 1,
    
} eReminderData;

typedef enum{
    
    eStartDate = 0,
    eEndDate = 1,
    eStartTime = 2,
    eEndTime = 3,
    
} PickerMode;

#define kCellHeight             390
#define kHeightForHeader        0
#define kHeightForFooter        .001
#define kNumberOfSections       1
#define kHeightPercentage       80
#define kDefaultCellCount       1


#define kPickerRows             5
#define kPickerSections         1
#define kPickerCellHeight       40
#define kPickerComponentWidth   100

#import "EventCreateViewController.h"
#import "CreateEventCustomCell.h"
#import "Constants.h"
#import <EventKit/EventKit.h>


@interface EventCreateViewController(){
    
    IBOutlet UITableView *tableView;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIPickerView *repeatValuePicker;
    IBOutlet UIPickerView *reminderValuePicker;
    IBOutlet UIView *bgDatePicker;
    IBOutlet NSLayoutConstraint *bottomConstraint;
    
    NSInteger indexForTextFieldNavigation;
    UIView *inputAccView;
    
    NSString *strTitle;
    NSString *strDescription;
    NSDate   *startDate;
    NSDate   *endDate;
    NSDate   *startTime;
    NSDate   *endTime;
    NSInteger reminderTime;
    NSString *repeatValue;
    
    PickerMode pickerMode;
    NSMutableArray *reminderPickerValues;
    NSArray *repeaterPickerValues;
}


@end

@implementation EventCreateViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUp];
    
    
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    reminderPickerValues = [NSMutableArray new];
    for (int i = 0; i <= 60; i ++) {
        [reminderPickerValues addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:i]]];
    }
    //reminderPickerValues = [NSArray arrayWithObjects:@"0",@"15",@"30",@"45",@"60", nil];
    repeaterPickerValues = [NSArray arrayWithObjects:@"Never",@"Daily",@"Weekly",@"Monthly",@"Yearly", nil];
    reminderTime = _reminderTime;
    repeatValue = _strRepeatValue;
    strTitle = _strGoalTitle;
    strDescription = _strGoalDescription;
    
    startDate = _startDate;
    startTime = _startTime;
    endDate = _endDate;
    endTime = _endTime;
    
    
}
#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return kDefaultCellCount;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CustomReminderCell";
    CreateEventCustomCell *cell = (CreateEventCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCellWith:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return kHeightForFooter;
}

#pragma mark - UITextfield delegate methods


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero
                                                  toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero
                                                  toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
         CreateEventCustomCell *cell = (CreateEventCustomCell*)textField.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:cell.txtTitle.tag data:textField.text];
        
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height );
    
    [tableView setContentOffset:contentOffset animated:YES];
    NSIndexPath *indexPath;
    if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textField convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    
    indexForTextFieldNavigation = indexPath.row;
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self createInputAccessoryView];
    [textField setInputAccessoryView:inputAccView];
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height );
    [tableView setContentOffset:contentOffset animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return true;
}

#pragma mark - UITextView delegate methods


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    [self createInputAccessoryView];
    [textView setInputAccessoryView:inputAccView];
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    NSIndexPath *indexPath;
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
    }
    indexForTextFieldNavigation = indexPath.row;
    contentOffset.y = (pointInTable.y - textView.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
    return YES;
    
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    CGPoint pointInTable = [textView.superview.superview convertPoint:textView.frame.origin toView:tableView];
    CGPoint contentOffset = tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textView.inputAccessoryView.frame.size.height);
    [tableView setContentOffset:contentOffset animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
    if ([textView.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        CGPoint buttonPosition = [textView convertPoint:CGPointZero toView: tableView];
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:buttonPosition];
        CreateEventCustomCell *cell = (CreateEventCustomCell*)textView.superview.superview;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
        [self getTextFromField:cell.txtDescrption.tag data:textView.text];
    }
    return YES;
}

#pragma mark - Data Access methods

-(void)gotoPrevTextfield{
    
    if (indexForTextFieldNavigation - 1 < 0) indexForTextFieldNavigation = 0;
    else indexForTextFieldNavigation -= 1;
    [self gotoTextField];
    
}

-(void)gotoNextTextfield{
    
    if (indexForTextFieldNavigation + 1 < 2) indexForTextFieldNavigation += 1;
    [self gotoTextField];
}

-(void)gotoTextField{
    
    CreateEventCustomCell *nextCell = (CreateEventCustomCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (!nextCell) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        nextCell = (CreateEventCustomCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
    }
    if (indexForTextFieldNavigation == 0) {
        [nextCell.txtTitle becomeFirstResponder];
    }else{
        [nextCell.txtDescrption becomeFirstResponder];
    }
}

-(void)getTextFromField:(NSInteger)type data:(NSString*)string{
    
    switch (type) {
        case eTitle:
            strTitle = string;
            break;
        case eDescription:
            strDescription = string;
            break;
        default:
            break;
    }
    
}


-(void)doneTyping{
    [self.view endEditing:YES];
    
}



#pragma mark - Cell Customization  Methods

-(void)configureCellWith:(CreateEventCustomCell*)cell{
    
    [cell.btnStatDate addTarget:self action:@selector(showStartDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnEndDate addTarget:self action:@selector(showEndDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnStartTime addTarget:self action:@selector(showStartTimePicker) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnEndTime addTarget:self action:@selector(showEndTimePicker) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnReminderTime addTarget:self action:@selector(showReminderPicker) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnRepeater addTarget:self action:@selector(showRepeatingMode) forControlEvents:UIControlEventTouchUpInside];
    cell.txtTitle.text = _strGoalTitle;
    cell.txtDescrption.text = _strGoalDescription;
    [cell.txtDescrption setClipsToBounds:YES];
    cell.txtTitle.tag = 0;
    cell.txtDescrption.tag = 1;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    cell.txtTitle.leftView = paddingView;
    cell.txtTitle.leftViewMode = UITextFieldViewModeAlways;

   // [cell.txtDescrption setContentOffset:CGPointZero animated:NO];

    
    if (endTime){
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"];
        [cell.btnEndTime setSelected:false];
        [cell.btnEndTime setTitle:[outputFormatter stringFromDate:endTime] forState: UIControlStateNormal];
    }
    
    if (startTime){
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"];
        [cell.btnStartTime setSelected:false];
        [cell.btnStartTime setTitle:[outputFormatter stringFromDate:startTime] forState: UIControlStateNormal];
    }
    
    if (startDate){
        
         NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd-MM-yyyy"];
        [cell.btnStatDate setSelected:false];
        [cell.btnStatDate setTitle:[df stringFromDate:startDate] forState: UIControlStateNormal];
    }
    
    if (endDate){
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd-MM-yyyy"];
        [cell.btnEndDate setSelected:false];
        [cell.btnEndDate setTitle:[df stringFromDate:endDate] forState: UIControlStateNormal];
    }
    
    if (repeatValue.length){
        [cell.btnRepeater setSelected:false];
        [cell.btnRepeater setTitle:[NSString stringWithFormat:@"%@",repeatValue] forState: UIControlStateNormal];
    }
    
    [cell.btnReminderTime setSelected:false];
    if (reminderTime == 60)
        [cell.btnReminderTime setTitle:[NSString stringWithFormat:@"Remind Before 1 Hour"] forState: UIControlStateNormal];
    else if (reminderTime > 0){
        NSString *title = [NSString stringWithFormat:@"Remind Before %ld Minutes",(long)reminderTime];
        [cell.btnReminderTime setTitle:title forState: UIControlStateNormal];
    }else{
        NSString *title = [NSString stringWithFormat:@"On Time"];
        [cell.btnReminderTime setTitle:title forState: UIControlStateNormal];
    }
   
}

-(IBAction)showStartDatePicker{
   
    datePicker.enabled = true;
    datePicker.hidden = false;
    reminderValuePicker.hidden = true;
    pickerMode = eStartDate;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [NSDate date];
    repeatValuePicker.hidden = true;
    [self showPickerWithAnimationWantsToShow:YES];
}

-(IBAction)showEndDatePicker{
    
    datePicker.enabled = true;
    datePicker.hidden = false;
    reminderValuePicker.hidden = true;
    pickerMode = eEndDate;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [NSDate date];
    repeatValuePicker.hidden = true;
    [self showPickerWithAnimationWantsToShow:YES];
    
}

-(IBAction)showStartTimePicker{
    
    datePicker.enabled = true;
    datePicker.hidden = false;
    reminderValuePicker.hidden = true;
    pickerMode = eStartTime;
     repeatValuePicker.hidden = true;
    datePicker.datePickerMode = UIDatePickerModeTime;
   [self showPickerWithAnimationWantsToShow:YES];

}

-(IBAction)showEndTimePicker{
   
    datePicker.enabled = true;
    datePicker.hidden = false;
    reminderValuePicker.hidden = true;
    pickerMode = eEndTime;
     repeatValuePicker.hidden = true;
    datePicker.datePickerMode = UIDatePickerModeTime;
    [self showPickerWithAnimationWantsToShow:YES];
    
}

-(IBAction)showReminderPicker{
    
     datePicker.enabled = false;
     reminderValuePicker.hidden = false;
     datePicker.hidden = true;
     repeatValuePicker.hidden = true;
     [self showPickerWithAnimationWantsToShow:YES];
}

-(IBAction)showRepeatingMode{
    
    datePicker.enabled = false;
    reminderValuePicker.hidden = true;
    datePicker.hidden = true;
    repeatValuePicker.hidden = false;
    [self showPickerWithAnimationWantsToShow:YES];
}



-(IBAction)hideDatePicker{
  
    if ([datePicker isEnabled]) {
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"h:mm a"];
        switch (pickerMode) {
            case eStartDate:
                startDate = datePicker.date;
                break;
                
            case eEndDate:
                endDate = datePicker.date;
                break;
                
            case eStartTime:
                startTime = datePicker.date;
                break;
                
            case eEndTime:
                endTime = datePicker.date;
                break;
                
            default:
                break;
        }

    }
    
    [self showPickerWithAnimationWantsToShow:NO];
    [tableView reloadData];
}

-(void)showPickerWithAnimationWantsToShow:(BOOL)wantsToShow{
    
    [self.view endEditing:YES];
    [self.view layoutIfNeeded];
    if (wantsToShow)
        bottomConstraint.constant = 5;
    else
        bottomConstraint.constant = -205;
    
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];

}


-(IBAction)createReminder:(id)sender{
    
    
    if (!startDate || !startTime || !endTime || !endDate || !strTitle || !strDescription || reminderTime < 0 || !repeatValue) {
        [ALToastView toastInView:self.view withText:@"Please fill all the Fields"];
        return;
    }
    
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:_achievementDate];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strToday = [dateFormatter  stringFromDate:refDate];// string with yyyy-MM-dd format
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [dateFormatter dateFromString:strToday];
    NSDate *combinedStartDate = [Utility combineDate:startDate withTime:startTime];
    NSDate *combinedEndDate =  [Utility combineDate:endDate withTime:endTime];
    
    
    if ([endDate compare:dateFromString] == NSOrderedDescending ) {
        // NSLog(@"date1 is later than date2");
      //  [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"End Date should be less than %@",strToday]];
        //return;
        
    }
    
    if ([startDate compare:endDate] == NSOrderedDescending) {
        // NSLog(@"date1 is later than date2");
       // [ALToastView toastInView:self.view withText:@"Action Start Date should be less Action End Date"];
       // return;
        
    }
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
   // NSString *strtdate = [dateFormatter stringFromDate:startDate];
   // NSString *enddate = [dateFormatter stringFromDate:endDate];
    
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString *strttime = [dateFormatter stringFromDate:startTime];
    NSString *endtime = [dateFormatter stringFromDate:endTime];
    
    [self showLoadingScreen];
    [APIMapper createNewReminderForActionWithActionID:_goalID title:strTitle descrption:strDescription startDate:[combinedStartDate timeIntervalSince1970] endDate:[combinedEndDate timeIntervalSince1970] startTime:strttime endTime:endtime actionAlert:reminderTime userID:[User sharedManager].userId repeatValue:repeatValue success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self hideLoadingScreen];
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Reminder"
                                      message:@"Reminder created successfully."
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self goBack:nil];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         [self hideLoadingScreen];
        
    }];
    
    
    NSDate *startDateAndTime = [self combineDate:startDate withTime:startTime];
    NSDate *endDateAndTime = [self combineDate:endDate withTime:endTime];
    
    EKEventStore *store = [EKEventStore new];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) {return; }
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = strTitle;
        event.notes = strDescription;
        event.startDate = startDateAndTime;
        event.endDate =  [startDateAndTime dateByAddingTimeInterval:3600];
        event.allDay = NO;
        [event addAlarm:[EKAlarm alarmWithRelativeOffset:-(reminderTime * 60)]];
        event.calendar = [store defaultCalendarForNewEvents];
        if (![repeatValue isEqualToString:@"Never"]) {
            EKRecurrenceRule *rule;
            if ([repeatValue isEqualToString:@"Daily"]) {
                rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 end:[EKRecurrenceEnd recurrenceEndWithEndDate:endDateAndTime]];
            }
            else if ([repeatValue isEqualToString:@"Weekly"]) {
                rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 end:[EKRecurrenceEnd recurrenceEndWithEndDate:endDateAndTime]];
            }
            else if ([repeatValue isEqualToString:@"Monthly"]) {
                rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 end:[EKRecurrenceEnd recurrenceEndWithEndDate:endDateAndTime]];
            }else if ([repeatValue isEqualToString:@"Yearly"]) {
                rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 end:[EKRecurrenceEnd recurrenceEndWithEndDate:endDateAndTime]];
            }
            [event addRecurrenceRule:rule];
        }
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ALToastView toastInView:self.view withText:@"Calendar Event created"];
            
            UIAlertController * alert=   [UIAlertController
                                          alertControllerWithTitle:@"Reminder"
                                          message:@"Reminder created successfully."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [self goBack:nil];
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
            
        });
        
    }];
}

- (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:
                             NSCalendarIdentifierGregorian];
    
    unsigned unitFlagsDate = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [gregorian components:unitFlagsDate
                                                    fromDate:date];
    unsigned unitFlagsTime = NSCalendarUnitHour | NSCalendarUnitMinute |  NSCalendarUnitSecond;
    
    NSDateComponents *timeComponents = [gregorian components:unitFlagsTime
                                                    fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [gregorian dateFromComponents:dateComponents];   
    
    return combDate;
}

#pragma mark - Picker delegates

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    if (pickerView == reminderValuePicker){
        return 2;
    }
    return kPickerSections;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (pickerView == reminderValuePicker){
        if (component == 0) {
            return  reminderPickerValues.count;
        }
        return 1;
    }
    return kPickerRows;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
   
    NSString *title;
    
    if (component == 1) {
        return @"Minutes before";
    }
    
    if (pickerView == reminderValuePicker) {
        if (row < reminderPickerValues.count) {
            title = [reminderPickerValues objectAtIndex:row];
        }
    }else{
        
        if (row < repeaterPickerValues.count) {
            title = [repeaterPickerValues objectAtIndex:row];
        }
    }
    
    return title;

}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if (pickerView == reminderValuePicker) {
        if (component == 1) {
            return;
        }
        if (row < reminderPickerValues.count) {
            reminderTime = [[reminderPickerValues objectAtIndex:row] integerValue];
        }
    }else{
        
        if (row < repeaterPickerValues.count) {
            repeatValue = [repeaterPickerValues objectAtIndex:row];
        }
    }
   
    [tableView reloadData];
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component ;{
    
    if (pickerView == reminderValuePicker){
        if (component == 0) {
            return 100;
        }
        return 200;
    }
    else if (pickerView == repeatValuePicker){
         return 200;
    }
    return kPickerComponentWidth;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return kPickerCellHeight;
    
}

-(void)createInputAccessoryView{
    
    inputAccView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 40.0)];
    [inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    [inputAccView setAlpha: 1];
    
    UIButton *btnPrev = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnPrev setFrame: CGRectMake(0.0, 0.0, 80.0, 40.0)];
    [btnPrev setTitle: @"PREVIOUS" forState: UIControlStateNormal];
    [btnPrev setBackgroundColor: [UIColor getHeaderOffBlackColor]];
    [btnPrev addTarget: self action: @selector(gotoPrevTextfield) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *btnNext = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNext setFrame:CGRectMake(85.0f, 0.0f, 80.0f, 40.0f)];
    [btnNext setTitle:@"NEXT" forState:UIControlStateNormal];
    [btnNext setBackgroundColor:[UIColor getHeaderOffBlackColor]];
    [btnNext addTarget:self action:@selector(gotoNextTextfield) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setFrame:CGRectMake(inputAccView.frame.size.width - 85, 1.0f, 80.0f, 38.0f)];
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor getThemeColor]];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    btnPrev.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    btnNext.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    btnDone.titleLabel.font = [UIFont fontWithName:CommonFont size:14];
    
    [inputAccView addSubview:btnPrev];
    [inputAccView addSubview:btnNext];
    [inputAccView addSubview:btnDone];
}

-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}


-(IBAction)goBack:(id)sender{
    
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
