//
//  AppDelegate.m
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define INSTAGRAM_SCHEME @"ig12345678910"
#define FACEBOOK_SCHEME  @"fb976918209110946"



#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "Constants.h"
#import "ChatComposeViewController.h"
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterIOSStyle.h"
#import "ChatUserListingViewController.h"
#import "MyMemmoriesViewController.h"
#import "Reachability.h"
#import "CommunityGEMListingViewController.h"
#import "EmotionalAwarenessViewController.h"
#import "GEMSListingsViewController.h"
#import "GoalsAndDreamsListingViewController.h"
#import "EmotionalIntelligenceViewController.h"
#import "MyFavouritesListingViewController.h"
#import "NotificationsListingViewController.h"
#import "ProfilePageViewController.h"
#import "WebBrowserViewController.h"
#import "SettingsViewController.h"
#import "GEMSWithHeaderListingsViewController.h"
#import "EventCreateViewController.h"
#import "ReminderListingViewController.h"
#import "LaunchPageViewController.h"
#import "JournalListViewController.h"
#import "IntroScreenViewController.h"
#import <Google/SignIn.h>

#define NOTIFICATION_TYPE_FOLLOW        @"follow"
#define NOTIFICATION_TYPE_CHAT          @"chat"
#define NOTIFICATION_TYPE_MEMMORY       @"memory"

@interface AppDelegate ()<UIAlertViewDelegate>{
    
    Reachability *internetReachability;
    UITabBarController *tabBarController;
    LaunchPageViewController *launchPage;
    SWRevealViewController *revealController;
    BOOL isAlertInProgress;
}

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.
    
  
    
    [self configureGoogleLoginIn];
    [Fabric with:@[[Crashlytics class]]];
    [Utility setUpGoogleMapConfiguration];
    [self getVersionStatus];
    [self getUserInfo];
    [self checkUserStatus];
    [self reachability];
    [self resetBadgeCount];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [self checkBuildForSignOut];
   
    return YES;
}

#pragma mark - Login with FB and Google configurations


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
        if ([[url scheme] isEqualToString:FACEBOOK_SCHEME]){
            return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation];
        }else
            return [[GIDSignIn sharedInstance] handleURL:url
                                       sourceApplication:sourceApplication
                                              annotation:annotation];
   
}

-(void)configureGoogleLoginIn{
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
}



-(void)logoutSinceUnAuthorized:(NSDictionary*)notification{
    if(isAlertInProgress) return;
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    isAlertInProgress = true;
    NSString *text = @"Invalid authentication token!";
    if (notification) {
        NSDictionary *dict  = notification;
        text = [dict objectForKey:@"text"];
    }
    [self clearUserSessions];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout"
                                                    message:text
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = 111;
    [alert show];
}

-(void)getUserInfo{
    
    [APIMapper getUserInfoOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([[responseObject objectForKey:@"status"] integerValue] == 1) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[responseObject objectForKey:@"title"]
                                                            message:[responseObject objectForKey:@"message"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    }];
    
}


-(void)getVersionStatus{
    
   [APIMapper getVersionStatusOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       
       if ([[responseObject objectForKey:@"status"] integerValue] == 1) {
           
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NEW VERSION AVAILABLE"
                                                           message:[responseObject objectForKey:@"text"]
                                                          delegate:self
                                                 cancelButtonTitle:@"CANCEL"
                                                 otherButtonTitles:@"UPDATE",nil];
           [alert show];
           alert.tag = 1;
       }
       
       
   } failure:^(AFHTTPRequestOperation *task, NSError *error) {
       
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                       message:error.localizedDescription
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil];
       [alert show];
       alert.tag = 2;

       
   }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 111){
        isAlertInProgress = false;
        return;
    }
    if (alertView.tag == 2) {
        
    }else{
        
        if (buttonIndex == 0) {
            //CANCEL
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppStoreURL]];
            //UPDATE
        }
    }
    
   exit(0);
   
}



-(void)checkBuildForSignOut{
    
    NSString * currentBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Build_No"])
    {
        NSString *lstBuild = [[NSUserDefaults standardUserDefaults] objectForKey:@"Build_No"];
        if ([lstBuild integerValue] < [currentBuild integerValue]) {
            [self clearUserSessions];
        }
         [[NSUserDefaults standardUserDefaults] setObject:currentBuild forKey:@"Build_No"];
        
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:currentBuild forKey:@"Build_No"];
       [self clearUserSessions];
    }


}

