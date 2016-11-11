//
//  MenuViewController.m
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//



typedef enum{
    
    eFollow = 0,
    eFollowPending = 1,
    eFollowed = 2,
    
} eFollowStatus;


#define kTagForImage                1
#define kTagForName                 2
#define kTagForDate                 3
#define kTagForButton               4


#define kTagForTitle            1
#define kCellHeight             70
#define kCellHeightForStatus    130
#define kHeightForHeader        300
#define kEmptyHeaderAndFooter   001
#define kSuccessCode            200


#import "LikedAndCommentedUserListings.h"
#import "Constants.h"
#import "ButtonWithID.h"
#import "ProfilePageViewController.h"

@interface LikedAndCommentedUserListings (){
    
    IBOutlet UITableView *tableView;
    IBOutlet UILabel *lblTitle;
    NSMutableArray *arrList;
    NSMutableDictionary *dictFollowers;
    NSString *title;
}

@end

@implementation LikedAndCommentedUserListings{
    
}



-(void)viewDidLoad{
    
    [super viewDidLoad];
    [self setUp];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)setUp{
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.automaticallyAdjustsScrollViewInsets=NO;
    dictFollowers = [NSMutableDictionary new];
    lblTitle.text = @"COMMENT";
    if ([title isEqualToString:@"like"]) {
        lblTitle.text = @"LIKE";
    }
}

-(void)loadUserListingsForType:(NSString*)type gemID:(NSString*)gemID{
    
    title = type;
    [self showLoadingScreen];
    [APIMapper getUserListingsWithGemID:gemID type:type userID:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self parseResponds:responseObject];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        if (error && error.localizedDescription) [ALToastView toastInView:self.view withText:NETWORK_ERROR_MESSAGE];
        [self hideLoadingScreen];
        
    }];

        
        
}

-(void)parseResponds:(NSDictionary*)details{
    
    if ([[details objectForKey:@"code"] integerValue] == kSuccessCode) {
        arrList = [NSMutableArray arrayWithArray:[details objectForKey:@"resultarray"]];
    }
    [tableView reloadData];
  
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    return arrList.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = (UITableViewCell *)[aTableView dequeueReusableCellWithIdentifier:@"TableCell"];
    [self configureCellWithCell:cell indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger tag = indexPath.row;
    if (tag < arrList.count) {
        NSDictionary *details = arrList[tag];
        if (NULL_TO_NIL([details objectForKey:@"user_id"])) {
            ProfilePageViewController *profilePage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForProfilePage];
            [[self navigationController]pushViewController:profilePage animated:YES];
            profilePage.canEdit = false;
            if ([[details objectForKey:@"user_id"] isEqualToString:[User sharedManager].userId]) {
                profilePage.canEdit = true;
            }
            [profilePage loadUserProfileWithUserID:[details objectForKey:@"user_id"] showBackButton:YES];
            
        }
    }

    
}

