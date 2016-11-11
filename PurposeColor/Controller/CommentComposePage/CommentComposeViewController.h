//
//  CommentComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol CommentActionDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "CLOSE" Button
 */
-(void)commentPopUpCloseAppplied;

/*!
 *This method is invoked when user Clicks "POST COMMENT" Button
 */
-(void)commentPostedSuccessfullyWithGemID:(NSString*)gemID commentCount:(NSInteger)count index:(NSInteger)index isAddComment:(BOOL)isAddComment;


@end



#import <UIKit/UIKit.h>

@interface CommentComposeViewController : UIViewController

@property (nonatomic,strong) NSDictionary *dictGemDetails;
@property (nonatomic,assign) NSInteger     selectedIndex;
@property (nonatomic,assign) BOOL          isFromCommunityGem;

@property (nonatomic,weak)  id<CommentActionDelegate>delegate;



@end