#pragma mark - Reachability

-(void)reachability{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
     internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
}

- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [internetReachability currentReachabilityStatus];
    NSString* statusString = @"";
    switch (netStatus)
    {
        case NotReachable:        {
            statusString = @"The internet is down.";
            break;
        }
            
        case ReachableViaWWAN:        {
            statusString = @"The internet is working via WWAN.";
            break;
        }
        case ReachableViaWiFi:        {
            statusString= @"The internet is working via WIFI.";
            break;
        }
    }
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Internet"
                                  message:statusString
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                             
                         }];
    [alert addAction:ok];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    
}


-(void)resetBadgeCount{
    
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [APIMapper updateBadgeCountWithuserIDOnsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
    }];
}

#pragma mark - Push Notifications

-(void)enablePushNotification{
    
    UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self updateTokenToWebServerWithToken:token];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error %@",err);
}

-(void)updateTokenToWebServerWithToken:(NSString*)token{
    
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    if ((token.length) && [User sharedManager].userId.length)
        [APIMapper setPushNotificationTokenWithUserID:[User sharedManager].userId token:token success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *task, NSError *error) {
            
        }];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self resetBadgeCount];
    if(application.applicationState == UIApplicationStateInactive) {
        [self handleNotificationWhenBackGroundWith:userInfo];
       completionHandler(UIBackgroundFetchResultNewData);
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
      //  [self handleNotificationWhenBackGroundWith:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
        
    } else {
        [self handleNotificationWhenForeGroundWith:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
        
    }
}