-(void)configureCellWithCell:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    
    if (indexPath.row < arrList.count) {
        
         NSDictionary *productInfo = arrList[[indexPath row]];
        if ([[cell contentView]viewWithTag:kTagForImage] && [[[cell contentView]viewWithTag:kTagForImage] isKindOfClass:[UIImageView class]]){
            UIImageView *image = (UIImageView*)[[cell contentView]viewWithTag:kTagForImage];
            image.layer.cornerRadius = 25;
             NSString *urlImage;
                if (NULL_TO_NIL([productInfo objectForKey:@"profileimg"]))
                    urlImage = [NSString stringWithFormat:@"%@",[productInfo objectForKey:@"profileimg"]];
                if (urlImage.length) {
                    [image sd_setImageWithURL:[NSURL URLWithString:urlImage]
                                 placeholderImage:[UIImage imageNamed:@"NoImage.png"]
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
                                        }];
                }
            
        }
        if ([[cell contentView]viewWithTag:kTagForName] && [[[cell contentView]viewWithTag:kTagForName] isKindOfClass:[UILabel class]]){
            UILabel *lblName = (UILabel*)[[cell contentView]viewWithTag:kTagForName];
            if (NULL_TO_NIL([productInfo objectForKey:@"firstname"]))
            lblName.text = [productInfo objectForKey:@"firstname"];
            
        }
        if ([[cell contentView]viewWithTag:kTagForDate] && [[[cell contentView]viewWithTag:kTagForDate] isKindOfClass:[UILabel class]]){
            UILabel *lblName = (UILabel*)[[cell contentView]viewWithTag:kTagForDate];
            if (NULL_TO_NIL([productInfo objectForKey:@"display_datetime"])) {
            double serverTime = [[productInfo objectForKey:@"display_datetime"] doubleValue];
            if (serverTime > 0)lblName.text = [Utility getDaysBetweenTwoDatesWith:serverTime];
            }
            
        }
        
        return;
        
        if (NULL_TO_NIL([productInfo objectForKey:@"follow_status"])){
             eFollowStatus    followStatus =  [[productInfo objectForKey:@"follow_status"] intValue];
            BOOL canFollow = true;
            if (NULL_TO_NIL([productInfo objectForKey:@"can_follow"]))
                canFollow = [[productInfo objectForKey:@"can_follow"] boolValue];
            if ([[cell contentView]viewWithTag:kTagForButton] && [[[cell contentView]viewWithTag:kTagForButton] isKindOfClass:[UIButton class]]){
                ButtonWithID  *btnFollow = (ButtonWithID*)[[cell contentView]viewWithTag:kTagForButton];
                btnFollow.index = indexPath.row;
                [btnFollow addTarget:self action:@selector(followButtonClickedWith:) forControlEvents:UIControlEventTouchUpInside];
                btnFollow.hidden = (canFollow) ? false : true;
                btnFollow.layer.borderWidth = 1.f;
                btnFollow.layer.borderColor = [UIColor getThemeColor].CGColor;
                btnFollow.layer.cornerRadius = 5.f;
                switch (followStatus) {
                    case eFollowed:
                        [btnFollow setEnabled:true];
                        [btnFollow setTitle:@"UnFollow" forState:UIControlStateNormal];
                        [btnFollow setBackgroundColor:[UIColor clearColor]];
                        [btnFollow setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
                        break;
                        
                    case eFollowPending:
                        [btnFollow setEnabled:false];
                        [btnFollow setTitle:@"Follow" forState:UIControlStateDisabled];
                        [btnFollow setBackgroundColor:[UIColor lightGrayColor]];
                        [btnFollow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                         btnFollow.layer.borderColor = [UIColor clearColor].CGColor;
                        break;
                        
                    case eFollow:
                        [btnFollow setTitle:@"Follow" forState:UIControlStateNormal];
                        [btnFollow setBackgroundColor:[UIColor clearColor]];
                        [btnFollow setEnabled:true];
                        [btnFollow setTitleColor:[UIColor getThemeColor] forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
                
            }
           

        }
       
        
        
        
    }
    
    

    
    
    
   
}

-(NSString*)getDaysBetweenTwoDatesWith:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
        NSString *msgDate;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:@"d MMM yyyy"];
    msgDate = [dateformater stringFromDate:refDate];
    return msgDate;
    
}


-(IBAction)followButtonClickedWith:(ButtonWithID*)btn{
    NSInteger index = btn.index;
    if (index < arrList.count) {
        NSDictionary *details = arrList[index];
        if (NULL_TO_NIL([details objectForKey:@"user_id"])) {
            NSString *followerID = [details objectForKey:@"user_id"];
            [self updateGemsWithFollowStatusWithIndex:index];
            [APIMapper sendFollowRequestWithUserID:[User sharedManager].userId followerID:followerID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } failure:^(AFHTTPRequestOperation *task, NSError *error) {
                
            }];
        }
    }
    
}

-(void)updateGemsWithFollowStatusWithIndex:(NSInteger)index{
    
    if (index < arrList.count) {
        NSDictionary *gemsInfo = arrList[index];
        if (NULL_TO_NIL([gemsInfo objectForKey:@"user_id"])) {
            NSString *followerID = [gemsInfo objectForKey:@"user_id"];
            if ([gemsInfo objectForKey:@"follow_status"]) {
                int status = (int)[[gemsInfo objectForKey:@"follow_status"] integerValue];
                if (NULL_TO_NIL([dictFollowers objectForKey:followerID]))
                    status = (int) [[dictFollowers objectForKey:followerID] integerValue];
                status += 1;
                if (status + 1 > eFollowed)
                    status = eFollow;
                [dictFollowers setObject:[NSNumber numberWithInteger:status] forKey:followerID];
            }
        }
        [tableView reloadData];
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
    
    [[self navigationController] popViewControllerAnimated:YES];
}


@end
