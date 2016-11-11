//
//  CountryListView.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StateSelectionDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeStateListingPopUpAfterADelay:(float)delay;

/*!
 *This method is invoked when user selects a State from the List, send selected Country Details sends back to Server
 */


-(void)updateStateDetailsToBackEnd:(NSDictionary*)stateDetails withUserID:(NSString*)userID;

@end



@interface StateListViewPopUp : UIView <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    
    UITableView *tableView;
    NSString *stateID;
}

@property (nonatomic,weak)  id<StateSelectionDelegate>delegate;
@property (nonatomic,strong)  NSArray *arrStates;
@property (nonatomic,strong)  NSString *userID;

-(void)setUp;
@end
