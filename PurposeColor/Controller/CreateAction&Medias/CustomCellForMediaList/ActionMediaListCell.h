//
//  ActionMediaComposeCell.h
//  PurposeColor
//
//  Created by Purpose Code on 25/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionInfoCellDelegate <NSObject>



/*!
 *This method is invoked when user Clicks "PLAY MEDIA" Button
 */
-(void)playSelectedMediaWithIndex:(NSInteger)tag ;


@optional



@end

@interface ActionMediaListCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UIImageView *imgMediaThumbnail;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic,weak) IBOutlet UIButton *btnAudioPlay;
@property (nonatomic,weak) IBOutlet UIButton *btnVideoPlay;

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic,weak)  id<ActionInfoCellDelegate>delegate;

-(void)setUpIndexPathWithRow:(NSInteger)row section:(NSInteger)section;

@end
