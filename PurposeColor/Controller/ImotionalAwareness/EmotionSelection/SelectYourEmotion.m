//
//  SelectYourFeel.m
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

typedef enum{
    
    eActionAdd = 1,
    eActionEdit = 2,
    eActionDelete = 3,
    
}eAction;


#define kTagForTextField                1
#define kCellMinimumCount               1
#define kHeightForHeader                60
#define kSectionCount                   1
#define kPadding                        60
#define kHeightForFooter                0.1
#define kSuccessCode                    200
#define kTabHeight                      0

#import "SelectYourEmotion.h"
#import "Constants.h"
#import "ButtonWithID.h"

@interface SelectYourEmotion () <UITextFieldDelegate,UISearchBarDelegate>{
    
    IBOutlet NSLayoutConstraint *rightConstraint;
    IBOutlet UITableView *tableView;
    UISearchBar *searchBar;
    IBOutlet UIButton *btnSearch;
    BOOL isDataAvailable;
    UIView *containerView;
    UITextField *txtField;
    NSMutableArray *arrDataSource;
    NSMutableArray *arrFiltered;
    
    eAction actionType;
    NSString *strSelectedTitle;
    NSInteger selectedEmotionID;
    NSInteger objectIndex;
    
}

@end

@implementation SelectYourEmotion

-(void)showSelectionPopUp{
    
    [self getAllEmotions];
    [self setUp];
    
}

-(void)setUp{
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width - 50, 44)];
    [searchBar setShowsCancelButton:YES];
    searchBar.delegate = self;
    
    UIView *headerView = [[UIView alloc] initWithFrame:searchBar.frame];
    [headerView addSubview:searchBar];
    tableView.tableHeaderView = headerView;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    UIButton *cancelButton = [searchBar valueForKey:@"_cancelButton"];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)getAllEmotions{
    
    [self showLoadingScreen];
    [APIMapper getAllEmotionsWithUserID:[User sharedManager].userId emotionValue:_emotionaValue success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showAllEmotionsWith:responseObject];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self withText:NETWORK_ERROR_MESSAGE];
        [self hideLoadingScreen];
    }];
    
}

