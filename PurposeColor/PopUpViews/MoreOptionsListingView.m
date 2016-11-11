//
//  CountryListView.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//





#define kCellHeight             50;
#define kHeightForHeader        50;
#define kNumberOfRaws           5;
#define kNumberOfSections       1;


#import "MoreOptionsListingView.h"
#import "Constants.h"

@implementation MoreOptionsListingView

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
    
    self.backgroundColor = [UIColor whiteColor];
    
    // Tableview Setup

    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    [self addSubview:tableView];
    self.clipsToBounds = YES;
    tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
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
    return kNumberOfSections;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return kNumberOfRaws;
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    
    [self configureCell:cell position:indexPath.row];
    cell.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    _tableView.separatorColor =  [UIColor lightGrayColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kCellHeight;
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[self delegate]selectedMenuFromMoreOptions:indexPath.row];
}


-(void)configureCell:(UITableViewCell*)cell position:(NSInteger)position{
    
    switch (position) {
        case eMyAccount:
            cell.textLabel.text = @"My Account";
            cell.imageView.image = [UIImage imageNamed:@"UserIcon.png"];
            break;
        case eMyOrder:
            cell.textLabel.text = @"My Orders";
            cell.imageView.image = [UIImage imageNamed:@"MyOrdersIcon.png"];
            break;

        case eShare:
            cell.textLabel.text = @"Share the App";
            cell.imageView.image = [UIImage imageNamed:@"ShareIcon.png"];
            break;

        case eHelp:
            cell.textLabel.text = @"Help center";
            cell.imageView.image = [UIImage imageNamed:@"PhoneIcon.png"];
            break;

        case eLogout:
            cell.textLabel.text = @"Logout";
            cell.imageView.image = [UIImage imageNamed:@"LogoutIcon.png"];
            break;

            
        default:
            break;
    }
}
#pragma mark - Common Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}


-(IBAction)closePopUp{
    
}
@end
