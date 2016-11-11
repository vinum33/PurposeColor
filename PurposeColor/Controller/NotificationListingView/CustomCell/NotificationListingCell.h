//
//  CustomCellForType.h
//  SignSpot
//
//  Created by Purpose Code on 18/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"


@protocol NotificationListingCellDelegate <NSObject>

/*!
 *This method is invoked when user taps the 'Share' Button.
 */

-(void)shareButtonTappedWithTag:(NSInteger)tag;

/*!
 *This method is invoked when user taps the 'Delete' Button.
 */


-(void)deleteSelectedCellWithTag:(NSInteger)tag;



@end


@interface NotificationListingCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIView *vwBackground;
@property (nonatomic,weak) IBOutlet UIImageView *imgTemplate;
@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblDescription;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,weak) IBOutlet UIButton *btnAccept;
@property (nonatomic,weak) IBOutlet UIButton *btnReject;
@property (nonatomic,weak)  id<NotificationListingCellDelegate>delegate;



@end
