//
//  ForgotPasswordPopUp.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



#define kCellHeight   130;
#define kHeightForHeader 30;
#define kHeightForFooter 150;
#define kHeightForTable 410
#define kWidthForTable 300

#define StatusSucess 200


#import "DeleteAccntPopUp.h"
#import "Constants.h"
#import "HideAccntPopUp.h"

@interface DeleteAccntPopUp (){
    
    HideAccntPopUp *hideAccntPopUp;
}

@end

@implementation DeleteAccntPopUp

-(void)setUp{
    
    

    self.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.6];
    
    // Tableview Setup
    
    tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.allowsSelection = NO;
    tableView.layer.cornerRadius = 5.f;
    tableView.layer.borderWidth = 1.f;
    tableView.layer.borderColor = [UIColor clearColor].CGColor;
    tableView.backgroundColor = [UIColor whiteColor];
    [self addSubview:tableView];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
    
    NSLayoutConstraint *yValueForTable = [NSLayoutConstraint constraintWithItem:tableView
                                                  attribute:NSLayoutAttributeCenterY
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeCenterY
                                                 multiplier:1.0
                                                   constant:0.0];
    
    [self addConstraint:yValueForTable];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:kWidthForTable]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                  attribute:NSLayoutAttributeHeight
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:nil
                                                  attribute:NSLayoutAttributeHeight
                                                 multiplier:1.0
                                                   constant:kHeightForTable]];
    
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    // Tap Gesture SetUp
}



#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    cell.textLabel.font = [UIFont fontWithName:CommonFont_New size:14];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed:0.40 green:0.40 blue:0.40 alpha:1.0];
    cell.textLabel.text = @"If you delete your account, you will lose your profile, goals, journal entries and all other contents permanently.This cannot be undone.\n\nIf you\'d rather keep your account but unpublish the contents from your account you can hide your account instead. You can reactivate the account later.\n\nAre you sure you want to delete your account? \n";
    
       return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *vwHeader = [UIView new];
    vwHeader.backgroundColor = [UIColor whiteColor];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [vwHeader addSubview:lblTitle];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [vwHeader addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    lblTitle.text = @"Are you sure?";
    lblTitle.font = [UIFont fontWithName:CommonFontBold size:14];
    lblTitle.textColor = [UIColor blackColor];
    
    return vwHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kHeightForHeader;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *vwFooter = [UIView new];
    vwFooter.backgroundColor = [UIColor clearColor];
    
    UIButton *btnHide = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwFooter addSubview:btnHide];
    btnHide.translatesAutoresizingMaskIntoConstraints = NO;
    [btnHide addTarget:self action:@selector(hideClicked)
    forControlEvents:UIControlEventTouchUpInside];
    btnHide.layer.borderColor = [UIColor clearColor].CGColor;
    btnHide.titleLabel.font = [UIFont fontWithName:CommonFontBold size:14];
    [btnHide setTitle:@"HIDE MY ACCOUNT" forState:UIControlStateNormal];
    [btnHide setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
    [btnHide setBackgroundColor:[UIColor clearColor]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btnHide]-100-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnHide)]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btnHide]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnHide)]];
    btnHide.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    btnHide.layer.borderWidth = 0.5f;
    
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, 300, 55)];
    [vwFooter addSubview:gradientView];
    UIColor *topColor = [UIColor getThemeColor];
    UIColor * bottomColor = [UIColor colorWithRed:0.01 green:0.89 blue:1.00 alpha:1.0];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.frame;
    gradient.colors = [NSArray arrayWithObjects:(id)topColor.CGColor, (id)bottomColor.CGColor, nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:0.7], nil];
    [gradientView.layer addSublayer:gradient];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwFooter addSubview:btnDelete];
    btnDelete.translatesAutoresizingMaskIntoConstraints = NO;
    [btnDelete addTarget:self action:@selector(deleteClicked)
      forControlEvents:UIControlEventTouchUpInside];
    btnDelete.layer.borderColor = [UIColor clearColor].CGColor;
    btnDelete.titleLabel.font = [UIFont fontWithName:CommonFontBold size:14];
    [btnDelete setTitle:@"DELETE MY ACCOUNT" forState:UIControlStateNormal];
    [btnDelete setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-50-[btnDelete]-50-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnDelete)]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btnDelete]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnDelete)]];
    
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [vwFooter addSubview:btnCancel];
    btnCancel.translatesAutoresizingMaskIntoConstraints = NO;
    [btnCancel addTarget:self action:@selector(cancelClicked)
        forControlEvents:UIControlEventTouchUpInside];
    btnCancel.layer.borderColor = [UIColor clearColor].CGColor;
    btnCancel.titleLabel.font = [UIFont fontWithName:CommonFontBold size:14];
    [btnCancel setTitle:@"CANCEL" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[btnCancel]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnCancel)]];
    [vwFooter addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btnCancel]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btnCancel)]];
    btnCancel.backgroundColor = [UIColor clearColor];
   
    
    
    return vwFooter;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return kHeightForFooter;
}




