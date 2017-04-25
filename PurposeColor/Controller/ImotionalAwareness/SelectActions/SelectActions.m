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
#import "ActionsCustomCell.h"
#import "QuickGoalViewController.h"
#import "ASJTagsView.h"

@interface SelectActions () <UITextFieldDelegate,CreateMediaInfoDelegate,QuickGoalDelegate>{
    
    IBOutlet NSLayoutConstraint *rightConstraint;
    IBOutlet NSLayoutConstraint *heightForTags;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnClear;
    IBOutlet UIButton *btnSend;
    IBOutlet UIButton *btnAddAction;
    NSInteger selectedIndex;

    
    NSMutableArray *arrEmotions;
    NSMutableDictionary *dictSelections;
    BOOL isDataAvailable;
    QuickGoalViewController *quickGoalView;
    IBOutlet ASJTagsView *_tagsView;
}

@end

@implementation SelectActions


-(void)showSelectionPopUp{
    
    [self getAllActions];
    [self setUp];
    [self handleTagBlocks];
    
}


- (void)handleTagBlocks
{
}

-(IBAction)deleteAllTags:(id)sender{
    [_tagsView deleteAllTags];
     heightForTags.constant = _tagsView.contentSize.height;
    [dictSelections removeAllObjects];
    for (NSMutableDictionary *details in arrEmotions) {
       [details setObject:[NSNumber numberWithBool:false] forKey:@"isSelected"];
       
    }
    btnClear.hidden = true;
    [tableView reloadData];
    [self layoutIfNeeded];
}
- (IBAction)addTapped:(NSString*)title
{
     btnClear.hidden = false;
    [_tagsView addTag:title];
    if (_tagsView.contentSize.height < 100) {
        heightForTags.constant = _tagsView.contentSize.height;
    }else{
        CGPoint bottomOffset = CGPointMake(0, _tagsView.contentSize.height - _tagsView.bounds.size.height);
        [_tagsView setContentOffset:bottomOffset animated:YES];
    }
    [self layoutIfNeeded];

}
- (IBAction)resetTagViewAfterDelete
{
    btnClear.hidden = false;
    heightForTags.constant = _tagsView.contentSize.height;
    
    [self layoutIfNeeded];
    
}
-(void)setUp{
    
    btnAddAction.layer.cornerRadius = 5;
    btnAddAction.layer.borderWidth = 1.f;
    btnAddAction.layer.borderColor = [UIColor clearColor].CGColor;
    btnSend.layer.cornerRadius = 5;
    btnSend.layer.borderWidth = 1.f;
    btnSend.layer.borderColor = [UIColor getThemeColor].CGColor;

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopUp)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    //[self addGestureRecognizer:tapGesture];
    dictSelections = [NSMutableDictionary new];
    arrEmotions = [NSMutableArray new];
    btnClear.hidden = true;
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
    
    NSArray *actions;
    if (NULL_TO_NIL([dictEmotions objectForKey:@"resultarray"]))
        actions = [NSArray arrayWithArray:[dictEmotions objectForKey:@"resultarray"]];
    for (NSDictionary *dcit in actions) {
        NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:dcit];
        [details setObject:[NSNumber numberWithBool:false] forKey:@"isSelected"];
        if ([_selectedActions objectForKey:[details objectForKey:@"id"]]) {
            [dictSelections setObject:details forKey:[details objectForKey:@"id"]];
            [details setObject:[NSNumber numberWithBool:true] forKey:@"isSelected"];
            [self addTapped:[details objectForKey:@"title"]];
        }
        [arrEmotions addObject:details];
    }
    
    if (arrEmotions.count) isDataAvailable = true;
        
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
    return arrEmotions.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        ActionsCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionsCustomCell"];
        if (cell == nil) {
            // Load the top-level objects from the custom cell XIB.
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ActionsCustomCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont fontWithName:CommonFont size:15];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = true;
        cell.btnQuickView.tag = indexPath.row;
        cell.lblTitle.textColor =  [UIColor colorWithRed:0.30 green:0.33 blue:0.38 alpha:1.0];;
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
            cell.textLabel.textColor = [UIColor colorWithRed:0.30 green:0.33 blue:0.38 alpha:1.0];
            return cell;
        }
        
        if (indexPath.row < arrEmotions.count) {
            
            //cell.imgRadio.image = [UIImage imageNamed:@"Emotion_CheckBox.png"];
            NSDictionary *details = arrEmotions[indexPath.row];
            if (NULL_TO_NIL([details objectForKey:@"title"])) {
                cell.lblTitle.text = [details objectForKey:@"title"];
            }
            if ([details objectForKey:@"isSelected"]) {
                [cell.btnQuickView setImage:[UIImage imageNamed:@"CheckBox_Goals"] forState:UIControlStateNormal];
                if ([[details objectForKey:@"isSelected"] boolValue]) {
                    [cell.btnQuickView setImage:[UIImage imageNamed:@"CheckBox_Goals_Active"] forState:UIControlStateNormal];
                    
                }
            }
            if (NULL_TO_NIL([details objectForKey:@"display_image"])) {
                [cell.imgRadio sd_setImageWithURL:[NSURL URLWithString:[details objectForKey:@"display_image"]]
                                 placeholderImage:[UIImage imageNamed:@"Purposecolor_Image"]
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                            
                                        }];
            }
            

            
        }
    
    return cell;
   
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 60;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (arrEmotions.count <= 0) return;
    [self endEditing:YES];
    [self enableQuickView:indexPath];
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

