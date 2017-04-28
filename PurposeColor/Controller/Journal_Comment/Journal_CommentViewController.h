//
//  CommentComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 11/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

@protocol Journal_CommentActionDelegate <NSObject>


@optional

/*!
 *This method is invoked when user Clicks "POST COMMENT" Button
 */
-(void)closeJournalCommentPopUpClicked;

-(void)notesUpdatedByNewNoteCount:(NSInteger)noteCount;


@end



#import <UIKit/UIKit.h>

@interface Journal_CommentViewController : UIViewController

@property (nonatomic,strong) NSDictionary *dictJournal;

@property (nonatomic,weak)  id<Journal_CommentActionDelegate>delegate;

-(void)showNavBar;


@end
