//
//  InnerTableViewCell.h
//  PurposeColor
//
//  Created by Purpose Code on 06/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol ActionCellDelegate <NSObject>


@optional

/*!
 *This method is invoked when user Clicks "LIKE" Button
 */
-(void)mediaCellClickedWithSection:(NSInteger)section andIndex:(NSInteger)index ;




@end



#import <UIKit/UIKit.h>

@interface InnerTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,weak)  IBOutlet UIImageView *imgGem;
@property (nonatomic,weak) IBOutlet UIButton *btnVideoPlay;
@property (nonatomic,weak) IBOutlet  UIButton *btnAudioPlay;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic,weak)  id<ActionCellDelegate>delegate;

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;

@end
