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

#import "CommentComposeViewController.h"
#include "CommentCustomCell.h"
#import  "Constants.h"
#import "HPGrowingTextView.h"


@interface CommentComposeViewController ()<HPGrowingTextViewDelegate,CommentCellDelegate>{
    
    IBOutlet UITableView *tableView;
    NSMutableArray *arrComments;
    UIView *containerView;
    HPGrowingTextView *textView;
    BOOL isDataAvailable;
    UIButton *btnDone;
    NSString *strNoDataText;
    
}

@end

@implementation CommentComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    [self getAllComments];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(void)setUp{
    
    arrComments = [NSMutableArray new];
    self.automaticallyAdjustsScrollViewInsets = NO;
    tableView.hidden = true;
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

-(void)getAllComments{
    
    if (_dictGemDetails) {
        NSString *gemID;
        NSString *gemType;
        NSInteger gemShare = 1;
        if (!_isFromCommunityGem)
            gemShare = 0;
        if (NULL_TO_NIL([_dictGemDetails objectForKey:@"gem_id"]))
            gemID = [_dictGemDetails objectForKey:@"gem_id"];
        if (NULL_TO_NIL([_dictGemDetails objectForKey:@"gem_type"]))
            gemType = [_dictGemDetails objectForKey:@"gem_type"];
        if (gemType&&gemID) {
            [self showLoadingScreenWithTitle:@"Loading.."];
            [APIMapper getAllCommentsForAGemWithGemID:gemID gemType:gemType shareComment:gemShare success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [self parseResponds:responseObject];
                [self hideLoadingScreen];
                
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment"
                                                                message:[responds objectForKey:@"text"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
            [delegate clearUserSessions];
            
        }
        
    }else{
        
        if ([responds objectForKey:@"text"]) {
            strNoDataText = [responds objectForKey:@"text"];
        }
        
    }
    
    if (arrComments.count) isDataAvailable = true;
    tableView.hidden = false;
    [tableView reloadData];
}

#pragma mark - TableView Delegates


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
     if (!isDataAvailable) return kMinimumCellCount;
    return arrComments.count;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UITableViewCell *_cell;
    if (!isDataAvailable) {
        _cell = [Utility getNoDataCustomCellWith:_tableView withTitle:strNoDataText];
        _cell.backgroundColor = [UIColor whiteColor];
        _cell.contentView.backgroundColor = [UIColor whiteColor];
        return _cell;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor getSeperatorColor];
    static NSString *CellIdentifier = @"CommentCustomCell";
    CommentCustomCell *cell = (CommentCustomCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.imgProfilePic setImage:[UIImage imageNamed:@"NoImage.png"]];
    cell.index = indexPath.row;
    cell.delegate = self;
    [self setUpCommentWith:cell index:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = [self getLabelHeight:indexPath.row];
    return height;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view endEditing:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
   [self.view endEditing:YES];    
}


-(void)setUpCommentWith:(CommentCustomCell*)cell index:(NSInteger)row{
    
    if (row < arrComments.count) {
        NSDictionary *comment = arrComments[row];
        if (NULL_TO_NIL([comment objectForKey:@"comment_datetime"])) {
            double serverTime = [[comment objectForKey:@"comment_datetime"] doubleValue];
            cell.lblDate.text = [Utility getDaysBetweenTwoDatesWith:serverTime];
        }
        
        if (NULL_TO_NIL([comment objectForKey:@"firstname"])) cell.lblName.text = [comment objectForKey:@"firstname"];
        if (NULL_TO_NIL([comment objectForKey:@"comment_txt"])){
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.2f;
            NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle,
                                         };
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:[comment objectForKey:@"comment_txt"] attributes:attributes];
            cell.lblComment.attributedText = attributedText;
           // cell.lblComment.text = [comment objectForKey:@"comment_txt"];
            
        }
        
        if (NULL_TO_NIL([comment objectForKey:@"profileurl"])) {
            NSString *videoThumb = [comment objectForKey:@"profileurl"];
            if (videoThumb.length) {
                [cell.imgProfilePic sd_setImageWithURL:[NSURL URLWithString:videoThumb]
                                    placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           }];
            }
        }
        cell.btnDelete.hidden = true;
        if ([[comment objectForKey:@"user_id"] integerValue] == [[User sharedManager].userId integerValue]) {
            cell.btnDelete.hidden = false;
        }
        
        cell.imgProfilePic.layer.borderWidth = 1.f;
        cell.imgProfilePic.layer.borderColor = [UIColor clearColor].CGColor;
        cell.imgProfilePic.layer.cornerRadius = 20.f;
        
    }
}

- (CGFloat)getLabelHeight:(NSInteger)index
{
    float heightPadding = 65;
    if (index < arrComments.count) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.2f;
        NSDictionary *comment = arrComments[index];
        NSString *strComment;
        if (NULL_TO_NIL([comment objectForKey:@"comment_txt"])) strComment = [comment objectForKey:@"comment_txt"];
        float widthPadding = 70;
        CGSize constraint = CGSizeMake(tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        CGSize size;
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize boundingBox = [strComment boundingRectWithSize:constraint
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14],NSParagraphStyleAttributeName:paragraphStyle}
                                                      context:context].size;
        
        size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
        return size.height + heightPadding;
    }
   
    
    return kDefaultCellHeight;
}


