//
//  JournalDetailPageViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 21/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Journal_DetailViewDelegate <NSObject>


@optional

/*!
 *This method is invoked when user Clicks "POST COMMENT" Button
 */

-(void)notesUpdatedByNewNoteCountFromDetailView:(NSInteger)noteCount;


@end


@interface JournalDetailPageViewController : UIViewController

@property (nonatomic,strong) NSDictionary *journalDetails;
@property (nonatomic,weak)  id<Journal_DetailViewDelegate>delegate;

@end
