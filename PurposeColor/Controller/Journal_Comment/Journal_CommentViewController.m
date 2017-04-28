//
//  CommentComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kHeightForHeader        65
#define kMinimumCellCount       1
#define kSuccessCode            200
#define kDefaultCellHeight      150
#define kHeightForFooter        0.001
#define kSuccessCode            200

#import "Journal_CommentViewController.h"
#import  "Constants.h"
#import "HPGrowingTextView.h"
#import "JournalListCustomCell.h"
#import "JournalCommentListCustomCell.h"

@interface Journal_CommentViewController ()<HPGrowingTextViewDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIView *vwNavBar;
    NSMutableArray *arrComments;
    UIView *containerView;
    HPGrowingTextView *textView;
    BOOL isDataAvailable;
    UIButton *btnDone;
    NSString *editID;
    NSInteger selectedIndex;
    NSString *strNoDataText;
    
}

@end

@implementation Journal_CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
   
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{
    
    btnCancel.hidden = true;
    btnCancel.layer.cornerRadius = 5.f;
    btnCancel.layer.borderWidth = 1.f;
    btnCancel.layer.borderColor = [UIColor whiteColor].CGColor;
    tableView.hidden = true;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 200;
    arrComments = [NSMutableArray new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [tableView addGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer.minimumPressDuration = .3;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,tableView.bounds.size.width, 0.01f)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    [self setUpGrowingTextView];
    
}

-(void)showNavBar{
    
    [self getAllComments];
    [UIView animateWithDuration:.3
                     animations:^{
                        vwNavBar.alpha = 1; // Called on parent view
                     }completion:^(BOOL finished) {
                     }];
    
}

-(void)getAllComments{
    
    if (_dictJournal) {
        NSString *journalID;
        if (NULL_TO_NIL([_dictJournal objectForKey:@"journal_id"]))
            journalID = [_dictJournal objectForKey:@"journal_id"];
       
        if (journalID) {
            [self showLoadingScreenWithTitle:@"Loading.."];
            [APIMapper getAllCommentsForAJournalWithJournalID:journalID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self parseResponds:responseObject];
                [self hideLoadingScreen];
                tableView.hidden = false;
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                  [self hideLoadingScreen];
                  tableView.hidden = false;
            }];
        }
        
    }
    
}

-(void)parseResponds:(NSDictionary*)responds{
    
    if ([[responds objectForKey:@"code"] integerValue] == kSuccessCode) {
        
        if (NULL_TO_NIL([responds objectForKey:@"resultarray"])) {
            arrComments  = [NSMutableArray arrayWithArray:[responds objectForKey:@"resultarray"]];
        }
    }
    
    else if ([[responds objectForKey:@"code"]integerValue] == kUnauthorizedCode){
        
        if (NULL_TO_NIL([responds objectForKey:@"text"])) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Note"
                                                                message:[responds objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [delegate clearUserSessions];
            
        }
        
    }else{
        strNoDataText = [responds objectForKey:@"text"];
    }
    
    if (arrComments.count) isDataAvailable = true;
    [tableView reloadData];
}



