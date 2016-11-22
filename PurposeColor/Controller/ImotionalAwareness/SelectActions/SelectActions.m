//
//  SelectYourFeel.m
//  PurposeColor
//
//  Created by Purpose Code on 16/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kTagForTextField                1
#define kCellMinimumCount               1
#define kHeightForHeader                60
#define kSectionCount                   1
#define kPadding                        60
#define kHeightForFooter                0.1
#define kSuccessCode                    200

#import "SelectActions.h"
#import "Constants.h"
#import "CreateActionInfoViewController.h"
#import "GoalsCustomCell.h"
#import "QuickGoalViewController.h"

@interface SelectActions () <UITextFieldDelegate,CreateMediaInfoDelegate,QuickGoalDelegate>{
    
    IBOutlet NSLayoutConstraint *rightConstraint;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnSend;
    NSMutableArray *arrEmotions;
    NSMutableDictionary *dictSelections;
    BOOL isDataAvailable;
     QuickGoalViewController *quickGoalView;
}

@end

@implementation SelectActions

-(void)showSelectionPopUp{
    
    [self getAllActions];
    [self setUp];
    
}

-(void)setUp{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    dictSelections = [NSMutableDictionary new];
    arrEmotions = [NSMutableArray new];
    btnSend.layer.borderColor = [[UIColor whiteColor] CGColor];
    btnSend.layer.borderWidth = 1.0f;
    btnSend.layer.cornerRadius = 5.0f;
}

-(void)getAllActions{
    
    [self showLoadingScreen];
    [APIMapper getAllEmotionalAwarenessGEMSListsWithUserID:[User sharedManager].userId gemType:@"action" goalID:_goalID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showAllEmotionsWith:responseObject];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
         if (error && error.localizedDescription) [ALToastView toastInView:self withText:NETWORK_ERROR_MESSAGE];
        [self hideLoadingScreen];
        
    }];
    

}

-(void)showAllEmotionsWith:(NSDictionary*)dictEmotions{
    
    if (NULL_TO_NIL([dictEmotions objectForKey:@"resultarray"]))
        arrEmotions = [NSMutableArray arrayWithArray:[dictEmotions objectForKey:@"resultarray"]];
    if (arrEmotions.count) isDataAvailable = true;
        
    [tableView reloadData];
    [self layoutIfNeeded];
    rightConstraint.constant = (self.frame.size.width * 80) / 100;
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
    return arrEmotions.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoalsCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BDCustomCell"];
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GoalsCustomCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = true;
    cell.btnQuickView.tag = indexPath.row;
    [cell.btnQuickView addTarget:self action:@selector(enableQuickView:) forControlEvents:UIControlEventTouchUpInside];
    if (!isDataAvailable) {
        
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:MyIdentifier];
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:@"No Actions Available."];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = false;
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    
    if (indexPath.row < arrEmotions.count) {
        
        cell.imgRadio.image = [UIImage imageNamed:@"Emotion_CheckBox.png"];
        NSDictionary *details = arrEmotions[indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"title"])) {
            cell.lblTitle.text = [details objectForKey:@"title"];
        }
        if ([dictSelections objectForKey:[details objectForKey:@"id"]]) {
             cell.imgRadio.image = [UIImage imageNamed:@"Emotion_CheckBox_Selected.png"];
        }
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 50;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (arrEmotions.count <= 0) return;
    [self endEditing:YES];
    UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    [UIView animateWithDuration:0.3/1.5 animations:^{
        cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3/2 animations:^{
            cell.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3/2 animations:^{
                cell.transform = CGAffineTransformIdentity;
                if (indexPath.row < arrEmotions.count ) {
                    NSDictionary *details = arrEmotions[indexPath.row];
                    if ([dictSelections objectForKey:[details objectForKey:@"id"]]) {
                        [dictSelections removeObjectForKey:[details objectForKey:@"id"]];
                        cell.imageView.image = [UIImage imageNamed:@"Emotion_CheckBox.png"];;
                    }else{
                        [dictSelections setObject:details forKey:[details objectForKey:@"id"]];
                        cell.imageView.image = [UIImage imageNamed:@"Emotion_CheckBox_Selected.png"];;
                    }
                    [tableView reloadData];
                }
            } completion:^(BOOL finished) {
                
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

-(IBAction)sendSeleciton:(UIButton*)btn{
    
    
        NSMutableString *strTitle = [NSMutableString new];
        for (NSDictionary *dict in [dictSelections allValues]) {
            [strTitle appendString:[ NSString stringWithFormat:@"%@,",[dict objectForKey:@"title"]]];
        }
        if ([self.delegate respondsToSelector:@selector(actionsSelectedWithTitle:actionIDs:)]) {
            [self.delegate actionsSelectedWithTitle:strTitle actionIDs:dictSelections];
        }
        [self closePopUp];
        
}

/*! Action Creation & Delegates !*/
-(IBAction)createNewAction:(UIButton*)btn{
    
    CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:detailPage];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    detailPage.strTitle = @"ADD ACTION";
    detailPage.actionType = eActionTypeActions;
    detailPage.delegate = self;
    detailPage.shouldShowReminder = YES;
    detailPage.strGoalID = [NSString stringWithFormat:@"%ld",(long)_goalID];
}

-(void)newActionCreatedWithActionTitle:(NSString*)actionTitle actionID:(NSInteger)actionID{
    
    NSDictionary *newAction = [NSDictionary dictionaryWithObjectsAndKeys:actionTitle,@"title",[NSNumber numberWithInteger:actionID],@"id", nil];
    [arrEmotions addObject:newAction];
    if (arrEmotions.count > 0) isDataAvailable = true;
    [dictSelections setObject:newAction forKey:[NSNumber numberWithInteger:actionID]];
    [tableView reloadData];
    [tableView beginUpdates];
    if (arrEmotions.count  > 0) {
        NSInteger index  = [arrEmotions indexOfObject:[arrEmotions lastObject]];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
    }
    [tableView endUpdates];
    
   
}

-(void)enableQuickView:(UIButton*)sender{
    
    if (!quickGoalView) {
        quickGoalView =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForQuickGoalView];
        quickGoalView.delegate = self;
    }
    
    if (sender.tag < arrEmotions.count) {
        NSDictionary *details = arrEmotions[sender.tag];
        [quickGoalView loadGoalDetailsWithGoalID:[NSString stringWithFormat:@"%d",[[details objectForKey:@"id"] integerValue]]];
    }
    quickGoalView.view.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window.rootViewController addChildViewController:quickGoalView];
    UIView *vwPopUP = quickGoalView.view;
    [app.window.rootViewController.view addSubview:vwPopUP];
    vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    [app.window.rootViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
    
    vwPopUP.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        vwPopUP.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        
        
        // if you want to do something once the animation finishes, put it here
    }];
    
}

-(void)closeQuickGoalViewPopUp{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        quickGoalView.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [quickGoalView.view removeFromSuperview];
        [quickGoalView removeFromParentViewController];
        quickGoalView = nil;
        
    }];
    
}


-(void)closePopUp{
    
    [self layoutIfNeeded];
    rightConstraint.constant = 0;
    [UIView animateWithDuration:.8
                         animations:^{
                             [self layoutIfNeeded];
                             // Called on parent view
                         } completion:^(BOOL finished) {
                             if (finished) {
                                 if ([self.delegate respondsToSelector:@selector(selectYourActionsPopUpCloseAppplied)]) {
                                     [self.delegate selectYourActionsPopUpCloseAppplied];
                                 }
                             }
                         }];
    
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
