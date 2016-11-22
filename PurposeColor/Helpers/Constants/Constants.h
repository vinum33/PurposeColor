//
//  Utility.h
//  SignSpot
//
//  Created by Purpose Code on 09/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })
#define kUnauthorizedCode               401

extern NSString * const StoryboardForLogin;
extern NSString * const DetailsStoryBoard;
extern NSString * const HomeDetailsStoryBoard;
extern NSString * const GEMDetailsStoryBoard;
extern NSString * const ChatDetailsStoryBoard;
extern NSString * const PROJECT_NAME;
extern NSString * const NETWORK_ERROR_MESSAGE;

extern NSString * const CommonFont;
extern NSString * const CommonFontBold;
extern NSString * const BaseURLString;
extern NSString * const BaseURL;

extern NSString * const GoogleMapAPIKey;

extern NSString * const StoryBoardIdentifierForLoginPage;
extern NSString * const StoryBoardIdentifierForRegistrationPage;

extern NSString * const StoryBoardIdentifierForMenuPage;
extern NSString * const StoryBoardIdentifierForHomePage ;
extern NSString * const StoryBoardIdentifierForCommunityGEMListings ;
extern NSString * const StoryBoardIdentifierForCommentCompose ;
extern NSString * const StoryBoardIdentifierForGEMDetailPage ;
extern NSString * const StoryBoardIdentifierForMyGEMS;
extern NSString * const StoryBoardIdentifierForGoalsDreams;
extern NSString * const StoryBoardIdentifierForGoalsDreamsDetailPage;
extern NSString * const StoryBoardIdentifierForCreateActionMedias;
extern NSString * const StoryBoardIdentifierForEventManager;
extern NSString * const StoryBoardIdentifierForEmotionalIntelligence;
extern NSString * const StoryBoardIdentifierForGEMListings;
extern NSString * const StoryBoardIdentifierForGEMSEventListings;
extern NSString * const StoryBoardIdentifierForNotificationsListing;
extern NSString * const StoryBoardIdentifierForChatUserListings;
extern NSString * const StoryBoardIdentifierForChatComposer;
extern NSString * const StoryBoardIdentifierForImotionalAwareness;
extern NSString * const StoryBoardIdentifierForMyFavourites;
extern NSString * const StoryBoardIdentifierForMyMemmories;
extern NSString * const StoryBoardIdentifierForGoalDetails;
extern NSString * const StoryBoardIdentifierForProfilePage;
extern NSString * const StoryBoardIdentifierForLikedAndCommentedUsers;
extern NSString * const StoryBoardIdentifierForWebBrowser;
extern NSString * const ExternalWebPageURL;
extern NSString * const StoryBoardIdentifierForJournal;
extern NSString * const StoryBoardIdentifierForQuickGoalView;
extern NSString * const StoryBoardIdentifierForSettings;
extern NSString * const StoryBoardIdentifierForGEMWithHeaderListings;
extern NSString * const StoryBoardIdentifierForReminderListings;
extern NSString * const StoryBoardIdentifierForLaunchPage;
extern NSString * const StoryBoardIdentifierForLaunchPage;

