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

#import "SelectYourGoalsAndDreams.h"
#import "Constants.h"
#import "CreateActionInfoViewController.h"
#import "GoalsCustomCell.h"
#import "QuickGoalViewController.h"

@interface SelectYourGoalsAndDreams () <UITextFieldDelegate,CreateMediaInfoDelegate,QuickGoalDelegate>{
    
    IBOutlet NSLayoutConstraint *rightConstraint;
    IBOutlet UITableView *tableView;
    NSMutableArray *arrEmotions;
    BOOL isDataAvailable;
    NSInteger selectedIndex;
    QuickGoalViewController *quickGoalView;
}

@end

@implementation SelectYourGoalsAndDreams

-(void)showSelectionPopUp{
    
    [self getAllEmotions];
    [self setUp];
    
}

-(void)setUp{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    arrEmotions = [NSMutableArray new];
    selectedIndex = -1;
    [tableView setContentInset:UIEdgeInsetsMake(0, 0, 80, 0)];


}

-(void)getAllEmotions{
    
    [self showLoadingScreen];
     [APIMapper getAllEmotionalAwarenessGEMSListsWithUserID:[User sharedManager].userId gemType:@"goal" goalID:0 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
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
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btnQuickView.tag = indexPath.row;
    [cell.btnQuickView addTarget:self action:@selector(enableQuickView:) forControlEvents:UIControlEventTouchUpInside];
    cell.imgRadio.image = [UIImage imageNamed:@"Goal_Radio_Inactive.png"];
   if (indexPath.row == selectedIndex) {
        cell.imgRadio.image = [UIImage imageNamed:@"Goal_Radio_Active.png"];
   }
    if (!isDataAvailable) {
        cell =  (GoalsCustomCell*)[Utility getNoDataCustomCellWith:aTableView withTitle:@"No Goals Available."];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = false;
         cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    
    if (indexPath.row < arrEmotions.count) {
        NSDictionary *details = arrEmotions[indexPath.row];
        if (NULL_TO_NIL([details objectForKey:@"title"])) {
             cell.lblTitle.text = [details objectForKey:@"title"];
        }
        
        if ([[details objectForKey:@"type"] isEqualToString:@"purposecolor"]) {
            cell.imgRadio.image = [UIImage imageNamed:@"PurposeColor_InActive.png"];
            cell.lblTitle.text = [NSString stringWithFormat:@"eg : %@",[details objectForKey:@"title"]];
        }else{
            cell.imgRadio.image = [UIImage imageNamed:@"Goal_Radio_Inactive.png"];
        }
        
        if (_selectedGoalID == [[details objectForKey:@"id"] integerValue]) {
            if ([[details objectForKey:@"type"] isEqualToString:@"purposecolor"]) {
                cell.imgRadio.image = [UIImage imageNamed:@"PurposeColor_Active.png"];
            }else{
                cell.imgRadio.image = [UIImage imageNamed:@"Goal_Radio_Active.png"];
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
    if (arrEmotions.count <= 0) return;
    GoalsCustomCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
    selectedIndex = indexPath.row;
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
                    if (indexPath.row < arrEmotions.count ) {
                        NSDictionary *details = arrEmotions[indexPath.row];
                        NSString *title = [details objectForKey:@"title"];
                        NSInteger emotionID = [[details objectForKey:@"id"] integerValue];
                         _selectedGoalID = [[details objectForKey:@"id"] integerValue];
                        if ([[details objectForKey:@"type"] isEqualToString:@"purposecolor"]) {
                            [self showPurposeColorTemplateGoalWithID:_selectedGoalID];
                            
                        }else{
                            if ([self.delegate respondsToSelector:@selector(goalsAndDreamsSelectedWithTitle:goalId:)])
                                [self.delegate goalsAndDreamsSelectedWithTitle:title goalId:emotionID];
                            [self closePopUp];
                        }
                        
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

-(void)showPurposeColorTemplateGoalWithID:(NSInteger)goalActionID{
    
    SWRevealViewController *root = (SWRevealViewController*)self.window.rootViewController;
    if ([root.frontViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)root.frontViewController;
        CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
        detailPage.actionType = eActionTypeGoalsAndDreams;
        detailPage.strTitle = @"CREATE GOAL";
        detailPage.delegate = self;
        detailPage.isPurposeColorGEM = TRUE;
        [nav pushViewController:detailPage animated:YES];
        [detailPage getMediaDetailsForGemsToBeEditedWithGEMID:[NSString stringWithFormat:@"%ld",(long)goalActionID] GEMType:@"goal"];
    }
   
}


/*! Event Creation & Delegates !*/
-(IBAction)showComposeView:(UIButton*)btn{
    
    SWRevealViewController *root = (SWRevealViewController*)self.window.rootViewController;
    if ([root.frontViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)root.frontViewController;
        CreateActionInfoViewController *detailPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCreateActionMedias];
        detailPage.strTitle = @"ADD GOALS&DREAMS";
        detailPage.actionType = eActionTypeGoalsAndDreams;
        detailPage.delegate = self;
        [nav pushViewController:detailPage animated:YES];
    }
}
-(IBAction)skip:(id)sender{
    
    [self closePopUp];
    if ([self.delegate respondsToSelector:@selector(skipButtonApplied)])
        [self.delegate skipButtonApplied];
}



-(void)goalsAndDreamsCreatedWithGoalTitle:(NSString*)goalTitle goalID:(NSInteger)goalID{
    
    if ([self.delegate respondsToSelector:@selector(goalsAndDreamsSelectedWithTitle:goalId:)])
        [self.delegate goalsAndDreamsSelectedWithTitle:goalTitle goalId:goalID];
    [self closePopUp];
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
                                 if ([self.delegate respondsToSelector:@selector(selectYourGoalsAndDreamsPopUpCloseAppplied)]) {
                                     [self.delegate selectYourGoalsAndDreamsPopUpCloseAppplied];
                                 }
                             }
                         }];
    
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

-(void)showLoadingScreen{
    
    SWRevealViewController *root = (SWRevealViewController*)self.window.rootViewController;
    if ([root.frontViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)root.frontViewController;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:nav.view animated:YES];
        hud.dimBackground = YES;
        hud.detailsLabelText = @"loading...";
        hud.removeFromSuperViewOnHide = YES;
        
    }
    
    
}
-(void)hideLoadingScreen{
    
    SWRevealViewController *root = (SWRevealViewController*)self.window.rootViewController;
    if ([root.frontViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)root.frontViewController;
        [MBProgressHUD hideHUDForView:nav.view animated:YES];
    }
    
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
