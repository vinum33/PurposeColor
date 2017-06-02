//
//  ForgotPasswordPopUp.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



#define kCellHeight   130;
#define kHeightForHeader 200;
#define kHeightForFooter 0.1;
#define StatusSucess 200


#import "HideAccntPopUp.h"
#import "Constants.h"



@implementation HideAccntPopUp

-(void)setUp{
    
    

    self.backgroundColor = [UIColor whiteColor];
    
    // Tableview Setup
    
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.allowsSelection = YES;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:tableView];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(tableView)]];
    
    
    
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
   
}



#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    UILabel *lblText;
    if (![[cell contentView] viewWithTag:1]) {
        lblText = [UILabel new];
        lblText.translatesAutoresizingMaskIntoConstraints = NO;
        lblText.tag = 1;
        [[cell contentView]addSubview:lblText];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblText]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblText)]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[lblText]-10-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblText)]];
    }else{
        lblText = (UILabel*)[[cell contentView] viewWithTag:1];
    }
   
    lblText.font = [UIFont fontWithName:CommonFontBold_New size:15];
    lblText.numberOfLines = 0;
    lblText.textAlignment = NSTextAlignmentLeft;
    lblText.textColor = [UIColor blackColor];
    
    if (indexPath.row == 0) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"Unhide Account \n\n Your hidden account will be activated again"];
        [attString addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:CommonFont_New size:13.0]
                          range:NSMakeRange(15, attString.length - 15)];
        
        lblText.attributedText = attString;
    }
    if (indexPath.row == 1) {
        lblText.text = @"Delete Account";
        
    }
    if (indexPath.row == 2) {
        lblText.text = @"Logout";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return 80;
    }
    return 50;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor whiteColor];
    
    UIView *vwHeaderTop = [UIView new];
    vwHeaderTop.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:vwHeaderTop];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwHeaderTop]-50-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwHeaderTop)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwHeaderTop]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwHeaderTop)]];
    vwHeaderTop.backgroundColor = [UIColor getThemeColor];
    
    UIImageView *imgDisplay = [UIImageView new];
    [vwHeader addSubview:imgDisplay];
    imgDisplay.translatesAutoresizingMaskIntoConstraints = NO;
    imgDisplay.clipsToBounds = YES;
    imgDisplay.layer.cornerRadius = 50.f;
    imgDisplay.backgroundColor = [UIColor blackColor];
    imgDisplay.contentMode = UIViewContentModeScaleAspectFill;
    [imgDisplay addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:100.0]];
    [imgDisplay addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:100.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:-20.0]];
    [vwHeader addConstraint:[NSLayoutConstraint constraintWithItem:imgDisplay
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:vwHeader
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    if ([User sharedManager].profileurl.length) {
        
        [imgDisplay sd_setImageWithURL:[NSURL URLWithString:[User sharedManager].profileurl]
                      placeholderImage:[UIImage imageNamed:@"UserProfilePic.png"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 
                             }];
    }
    
    return vwHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        [self unHideClicked];
    }
    if (indexPath.row == 1) {
        [self deleteClicked];
    }
    if (indexPath.row == 2) {
        [self logOutClicked];
    }
}


#pragma mark - Common Delegates

-(void)logOutClicked{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate clearUserSessions];

}

-(IBAction)unHideClicked{
    
    [self showLoadingScreen];
    [APIMapper enableUserAccountOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responds = (NSDictionary*)responseObject;
        if ( NULL_TO_NIL( [responds objectForKey:@"code"])) {
            NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
            if (statusCode == StatusSucess) {
                
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"ACCOUNT_ENABLED"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [delegate showLauchPage];
                [self removeFromSuperview];
                
            }
            else{
                
                if (responds && [responds objectForKey:@"text"]){
                    [self showAlertWithTitle:@"Unhide Account" message:[responds objectForKey:@"text"]];
                }
                
            }
        }
        
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self showAlertWithTitle:@"Unhide Account" message:@"Failed to unhide.Please try again later"];
        
        [self hideLoadingScreen];
    }];

    
}

-(IBAction)deleteClicked{
    
    [self showLoadingScreen];
    [APIMapper deleteOrHideMyAccountWithType:@"delete" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responds = (NSDictionary*)responseObject;
        if ( NULL_TO_NIL( [responds objectForKey:@"code"])) {
            NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
            if (statusCode == StatusSucess) {
                
                AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                [delegate clearUserSessions];

            }
            else{
                
                if (responds && [responds objectForKey:@"text"]){
                    [self showAlertWithTitle:@"Delete Account" message:[responds objectForKey:@"text"]];
                }
                
            }
        }
        
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         [self showAlertWithTitle:@"Delete Account" message:@"Failed to delete.Please try again later"];
        
         [self hideLoadingScreen];
    }];
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}



-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self animated:YES];
    
}



@end
