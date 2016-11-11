//
//  User.h
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic,assign) BOOL       isLoggedIn;
@property (nonatomic,assign) BOOL       daily_notify;
@property (nonatomic,assign) BOOL       follow_status;
@property (nonatomic,strong) NSString * userId;
@property (nonatomic,strong) NSString * userTypeId;
@property (nonatomic,strong) NSString * statusMsg;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * email;
@property (nonatomic,strong) NSString * regDate;
@property (nonatomic,strong) NSString * loggedStatus;
@property (nonatomic,strong) NSString * verifiedStatus;
@property (nonatomic,strong) NSString * profileurl;
@property (nonatomic,assign) NSInteger cartCount;
@property (nonatomic,assign) NSInteger notificationCount;
@property (nonatomic,strong) NSString * companyID;


+ (User*)sharedManager;

@end