-(void)handleNotificationWhenBackGroundWith:(NSDictionary*)userInfo{
    if (NULL_TO_NIL([userInfo objectForKey:@"aps"])) {
        if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"notification_type"])) {
            NSString *notification_type =[[userInfo objectForKey:@"aps"] objectForKey:@"notification_type"];
            if ([notification_type isEqualToString:NOTIFICATION_TYPE_CHAT]){
                
                UINavigationController *nav = _navGeneral;
                if ([[nav.viewControllers lastObject] isKindOfClass:[ChatComposeViewController class]]) {
                    ChatComposeViewController *chatView = (ChatComposeViewController*)[nav.viewControllers lastObject];
                    NSString *fromUserID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                    if ([chatView.chatUserInfo objectForKey:@"chatuser_id"]) {
                        NSString *toUserID =[chatView.chatUserInfo objectForKey:@"chatuser_id"];
                        if ([toUserID isEqualToString:fromUserID]) {
                            [chatView newChatHasReceivedWithDetails:userInfo];
                        }else{
                            
                            NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: nav.viewControllers];
                            [navigationArray removeLastObject];  // You can pass your index here
                            nav.viewControllers = navigationArray;
                            ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatComposer];
                            NSString *fname = [[userInfo objectForKey:@"aps"] objectForKey:@"from_user"];
                            NSString *image = [[userInfo objectForKey:@"aps"] objectForKey:@"profileimg"];
                            NSString *userID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                            double dateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"] doubleValue];
                            NSDictionary *chatInfo = [[NSDictionary alloc] initWithObjectsAndKeys:fname,@"firstname",image,@"profileimage",userID,@"chatuser_id",[NSNumber numberWithDouble:dateTime],@"chat_datetime", nil];
                            chatCompose.chatUserInfo = chatInfo;
                            [nav pushViewController:chatCompose animated:YES];
                            
                        }
                    }
                    
                }else{
                    
                    if (!_navGeneral) {
                        ChatUserListingViewController *chatUser =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatUserListings];
                        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        app.navGeneral = [[UINavigationController alloc] initWithRootViewController:chatUser];
                        app.navGeneral.navigationBarHidden = true;
                        [UIView transitionWithView:app.window
                                          duration:0.3
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{  app.window.rootViewController = app.navGeneral; }
                                        completion:nil];
                        nav = app.navGeneral;
                        
                    }
                    
                    ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatComposer];
                    NSString *fname = [[userInfo objectForKey:@"aps"] objectForKey:@"from_user"];
                    NSString *image = [[userInfo objectForKey:@"aps"] objectForKey:@"profileimg"];
                    NSString *userID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                    double dateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"] doubleValue];
                    NSDictionary *chatInfo = [[NSDictionary alloc] initWithObjectsAndKeys:fname,@"firstname",image,@"profileimage",userID,@"chatuser_id",[NSNumber numberWithDouble:dateTime],@"chat_datetime", nil];
                    chatCompose.chatUserInfo = chatInfo;
                    [nav pushViewController:chatCompose animated:YES];
                    
                }

            }else if ([notification_type isEqualToString:NOTIFICATION_TYPE_MEMMORY]){
                [self configureMemmoryUserInfo:userInfo isFromBackGround:YES];
            }else if ([notification_type isEqualToString:NOTIFICATION_TYPE_FOLLOW]){
                
                [self configureFollowRequestWithUserInfo:userInfo];
            }else{
                [self handleOtherNotificationTypes:userInfo];
            }

        }
    }
    
}
-(void)handleNotificationWhenForeGroundWith:(NSDictionary*)userInfo{

    if (NULL_TO_NIL([userInfo objectForKey:@"aps"])) {
        if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"notification_type"])) {
            NSString *notification_type =[[userInfo objectForKey:@"aps"] objectForKey:@"notification_type"];
            if ([notification_type isEqualToString:NOTIFICATION_TYPE_CHAT]){
               __block UINavigationController *nav = _navGeneral;
                if ([[nav.viewControllers lastObject] isKindOfClass:[ChatComposeViewController class]]) {
                    
                    /*! If the user standing in the  chat page !*/
                    
                    ChatComposeViewController *chatView = (ChatComposeViewController*)[nav.viewControllers lastObject];
                    NSString *fromUserID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                    if ([chatView.chatUserInfo objectForKey:@"chatuser_id"]) {
                        NSString *toUserID =[chatView.chatUserInfo objectForKey:@"chatuser_id"];
                        if ([toUserID isEqualToString:fromUserID]) {
                            
                            /*! If chat notification comes with a same user !*/
                            
                            [chatView newChatHasReceivedWithDetails:userInfo];
                            
                        }else{
                            
                            /*! If chat notification comes with a defefrent user !*/
                            
                            
                            NSString *message;
                            NSString *appName = PROJECT_NAME;
                            if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
                                message = [NSString stringWithFormat:@"%@ : %@",[[userInfo objectForKey:@"aps"] objectForKey:@"from_user"],[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
                            [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
                            [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                                
                                NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: nav.viewControllers];
                                [navigationArray removeLastObject];  // You can pass your index here
                                nav.viewControllers = navigationArray;
                                ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatComposer];
                                NSString *fname = [[userInfo objectForKey:@"aps"] objectForKey:@"from_user"];
                                NSString *image = [[userInfo objectForKey:@"aps"] objectForKey:@"profileimg"];
                                NSString *userID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                                double dateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"] doubleValue];
                                NSDictionary *chatInfo = [[NSDictionary alloc] initWithObjectsAndKeys:fname,@"firstname",image,@"profileimage",userID,@"chatuser_id",[NSNumber numberWithDouble:dateTime],@"chat_datetime", nil];
                                chatCompose.chatUserInfo = chatInfo;
                                [nav pushViewController:chatCompose animated:YES];
                                
                            }];
                            
                        }
                    }
                    
                }
                else if([[nav.viewControllers lastObject] isKindOfClass:[ChatUserListingViewController class]]){
                    
                    /*! If the user standing in the  Chat User List page !*/
                    
                    ChatUserListingViewController *chatList = (ChatUserListingViewController*)[nav.viewControllers lastObject];
                    [chatList loadAllChatUsers];
                    NSString *message;
                    NSString *appName = PROJECT_NAME;
                    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
                        message = [NSString stringWithFormat:@"%@ : %@",[[userInfo objectForKey:@"aps"] objectForKey:@"from_user"],[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
                    [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
                    [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        [UIView transitionWithView:app.window
                                          duration:0.3
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{  app.window.rootViewController = app.navGeneral; }
                                        completion:nil];
                        ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatComposer];
                        NSString *fname = [[userInfo objectForKey:@"aps"] objectForKey:@"from_user"];
                        NSString *image = [[userInfo objectForKey:@"aps"] objectForKey:@"profileimg"];
                        NSString *userID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                        double dateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"] doubleValue];
                        NSDictionary *chatInfo = [[NSDictionary alloc] initWithObjectsAndKeys:fname,@"firstname",image,@"profileimage",userID,@"chatuser_id",[NSNumber numberWithDouble:dateTime],@"chat_datetime", nil];
                        chatCompose.chatUserInfo = chatInfo;
                        [nav pushViewController:chatCompose animated:YES];
                        
                    }];
                    
                }
                else{
                    
                    /*! All other pages !*/
                    
                    NSString *message;
                    NSString *appName = PROJECT_NAME;
                    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
                        message = [NSString stringWithFormat:@"%@ : %@",[[userInfo objectForKey:@"aps"] objectForKey:@"from_user"],[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
                    
                    [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
                    [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
                        
                        if (!_navGeneral) {
                            ChatUserListingViewController *chatUser =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatUserListings];
                            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                            app.navGeneral = [[UINavigationController alloc] initWithRootViewController:chatUser];
                            app.navGeneral.navigationBarHidden = true;
                            [UIView transitionWithView:app.window
                                              duration:0.3
                                               options:UIViewAnimationOptionTransitionCrossDissolve
                                            animations:^{  app.window.rootViewController = app.navGeneral; }
                                            completion:nil];
                            nav = app.navGeneral;
                            
                        }
                        ChatComposeViewController *chatCompose =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForChatComposer];
                        NSString *fname = [[userInfo objectForKey:@"aps"] objectForKey:@"from_user"];
                        NSString *image = [[userInfo objectForKey:@"aps"] objectForKey:@"profileimg"];
                        NSString *userID = [[userInfo objectForKey:@"aps"] objectForKey:@"from_id"];
                        double dateTime = [[[userInfo objectForKey:@"aps"] objectForKey:@"chat_datetime"] doubleValue];
                        NSDictionary *chatInfo = [[NSDictionary alloc] initWithObjectsAndKeys:fname,@"firstname",image,@"profileimage",userID,@"chatuser_id",[NSNumber numberWithDouble:dateTime],@"chat_datetime", nil];
                        chatCompose.chatUserInfo = chatInfo;
                        [nav pushViewController:chatCompose animated:YES];
                        
                    }];
                    
                }
            }else if ([notification_type isEqualToString:NOTIFICATION_TYPE_MEMMORY]){
                 [self configureMemmoryUserInfo:userInfo isFromBackGround:NO];
            }
            else if ([notification_type isEqualToString:NOTIFICATION_TYPE_FOLLOW]){
                [self configureFollowRequestWithUserInfo:userInfo];
            }else{
                [self handleOtherNotificationTypes:userInfo];
            }
        }
        
    }

}


