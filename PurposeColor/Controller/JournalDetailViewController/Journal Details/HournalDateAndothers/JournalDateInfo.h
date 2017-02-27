//
//  JournalDateInfo.h
//  PurposeColor
//
//  Created by Purpose Code on 22/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalDateInfo : UITableViewCell


@property (nonatomic,weak) IBOutlet UILabel *lblDate;
@property (nonatomic,weak) IBOutlet UILabel *lblContact;
@property (nonatomic,weak) IBOutlet UILabel *lblLoc;
@property (nonatomic,weak) IBOutlet UILabel *lblEmotion;
@property (nonatomic,weak) IBOutlet UILabel *lblGoal;

@end
