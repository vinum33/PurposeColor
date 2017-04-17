//
//  AppDelegate.h
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

 enum{
    
    eMenu_EmotionalAwareness = 0,
    eMenu_GEMS = 3,
    eMenu_Goals_Dreams = 2,
    eMenu_Emotional_Intelligence = 1,
    eMenu_Community_GEMS = 4,
    eMenu_Reminders = 5,
     
    eMenu_Journal = 6,
    eMenu_SavedGEMs = 7,
    eMenu_Notifications = 8,
    eMenu_Privacy = 9,
    eMenu_Terms = 10,
    eMenu_Share = 11,
    eMenu_Logout = 12,
    
     
    eMenu_Memories = 13,
    eMenu_Help = 14,
    eMenu_Favourites = 15,
    eMenu_Profile = 16,
    eMenu_Settings = 17,
    
     
 };typedef NSInteger EMenuActions ;


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "LoginViewController.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,LoginDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) User *currentUser;
@property (strong, nonatomic)  UINavigationController *navRootVC;
@property (strong, nonatomic)  UINavigationController *navGeneral;

-(void)goToHomeAfterLogin;
- (void)showLauchPage;
-(void)checkUserStatus;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(void)enablePushNotification;
- (void)changeHomePageDynamicallyWithType:(EMenuActions)menu_type;
-(void)clearUserSessions;
-(void)showEmotionalAwarenessPageIsFromVisualization:(BOOL)isFromVsiualization;
-(void)showJournalListView;
-(void)showCommubityGEMS;
-(void)showGEMSListingsPage;
-(void)emotionalIntelligencePage;
-(void)logoutSinceUnAuthorized;
@end