#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    if (!isDataAvailable) {
        return kMinimumCellCount;
    }
    return arrComments.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JournalListCustomCell * cell = (JournalListCustomCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalListCustomCell"];
    
    if (indexPath.section == 0) {
        
        JournalListCustomCell * cell = (JournalListCustomCell *)[aTableView dequeueReusableCellWithIdentifier:@"JournalListCustomCell"];
        cell.btnGoal.tag = indexPath.row;
        cell.btnGallery.tag = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.btnComent.tag = indexPath.row;
            NSDictionary *journal = _dictJournal;
            cell.lblTitle.text = @"";
            cell.lblFeel.text = @"";
            cell.lblGoal.text = @"";
            cell.lblDate.text = @"";
            cell.lblLoc.text = @"";
            cell.lblContact.text = @"";
            
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
                attachment.bounds = CGRectMake(0, -(icon.size.height / 2) -  cell.lblFeel.font.descender, icon.size.width, icon.size.height);
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
                                               [UIView transitionWithView:cell.imgGemMedia
                                                                 duration:.5f
                                                                  options:UIViewAnimationOptionTransitionCrossDissolve
                                                               animations:^{
                                                                   cell.imgGemMedia.image = image;
                                                               } completion:nil];
                                               
                                               
                                               [cell.activityIndicator stopAnimating];
                                           }];
                
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
    
    }else{
        UITableViewCell *_cell;
        if (!isDataAvailable) {
            if (!strNoDataText) strNoDataText = @"No Notes!";
            _cell = [Utility getNoDataCustomCellWith:tableView withTitle:strNoDataText];
            _cell.backgroundColor = [UIColor whiteColor];
            _cell.selectionStyle = UITableViewCellSelectionStyleNone;
            _cell.contentView.backgroundColor = [UIColor whiteColor];
            return _cell;
        }
        JournalCommentListCustomCell * cell = (JournalCommentListCustomCell *)[aTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.imgRound.layer.cornerRadius = 15.f;
        cell.imgRound.layer.borderWidth = 1.f;
        cell.imgRound.layer.borderColor = [UIColor clearColor].CGColor;
        cell.lblNo.text = [NSString stringWithFormat:@"%ld",arrComments.count - indexPath.row];
        if (indexPath.row < arrComments.count) {
            NSDictionary *coment = arrComments[[indexPath row]];
            if (NULL_TO_NIL([coment objectForKey:@"comment_txt"]))
                cell.lblTitle.text = [coment objectForKey:@"comment_txt"];
            if (NULL_TO_NIL([coment objectForKey:@"comment_datetime"]))
                cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:[[coment objectForKey:@"comment_datetime"] doubleValue]];
            
            
        }
        return cell;
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self.view endEditing:YES];
}


#pragma mark - Growing Text View


- (void)setUpGrowingTextView {
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width , 45)];
    containerView.backgroundColor = [UIColor whiteColor];
    
    UIView *vwBorder = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , 0.5)];
    vwBorder.backgroundColor = [UIColor lightGrayColor];
    vwBorder.alpha = 0.5;
    [containerView addSubview:vwBorder];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 7, self.view.frame.size.width - 80, 35)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(5, 5, 0, 5);
    //textView.layer.borderWidth = 1.f;
    //textView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
   // textView.layer.cornerRadius = 5;
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont fontWithName:CommonFont_New size:14];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Add Notes..";
    textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    //textView.keyboardType=UIKeyboardTypeASCIICapable;

    // textView.text = @"test\n\ntest";
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 5, 63, 35);
    [doneBtn setTitle:@"Add" forState:UIControlStateNormal];
    doneBtn.layer.borderWidth = 1.f;
    doneBtn.layer.borderColor = [UIColor clearColor].CGColor;
    doneBtn.layer.cornerRadius = 5;
    [doneBtn setBackgroundColor:[UIColor getThemeColor]];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont fontWithName:CommonFontBold_New size:14];
    [doneBtn addTarget:self action:@selector(postComment) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setAlpha:0.4];
    [containerView addSubview:doneBtn];
    btnDone = doneBtn;
    [btnDone setEnabled:FALSE];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
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
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
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

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    
     NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length > 0){
        [btnDone setAlpha:1];
        [btnDone setEnabled:TRUE];
    }else{
        [btnDone setAlpha:0.4];
        [btnDone setEnabled:FALSE];
    }
    
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    
}

#pragma mark - Post Comment


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    CGPoint p = [gestureRecognizer locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    if (indexPath.section == 0) return;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIAlertController * alert=  [UIAlertController alertControllerWithTitle:@"Note" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* edit = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            btnCancel.hidden = false;
            if (indexPath.row < arrComments.count) {
                selectedIndex = indexPath.row;
                NSDictionary *coment = arrComments[[indexPath row]];
                if (NULL_TO_NIL([coment objectForKey:@"journalcomment_id"]))
                    editID = [coment objectForKey:@"journalcomment_id"];
                if (NULL_TO_NIL([coment objectForKey:@"comment_txt"]))
                    textView.text = [coment objectForKey:@"comment_txt"];
                [textView becomeFirstResponder];
            }
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        UIAlertAction* delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            
             [self deleteCommentClicked:indexPath.row];
            [alert dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
                                 {
                                    textView.text = @"";
                                     [self.view endEditing:YES];
                                 }];
        [alert addAction:edit];
        [alert addAction:delete];
        [alert addAction:cancel];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
    }
}
-(IBAction)cancelEdit:(id)sender{
    
    btnCancel.hidden = true;
    editID = nil;
    textView.text = @"";
    [self.view endEditing:YES];
}

