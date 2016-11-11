//
//  ChatComposeViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kDefaultCellHeight          70
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeightForHeader            40

#define kTagForImage                1
#define kTagForName                 2


#import "ChatComposeViewController.h"
#import "Constants.h"
#import "ComposeMessageTableViewCell.h"
#import "HPGrowingTextView.h"
#import "ProfilePageViewController.h"

@interface ChatComposeViewController () <HPGrowingTextViewDelegate>{
    
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblTitleName;
    IBOutlet UIView *vwLoadHistory;
    IBOutlet UIImageView *imgProfilePic;
    IBOutlet NSLayoutConstraint *tableConstraint;
    IBOutlet UIButton *btnDelete;
    IBOutlet UIButton *btnCancel;
    IBOutlet NSLayoutConstraint *deletePanelConstarint;
    IBOutlet UIButton *btnDeleteAPI;
    IBOutlet UILabel *lblDeleteCount;
    
    NSMutableArray *arrMessages;
    NSMutableDictionary *dictWidthConstraint;
    UIButton *btnDone;;
    
    NSMutableDictionary *dictDeleteIDs;
    BOOL isPageRefresing;
    NSInteger totalPages;
    HPGrowingTextView *textView;
    UIView *containerView;
    NSInteger currentPage;
    BOOL showDeleteBtn;
    BOOL isDeleting;
    BOOL shouldAnimate;
}

@end

@implementation ChatComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
    vwLoadHistory.hidden = true;
    [self loadChatHistoryWithPageNo:currentPage isByPagination:NO];
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
//    UIGraphicsBeginImageContext(self.view.frame.size);
//    [[UIImage imageNamed:@"Chat_Bg.png"] drawInRect:self.view.bounds];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    self.view.backgroundColor = [UIColor colorWithRed:0.92 green:0.91 blue:0.87 alpha:1.0];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Chat_Bg.png"]];
    btnDelete.hidden = true;
    currentPage = 1;
    totalPages = 10;
    showDeleteBtn = false;
    btnCancel.hidden = true;
    arrMessages = [NSMutableArray new];
    dictWidthConstraint = [NSMutableDictionary new];
    dictDeleteIDs = [NSMutableDictionary new];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.hidden = true;
    imgProfilePic.layer.cornerRadius = 20.f;
    tableView.tableHeaderView = nil;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserProfilePage:)];
    [imgProfilePic addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
    imgProfilePic.userInteractionEnabled = true;
    if (_chatUserInfo) {
        if (NULL_TO_NIL([_chatUserInfo objectForKey:@"firstname"])) {
            lblTitleName.text = [_chatUserInfo objectForKey:@"firstname"];
        }
        if (NULL_TO_NIL([_chatUserInfo objectForKey:@"profileimage"])) {
            NSString *urlImage =[_chatUserInfo objectForKey:@"profileimage"];
            if (urlImage.length) {
                [imgProfilePic sd_setImageWithURL:[NSURL URLWithString:urlImage]
                                    placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               
                                           }];
            }
            lblTitleName.text = [_chatUserInfo objectForKey:@"firstname"];
        }
    }
    
    
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

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}


-(void)loadChatHistoryWithPageNo:(NSInteger)pageNo isByPagination:(BOOL)isPagination{
    
    NSString *toUserID;
    if ([_chatUserInfo objectForKey:@"chatuser_id"]) {
        toUserID =[_chatUserInfo objectForKey:@"chatuser_id"];
    }
    
    if (!isPagination){
        [self hideLoadingScreen];
        [self showLoadingScreen];
    }
    
    else
        vwLoadHistory.hidden = false;
    [APIMapper loadChatHistoryWithFrom:[User sharedManager].userId toUserID:toUserID page:pageNo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self showAllChatHistoryMessagesWith:responseObject isPagination:isPagination];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
        isPageRefresing = NO;
        vwLoadHistory.hidden = true;
    }];
    
    
}

