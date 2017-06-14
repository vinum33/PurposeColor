//
//  JournalListViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 20/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//
#define kSectionCount               1
#define kDefaultCellHeight          95
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kWidthPadding               115
#define kFollowHeightPadding        85
#define kOthersHeightPadding        20

#import "JournalListViewController.h"
#import "JournalListCustomCell.h"
#import "JournalDetailPageViewController.h"
#import "Constants.h"
#import "GoalDetailViewController.h"
#import "JournalGalleryViewController.h"
#import "Journal_CommentViewController.h"

@interface JournalListViewController () <UIGestureRecognizerDelegate,Journal_CommentActionDelegate,Journal_DetailViewDelegate> {
    
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblJournal;
    NSMutableArray *arrJournal;
    BOOL isDataAvailable;
    NSInteger totalPages;
    NSInteger currentPage;
    NSInteger clickedIndex;
    BOOL isPageRefresing;
    Journal_CommentViewController *composeComment;
    NSString *strNoDataText;
}

@end

@implementation JournalListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self loadAllJournalsWithPageNo:currentPage isByPagination:NO];
   

    
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    if (_strRegion.length) {
        lblJournal.text = [NSString stringWithFormat:@"%@ JOURNALS", [_strRegion uppercaseString]];
    }
    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    currentPage = 1;
    totalPages = 0;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.alwaysBounceVertical = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    arrJournal = [NSMutableArray new];
    isDataAvailable = false;
    [tableView setHidden:true];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    [tableView addGestureRecognizer:lpgr];
}

-(void)loadAllJournalsWithPageNo:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    
    if (!isPagination) {
        [self showLoadingScreen];
    }
    [APIMapper getUserJournalWithUserID:[User sharedManager].userId page:pageNo region:_strRegion Onsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self getJournalsFromResponds:responseObject];
        [self hideLoadingScreen];
        [tableView setHidden:false];
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        isPageRefresing = false;
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
    }];
    
    
    
}