-(void)postComment
{
    [textView resignFirstResponder];
    [self.view endEditing:YES];
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length > 0) {
        if (_dictJournal) {
            NSString *journalID;
            if (NULL_TO_NIL([_dictJournal objectForKey:@"journal_id"]))
                journalID = [_dictJournal objectForKey:@"journal_id"];
            if (journalID) {
                [self showLoadingScreenWithTitle:@"Posting.."];
                NSString *comment = textView.internalTextView.text;
                [APIMapper postJournalCommentWithUserID:[User sharedManager].userId journalID:journalID editID:editID comment:comment success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode) {
                        BOOL shoulsScroll = false;
                        if ([responseObject objectForKey:@"comment"]) {
                            if (editID.length) {
                                shoulsScroll = false;
                                [arrComments replaceObjectAtIndex:selectedIndex withObject:[responseObject objectForKey:@"comment"]];
                            }else{
                                shoulsScroll = true;
                                //[arrComments addObject:[responseObject objectForKey:@"comment"]];
                                [arrComments insertObject:[responseObject objectForKey:@"comment"] atIndex:0];
                            }
                        }
                        if (arrComments.count > 0)isDataAvailable = true;
                        [tableView reloadData];
                        if (shoulsScroll) [self tableScrollToFirstCell];
                    }
                    else if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                        
                        if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Note"
                                                                                message:[responseObject objectForKey:@"text"]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                            [delegate clearUserSessions];
                            
                        }
                        
                    }
                    [self hideLoadingScreen];
                    textView.text = @"";
                    btnCancel.hidden = true;
                    editID = nil;
                    
                } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                    
                    [self showMessage:@"Failed to add comment!"];
                    [self hideLoadingScreen];
                }];
                
            }
        }
    }
    
}

-(void)tableScrollToFirstCell{
    
    if (arrComments.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionTop
                                 animated:YES];
    }
   
    
}

-(void)deleteCommentClicked:(NSInteger)index {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Note"
                                  message:@"Delete the selected note?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (index < arrComments.count) {
                                 
                                 NSDictionary *comment = arrComments[index];
                                 if (NULL_TO_NIL([comment objectForKey:@"journalcomment_id"])) {
                                     NSString *commentID = [comment objectForKey:@"journalcomment_id"];
                                     if (commentID) {
                                         [self showLoadingScreenWithTitle:@"Deleting.."];
                                         [APIMapper removeJournalCommentWithCommentID:commentID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode)
                                                 [self updateCommentCountWithGemID:nil commentCount:0 isAddComment:NO];
                                             
                                             else if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                                                 
                                                 if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Note"
                                                                                                         message:[responseObject objectForKey:@"text"]
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:@"OK"
                                                                                               otherButtonTitles:nil];
                                                     [alertView show];
                                                     AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                                     [delegate clearUserSessions];
                                                     
                                                 }
                                             }
                                             
                                                 
                                             isDataAvailable = true;
                                             if (index < arrComments.count) {
                                                 [arrComments removeObjectAtIndex:index];
                                                 if (arrComments.count <= 0) isDataAvailable = false;
                                                 [tableView reloadData];
                                             }
                                             [self hideLoadingScreen];
                                             
                                             
                                        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                             
                                             [self showMessage:@"Failed to delete comment!"];
                                             [self hideLoadingScreen];
                                         }];
                                     }
                                 }
                             }
                             
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

-(void)showMessage:(NSString*)message{
    
    [[[UIAlertView alloc] initWithTitle:@"Note" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)showLoadingScreenWithTitle:(NSString*)title{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = title;
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}


-(IBAction)closePopUp{
    
    if ([self.delegate respondsToSelector:@selector(notesUpdatedByNewNoteCount:)])
        [self.delegate notesUpdatedByNewNoteCount:arrComments.count];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.delegate respondsToSelector:@selector(closeJournalCommentPopUpClicked)])
        [self.delegate closeJournalCommentPopUpClicked];

 
}

-(void)updateCommentCountWithGemID:(NSString*)gemID commentCount:(NSInteger)count isAddComment:(BOOL)isAddComment{
    
  
}


-(void)dealloc{
    
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
