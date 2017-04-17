//
//  User.m
//  SignSpot
//
//  Created by Purpose Code on 10/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "User.h"

@implementation User

+(User*)sharedManager {
    
    static User *currentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentUser = [[self alloc] init];
    });
    return currentUser;
    
}


- (User*)init {
    if ( (self = [super init]) ) {
        // your custom initialization
        
        self.isLoggedIn = false;
        self.userTypeId = [NSString new];
        self.userId = [NSString new];
        self.name = [NSString new];
        self.email = [NSString new];
        self.regDate = [NSString new];
        self.loggedStatus = [NSString new];
        self.verifiedStatus = [NSString new];
        self.profileurl = [NSString new];
        self.cartCount = 0;
        self.notificationCount = 0;
        self.companyID = [NSString new];
        self.statusMsg = [NSString new];
        self.token = [NSString new];
        
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeBool:self.isLoggedIn forKey:@"LoggedIn"];
    [encoder encodeObject:self.userTypeId forKey:@"UserTypeID"];
    [encoder encodeObject:self.userId forKey:@"userID"];
    [encoder encodeObject:self.name forKey:@"Name"];
    [encoder encodeObject:self.email forKey:@"Email"];
    [encoder encodeObject:self.regDate forKey:@"RegDate"];
    [encoder encodeObject:self.loggedStatus forKey:@"LoggedStatus"];
    [encoder encodeObject:self.verifiedStatus forKey:@"VerifiedStatus"];
    [encoder encodeObject:self.profileurl forKey:@"ProfileURL"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.cartCount] forKey:@"CartCount"];
    [encoder encodeObject:[NSNumber numberWithInteger:self.notificationCount]forKey:@"NotificationCount"];
    [encoder encodeObject:self.companyID forKey:@"CompanyID"];
    [encoder encodeObject:self.statusMsg forKey:@"StatusMessage"];
    [encoder encodeBool:self.daily_notify forKey:@"DailyNotify"];
    [encoder encodeBool:self.follow_status forKey:@"FollowStatus"];
    [encoder encodeObject:self.token forKey:@"Token"];
    
    
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.isLoggedIn = [decoder decodeBoolForKey:@"LoggedIn"];
        self.userTypeId = [decoder decodeObjectForKey:@"UserTypeID"];
        self.userId = [decoder decodeObjectForKey:@"userID"];
        self.name = [decoder decodeObjectForKey:@"Name"];
        self.email = [decoder decodeObjectForKey:@"Email"];
        self.regDate = [decoder decodeObjectForKey:@"RegDate"];
        self.loggedStatus = [decoder decodeObjectForKey:@"LoggedStatus"];
        self.verifiedStatus = [decoder decodeObjectForKey:@"VerifiedStatus"];
        self.profileurl = [decoder decodeObjectForKey:@"ProfileURL"];
        self.cartCount = [[decoder decodeObjectForKey:@"CartCount"] integerValue];
        self.notificationCount = [[decoder decodeObjectForKey:@"NotificationCount"] integerValue];
        self.companyID = [decoder decodeObjectForKey:@"CompanyID"];
        self.statusMsg = [decoder decodeObjectForKey:@"StatusMessage"];
        self.daily_notify = [decoder decodeBoolForKey:@"DailyNotify"];
        self.follow_status = [decoder decodeBoolForKey:@"FollowStatus"];
        self.token = [decoder decodeObjectForKey:@"Token"];
    }
    return self;
}

@end
