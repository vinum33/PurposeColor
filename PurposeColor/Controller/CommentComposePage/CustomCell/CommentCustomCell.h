//
//  CommentCustomCell.h
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//
@protocol CommentCellDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "COMMENT" Button
 */
-(void)deleteCommentClicked:(NSInteger)index ;


@end


#import <UIKit/UIKit.h>

@interface CommentCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *imgProfilePic;

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblComment;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,assign) NSInteger index;

@property (nonatomic,weak)  id<CommentCellDelegate>delegate;
@end
