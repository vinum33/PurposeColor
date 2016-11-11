//
//  CountryListView.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


#define kCellHeight   40;
#define kHeightForHeader 50;


#import "CountryListView.h"
#import "Constants.h"

@implementation CountryListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUp{
    
    [self loadUI];
    [self loadAllCountries];
}

-(void)loadUI{
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    // Tableview Setup
    
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    [self addSubview:tableView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[tableView]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[tableView]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    
    // Tap Gesture SetUp
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
}

-(void)loadAllCountries{
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Add code here to do background processing
        //
        arrCountries = [NSMutableArray new];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"CountryList" ofType:@"txt"];
        NSString *countryJSON = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
        NSData *jsonData = [countryJSON dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        NSDictionary *country = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
        
        if ( NULL_TO_NIL([country objectForKey:@"resultarray"])) {
            NSDictionary *result = [country objectForKey:@"resultarray"];
            for (NSDictionary *dict in result) {
                [arrCountries addObject:dict];
            }
            
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            [tableView reloadData];
            if (_selectedCountryID.length) {
                NSInteger index = [_selectedCountryID intValue];
                if (index < arrCountries.count) 
                    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
        });
    });

}


#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [arrCountries count];    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:MyIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:@"UnCheckMark.png"];
    if (indexPath.row < arrCountries.count) {
        
        NSDictionary *country = [arrCountries objectAtIndex:indexPath.row];
        if ( NULL_TO_NIL( [country objectForKey:@"name"])) {
             cell.textLabel.text = [country objectForKey:@"name"];
        }
        if (_selectedCountryID == [country objectForKey:@"id"]) cell.imageView.image = [UIImage imageNamed:@"CheckMark.png"];
        
    }
   
    cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor getThemeColor];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    lblTitle.text = @"CHOOSE YOUR COUNTRY";
    lblTitle.font = [UIFont fontWithName:CommonFont size:16];
    lblTitle.textColor = [UIColor whiteColor];
    
    return vwHeader;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrCountries.count) {
        NSDictionary *country = [arrCountries objectAtIndex:indexPath.row];
        if (country)
            [[self delegate]sendSelectedCountryDetailsToRegisterPage:country];
           _selectedCountryID = [country objectForKey:@"id"];
    }
    [tableView reloadData];
    float delay = .5;
    
    [[self delegate]closeCountryPopUpAfterADelay:delay];
}

#pragma mark - Common Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}


-(IBAction)closePopUp{
    
    [[self delegate]closeCountryPopUpAfterADelay:0];
}
@end