-(IBAction)actionSelected:(id)object{
    NSInteger index = 0;
    if ([object isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)object;
        index = btn.tag;
    }else if([object isKindOfClass:[NSIndexPath class]]){
        NSIndexPath *indexPath = (NSIndexPath*)object;
        index = indexPath.row;
    }
    else{
        index = [object integerValue];
    }
    if (index < arrEmotions.count ) {
        NSMutableDictionary *details = [NSMutableDictionary dictionaryWithDictionary:arrEmotions[index]];
        if ([details objectForKey:@"isSelected"]) {
            
            if ([[details objectForKey:@"isSelected"] boolValue]) {
                [details setObject:[NSNumber numberWithBool:false] forKey:@"isSelected"];
                [dictSelections removeObjectForKey:[details objectForKey:@"id"]];
                [_tagsView deleteTag:[details objectForKey:@"title"]];
                if (dictSelections.count <= 0) {
                    [self deleteAllTags:nil];
                }else{
                    [self resetTagViewAfterDelete];
                }
            }else{
                [details setObject:[NSNumber numberWithBool:true] forKey:@"isSelected"];
                [dictSelections setObject:details forKey:[details objectForKey:@"id"]];
                [self addTapped:[details objectForKey:@"title"]];
            }
            
        }else{
            
            [dictSelections setObject:details forKey:[details objectForKey:@"id"]];
            [details setObject:[NSNumber numberWithBool:true] forKey:@"isSelected"];
            [self addTapped:[details objectForKey:@"title"]];
        }
       
        [arrEmotions replaceObjectAtIndex:index withObject:details];
    }
    [tableView reloadData];
    
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
    
     NSMutableDictionary *newAction = [NSMutableDictionary dictionaryWithObjectsAndKeys:actionTitle,@"title",[NSNumber numberWithInteger:actionID],@"id",[NSNumber numberWithBool:true],@"isSelected", nil];
    [dictSelections setObject:newAction forKey:[NSNumber numberWithInteger:actionID]];
    [self addTapped:[newAction objectForKey:@"title"]];
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

-(void)enableQuickView:(NSIndexPath*)indexPath{
    
    if (!quickGoalView) {
        quickGoalView =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForQuickGoalView];
        quickGoalView.delegate = self;
    }
    
    if (indexPath.row < arrEmotions.count) {
        selectedIndex = indexPath.row ;
        NSDictionary *details = arrEmotions[indexPath.row ];
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

-(void)goalSelectedFromQuickView{
    
    if (selectedIndex < arrEmotions.count) {
       
        [self actionSelected:[NSNumber numberWithInteger:selectedIndex]];
        [self closeQuickGoalViewPopUp];
    }
    
}


-(IBAction)closePopUp{
    
    [self layoutIfNeeded];
    rightConstraint.constant = 500;
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