-(void)getJournalsFromResponds:(NSDictionary*)responseObject{
    
    isDataAvailable = false;
    if ( NULL_TO_NIL([responseObject objectForKey:@"journals"])) {
        NSArray *results = [responseObject objectForKey:@"journals"];
        for (NSDictionary *dict in results)
            [arrJournal addObject:dict];
    }
    else{
        if (NULL_TO_NIL([[responseObject objectForKey:@"header"] objectForKey:@"text"]))
            strNoDataText = [[responseObject objectForKey:@"header"] objectForKey:@"text"];
    }
    if (arrJournal.count) isDataAvailable = true;
    if (NULL_TO_NIL([[responseObject objectForKey:@"header"] objectForKey:@"pageCount"]))
        totalPages =  [[[responseObject objectForKey:@"header"] objectForKey:@"pageCount"]integerValue];
    
    if (NULL_TO_NIL([[responseObject objectForKey:@"header"] objectForKey:@"currentPage"]))
        currentPage =  [[[responseObject objectForKey:@"header"] objectForKey:@"currentPage"]integerValue];
    
    [tableView reloadData];
    
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
    return arrJournal.count;

}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strNoDataText];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }else{
        JournalListCustomCell * cell = (JournalListCustomCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalListCustomCell"];
        cell.btnGoal.tag = indexPath.row;
        cell.btnGallery.tag = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.btnComent.tag = indexPath.row;
        if (indexPath.row < arrJournal.count) {
            NSDictionary *journal = arrJournal[indexPath.row];
            cell.lblTitle.text = @"";
            cell.lblFeel.text = @"";
            cell.lblGoal.text = @"";
            cell.lblDate.text = @"";
            cell.lblLoc.text = @"";
            cell.lblContact.text = @"";
            
            NSMutableAttributedString *noteCount = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"SELF NOTES (%ld)",[[journal objectForKey:@"note_count"] integerValue]]];
            [noteCount addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(11,noteCount.length - 11)];
            cell.lblNoteCount.attributedText = noteCount;
            
            if ([journal objectForKey:@"event_title"]) cell.lblTitle.text = [journal objectForKey:@"event_title"];
            if ([journal objectForKey:@"journal_datetime"]){
                 NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] initWithString:[Utility getDateStringFromSecondsWith:[[journal objectForKey:@"journal_datetime"] doubleValue] withFormat:@"d MMM,yyyy h:mm a"]];
                [myString addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0,myString.length)];
                cell.lblDate.attributedText = myString;
                
            }
            cell.topForLocation.constant = 0;
            if ([journal objectForKey:@"location_name"]) {
                cell.topForLocation.constant = 5;
                NSMutableAttributedString *myString = [NSMutableAttributedString new];
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                UIImage *icon = [UIImage imageNamed:@"Loc_Small"];
                attachment.image = icon;
                attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblLoc.font.descender + 2), icon.size.width, icon.size.height);
                
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                [myString appendAttributedString:attachmentString];
                NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[journal objectForKey:@"location_name"]]];
                [myString appendAttributedString:myText];
                cell.lblLoc.attributedText = myString;
            }
             cell.topForContact.constant = 0;
            if ([journal objectForKey:@"contact_name"]) {
                cell.topForContact.constant = 5;
                NSMutableAttributedString *myString = [[NSMutableAttributedString alloc] init];
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                UIImage *icon = [UIImage imageNamed:@"contact_icon"];
                attachment.image = icon;
                attachment.bounds = CGRectMake(0, (-(icon.size.height / 2) -  cell.lblContact.font.descender) + 2, icon.size.width, icon.size.height);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                [myString appendAttributedString:attachmentString];
                NSAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[journal objectForKey:@"contact_name"]]];
                [myString appendAttributedString:myText];
                 cell.lblContact.attributedText = myString;
            }
           
            if ([journal objectForKey:@"emotion_title"]){
                
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                UIImage *icon ;
                if ([[journal objectForKey:@"emotion_value"] integerValue] == 2)
                    icon = [UIImage imageNamed:@"5_Star_Small"];
                if ([[journal objectForKey:@"emotion_value"] integerValue] == 1)
                    icon = [UIImage imageNamed:@"4_Star_Small"];
                if ([[journal objectForKey:@"emotion_value"] integerValue] == 0)
                    icon = [UIImage imageNamed:@"3_Star_Small"];
                if ([[journal objectForKey:@"emotion_value"] integerValue] == -1)
                    icon = [UIImage imageNamed:@"2_Star_Small"];
                if ([[journal objectForKey:@"emotion_value"] integerValue] == -2)
                    icon = [UIImage imageNamed:@"1_Star_Small"];
                
                attachment.image = icon;
                attachment.bounds = CGRectMake(0, -(icon.size.height / 2) -  cell.lblFeel.font.descender + 2, icon.size.width, icon.size.height);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
                NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" Feeling %@",[journal objectForKey:@"emotion_title"]]];
                [myText addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0,8)];
                [strFeel appendAttributedString:myText];
                cell.lblFeel.attributedText = strFeel;
                
            }
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                UIImage *icon ;
            
            if ([[journal objectForKey:@"drive_value"] integerValue] == 2)
                icon = [UIImage imageNamed:@"Strongly_Agree_Blue_Small"];
            if ([[journal objectForKey:@"drive_value"] integerValue] == 1)
                icon = [UIImage imageNamed:@"Agree_Blue_Small"];
            if ([[journal objectForKey:@"drive_value"] integerValue] == 0)
                icon = [UIImage imageNamed:@"Neutral_Blue_Small"];
            if ([[journal objectForKey:@"drive_value"] integerValue] == -1)
                icon = [UIImage imageNamed:@"Disagree_Blue_Small"];
            if ([[journal objectForKey:@"drive_value"] integerValue] == -2)
                icon = [UIImage imageNamed:@"Strongly_DisAgree_Blue_Small"];
            
                attachment.image = icon;
                attachment.bounds = CGRectMake(0, (-(20 / 2) - cell.lblGoal.font.descender) + 2, 20, 20);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                NSMutableAttributedString *strFeel = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
                cell.btnGoal.hidden = true;
                if ([journal objectForKey:@"goal_title"]) {
                    NSMutableAttributedString *myText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",[journal objectForKey:@"goal_title"]]];
                    [myText addAttribute:NSForegroundColorAttributeName value:[UIColor getThemeColor] range:NSMakeRange(0,myText.length)];
                    [strFeel appendAttributedString:myText];
                    cell.btnGoal.hidden = false;
                }
                cell.lblGoal.attributedText = strFeel;
            
            cell.imgGemMedia.image = [UIImage imageNamed:@"NoImage.png"];
            [cell.activityIndicator stopAnimating];
            if ([journal objectForKey:@"display_image"]) {
                [cell.activityIndicator startAnimating];
                [cell.imgGemMedia sd_setImageWithURL:[NSURL URLWithString:[journal objectForKey:@"display_image"]]
                                    placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               [cell.activityIndicator stopAnimating];
                                           }];

            }
       }
      
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), 99999);
        cell.contentView.bounds = cell.bounds;
        [cell layoutIfNeeded];
        cell.lblFeel.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblFeel.frame);
        cell.lblGoal.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblGoal.frame);
        cell.lblTitle.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblTitle.frame);
        cell.lblDate.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblDate.frame);
        cell.lblLoc.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblLoc.frame);
        cell.lblContact.preferredMaxLayoutWidth = CGRectGetWidth(cell.lblContact.frame);
        
        return cell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrJournal.count) {
        NSDictionary *joiurnal = arrJournal[indexPath.row];
        clickedIndex  = indexPath.row;
         JournalDetailPageViewController *journalVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForJournalDetailPage];
        journalVC.delegate = self;
        journalVC.journalDetails = joiurnal;
         [self.navigationController pushViewController:journalVC animated:YES];
    }
    
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage ;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self loadAllJournalsWithPageNo:nextPage isByPagination:YES];
            }
            
        }
    }
    
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

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete"
                                                                       message:@"Do you want to delete this Journal?"
                                                                preferredStyle:UIAlertControllerStyleActionSheet]; // 1
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                              style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                              }]; // 2
        UIAlertAction *secondAction = [UIAlertAction actionWithTitle:@"Delete"
                                                               style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                                                                   
                                                                   [self deleteJournalWithIndex:indexPath.row];
                                                               }]; // 3
        
        [alert addAction:firstAction]; // 4
        [alert addAction:secondAction]; // 5
        
        [self presentViewController:alert animated:YES completion:nil]; // 6
        
    } else {
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    
    return YES;
}

