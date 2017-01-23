//
//  APIMapper.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface APIMapper : NSObject

+ (void)registerUserWithName:(NSString*)userName userEmail:(NSString*)email phoneNumber:(NSString*)phone countryID:(NSString*)country userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)loginUserWithUserName:(NSString*)userName userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)forgotPasswordWithEmail:(NSString*)email success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllCommunityGemsByUserID:(NSString*)userID pageNo:(NSInteger)pageNo purposeGemShow:(BOOL)shouldShow success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)likeAGEMWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllCommentsForAGemWithGemID:(NSString*)gemID gemType:(NSString*)gemType shareComment:(NSInteger)shareType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)postCommentWithUserID:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType comment:(NSString*)comment shareComment:(NSInteger)shareType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)removeCommentWithCommentID:(NSString*)commentID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)sendFollowRequestWithUserID:(NSString*)userID followerID:(NSString*)followerID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getMyGemsByUserID:(NSString*)userID pageNo:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)deleteAGEMWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)hideAGEMWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)shareAGEMToCommunityWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)loadAllMyGoalsAndDreamsWith:(NSString*)userID pageNo:(NSInteger)pageNo status:(NSInteger)status success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getGoalActionDetailsByGoalActionID:(NSString*)goalActionID actionID:(NSString*)actionID goalID:(NSString*)goalID andUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateGoalActionStatusWithActionID:(NSString*)actionID goalID:(NSString*)goalID goalActionID:(NSString*)goalActionID andUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllMyRemindersWith:(NSString*)userID pageNumber:(NSInteger)pageNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)uploadActionMediasWithImageArray:(NSArray*)images OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure
                progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress;

+ (void)getPieChartViewWithUserID:(NSString*)userID startDate:(double)startDate endDate:(double)endDate session:(NSInteger)session isFirstTime:(BOOL)isFirstTime success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)deleteEmotionFromSupportingEmotionsWithEmotionID:(NSString*)emotionID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllGoalsWith:(NSString*)userID pageNo:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllGEMEmotionsByUserID:(NSString*)userID pageNo:(NSInteger)pageNo isFirstTime:(BOOL)isFirstTime success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllEventsByUserID:(NSString*)userID groupID:(NSString*)groupID pageNo:(NSInteger)pageNo sortType:(NSInteger)sortType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)setPushNotificationTokenWithUserID:(NSString*)userID token:(NSString*)token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateFollowRequestByUserID:(NSString*)userID followRequestID:(NSInteger)followRequestID status:(NSString*)status success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;
                                   
+ (void)getAllMyNotificationsWith:(NSString*)userID pageNumber:(NSInteger)pageNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllChatUsersWithUserID:(NSString*)userID pageNumber:(NSInteger)pageNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)postChatMessageWithUserID:(NSString*)userID toUserID:(NSString*)toUser message:(NSString*)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)loadChatHistoryWithFrom:(NSString*)userID toUserID:(NSString*)toUser page:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)deleteChatWithIDs:(NSArray*)ids success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllEmotionsWithUserID:(NSString*)userID emotionValue:(NSInteger)emotionID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)addNewEmotionWithUserID:(NSString*)userID feelValue:(NSInteger)feelValue emotionTitle:(NSString*)title operationType:(NSInteger)type emotionID:(NSInteger)emotionID  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)addNewEventWithUserID:(NSString*)userID eventTitle:(NSString*)title operationType:(NSInteger)type eventID:(NSInteger)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllEmotionalAwarenessGEMSListsWithUserID:(NSString*)userID gemType:(NSString*)gemType goalID:(NSInteger)goalID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+(void)createOrEditAGemWith:(NSArray*)dataSource eventTitle:(NSString*)title description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)adress address:(NSString*)locAddress contactName:(NSString*)conatctName gemID:(NSString*)gemID goalID:(NSString*)goalID deletedIDs:(NSMutableArray*)deletedIDs gemType:(NSString*)gemType OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress;

+(void)shareGEMToPurposeColorWith:(NSArray*)dataSource eventTitle:(NSString*)title description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)adress address:(NSString*)locAddress contactName:(NSString*)conatctName gemID:(NSString*)gemID deletedIDs:(NSMutableArray*)deletedIDs gemType:(NSString*)gemType OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress;

+ (void)createNewReminderForActionWithActionID:(NSInteger)goalActionID title:(NSString*)title descrption:(NSString*)description startDate:(double)startDate endDate:(double)endDate  startTime:(NSString*)startTime endTime:(NSString*)endTime actionAlert:(NSInteger)alertTime userID:(NSString*)userID repeatValue:(NSString*)repeatValue success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)addGemToFavouritesWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllFavouritesByUserID:(NSString*)userID pageNo:(NSInteger)pageNo type:(BOOL)isInspired success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)removeFromFavouritesWithUserID:(NSString*)userID favouriteID:(NSString*)favouriteID type:(BOOL)isInspired success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getGemDetailsForEditWithGEMID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getGoalDetailsWithGoalID:(NSString*)goalID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getAllTodaysMemoryWithUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getUserProfileWithUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateUserProfileWithUserID:(NSString*)userID firstName:(NSString*)fname statusMsg:(NSString*)statusMsg image:(UIImage*)image canFollow:(BOOL)canFollow success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getUserListingsWithGemID:(NSString*)gemID type:(NSString*)listType userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)addEmotionToSupportingEmotionsWithEmotionID:(NSString*)emotionID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)copyAGEMToNewGEMWithGEMID:(NSString*)gemID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)logoutFromAccount:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateBadgeCountWithuserIDOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)updateUserSettingsWithUserID:(NSString*)userID canFollow:(BOOL)canFollow dailyNotification:(BOOL)dailyNotification adminListSuggestions:(NSMutableDictionary*)dictList success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)changePasswordWithCurrentPwd:(NSString*)currentPWD newPWD:(NSString*)newPWD confirmPWD:(NSString*)confirmPWD success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+(void)createOrEditAGoalWith:(NSArray*)dataSource eventTitle:(NSString*)title description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)locName address:(NSString*)locAddress contactName:(NSString*)conatctName gemID:(NSString*)gemID goalID:(NSString*)goalID deletedIDs:(NSMutableArray*)deletedIDs gemType:(NSString*)gemType achievementDate:(double)achievementDate status:(NSString*)status isPurposeColor:(BOOL)isPurposeColor OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress;

+(void)createAJournelWith:(NSArray*)dataSource description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)locName address:(NSString*)locAddress contactName:(NSString*)conatctName emotionAwarenssValues:(NSDictionary*)awarenessValues OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress;

+ (void)getAllAbuseReasonsOnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)postReportAbuseWithUserID:(NSString*)userID gemUserID:(NSString*)gemUserID gemID:(NSString*)gemID option:(NSInteger)option otherInfo:(NSString*)otherInfo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)getWebContentWithType:(NSString*)type success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;

+ (void)checkUserHasEntryInPurposeColorOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure;


@end
