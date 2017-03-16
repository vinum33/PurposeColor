//
//  ContactsPickerViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 15/03/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol ContactPickerDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)pickedContactsList:(NSMutableArray*)lists;

/*!
 *This method is invoked when user Clicks "EMOTION" Button
 */


@end


#import <UIKit/UIKit.h>

@interface ContactsPickerViewController : UIViewController

@property (nonatomic,weak)  id<ContactPickerDelegate>delegate;

@end