-(void)deleteJournalWithIndex:(NSInteger)index{
    
    if (index < arrJournal.count) {
        
        NSDictionary *journal = arrJournal[index];
        [self showLoadingScreen];
        [APIMapper deleteJournalWithJournalID:[journal objectForKey:@"journal_id"] userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [arrJournal removeObjectAtIndex:index];
            [tableView reloadData];
            [self hideLoadingScreen];
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
             [self hideLoadingScreen];
        }];
        
       
    }
}

-(IBAction)showJournalCommentView:(UIButton*)btn{
    
    if (btn.tag < arrJournal.count) {
        NSDictionary *journal = arrJournal[btn.tag];
        clickedIndex = btn.tag;
        composeComment =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForJournalCommentView];
        composeComment.dictJournal = journal;
        composeComment.delegate = self;
        CGPoint p = [btn.superview convertPoint:btn.center toView:self.view];
        float strtPoint = p.y - 40;
        
        [self addChildViewController:composeComment];
        UIView *vwPopUP = composeComment.view;
        [self.view addSubview:vwPopUP];
        vwPopUP.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[vwPopUP]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(vwPopUP)]];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:vwPopUP
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:strtPoint];
        [self.view addConstraint:top];
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:vwPopUP
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:50];
        [vwPopUP addConstraint:height];
        [self.view layoutIfNeeded];
        top.constant = 0;
        height.constant = self.view.frame.size.height;
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self.view layoutIfNeeded]; // Called on parent view
                         }completion:^(BOOL finished) {
                             [composeComment showNavBar];
                         }];
        
        
        
        
    }
    
    
}

-(void)closeJournalCommentPopUpClicked{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        composeComment.view.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [composeComment.view removeFromSuperview];
        [composeComment removeFromParentViewController];
        composeComment = nil;
        
    }];
    
}

-(void)notesUpdatedByNewNoteCount:(NSInteger)noteCount{
    
    // Directly from jouranl comment list
    
    if (clickedIndex < arrJournal.count) {
        NSDictionary *journal = arrJournal[clickedIndex];
        NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:journal];
        [dictUpdated setObject:[NSNumber numberWithInteger:noteCount] forKey:@"note_count"];
        [arrJournal replaceObjectAtIndex:clickedIndex withObject:dictUpdated];
        [tableView reloadData];
        
    }

}

-(void)notesUpdatedByNewNoteCountFromDetailView:(NSInteger)noteCount;{
    
    //From detail page
    
    if (clickedIndex < arrJournal.count) {
        NSDictionary *journal = arrJournal[clickedIndex];
        NSMutableDictionary *dictUpdated = [NSMutableDictionary dictionaryWithDictionary:journal];
        [dictUpdated setObject:[NSNumber numberWithInteger:noteCount] forKey:@"note_count"];
        [arrJournal replaceObjectAtIndex:clickedIndex withObject:dictUpdated];
        [tableView reloadData];
        
    }
}


-(IBAction)showGoalDetails:(UIButton*)sender{
    
    if (sender.tag < arrJournal.count) {
        NSDictionary *joiurnal = arrJournal[sender.tag];
        GoalDetailViewController *goalDetailsVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForGoalDetails];
        [goalDetailsVC getGoaDetailsByGoalID:[joiurnal objectForKey:@"goal_id"]];
        [[self navigationController]pushViewController:goalDetailsVC animated:YES];
    }
}

-(IBAction)showGallery:(UIButton*)sender{
    
    if (sender.tag < arrJournal.count) {
        NSDictionary *joiurnal = arrJournal[sender.tag];
        if ([joiurnal objectForKey:@"journal_media"]){
             JournalGalleryViewController *galleryVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForJournalGallery];
            galleryVC.arrMedia = [joiurnal objectForKey:@"journal_media"];
            [self.navigationController pushViewController:galleryVC animated:YES];
        }
        
    }
}

-(IBAction)goBack:(id)sender{
    
    if (self.navigationController.viewControllers.count == 1) {
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.navGeneral willMoveToParentViewController:nil];
        [app.navGeneral.view removeFromSuperview];
        [app.navGeneral removeFromParentViewController];
        app.navGeneral = nil;
        [app showLauchPage];
    }else{
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