-(void)showAllEmotionsWith:(NSDictionary*)dictEmotions{
    
    if (NULL_TO_NIL([dictEmotions objectForKey:@"resultarray"]))
       arrDataSource = [NSMutableArray arrayWithArray:[dictEmotions objectForKey:@"resultarray"]];
    arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
    if (arrFiltered.count > 0) isDataAvailable = true;
    [tableView reloadData];
    [self layoutIfNeeded];
    rightConstraint.constant = 0;
    [UIView animateWithDuration:.8
                     animations:^{
                         [self layoutIfNeeded]; // Called on parent view
                     }];
    
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable)return kCellMinimumCount;
    return arrFiltered.count;
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
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = true;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Emotions Available."];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = false;
        cell.textLabel.textColor = [UIColor whiteColor];
        if ([[cell contentView] viewWithTag:100]) {
            UIButton *btnRecent = (UIButton*) [[cell contentView] viewWithTag:100] ;
            btnRecent.hidden = true;
        }
        if ([[cell contentView] viewWithTag:101]) {
            UIButton *btnRecent = (UIButton*) [[cell contentView] viewWithTag:101] ;
            btnRecent.hidden = true;
        }
        return cell;
    }
    UIButton *btnRecent;
    if (![[cell contentView] viewWithTag:100]) {
        btnRecent = [UIButton buttonWithType:UIButtonTypeCustom];
        btnRecent.translatesAutoresizingMaskIntoConstraints = NO;
        [btnRecent setTitle:@"Recent" forState:UIControlStateNormal];
        btnRecent.titleLabel.font = [UIFont fontWithName:CommonFont size:12];
        [btnRecent setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
        btnRecent.backgroundColor = [UIColor clearColor];
        btnRecent.tag = 100;
        btnRecent.hidden = true;
        btnRecent.titleEdgeInsets = UIEdgeInsetsMake(3,0, 0, 0);
        [[cell contentView] addSubview:btnRecent];
        [btnRecent addConstraint:[NSLayoutConstraint constraintWithItem:btnRecent
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:20]];
        [btnRecent addConstraint:[NSLayoutConstraint constraintWithItem:btnRecent
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:50]];
        [[cell contentView] addConstraint:[NSLayoutConstraint constraintWithItem:btnRecent
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:[cell contentView]
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-10]];
        [[cell contentView] addConstraint:[NSLayoutConstraint constraintWithItem:btnRecent
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:[cell contentView]
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0]];
        btnRecent.layer.borderColor = [UIColor getThemeColor].CGColor;
        btnRecent.layer.borderWidth = 1.0;
        btnRecent.layer.cornerRadius = 5.f;
    }else{
        btnRecent = [[cell contentView] viewWithTag:100] ;
        btnRecent.hidden = true;
    }
    
    ButtonWithID *btnMore;
    if (![[cell contentView] viewWithTag:101]) {
        btnMore = [ButtonWithID buttonWithType:UIButtonTypeCustom];
        btnMore.translatesAutoresizingMaskIntoConstraints = NO;
        btnMore.backgroundColor = [UIColor clearColor];
        btnMore.tag = 101;
        btnMore.hidden = true;
        btnMore.alpha = 0.5;
        [btnMore setImage:[UIImage imageNamed:@"More_Icon.png"] forState:UIControlStateNormal];
        [btnMore addTarget:self action:@selector(showMoreOptions:) forControlEvents:UIControlEventTouchUpInside];
        [[cell contentView] addSubview:btnMore];
        [btnMore addConstraint:[NSLayoutConstraint constraintWithItem:btnMore
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:40]];
        
        [btnMore addConstraint:[NSLayoutConstraint constraintWithItem:btnMore
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:40]];
        [[cell contentView] addConstraint:[NSLayoutConstraint constraintWithItem:btnMore
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:[cell contentView]
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0]];
        
        [[cell contentView] addConstraint:[NSLayoutConstraint constraintWithItem:btnMore
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:[cell contentView]
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0]];
    }else{
        btnMore = [[cell contentView] viewWithTag:101] ;
        btnMore.hidden = true;
    }
    btnMore.hidden = false;
    btnMore.index = indexPath.row;
    if (indexPath.row < arrFiltered.count) {
        
        NSDictionary *details = arrFiltered[indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"title"])) {
            cell.textLabel.text = [details objectForKey:@"title"];
        }
        if (NULL_TO_NIL([details objectForKey:@"type"])) {
            NSString *type = [details objectForKey:@"type"];
            if ([type isEqualToString:@"recent"]) {
                btnRecent.hidden = false;
                btnMore.hidden = true;
            }
        }
        if (NULL_TO_NIL([details objectForKey:@"user_id"])) {
            NSString *userID = [details objectForKey:@"user_id"];
            if (![userID isEqualToString:[User sharedManager].userId]) {
                btnMore.hidden = true;
            }
        }
        
        if (NULL_TO_NIL([details objectForKey:@"type"])) {
            NSString *type = [details objectForKey:@"type"];
            cell.textLabel.textColor = [UIColor colorWithRed:0.30 green:0.33 blue:0.38 alpha:1.0];
            if ([type isEqualToString:@"recent"]) {
                 cell.textLabel.textColor = [UIColor getThemeColor];
            }
            else if ([type isEqualToString:@"second"]) {
                cell.textLabel.textColor = [UIColor grayColor];
            }
        }
        
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (arrFiltered.count <= 0) return;
    [self resetComposeView];
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
                    if (indexPath.row < arrFiltered.count ) {
                        NSDictionary *details = arrFiltered[indexPath.row];
                        NSString *title = [details objectForKey:@"title"];
                        NSInteger emotionID = [[details objectForKey:@"id"] integerValue];
                        if ([self.delegate respondsToSelector:@selector(emotionSelectedWithEmotionTitle:emotionID:)])
                            [self.delegate emotionSelectedWithEmotionTitle:title emotionID:emotionID];
                        [self closePopUp];
                    }
                    
                }
            }];
        }];
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return  kHeightForFooter;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tableView])
        return NO;
    return YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    switch (scrollView.panGestureRecognizer.state) {
            
        case UIGestureRecognizerStateBegan:
            
            [self resetComposeView];
            break;
            
        case UIGestureRecognizerStateChanged:
            
            // User is currently dragging the scroll view
            break;
            
        case UIGestureRecognizerStatePossible:
            
            // The scroll view scrolling but the user is no longer touching the scrollview (table is decelerating)
            break;
            
        default:
            break;
    }
   
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self resetComposeView];
    return YES;
}