-(void)configureFollowRequestWithUserInfo:(NSDictionary*)userInfo{
    
    NSString *title = @"PurposeColor";
    NSString *message;
    NSInteger followReqID;
    __block NSString *status;
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"title"]))
        title = [[userInfo objectForKey:@"aps"] objectForKey:@"title"];
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
        message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
        message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"followrequest_id"]))
        followReqID = [[[userInfo objectForKey:@"aps"] objectForKey:@"followrequest_id"] integerValue];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction;
    UIAlertAction *secondAction;
    if (followReqID > 0) {
        firstAction = [UIAlertAction actionWithTitle:@"Accept"
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   status = @"2";
                                                   [self updateFollowStatusWithFollowID:followReqID status:status];
                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                   
                                               }];
        secondAction = [UIAlertAction actionWithTitle:@"Reject"
                                                style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                    status = @"0";
                                                    [self updateFollowStatusWithFollowID:followReqID status:status];
                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                }];
        [alert addAction:firstAction];
        [alert addAction:secondAction];
        
    }else{
        
        firstAction = [UIAlertAction actionWithTitle:@"OK"
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                   [self refreshFollowButtonInClasses];
                                               }];
        [alert addAction:firstAction];
    }
    
    if (self.window.rootViewController)
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
}

-(void)updateFollowStatusWithFollowID:(NSInteger)followID status:(NSString*)status{
    
    [APIMapper updateFollowRequestByUserID:[User sharedManager].userId followRequestID:followID status:status success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self refreshFollowButtonInClasses];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
    }];
}

