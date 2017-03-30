//
//  ChatUserListingViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kSectionCount               1
#define kDefaultCellHeight          80
#define kSuccessCode                200
#define kMinimumCellCount           1

#define kTagForImage                1
#define kTagForName                 2
#define kTagForDate                 3
#define kTagForMsg                  4

#import "ChatUserListingViewController.h"
#import "Constants.h"
#import "ChatComposeViewController.h"

@interface ChatUserListingViewController (){
    
    IBOutlet UITableView *tableView;
    NSMutableArray *arrChatUser;
    BOOL isDataAvailable;
    BOOL showIndicator;
    NSString *strNoDataText;
}

@end

@implementation ChatUserListingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
   
    // Do any additional setup after loading the view.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadAllChatUsers];
    
}

-(void)setUp{
    
    showIndicator = true;
    arrChatUser = [NSMutableArray new];
    isDataAvailable = false;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    tableView.hidden = true;
}

-(void)loadAllChatUsers{
    
    if (showIndicator)[self showLoadingScreen];
    [APIMapper getAllChatUsersWithUserID:[User sharedManager].userId pageNumber:1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getAllUserListWith:responseObject];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        [self hideLoadingScreen];
        [tableView reloadData];
        [tableView setHidden:false];
        showIndicator = false;
        
    }];
    
}


-(void)getAllUserListWith:(NSDictionary*)responds{
    
    isDataAvailable = false;
    if (NULL_TO_NIL([responds objectForKey:@"resultarray"]))
        arrChatUser = [NSMutableArray arrayWithArray:[responds objectForKey:@"resultarray"]];
    if (arrChatUser.count)
        isDataAvailable = true;
    
    tableView.hidden = false;
    showIndicator = false;
    [tableView reloadData];
    
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return kSectionCount;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isDataAvailable) return kMinimumCellCount;
    return arrChatUser.count;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (!isDataAvailable) {
        cell = [Utility getNoDataCustomCellWith:aTableView withTitle:strNoDataText];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor =  [UIColor clearColor];
        return cell;
    }
    cell = [self configureCellForIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kDefaultCellHeight;
}


-(UITableViewCell*)configureCellForIndexPath:(NSIndexPath*)indexPath{
    
    if (!isDataAvailable) {
        /*****! No listing found , default cell !**************/
        UITableViewCell *cell = [Utility getNoDataCustomCellWith:tableView withTitle:@"No Listing found"];
        return cell;
    }
    static NSString *CellIdentifier = @"ChatListingCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row < arrChatUser.count) {
        
        if ([[cell contentView]viewWithTag:kTagForImage] && [[[cell contentView]viewWithTag:kTagForImage] isKindOfClass:[UIImageView class]]){
            UIImageView *image = (UIImageView*)[[cell contentView]viewWithTag:kTagForImage];
            image.layer.cornerRadius = 22.5;
            NSString *urlImage;
            NSDictionary *productInfo = arrChatUser[[indexPath row]];
            if (NULL_TO_NIL([productInfo objectForKey:@"profileimage"]))
                urlImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"profileimage"]];
            if (urlImage.length) {
                [image sd_setImageWithURL:[NSURL URLWithString:urlImage]
                                    placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                               
                                           }];
            }
            
        }
        
        if ([[cell contentView]viewWithTag:kTagForName] && [[[cell contentView]viewWithTag:kTagForName] isKindOfClass:[UILabel class]]){
            NSDictionary *productInfo = arrChatUser[[indexPath row]];
            UILabel *lblName = (UILabel*)[[cell contentView]viewWithTag:kTagForName];
            if (NULL_TO_NIL([productInfo objectForKey:@"firstname"]))
                lblName.text = [productInfo objectForKey:@"firstname"];
        
        }
        
        if ([[cell contentView]viewWithTag:kTagForDate] && [[[cell contentView]viewWithTag:kTagForDate] isKindOfClass:[UILabel class]]){
            NSDictionary *productInfo = arrChatUser[[indexPath row]];
            UILabel *lblName = (UILabel*)[[cell contentView]viewWithTag:kTagForDate];
            lblName.text = @"";
            if (NULL_TO_NIL([productInfo objectForKey:@"chat_datetime"])) {
                double serverTime = [[productInfo objectForKey:@"chat_datetime"] doubleValue];
                if (serverTime > 0)lblName.text = [Utility getDaysBetweenTwoDatesWith:serverTime];
            }
            
        }
        if ([[cell contentView]viewWithTag:kTagForMsg] && [[[cell contentView]viewWithTag:kTagForMsg] isKindOfClass:[UILabel class]]){
           
            NSDictionary *productInfo = arrChatUser[[indexPath row]];
            UILabel *lblName = (UILabel*)[[cell contentView]viewWithTag:kTagForMsg];
            lblName.font = [UIFont fontWithName:CommonFont size:14];
            if ([[productInfo objectForKey:@"in_out"] integerValue] == 1) {
                lblName.text = @"";
                NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"You : %@",[productInfo objectForKey:@"msg"]]];
                                                  [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:CommonFontBold size:14.0] range:NSMakeRange(0, 5)];
                                                  lblName.attributedText = str;
                
            }else if (NULL_TO_NIL([productInfo objectForKey:@"msg"])){
                 lblName.text = @"";
                 lblName.text = [productInfo objectForKey:@"msg"];
            }
            
            if (NULL_TO_NIL([productInfo objectForKey:@"can_chat"])) {
                BOOL canChat = [[productInfo objectForKey:@"can_chat"] boolValue];
                if (!canChat) {
                    lblName.attributedText = [[NSAttributedString alloc]initWithString: @"This user no longer available!!" attributes: @{NSFontAttributeName: [UIFont italicSystemFontOfSize:14]}];
                    
                }
            }
            
        }
        
    }
    
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row < arrChatUser.count) {
        NSDictionary *details = arrChatUser[[indexPath row]];
        [self composeChat:details];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    /**! Pagination call !**/
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height){
        
    }
    
}


-(void)composeChat:(NSDictionary*)info{
    
    ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatComposer];
    chatCompose.chatUserInfo = info;
    [[self navigationController]pushViewController:chatCompose animated:YES];
    
}

#pragma mark - Generic Methods

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
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.navGeneral willMoveToParentViewController:nil];
    [app.navGeneral.view removeFromSuperview];
    [app.navGeneral removeFromParentViewController];
    app.navGeneral = nil;
    [app showLauchPage];
    
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
