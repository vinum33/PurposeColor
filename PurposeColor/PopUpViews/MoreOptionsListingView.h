

typedef enum{
    
    eMyAccount = 0,
    eMyOrder = 1,
    eShare = 2,
    eHelp = 3,
    eLogout = 4
    
    
}eOption;

#import <UIKit/UIKit.h>

@protocol MoreOptionsDelegate <NSObject>



/*!
 *This method is invoked when user selects an Option from the List, send selected Menu Details sends back to delegate.
 */


-(void)selectedMenuFromMoreOptions:(NSInteger)selectedMenu;

@end



@interface MoreOptionsListingView : UIView <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    
    UITableView *tableView;
    NSString *stateID;
}

@property (nonatomic,weak)  id<MoreOptionsDelegate>delegate;
@property (nonatomic,strong)  NSArray *arrStates;
@property (nonatomic,strong)  NSString *userID;

-(void)setUp;
@end
