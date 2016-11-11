//
//  CountryListView.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountrySelectionDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Close' Button.
 */

-(void)closeCountryPopUpAfterADelay:(float)delay;

/*!
 *This method is invoked when user selects a country.The selected Country Details sends back to Registration page
 */


-(void)sendSelectedCountryDetailsToRegisterPage:(NSDictionary*)country;

@end



@interface CountryListView : UIView <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    
    UITableView *tableView;
    NSMutableArray *arrCountries;
    
}

@property (nonatomic,weak)  id<CountrySelectionDelegate>delegate;
@property (nonatomic,weak) NSString *selectedCountryID;

-(void)setUp;
@end
