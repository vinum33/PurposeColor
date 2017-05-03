//
//  RegistrationViewController.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryListView.h"

@interface RegistrationViewController : UIViewController<CountrySelectionDelegate>

@property (nonatomic,assign) BOOL isFromIntroPage;

@end
