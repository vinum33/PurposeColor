//
//  JournalListCustomCell.h
//  PurposeColor
//
//  Created by Purpose Code on 20/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalCommentListCustomCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UILabel *lblTitle;
@property (nonatomic,weak) IBOutlet UILabel *lblNo;
@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UIImageView *imgRound;

@end