-(void)refreshFollowButtonInClasses{
    
    if (self.navRootVC) {
        
        if ([[self.navRootVC.viewControllers lastObject] isKindOfClass:[CommunityGEMListingViewController class]]){
            CommunityGEMListingViewController *communityVC = (CommunityGEMListingViewController*) [self.navRootVC.viewControllers lastObject];
            [communityVC refreshData];
        }
    }
 
   
}

-(void)configureMemmoryUserInfo:(NSDictionary*)memoryDetails isFromBackGround:(BOOL)isFromBackGround{
    
    NSString *message;
    NSString *appName = PROJECT_NAME;
    if (NULL_TO_NIL([[memoryDetails objectForKey:@"aps"] objectForKey:@"alert"]))
        message = [[memoryDetails objectForKey:@"aps"] objectForKey:@"alert"];
    
    if (isFromBackGround) {
        __block UINavigationController *nav = _navGeneral;
        
        if ([[nav.viewControllers lastObject] isKindOfClass:[MyMemmoriesViewController class]]) {
            /*! If the user standing in the  Memmory page !*/
        }else{
            
            /*! All other pages !*/
            
            MyMemmoriesViewController *myMemmories =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForMyMemmories];
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (!_navGeneral) {
                
                
                app.navGeneral = [[UINavigationController alloc] initWithRootViewController:myMemmories];
                app.navGeneral.navigationBarHidden = true;
                [UIView transitionWithView:app.window
                                  duration:0.3
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{  app.window.rootViewController = app.navGeneral; }
                                completion:nil];
                nav = app.navGeneral;
                
            }else{
                [app.navGeneral pushViewController:myMemmories animated:YES];
            }
        }

    }else{
        
        [JCNotificationCenter sharedCenter].presenter = [JCNotificationBannerPresenterIOSStyle new];
        [JCNotificationCenter enqueueNotificationWithTitle:appName message:message tapHandler:^{
            
            __block UINavigationController *nav = _navGeneral;
            
            if ([[nav.viewControllers lastObject] isKindOfClass:[MyMemmoriesViewController class]]) {
                /*! If the user standing in the  Memmory page !*/
            }else{
                
                /*! All other pages !*/
                
                MyMemmoriesViewController *myMemmories =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForMyMemmories];
                AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
                if (!_navGeneral) {
                    
                    
                    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:myMemmories];
                    app.navGeneral.navigationBarHidden = true;
                    [UIView transitionWithView:app.window
                                      duration:0.3
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{  app.window.rootViewController = app.navGeneral; }
                                    completion:nil];
                    nav = app.navGeneral;
                    
                }else{
                    [app.navGeneral pushViewController:myMemmories animated:YES];
                }
            }
            
        }];
    }
    
    
    
}

-(void)handleOtherNotificationTypes:(NSDictionary*)userInfo{
    
    NSString *title = @"PurposeColor";
    NSString *message;
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"title"]))
        title = [[userInfo objectForKey:@"aps"] objectForKey:@"title"];
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
        message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    if (NULL_TO_NIL([[userInfo objectForKey:@"aps"] objectForKey:@"alert"]))
        message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *firstAction;

    firstAction = [UIAlertAction actionWithTitle:@"OK"
                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                            }];
    [alert addAction:firstAction];
    
    
    if (self.window.rootViewController)
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Login Actions

-(void)checkUserStatus{
    
    if ([User sharedManager]) self.currentUser = (User*)[User sharedManager];
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (userExists) [self showLauchPage];
    else            [self showIntroLoginPage];

}

/*!.........Check Availability of User !...........*/

- (BOOL )loadUserObjectWithKey:(NSString *)key {
    BOOL isUserExists = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    if (encodedObject) {
        User *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        if (object)isUserExists = true;
        [self createUserObject:object];
        
    }
    return isUserExists;
}

-(void)createUserObject:(User*)user{
    
    // Creating singleton user object with Decoded data from NSUserDefaults
    
    [User sharedManager].isLoggedIn = user.isLoggedIn;
    [User sharedManager].userId = user.userId;
    [User sharedManager].userTypeId = user.userTypeId;
    [User sharedManager].name = user.name;
    [User sharedManager].email = user.email;
    [User sharedManager].regDate = user.regDate;
    [User sharedManager].loggedStatus = user.loggedStatus;
    [User sharedManager].verifiedStatus = user.verifiedStatus;
    [User sharedManager].profileurl = user.profileurl;
    [User sharedManager].cartCount = user.cartCount;
    [User sharedManager].notificationCount = user.notificationCount;
    [User sharedManager].companyID = user.companyID;
    [User sharedManager].statusMsg = user.statusMsg;
    [User sharedManager].follow_status = user.follow_status;
    [User sharedManager].daily_notify  = user.daily_notify;
    [User sharedManager].token  = user.token;
    
}