-(void)showAllChatHistoryMessagesWith:(NSDictionary*)responds isPagination:(BOOL)isPagination{
    
    vwLoadHistory.hidden = true;
    if ([[responds objectForKey:@"code"] integerValue] == kSuccessCode) {
        if (NULL_TO_NIL([responds objectForKey:@"resultarray"])){
            NSArray *result = [responds objectForKey:@"resultarray"];
            if (result.count) {
                if (isPagination) {
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for (int i = 0; i < result.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        [arrMessages insertObject:result[i] atIndex:i];
                    }
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                    [tableView endUpdates];
                }else{
                    [arrMessages addObjectsFromArray:result];
                    [tableView reloadData];
                    [self tableScrollToLastCell];
                }
            }
        }
    }
    if (NULL_TO_NIL([responds objectForKey:@"pageCount"]))
        totalPages =  [[responds objectForKey:@"pageCount"]integerValue];
    
    if (NULL_TO_NIL([responds  objectForKey:@"currentPage"]))
        currentPage =  [[responds objectForKey:@"currentPage"]integerValue];

    tableView.hidden = false;
    isPageRefresing = NO;
    
}



-(void)newChatHasReceivedWithDetails:(NSDictionary*)chatInfo{
    
    NSString *message;
    NSString *sender;
    NSString *chat_id;
    double serverTime = 0;
    
    if (NULL_TO_NIL([[chatInfo objectForKey:@"aps"] objectForKey:@"alert"]))
        message = [[chatInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    if (NULL_TO_NIL([[chatInfo objectForKey:@"aps"] objectForKey:@"from_user"]))
        sender = [[chatInfo objectForKey:@"aps"] objectForKey:@"from_user"];
    
    if (NULL_TO_NIL([[chatInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"]))
         serverTime =  [[[chatInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"] doubleValue];
    
    if (NULL_TO_NIL([[chatInfo objectForKey:@"aps"] objectForKey:@"chat_id"]))
        chat_id = [[chatInfo objectForKey:@"aps"] objectForKey:@"chat_id"];
        
    if (message && sender) {
        NSDictionary *details = [[NSDictionary alloc] initWithObjectsAndKeys:sender,@"from_id",message,@"msg",[NSNumber numberWithDouble:serverTime],@"chat_datetime",chat_id,@"chat_id", nil];
        [arrMessages addObject:details];
    }
        
    [tableView reloadData];
    [self tableScrollToLastCell];
    
    
}

#pragma mark - UITableViewDataSource Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrMessages.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    cell = [self configureCellForIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
   
    static NSString *CellIdentifier = @"ChatComposeCell";
    ComposeMessageTableViewCell *cell = (ComposeMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    if (indexPath.row < arrMessages.count ) {
        NSDictionary *chatInfo = (NSDictionary *) [arrMessages objectAtIndex:indexPath.row];
        cell.btnDelete.tag = indexPath.row;
        [cell.btnDelete addTarget:self action:@selector(deleteSelectedChat:) forControlEvents:UIControlEventTouchUpInside];
       [cell.btnDelete setImage:[UIImage imageNamed:@"Chat_Message_Delete_Inactive"] forState:UIControlStateNormal];
        cell.leftForDelete.constant = -40;
        if (isDeleting) {
            cell.leftForDelete.constant = 0;
            if ([dictDeleteIDs objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
                [cell.btnDelete setImage:[UIImage imageNamed:@"Chat_Message_Delete_Active"] forState:UIControlStateNormal];
            }
           
        }
        NSString *sender = @"OTHERS";
        NSString *localDateTime;
        if ([[chatInfo objectForKey:@"in_out"] integerValue] == 1) {
            sender = @"YOU";
        }
        NSString *message = [chatInfo objectForKey:@"msg"];
        if ([chatInfo objectForKey:@"chat_datetime"]) {
            double serverTime = [[chatInfo objectForKey:@"chat_datetime"] doubleValue];
            localDateTime = [Utility getDaysBetweenTwoDatesWith:serverTime];
            
        }
        cell.lblTime.text = localDateTime;
        UIImage *bgImage = nil;
        cell.lblMessage.text = message;
       
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [cell.contentView addGestureRecognizer:longPress];
        cell.contentView.tag = indexPath.row;
        
        cell.rightForBg.constant = 10;
        cell.leftForBg.constant = 10;
        float width = 100;
        if (NULL_TO_NIL([chatInfo objectForKey:@"chat_id"])) {
            NSString *chatID = [chatInfo objectForKey:@"chat_id"];
            if ([dictWidthConstraint objectForKey:chatID]) {
                width = [[dictWidthConstraint objectForKey:chatID] floatValue];
            }
        }
        if ([sender isEqualToString:@"OTHERS"]){
             bgImage = [[UIImage imageNamed:@"Chat_White_buble.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
             cell.rightForBg.constant = self.view.frame.size.width - width;
            
        }
        else{
            bgImage = [[UIImage imageNamed:@"Chat_Green_buble.png"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
            cell.leftForBg.constant = self.view.frame.size.width - width;
            
        }
        if (isDeleting) {
            cell.leftForBg.constant =  cell.leftForBg.constant + 50;
        }
        
        cell.imgBg.image = bgImage;
        if (shouldAnimate) {
            [UIView animateWithDuration:.3
                             animations:^{
                                 [cell.contentView layoutIfNeeded];
                                 // Called on parent view
                             }completion:^(BOOL finished) {
                                 
                             }];
        }
       return cell;
    }
  
    return cell;
}

-(CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float widthPadding = 110;
    float heightPadding = 50;
    CGFloat height = kDefaultCellHeight;
    CGFloat width = _tableView.bounds.size.width - widthPadding;
    if (indexPath.row < arrMessages.count) {
        
        NSDictionary *dict = (NSDictionary *)[arrMessages objectAtIndex:indexPath.row];
        NSString *msg = [dict objectForKey:@"msg"];
        
        CGSize constraint = CGSizeMake(_tableView.bounds.size.width - widthPadding, CGFLOAT_MAX);
        CGFloat height;
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize boundingBox = [msg boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:CommonFont size:14]}
                                               context:context].size;
        height = boundingBox.height + heightPadding;
        width = boundingBox.width + 90;
        
        height = height < 70 ? 70 : height;
        if ([dict objectForKey:@"chat_id"]) {
             [dictWidthConstraint setObject:[NSNumber numberWithFloat:width] forKey:[dict objectForKey:@"chat_id"]];
        }
       
        return height;
    }
    
    return height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self resetHeightConstraints];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    if (scrollView.contentOffset.y <= 0){
        
        if(isPageRefresing == NO){ // no need to worry about threads because this is always on main thread.
            
            NSInteger nextPage = currentPage ;
            nextPage += 1;
            if (nextPage  <= totalPages) {
                isPageRefresing = YES;
                [self loadChatHistoryWithPageNo:nextPage isByPagination:YES];
            }
            
        }

    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (isDeleting) {
        [self cancelDelete:nil];
    }
    
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
    textView.placeholder = @"Message..";
    textView.internalTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.keyboardType = UIKeyboardTypeASCIICapable;
    
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [containerView addSubview:textView];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 5, 63, 40);
    [doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [UIFont fontWithName:CommonFontBold size:15];
    [doneBtn setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:doneBtn];
    btnDone = doneBtn;
    btnDone.alpha = 0.5;
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
    [self.view layoutIfNeeded];
    float constant =  keyboardBounds.size.height + containerFrame.size.height;
    tableConstraint.constant = constant;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view layoutIfNeeded];
                          // Called on parent view
                     }];
    
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
    tableConstraint.constant = 50;
    [UIView animateWithDuration:.5
                     animations:^{
                         [self.view layoutIfNeeded];
                         // Called on parent view
                     }];
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
    
    [btnDone setEnabled:TRUE];
    btnDone.enabled = YES;
    btnDone.alpha = 1;
    NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length > 0) [btnDone setEnabled:TRUE];
    else{
        
        btnDone.enabled = NO;
        btnDone.alpha = 0.5;
        [btnDone setEnabled:FALSE];
    }
    
}
#pragma mark -  Chat Operations

-(IBAction)deleteSelectedChat:(UIButton*)_btnDelete{
    if (_btnDelete.tag < arrMessages.count) {
        NSDictionary *details = arrMessages[_btnDelete.tag];
        if ([dictDeleteIDs objectForKey:[NSString stringWithFormat:@"%ld",(long)_btnDelete.tag]]) {
            [dictDeleteIDs removeObjectForKey:[NSString stringWithFormat:@"%ld",(long)_btnDelete.tag]];
            [_btnDelete setImage:[UIImage imageNamed:@"Chat_Message_Delete_Inactive"] forState:UIControlStateNormal];
        }else{
            if([details objectForKey:@"chat_id"]){
                [dictDeleteIDs setObject:details forKey:[NSString stringWithFormat:@"%ld",(long)_btnDelete.tag]];
                [_btnDelete setImage:[UIImage imageNamed:@"Chat_Message_Delete_Active"] forState:UIControlStateNormal];
            }
        }
       
    }
    
    btnDeleteAPI.enabled = true;
    lblDeleteCount.text = [NSString stringWithFormat:@"%lu Selected",(unsigned long)[dictDeleteIDs count]];
    if (dictDeleteIDs.count <= 0) {
        btnDeleteAPI.enabled = false;
    }
    
}

-(void)postMessage{
    
    if (textView.text.length > 0) {
        NSString *message = textView.text;
        NSString *toUserID;
        if ([_chatUserInfo objectForKey:@"chatuser_id"]) {
            toUserID =[_chatUserInfo objectForKey:@"chatuser_id"];
        }
        [APIMapper postChatMessageWithUserID:[User sharedManager].userId toUserID:toUserID message:message success:^(AFHTTPRequestOperation *operation, id responseObject){
            
            if ([[responseObject objectForKey:@"code"] integerValue] == kSuccessCode) {
                
                if (NULL_TO_NIL([responseObject objectForKey:@"chat"])) {
                    [arrMessages addObject:[responseObject objectForKey:@"chat"]];
                    [tableView reloadData];
                    [self tableScrollToLastCell];
                }
            }else{
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Chat"
                                              message:[responseObject objectForKey:@"text"]
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
                                     
                                         
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];
        
        textView.text = @"";
    }
}

-(IBAction)deleteChat:(UIButton*)_btnDelete{
    
    [self.view endEditing:YES];
    imgProfilePic.hidden = true;
    btnCancel.hidden = false;
    containerView.alpha = 0;
    btnDelete.hidden = true;
    isDeleting = true;
    shouldAnimate = true;
    if (_btnDelete.tag < arrMessages.count) {
        NSDictionary *details = arrMessages[_btnDelete.tag];
        if([details objectForKey:@"chat_id"]){
            [dictDeleteIDs setObject:details forKey:[NSString stringWithFormat:@"%ld",(long)_btnDelete.tag]];
        }
    }
    deletePanelConstarint.constant = 0;
    btnDeleteAPI.enabled = true;
    lblDeleteCount.text = [NSString stringWithFormat:@"%lu Selected",(unsigned long)[dictDeleteIDs count]];
    if (dictDeleteIDs.count <= 0) {
        btnDeleteAPI.enabled = false;
    }
    [UIView animateWithDuration:.3
                     animations:^{
                         [self.view layoutIfNeeded];
                         // Called on parent view
                     }completion:^(BOOL finished) {
                         
                     }];
    
    [tableView reloadData];
    
   
}

-(IBAction)cancelDelete:(id)sender{
    
    isDeleting = false;
    imgProfilePic.hidden = false;
    btnCancel.hidden = true;
   [dictDeleteIDs removeAllObjects];
    deletePanelConstarint.constant = -50;
    shouldAnimate = true;
    [UIView animateWithDuration:.3
                     animations:^{
                         [self.view layoutIfNeeded];
                         containerView.alpha = 1.f;
                         // Called on parent view
                     }completion:^(BOOL finished) {
                         if (finished) {
                             shouldAnimate = false;
                         }
                     }];
    
    [tableView reloadData];
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPress{
    
    [self.view endEditing:YES];
    if (longPress && longPress.view) {
        NSInteger tag = longPress.view.tag;
        btnDelete.tag = tag;
    }
    if (longPress.state == UIGestureRecognizerStateBegan) {
        btnDelete.hidden = false;
        showDeleteBtn = true;
        CGPoint coords = [longPress locationInView:longPress.view];
        CGPoint pointForTargetView = [self.view convertPoint:coords fromView:longPress.view];
        float topPadding = -50;
        
        if (pointForTargetView.x - btnDelete.frame.size.width < 70) {
            pointForTargetView = CGPointMake(70, pointForTargetView.y);
        }
        if (pointForTargetView.x + btnDelete.frame.size.width > self.view.frame.size.width - 70) {
            pointForTargetView = CGPointMake(self.view.frame.size.width - 70, pointForTargetView.y);
        }
        
        if (pointForTargetView.y + btnDelete.frame.size.height > self.view.frame.size.height - 50) {
            pointForTargetView = CGPointMake(pointForTargetView.x, self.view.frame.size.height - 50);
        }
        
        if (pointForTargetView.y - btnDelete.frame.size.height <=  65) {
            pointForTargetView = CGPointMake(pointForTargetView.x,  100);
        }
        btnDelete.center = CGPointMake(pointForTargetView.x, pointForTargetView.y + topPadding);
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^(void) {
                             btnDelete.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
      
    }
    if (longPress.state == UIGestureRecognizerStateEnded) {
        showDeleteBtn = false;
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (!showDeleteBtn)
                btnDelete.alpha = 0.0;
         });
    }
    
}


-(IBAction)deleteAllSelectedChatMessages{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete"
                                  message:@"Delete the selected chat?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if (dictDeleteIDs.count) {
                                 
                                 NSArray *ids = [dictDeleteIDs allValues];
                                 NSMutableArray *arrIDS  =[NSMutableArray new];
                                 for (NSDictionary *dict in ids) {
                                     [arrIDS addObject:[dict objectForKey:@"chat_id"]];
                                 }
                                 [arrMessages removeObjectsInArray:ids];
                                 [dictDeleteIDs removeAllObjects];
                                 [tableView reloadData];
                                 [self cancelDelete:nil];
                                 [APIMapper deleteChatWithIDs:arrIDS success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                     
                                 } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                                     
                                 }];
                                 
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


#pragma mark - Generic Methods


-(IBAction)showUserProfilePage:(UITapGestureRecognizer*)gesture{
    
    if (NULL_TO_NIL([_chatUserInfo objectForKey:@"chatuser_id"])) {
        ProfilePageViewController *profilePage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForProfilePage];
        [[self navigationController]pushViewController:profilePage animated:YES];
        profilePage.canEdit = false;
        if ([[_chatUserInfo objectForKey:@"chatuser_id"] isEqualToString:[User sharedManager].userId]) {
            profilePage.canEdit = true;
        }
        [profilePage loadUserProfileWithUserID:[_chatUserInfo objectForKey:@"chatuser_id"] showBackButton:YES];
    }
    
    
}



-(void)resetHeightConstraints{
    
    [self.view endEditing:YES];
    tableConstraint.constant = 50;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)tableScrollToLastCell{
    
    if (arrMessages.count - 1 > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:arrMessages.count - 1 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
    }
    

}
-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

-(IBAction)goBack:(id)sender{
    
    [[self navigationController]popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