-(void)showMoreOptions:(ButtonWithID*)button{
    
    [self resetComposeView];
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nav;
    nav = (UINavigationController*) delegate.window.rootViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EMOTION"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              
                                                              actionType = eActionDelete;
                                                              
                                                              AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                              UINavigationController *nav;
                                                              nav = (UINavigationController*) delegate.window.rootViewController;
                                                              
                                                              
                                                              UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                                                                             message:@"Do you want to delete this Emotion ?"
                                                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                                              UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                                                                                    style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                                                                        [self deleteEmotionWithIndex:button.index];
                                                                                                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                        
                                                                                                                    }];
                                                              UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                                                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                                                                   
                                                                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                               }];
                                                              
                                                              [alert addAction:firstAction];
                                                              [alert addAction:second];
                                                              [nav presentViewController:alert animated:YES completion:nil];
                                                              
                                                          }];
    UIAlertAction *edit = [UIAlertAction actionWithTitle:@"Edit"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                         
                                                          actionType = eActionEdit;
                                                         [self getSelectedEmotionTitleWithIndex:button.index];
                                                         [self setUpGrowingTextView];
                                                         
                                                     }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                             {
                                 
                             }];
    
    
    [alert addAction:edit];
   // [alert addAction:delete];
    [alert addAction:cancel];
    [nav presentViewController:alert animated:YES completion:nil];

}

-(void)getSelectedEmotionTitleWithIndex:(NSInteger)index{
    
    if (index < arrFiltered.count) {
        NSDictionary *details = arrFiltered[index];
        strSelectedTitle = [details objectForKey:@"title"];
        selectedEmotionID = [[details objectForKey:@"id"] integerValue];
    }
}

-(void)deleteEmotionWithIndex:(NSInteger)index{
    
    if (index < arrDataSource.count) {
        objectIndex = index;
        NSDictionary *details = arrDataSource[index];
        strSelectedTitle = [details objectForKey:@"title"];
        selectedEmotionID = [[details objectForKey:@"id"] integerValue];
        [self validateMewEmotion];
    }
}



-(IBAction)postNewEmotion{
    
    if ([txtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        NSString *title = txtField.text;
        strSelectedTitle = title;
        NSString *searchTerm = title;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title LIKE[cd] %@", searchTerm];
        NSArray *filtered = [arrDataSource filteredArrayUsingPredicate:predicate];
        if (filtered.count > 0) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Emotion"
                                                                message:@"Emotion already exists."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            strSelectedTitle = @"";
            return;
        }
        
        [self resetComposeView];
        [self validateMewEmotion];
        
    }
    
}

-(void)validateMewEmotion{
    
    if (actionType == eActionEdit) {
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Edit"
                                                                       message:@"This may affect all your GEMS.Do you want to continue?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                                   [self postNewEmotionToWeb];
                                                              }];
        UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                             
                                                         }];
        
        [alert addAction:firstAction];
        [alert addAction:second];
        [delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
        
    }else{
        
        [self postNewEmotionToWeb];
        
    }
   
}

-(void)postNewEmotionToWeb{
    
    [self showLoadingScreen];
    [APIMapper addNewEmotionWithUserID:[User sharedManager].userId feelValue:_emotionaValue emotionTitle:strSelectedTitle operationType:actionType emotionID:selectedEmotionID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        strSelectedTitle = @"";
        selectedEmotionID = 0;
        [self hideLoadingScreen];
        [self getEmotionDetailsWith:responseObject];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
        
    }];

}

-(void)getEmotionDetailsWith:(NSDictionary*)details{
    
    if ([[details objectForKey:@"code"] integerValue] == kSuccessCode) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSString *title = [details objectForKey:@"title"];
            NSInteger emotionID = [[details objectForKey:@"id"] integerValue];
            if (actionType == eActionDelete) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Emotion"
                                                                    message:[details objectForKey:@"text"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                if (objectIndex < arrDataSource.count) {
                    [arrDataSource removeObjectAtIndex:objectIndex];
                     arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
                     [tableView reloadData];
                }
                
            }else{
                if ([self.delegate respondsToSelector:@selector(emotionSelectedWithEmotionTitle:emotionID:)]) {
                    [self.delegate emotionSelectedWithEmotionTitle:title emotionID:emotionID];
                }
                [self closePopUp];
            }
            
            
        });
    }else{
        
         if ([[details objectForKey:@"code"]integerValue] == kUnauthorizedCode){
             
             if (NULL_TO_NIL([details objectForKey:@"text"])) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Emotion"
                                                                     message:[details objectForKey:@"text"]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                 [alertView show];
                 AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                 [delegate clearUserSessions];
                 
             }
             
         }else{
             
             if (NULL_TO_NIL([details objectForKey:@"text"])) {
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Emotion"
                                                                     message:[details objectForKey:@"text"]
                                                                    delegate:nil
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil];
                 [alertView show];
             }
         }
        
    }
}

