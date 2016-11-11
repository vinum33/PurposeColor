//
//  CountryListView.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


#define kCellHeight   40;
#define kHeightForHeader 50;


#import "StateListViewPopUp.h"
#import "Constants.h"

@implementation StateListViewPopUp

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setUp{
    
    [self loadUI];
}

-(void)loadUI{
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    // Tableview Setup
    
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    [self addSubview:tableView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[tableView]-80-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[tableView]-30-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // Tap Gesture SetUp
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
}



#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_arrStates count];    //count number of row from counting array hear cataGorry is An Array
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
    if (indexPath.row < _arrStates.count) {
        
        NSDictionary *state = [_arrStates objectAtIndex:indexPath.row];
        if ([stateID isEqualToString:[state objectForKey:@"company_id"]]) {
             cell.imageView.image = [UIImage imageNamed:@"CheckMark.png"];
        }
        if (state && [state objectForKey:@"company_location"])
             cell.textLabel.text = [state objectForKey:@"company_location"];
        
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
    lblTitle.text = @"Choose Your State";
    lblTitle.font = [UIFont fontWithName:CommonFont size:16];
    lblTitle.textColor = [UIColor whiteColor];
    
    return vwHeader;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < _arrStates.count) {
        NSDictionary *state = [_arrStates objectAtIndex:indexPath.row];
        if (state){
            stateID = [state objectForKey:@"company_id"];
            [tableView reloadData];
             [[self delegate]updateStateDetailsToBackEnd:state withUserID:_userID];
        }
    }
    float delay = .5;
    [[self delegate]closeStateListingPopUpAfterADelay:delay];
}

#pragma mark - Common Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}


-(IBAction)closePopUp{
    
    [[self delegate]closeStateListingPopUpAfterADelay:0];
}
@end