-(void)showIntroLoginPage{
    
    IntroScreenViewController *introScreen =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForIntroScreen];
    UINavigationController *logginVC = [[UINavigationController alloc] initWithRootViewController:introScreen];
    logginVC.navigationBarHidden = true;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = logginVC;
    [self.window makeKeyAndVisible];
}

// Success call back from login after successful attempt

-(void)goToHomeAfterLogin{
    
    [self enablePushNotification];
    launchPage = nil;
    revealController = nil;
    [self showLauchPage];
}

- (void)showLauchPage {
    
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (!launchPage){
        launchPage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:HomeDetailsStoryBoard Identifier:StoryBoardIdentifierForLaunchPage];
        // GEMSWithHeaderListingsViewController *imotionalAwareness =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMWithHeaderListings];
        UINavigationController *navHome = [[UINavigationController alloc] initWithRootViewController:launchPage];
        MenuViewController *menuVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:HomeDetailsStoryBoard Identifier:StoryBoardIdentifierForMenuPage];
        UINavigationController *navMenu = [[UINavigationController alloc] initWithRootViewController:menuVC];
        navMenu.navigationBarHidden = true;
        revealController = [[SWRevealViewController alloc] initWithRearViewController:navMenu frontViewController:navHome];
        revealController.rightViewController = navMenu;
        navHome.navigationBarHidden = true;
    }
    
    [UIView transitionWithView:app.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ app.window.rootViewController = revealController; }
                    completion:nil];
 
}

#pragma mark - Dynamic Menu Selection

- (void)changeHomePageDynamicallyWithType:(EMenuActions)menu_type {
    
    switch (menu_type) {
            
        case eMenu_Community_GEMS:
            [self showCommubityGEMS];
            break;
            
        case eMenu_EmotionalAwareness:
             [self showEmotionalAwarenessPageIsFromVisualization:NO];
            break;
            
        case eMenu_GEMS:
            //[self showGEMSListingsPage];
            break;
            
        case eMenu_Goals_Dreams:
            [self showGoalsAndDreams];
            break;
            
        case eMenu_Emotional_Intelligence:
            [self emotionalIntelligencePage];
            break;
            
        case eMenu_Favourites:
            [self showAllMyFavouriteGEMs];
            break;
            
        case eMenu_Notifications:
            [self showNotificationListings];
            break;
            
        case eMenu_SavedGEMs:
            [self showAllInspiredGEMs];
            break;
                        
        case eMenu_Memories:
            [self showMyMemmories];
            break;
            
        case eMenu_Profile:
            [self showUserProfilePage];
            break;
            
        case eMenu_Logout:
            [self logOutUser];
            break;
            
        case eMenu_Settings:
            [self showSettings];
            break;
            
        case eMenu_Reminders:
            [self showReminders];
            break;
            
        case eMenu_Terms:
            [self showTermsOfSerivice];
            break;
            
        case eMenu_Privacy:
            [self showPrivacyPolicy];
            break;
            
        case eMenu_Share:
            [self shareApp];
            break;
            
        case eMenu_Journal:
            [self showJournalListView];
            break;
            
        default:
            break;
    }

    
}
-(void)showEmotionalAwarenessPage{
    
    [self showEmotionalAwarenessPageIsFromVisualization:NO];
   // [launchPage showEmoitonalAwareness:nil];
}


-(void)showCommubityGEMS{
    
    [launchPage showCommunityGems:nil];
}

-(void)showGEMSListingsPage{
    
    [launchPage showGEMS:nil];
}

-(void)showGoalsAndDreams{
    
   [launchPage showGoalsAndDreams:nil];
}

-(void)emotionalIntelligencePage{
    
  [launchPage showEmoitonalIntelligence:nil];
}

