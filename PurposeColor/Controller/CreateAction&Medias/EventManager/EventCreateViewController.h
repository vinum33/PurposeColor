//
//  EventCreateViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 26/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventCreateViewController : UIViewController

@property (nonatomic,assign) NSInteger goalID;

@property (nonatomic,strong) NSString *strGoalTitle;
@property (nonatomic,strong) NSString *strGoalDescription;
@property (nonatomic,strong) NSString *strRepeatValue;
@property (nonatomic,assign) NSInteger reminderTime;

@property (nonatomic,strong) NSDate *startDate;
@property (nonatomic,strong) NSDate *startTime;
@property (nonatomic,strong) NSDate *endDate;
@property (nonatomic,strong) NSDate *endTime;

@property (nonatomic,assign) double  achievementDate;
@end
