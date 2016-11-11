//
//  CustomCellWithTable.h
//  PurposeColor
//
//  Created by Purpose Code on 06/10/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol ActionDetailCellDelegate <NSObject>


@optional

/*!
 *This method is invoked when user Clicks "LIKE" Button
 */
-(void)mediaCellClickedWithSection:(NSInteger)section andIndex:(NSInteger)index parentSection:(NSInteger)parentSection;




@end


#import <UIKit/UIKit.h>

@interface CustomCellWithTable : UITableViewCell

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak)  id<ActionDetailCellDelegate>delegate;
@property (nonatomic,strong) UIColor *headerBGColor;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstarintForTable;
@property (nonatomic,assign) BOOL isTabEmotion;

-(void)setUpParentSection:(NSInteger)parentSection;
-(void)setUpActionsWithDataSource:(NSArray*)dataSource;

@end