-(void)showAllMyFavouriteGEMs{
    
  MyFavouritesListingViewController *myFavourites =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForMyFavourites];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:myFavourites];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];}

-(void)showAllInspiredGEMs{
    
    MyFavouritesListingViewController *myFavourites =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForMyFavourites];
     myFavourites.isInspiredGEM = true;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:myFavourites];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];

}


-(void)showNotificationListings{
    
     NotificationsListingViewController *notifications =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForNotificationsListing];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:notifications];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    
}


-(void)showMyMemmories{
    
   MyMemmoriesViewController *myMemmories =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForMyMemmories];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:myMemmories];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
}

-(void)showUserProfilePage{
    
    ProfilePageViewController *profilePage =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForProfilePage];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:profilePage];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    profilePage.canEdit = true;
    [profilePage loadUserProfileWithUserID:[User sharedManager].userId showBackButton:YES];
    
   
    
}

-(void)showHelpPage{
    
   WebBrowserViewController *browser = [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForWebBrowser];
    UINavigationController *navHome = [[UINavigationController alloc] initWithRootViewController:browser];
    if ([self.window.rootViewController isKindOfClass:[SWRevealViewController class]]) {
        SWRevealViewController *root = (SWRevealViewController*)self.window.rootViewController;
        root.frontViewController = navHome;
    }
    _navGeneral = navHome;
    _navGeneral.navigationBarHidden = true;
    browser.strTitle = @"HELP";
    browser.strURL =[NSString stringWithFormat:@"%@help.php",ExternalWebPageURL];
}

-(void)showPrivacyPolicy{
    
    WebBrowserViewController *browser = [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForWebBrowser];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:browser];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    _navGeneral.navigationBarHidden = true;
    browser.strTitle = @"PRIVACY POLICY";
    
    
}

-(void)shareApp{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *nav;
    nav = (UINavigationController*) delegate.window.rootViewController;
    NSArray *objectsToShare = @[[NSURL URLWithString:@"https://itunes.apple.com/us/app/purpose-color-life-success/id1186639523?ls=1&mt=8"]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    [nav presentViewController:activityVC animated:YES completion:nil];

    
}

-(void)showTermsOfSerivice{
    
    WebBrowserViewController *browser = [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForWebBrowser];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:browser];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    _navGeneral.navigationBarHidden = true;
    browser.strTitle = @"TERMS OF SERVICE";
    
}

-(void)showSettings{
    
    SettingsViewController *settings =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForSettings];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:settings];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
}

-(void)showReminders{
    
    ReminderListingViewController *reminder =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForReminderListings];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:reminder];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
}
-(void)showJournalListView{
    
    JournalListViewController *journalList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForJournalListVC];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:journalList];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
}

-(void)showEmotionalAwarenessPageIsFromVisualization:(BOOL)isFromVsiualization{
    
    EmotionalAwarenessViewController *journalList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForImotionalAwareness];
    journalList.shouldOpenFirstMenu = isFromVsiualization;
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:journalList];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
}




-(void)logOutUser{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Confirm Logout"
                                  message:@"Logout from the app ?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self clearUserSessions];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(void)clearUserSessions{
    
    BOOL userExists = [self loadUserObjectWithKey:@"USER"];
    if (!userExists) return;
    
    [self showLoadingScreen];
    [APIMapper logoutFromAccount:[User sharedManager].userId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[GIDSignIn sharedInstance] signOut];
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (defaults && [defaults objectForKey:@"USER"])
            [defaults removeObjectForKey:@"USER"];
        [delegate checkUserStatus];
        [self hideLoadingScreen];
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Logout"
                                      message:[error localizedDescription]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        
        [alert addAction:ok];
         AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app.window.rootViewController presentViewController:alert animated:YES completion:nil];
        [self hideLoadingScreen];
    }];
    
    
}



-(void)showLoadingScreen{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.dimBackground = YES;
    hud.detailsLabelText = @"loading...";
    hud.removeFromSuperViewOnHide = YES;
    
}
-(void)hideLoadingScreen{
    
    [MBProgressHUD hideHUDForView:self.window animated:YES];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
     [self resetBadgeCount];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [FBSDKAppEvents activateApp];
    if ([User sharedManager].userId.length) [self enablePushNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.sample.SignSpot" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SignSpot" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SignSpot.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}




@end