-(IBAction)closePopUp{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self layoutIfNeeded];
    rightConstraint.constant = 500;
    [self resetComposeView];
    [UIView animateWithDuration:.8
                         animations:^{
                             [self layoutIfNeeded];
                             // Called on parent view
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 if ([self.delegate respondsToSelector:@selector(SelectYourEmotionPopUpCloseAppplied)]) {
                                     [self.delegate SelectYourEmotionPopUpCloseAppplied];
                                 }
                             }
                         }];
    
}

- (IBAction)createEmotion{
    
    actionType = eActionAdd;
    strSelectedTitle = @"";
    selectedEmotionID = 0;
    [self resetComposeView];
    [self setUpGrowingTextView];
}

- (IBAction)setUpGrowingTextView {
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height , self.frame.size.width , 55)];
    containerView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1];
    txtField = [[UITextField alloc] initWithFrame:CGRectMake(5, 8, self.frame.size.width - 60, 40)];
    txtField.layer.borderWidth = 1.f;
    txtField.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    txtField.layer.cornerRadius = 5;
    txtField.font = [UIFont fontWithName:CommonFont size:14];
    txtField.delegate = self;
    txtField.backgroundColor = [UIColor whiteColor];
    txtField.placeholder = @"Create emotion..";
    txtField.text = strSelectedTitle;
    txtField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    txtField.autocorrectionType = UITextAutocorrectionTypeNo;
    txtField.keyboardType=UIKeyboardTypeASCIICapable;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtField.leftView = paddingView;
    txtField.leftViewMode = UITextFieldViewModeAlways;
    [self addSubview:containerView];
    [containerView addSubview:txtField];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 50, 5, 40, 40);
    [doneBtn setImage:[UIImage imageNamed:@"Send_Button.png"]forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(postNewEmotion) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    [txtField becomeFirstResponder];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.bounds.size.height + kTabHeight - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void)resetComposeView{
    
    [self endEditing:YES];
    [containerView removeFromSuperview];
}

-(void)showLoadingScreen{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:delegate.window.rootViewController.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
    
}
-(void)hideLoadingScreen{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [MBProgressHUD hideHUDForView:delegate.window.rootViewController.view animated:YES];
}

#pragma mark - Search Methods and Delegates

- (void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchString{
    
    [arrFiltered removeAllObjects];
    if (searchString.length > 0) {
        if (arrDataSource.count > 0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *regexString  = [NSString stringWithFormat:@".*\\b%@.*", searchString];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches[cd] %@", regexString];
               // NSPredicate *predicate =[NSPredicate predicateWithFormat:@"ANY words BEGINSWITH[c] %@",searchString];
                arrFiltered = [NSMutableArray arrayWithArray:[arrDataSource filteredArrayUsingPredicate:predicate]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    isDataAvailable = true;
                    if (arrFiltered.count <= 0)isDataAvailable = false;
                    [tableView reloadData];
                });
            });
            
        }
    }else{
        if (arrDataSource.count > 0) {
            if (searchBar.text.length > 0) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSString *regexString  = [NSString stringWithFormat:@".*\\b%@.*", searchString];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches[cd] %@", regexString];
                    arrFiltered = [NSMutableArray arrayWithArray:[arrDataSource filteredArrayUsingPredicate:predicate]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        isDataAvailable = true;
                        if (arrFiltered.count <= 0)isDataAvailable = false;
                        [tableView reloadData];
                    });
                });
            }else{
                
                arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
                dispatch_async(dispatch_get_main_queue(), ^{
                    isDataAvailable = true;
                    if (arrFiltered.count <= 0)isDataAvailable = false;
                    [tableView reloadData];
                });
            }
            
        }
    }
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar{
    
    [_searchBar resignFirstResponder];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar{
    
    [searchBar resignFirstResponder];
    arrFiltered = [NSMutableArray arrayWithArray:arrDataSource];
    [tableView reloadData];
    searchBar.text = @"";
    
  

    
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