#pragma mark - Common Delegates

-(IBAction)hideClicked{
    
    [self showLoadingScreen];
    [APIMapper deleteOrHideMyAccountWithType:@"hide" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responds = (NSDictionary*)responseObject;
        if ( NULL_TO_NIL( [responds objectForKey:@"code"])) {
            NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
            if (statusCode == StatusSucess) {
                
                 [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"ACCOUNT_ENABLED"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                [self showHideAccountPopUp];
                [self showAlertWithTitle:@"Hide Account" message:[responds objectForKey:@"text"]];
                
            }
            else{
                
                if (responds && [responds objectForKey:@"text"]){
                    [self showAlertWithTitle:@"Hide Account" message:[responds objectForKey:@"text"]];
                }
                
            }
        }
        
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self showAlertWithTitle:@"Hide Account" message:@"Failed to hide try again later"];
        
        [self hideLoadingScreen];
    }];

}

-(IBAction)deleteClicked{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nav = delegate.navGeneral;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Account"
                                                                   message:@"Are you sure want to delete your account?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              
                                                              [self showLoadingScreen];
                                                              [APIMapper deleteOrHideMyAccountWithType:@"delete" success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                  
                                                                  NSDictionary *responds = (NSDictionary*)responseObject;
                                                                  if ( NULL_TO_NIL( [responds objectForKey:@"code"])) {
                                                                      NSInteger statusCode = [[responds objectForKey:@"code"] integerValue];
                                                                      if (statusCode == StatusSucess) {
                                                                          
                                                                          [self closePopUp];
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
                                                          }];
    
    UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    
    [alert addAction:firstAction];
    [alert addAction:second];
    [nav presentViewController:alert animated:YES completion:nil];

    
    
}

-(IBAction)cancelClicked{
     [self closePopUp];
}


#pragma mark - Forgot Password Methods and Delegates


-(IBAction)showHideAccountPopUp{
    
    if (!hideAccntPopUp) {
        
        hideAccntPopUp = [HideAccntPopUp new];
        [self addSubview:hideAccntPopUp];
        hideAccntPopUp.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[hideAccntPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(hideAccntPopUp)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[hideAccntPopUp]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(hideAccntPopUp)]];
        hideAccntPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            // animate it to the identity transform (100% scale)
            hideAccntPopUp.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            // if you want to do something once the animation finishes, put it here
        }];
        
        
    }
    
    [hideAccntPopUp setUp];
}



-(void)closeForgotPwdPopUp{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        hideAccntPopUp.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [hideAccntPopUp removeFromSuperview];
        hideAccntPopUp = nil;
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


-(IBAction)closePopUp{
    
    [[self delegate]closeForgotPwdPopUp];
    
}

@end