#pragma mark - Growing Text View


- (void)setUpGrowingTextView {
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width , 50)];
    containerView.backgroundColor = [UIColor colorWithRed:245/255.f green:245/255.f blue:245/255.f alpha:1];
    
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(5, 8, self.view.frame.size.width - 80, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(5, 5, 0, 5);
    textView.layer.borderWidth = 1.f;
    textView.layer.borderColor = [UIColor getSeperatorColor].CGColor;
    textView.layer.cornerRadius = 5;
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont fontWithName:CommonFont size:14];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Comment..";
    textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    //textView.keyboardType=UIKeyboardTypeASCIICapable;

    // textView.text = @"test\n\ntest";
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 5, 63, 40);
    [doneBtn setTitle:@"Send" forState:UIControlStateNormal];
   // [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont fontWithName:CommonFontBold size:16];
    [doneBtn addTarget:self action:@selector(postComment) forControlEvents:UIControlEventTouchUpInside];
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
    if (trimmedString.length > 0) [btnDone setEnabled:TRUE];
    else [btnDone setEnabled:FALSE];
    
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    
}

#pragma mark - Post Comment


-(void)postComment
{
    [textView resignFirstResponder];
    [self.view endEditing:YES];
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (trimmedString.length > 0) {
        
        if (_dictGemDetails) {
            NSString *gemID;
            NSString *gemType;
            NSInteger gemShare = 1;
            if (!_isFromCommunityGem)
                gemShare = 0;
            if (NULL_TO_NIL([_dictGemDetails objectForKey:@"gem_id"]))
                gemID = [_dictGemDetails objectForKey:@"gem_id"];
            if (NULL_TO_NIL([_dictGemDetails objectForKey:@"gem_type"]))
                gemType = [_dictGemDetails objectForKey:@"gem_type"];
            if (gemID && gemType) {
                 [self showLoadingScreenWithTitle:@"Posting.."];
                NSString *comment = textView.internalTextView.text;
                [APIMapper postCommentWithUserID:[User sharedManager].userId gemID:gemID gemType:gemType comment:comment shareComment:gemShare success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode) {
                        if (NULL_TO_NIL([responseObject objectForKey:@"comment_count"])) {
                            NSInteger count =[[responseObject objectForKey:@"comment_count"] integerValue];
                            [self updateCommentCountWithGemID:gemID commentCount:count isAddComment:YES];
                            if ([responseObject objectForKey:@"comment"]) {
                                [arrComments addObject:[responseObject objectForKey:@"comment"]];
                                tableView.hidden = false;
                            }
                            if (arrComments.count > 0)isDataAvailable = true;
                            [tableView reloadData];
                            [self tableScrollToLastCell];
                        }
                    }
                    else if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                        
                        if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment"
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
                } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                    
                    [self showMessage:@"Failed to add comment!"];
                    [self hideLoadingScreen];
                    
                }];
                
            }
        }
    }
}

-(void)tableScrollToLastCell{
    
    if (arrComments.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrComments.count - 1 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
    }
   
    
}

-(void)deleteCommentClicked:(NSInteger)index {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete"
                                  message:@"Delete the selected Comment?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (index < arrComments.count) {
                                 
                                 NSDictionary *comment = arrComments[index];
                                 if (NULL_TO_NIL([comment objectForKey:@"comment_id"])) {
                                     NSString *commentID = [comment objectForKey:@"comment_id"];
                                     if (commentID) {
                                         [self showLoadingScreenWithTitle:@"Deleting.."];
                                         [APIMapper removeCommentWithCommentID:commentID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode)
                                                 [self updateCommentCountWithGemID:nil commentCount:0 isAddComment:NO];
                                             
                                             else if ([[responseObject objectForKey:@"code"]integerValue] == kUnauthorizedCode){
                                                 
                                                 if (NULL_TO_NIL([responseObject objectForKey:@"text"])) {
                                                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Comment"
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
    
    [[[UIAlertView alloc] initWithTitle:@"Comment" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(void)showLoadingScreenWithTitle:(NSString*)title{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:app.window.rootViewController.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = title;
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [MBProgressHUD hideHUDForView:app.window.rootViewController.view animated:YES];
    
}


-(IBAction)closePopUp{
    
     [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([self.delegate respondsToSelector:@selector(commentPopUpCloseAppplied)]) {
        [self.delegate commentPopUpCloseAppplied];
    }
   
 
}

-(void)updateCommentCountWithGemID:(NSString*)gemID commentCount:(NSInteger)count isAddComment:(BOOL)isAddComment{
    
    if ([self.delegate respondsToSelector:@selector(commentPostedSuccessfullyWithGemID:commentCount:index:isAddComment:)]) {
        [self.delegate commentPostedSuccessfullyWithGemID:gemID commentCount:count index:_selectedIndex isAddComment:isAddComment];
    }
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
