//
//  APIMapper.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "APIMapper.h"
#import "Constants.h"

@implementation APIMapper

+ (void)registerUserWithName:(NSString*)userName userEmail:(NSString*)email phoneNumber:(NSString*)phone countryID:(NSString*)country userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *task, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=register",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"firstname": userName,
                             @"email": email,
                             @"password":password,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure (operation,error);
    }];

    
}

+ (void)loginUserWithUserName:(NSString*)userName userPassword:(NSString*)password success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=login",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"email": userName,
                             @"password": password,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error.localizedDescription);
        failure (operation,error);
    }];

    
    
}


+ (void)forgotPasswordWithEmail:(NSString*)email success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=forgotpassword",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"email": email,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    

}

+ (void)getAllCommunityGemsByUserID:(NSString*)userID pageNo:(NSInteger)pageNo purposeGemShow:(BOOL)shouldShow success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getallcommunitygems",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNo],
                             @"first_time":[NSNumber numberWithBool:shouldShow]
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)likeAGEMWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=like",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"gem_id": gemID,
                             @"gem_type": gemType
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)addGemToFavouritesWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=addtofavorite",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"gem_id": gemID,
                             @"gem_type": gemType
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}



+ (void)getAllCommentsForAGemWithGemID:(NSString*)gemID gemType:(NSString*)gemType shareComment:(NSInteger)shareType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getcomments",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"gem_id": gemID,
                             @"gem_type": gemType,
                             @"user_id": [User sharedManager].userId,
                              @"share_comment": [NSNumber numberWithInteger:shareType]
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)postCommentWithUserID:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType comment:(NSString*)comment shareComment:(NSInteger)shareType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=addcomments",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"gem_id": gemID,
                             @"gem_type": gemType,
                             @"share_comment": [NSNumber numberWithInteger:shareType],
                             @"user_id": userID,
                             @"comment_txt": comment
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}
+ (void)removeCommentWithCommentID:(NSString*)commentID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=removecomment",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"comment_id": commentID,
                             @"user_id": [User sharedManager].userId,
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)sendFollowRequestWithUserID:(NSString*)userID followerID:(NSString*)followerID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=follow",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"followid": followerID
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)getMyGemsByUserID:(NSString*)userID pageNo:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=mygems",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNo]
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)deleteAGEMWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=deletegem",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"gem_id": gemID,
                             @"gem_type": gemType
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)hideAGEMWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=hidegem",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"gem_id": gemID,
                             @"gem_type": gemType
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)shareAGEMToCommunityWith:(NSString*)userID gemID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=sharetocommunity",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"gem_id": gemID,
                             @"gem_type": gemType
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)loadAllMyGoalsAndDreamsWith:(NSString*)userID pageNo:(NSInteger)pageNo status:(NSInteger)status success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=goalsanddreams",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNo],
                              @"status": [NSNumber numberWithInteger:status],
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

    
}

+ (void)getGoalActionDetailsByGoalActionID:(NSString*)goalActionID actionID:(NSString*)actionID goalID:(NSString*)goalID andUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getactiondetails",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"goalaction_id": goalActionID,
                             @"user_id": userID,
                             @"goal_id": goalID,
                             @"action_id": actionID
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)updateGoalActionStatusWithActionID:(NSString*)actionID goalID:(NSString*)goalID goalActionID:(NSString*)goalActionID  andUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=updategoalaction",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"goal_id": goalID,
                             @"action_id": actionID,
                             @"goalaction_id": goalActionID,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+(void)uploadActionMediasWithImageArray:(NSArray*)dataSource OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=addmedia",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"media_count": [NSNumber numberWithInteger:dataSource.count],
                             };
    AFHTTPRequestOperation *operation = [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
       
        NSInteger index = 1;
        NSString *dataPath = [Utility getMediaSaveFolderPath];
        for (NSString *filename in dataSource) {
            NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                if ([[filename pathExtension] isEqualToString:@"jpeg"]){
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                }
                else if ([[filename pathExtension] isEqualToString:@"mp4"]){
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"video/mp4"];
                }
                else if ([[filename pathExtension] isEqualToString:@"aac"]){
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"audio/aac"];
                }
                index ++;
                
            }
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        progress(totalBytesWritten,totalBytesExpectedToWrite);
        
    }];

    
    
}
+ (void)getPieChartViewWithUserID:(NSString*)userID startDate:(double)startDate endDate:(double)endDate session:(NSInteger)session isFirstTime:(BOOL)isFirstTime success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=emotional_intelligence",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userID forKey:@"user_id"];
    if (startDate > 0) [params setObject:[NSNumber numberWithDouble:startDate] forKey:@"start_date"];
    if (endDate > 0) [params setObject:[NSNumber numberWithDouble:endDate] forKey:@"end_date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ZZZZZ"];
    [params setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"timezone"];
    
    [params setObject:[NSNumber numberWithInteger:session] forKey:@"time_at"];
    [params setObject:[NSNumber numberWithBool:isFirstTime] forKey:@"first_time"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)getAllGEMEmotionsByUserID:(NSString*)userID pageNo:(NSInteger)pageNo isFirstTime:(BOOL)isFirstTime success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=GEMemotions",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNo],
                               @"first_time":[NSNumber numberWithBool:isFirstTime]
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)getAllGoalsWith:(NSString*)userID pageNo:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=GEMgoals",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNo],
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)getAllEventsByUserID:(NSString*)userID groupID:(NSString*)groupID pageNo:(NSInteger)pageNo sortType:(NSInteger)sortType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=detailedGEMview",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                            @"group_id": groupID,
                            @"page_no": [NSNumber numberWithInteger:pageNo],
                            @"list_type": [NSNumber numberWithInteger:sortType],
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)setPushNotificationTokenWithUserID:(NSString*)userID token:(NSString*)token success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=setusertoken",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    if (userID.length > 0) {
        NSDictionary *params = @{@"user_id": userID,
                                 @"registration_id": token,
                                 @"device_os" : @"ios"
                                 };
        
        [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            success(operation,responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            failure (operation,error);
        }];
    }
   

}


+ (void)updateFollowRequestByUserID:(NSString*)userID followRequestID:(NSInteger)followRequestID status:(NSString*)status success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=updatefollowstatus",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"follow_status": status,
                             @"followrequest_id" : [NSNumber numberWithInteger:followRequestID]
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)getAllMyNotificationsWith:(NSString*)userID pageNumber:(NSInteger)pageNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getallnotifications",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNumber]
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)getAllMyRemindersWith:(NSString*)userID pageNumber:(NSInteger)pageNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getallreminder",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNumber]
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}


+ (void)getAllChatUsersWithUserID:(NSString*)userID pageNumber:(NSInteger)pageNumber success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=chatuserlist",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)postChatMessageWithUserID:(NSString*)userID toUserID:(NSString*)toUser message:(NSString*)message success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=chatmessage",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"from_id": userID,
                             @"to_id": toUser,
                             @"msg": message,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)loadChatHistoryWithFrom:(NSString*)userID toUserID:(NSString*)toUser page:(NSInteger)pageNo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=chathistory",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"from_id": userID,
                             @"to_id": toUser,
                             @"page_no": [NSNumber numberWithInteger:pageNo]
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)deleteChatWithIDs:(NSArray*)ids success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=deletechat",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"chat_ids": ids,
                             @"user_id": [User sharedManager].userId,
                             };
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)getAllEmotionsWithUserID:(NSString*)userID emotionValue:(NSInteger)emotionID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=emotions",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"emotion_value" : [NSNumber numberWithInteger:emotionID]
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)addNewEmotionWithUserID:(NSString*)userID feelValue:(NSInteger)feelValue emotionTitle:(NSString*)title operationType:(NSInteger)type emotionID:(NSInteger)emotionID  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=manageemotion",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"emotion_value" : [NSNumber numberWithInteger:feelValue],
                             @"emotion_title": title,
                             @"type" : [NSNumber numberWithInteger:type],
                             @"emotion_id" : [NSNumber numberWithInteger:emotionID],
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)addNewEventWithUserID:(NSString*)userID eventTitle:(NSString*)title operationType:(NSInteger)type eventID:(NSInteger)eventID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=manageevent",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"event_title": title,
                             @"type" : [NSNumber numberWithInteger:type],
                             @"event_id" : [NSNumber numberWithInteger:eventID],
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)getAllEmotionalAwarenessGEMSListsWithUserID:(NSString*)userID gemType:(NSString*)gemType goalID:(NSInteger)goalID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getallgems",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[User sharedManager].userId forKey:@"user_id"];
    [params setObject:gemType forKey:@"gem_type"];
    if (goalID > 0) [params setObject:[NSNumber numberWithInteger:goalID] forKey:@"goal_id"];
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}



+(void)createOrEditAGemWith:(NSArray*)dataSource eventTitle:(NSString*)title description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)locName address:(NSString*)locAddress contactName:(NSString*)conatctName gemID:(NSString*)gemID goalID:(NSString*)goalID deletedIDs:(NSMutableArray*)deletedIDs gemType:(NSString*)gemType OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=gemaction",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[User sharedManager].userId forKey:@"user_id"];
    [params setObject:title forKey:@"title"];
    [params setObject:descritption forKey:@"details"];
    [params setObject:gemType forKey:@"gem_type"];
    if (locName.length){
        NSMutableDictionary *location = [NSMutableDictionary new];
        [location setObject:locName forKey:@"location_name"];
        if (locAddress.length)[location setObject:locAddress forKey:@"location_address"];
        [location setObject:[NSNumber numberWithDouble:latitude] forKey:@"location_latitude"];
        [location setObject:[NSNumber numberWithDouble:longitude] forKey:@"location_longitude"];
        [params setObject:location forKey:@"location"];
        
    }
    if (conatctName.length) [params setObject:conatctName forKey:@"contact_name"];
    if (gemID.length) [params setObject:gemID forKey:@"gem_id"];
    if (goalID.length) [params setObject:goalID forKey:@"goal_id"];
    NSInteger mediacount = dataSource.count;
    if (gemID.length){
        mediacount = 0;
        for (id obj in dataSource) {
            if (![obj isKindOfClass:[NSDictionary class]])
                mediacount ++;
        }
    }
    [params setObject:[NSNumber numberWithInteger:mediacount] forKey:@"media_count"];
    [params setObject:deletedIDs forKey:@"media_id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *jsonEvent = [NSDictionary dictionaryWithObjectsAndKeys:jsonString,@"json_event", nil];
    
    AFHTTPRequestOperation *operation = [manager POST:urlString parameters:jsonEvent constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger index = 1;
        NSString *dataPath = [Utility getMediaSaveFolderPath];
        for (id object in dataSource) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                
            }else{
                NSString *filename = (NSString*)object;
                NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
                if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    if ([[filename pathExtension] isEqualToString:@"jpeg"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                    }
                    else if ([[filename pathExtension] isEqualToString:@"mp4"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"video/mp4"];
                        UIImage *thumbnail = [Utility getThumbNailFromVideoURL:filePath];
                        NSData *imageData = UIImageJPEGRepresentation(thumbnail,1);
                        if (imageData.length)
                            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"video_thumb%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                    }
                    else if ([[filename pathExtension] isEqualToString:@"aac"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"audio/aac"];
                    }
                    
                    index ++;
                    
                }
            }
           
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        progress(totalBytesWritten,totalBytesExpectedToWrite);
        
    }];
    
}

+(void)createOrEditAGoalWith:(NSArray*)dataSource eventTitle:(NSString*)title description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)locName address:(NSString*)locAddress contactName:(NSString*)conatctName gemID:(NSString*)gemID goalID:(NSString*)goalID deletedIDs:(NSMutableArray*)deletedIDs gemType:(NSString*)gemType achievementDate:(double)achievementDate status:(NSString*)status isPurposeColor:(BOOL)isPurposeColor OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=gemaction",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[User sharedManager].userId forKey:@"user_id"];
    [params setObject:title forKey:@"title"];
    [params setObject:descritption forKey:@"details"];
    [params setObject:gemType forKey:@"gem_type"];
    if (locName.length){
        NSMutableDictionary *location = [NSMutableDictionary new];
        [location setObject:locName forKey:@"location_name"];
        if (locAddress.length)[location setObject:locAddress forKey:@"location_address"];
        [location setObject:[NSNumber numberWithDouble:latitude] forKey:@"location_latitude"];
        [location setObject:[NSNumber numberWithDouble:longitude] forKey:@"location_longitude"];
        [params setObject:location forKey:@"location"];
        
    }
    [params setObject:[NSNumber numberWithDouble:achievementDate] forKey:@"goal_enddate"];
    NSInteger _status = 0;
    if ([status isEqualToString:@"Completed"]) {
        _status = 1;
    }
    [params setObject:[NSNumber numberWithInteger:_status] forKey:@"goal_status"];
    if (gemID.length){
        if (isPurposeColor) [params setObject:gemID forKey:@"purposegem_id"];
        else [params setObject:gemID forKey:@"gem_id"];
    }
    if (conatctName.length) [params setObject:conatctName forKey:@"contact_name"];
    if (goalID.length) [params setObject:goalID forKey:@"goal_id"];
    NSInteger mediacount = dataSource.count;
    if (gemID.length){
        mediacount = 0;
        for (id obj in dataSource) {
            if (![obj isKindOfClass:[NSDictionary class]])
                mediacount ++;
        }
    }
    [params setObject:[NSNumber numberWithInteger:mediacount] forKey:@"media_count"];
    [params setObject:deletedIDs forKey:@"media_id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *jsonEvent = [NSDictionary dictionaryWithObjectsAndKeys:jsonString,@"json_event", nil];
    
    AFHTTPRequestOperation *operation = [manager POST:urlString parameters:jsonEvent constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger index = 1;
        NSString *dataPath = [Utility getMediaSaveFolderPath];
        for (id object in dataSource) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                
            }else{
                NSString *filename = (NSString*)object;
                NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
                if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    if ([[filename pathExtension] isEqualToString:@"jpeg"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                    }
                    else if ([[filename pathExtension] isEqualToString:@"mp4"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"video/mp4"];
                        UIImage *thumbnail = [Utility getThumbNailFromVideoURL:filePath];
                        NSData *imageData = UIImageJPEGRepresentation(thumbnail,1);
                        if (imageData.length)
                            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"video_thumb%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                    }
                    else if ([[filename pathExtension] isEqualToString:@"aac"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"audio/aac"];
                    }
                    
                    index ++;
                    
                }
            }
            
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        progress(totalBytesWritten,totalBytesExpectedToWrite);
        
    }];
    
}

+(void)shareGEMToPurposeColorWith:(NSArray*)dataSource eventTitle:(NSString*)title description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)locName address:(NSString*)locAddress contactName:(NSString*)conatctName gemID:(NSString*)gemID deletedIDs:(NSMutableArray*)deletedIDs gemType:(NSString*)gemType OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=shareaction",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[User sharedManager].userId forKey:@"user_id"];
    [params setObject:title forKey:@"title"];
    [params setObject:descritption forKey:@"details"];
    [params setObject:gemType forKey:@"gem_type"];
    if (locName.length){
        NSMutableDictionary *location = [NSMutableDictionary new];
        [location setObject:locName forKey:@"location_name"];
        if (locAddress.length)[location setObject:locAddress forKey:@"location_address"];
        [location setObject:[NSNumber numberWithDouble:latitude] forKey:@"location_latitude"];
        [location setObject:[NSNumber numberWithDouble:longitude] forKey:@"location_longitude"];
        [params setObject:location forKey:@"location"];
        
    }
    if (conatctName.length) [params setObject:conatctName forKey:@"contact_name"];
    if (gemID.length) [params setObject:gemID forKey:@"gem_id"];
    NSInteger mediacount = dataSource.count;
    if (gemID.length){
        mediacount = 0;
        for (id obj in dataSource) {
            if (![obj isKindOfClass:[NSDictionary class]])
                mediacount ++;
        }
    }
    [params setObject:[NSNumber numberWithInteger:mediacount] forKey:@"media_count"];
    [params setObject:deletedIDs forKey:@"media_id"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSDictionary *jsonEvent = [NSDictionary dictionaryWithObjectsAndKeys:jsonString,@"json_event", nil];
    
    AFHTTPRequestOperation *operation = [manager POST:urlString parameters:jsonEvent constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger index = 1;
        NSString *dataPath = [Utility getMediaSaveFolderPath];
        for (id object in dataSource) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                
            }else{
                NSString *filename = (NSString*)object;
                NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
                if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
                {
                    if ([[filename pathExtension] isEqualToString:@"jpeg"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                    }
                    else if ([[filename pathExtension] isEqualToString:@"mp4"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"video/mp4"];
                        UIImage *thumbnail = [Utility getThumbNailFromVideoURL:filePath];
                        NSData *imageData = UIImageJPEGRepresentation(thumbnail,1);
                        if (imageData.length)
                            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"video_thumb%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                    }
                    else if ([[filename pathExtension] isEqualToString:@"aac"]){
                        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                        [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"audio/aac"];
                    }
                    
                    index ++;
                    
                }
            }
            
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        progress(totalBytesWritten,totalBytesExpectedToWrite);
        
    }];
    
}

+ (void)createNewReminderForActionWithActionID:(NSInteger)goalActionID title:(NSString*)title descrption:(NSString*)description startDate:(double)startDate endDate:(double)endDate  startTime:(NSString*)startTime endTime:(NSString*)endTime actionAlert:(NSInteger)alertTime userID:(NSString*)userID repeatValue:(NSString*)repeatValue success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=newreminder",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ZZZZZ"];
   
    
    NSDictionary *params = @{@"user_id": userID,
                             @"goalaction_id": [NSNumber numberWithInteger:goalActionID],
                             @"reminder_startdate": [NSNumber numberWithLong:startDate],
                             @"reminder_starttime": startTime,
                             @"reminder_enddate": [NSNumber numberWithLong:endDate],
                             @"reminder_endtime": endTime,
                             @"reminder_title": title,
                             @"reminder_desc": description,
                             @"reminder_alert": [NSNumber numberWithInteger:alertTime],
                             @"reminder_repeat": repeatValue,
                             @"timezone": [dateFormatter stringFromDate:[NSDate date]],
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}


+(void)createAJournelWith:(NSArray*)dataSource description:(NSString*)descritption latitude:(double)latitude longitude:(double)longitude locName:(NSString*)locName address:(NSString*)locAddress contactName:(NSString*)conatctName emotionAwarenssValues:(NSDictionary*)awarenessValues OnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure progress:(void (^)( long long totalBytesWritten,long long totalBytesExpectedToWrite))progress{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=savejournal",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[User sharedManager].userId forKey:@"user_id"];
    if (descritption.length)[params setObject:descritption forKey:@"journal_desc"];
    if (locName.length){
        NSMutableDictionary *location = [NSMutableDictionary new];
        [location setObject:locName forKey:@"location_name"];
        if (locAddress.length)[location setObject:locAddress forKey:@"location_address"];
        [location setObject:[NSNumber numberWithDouble:latitude] forKey:@"location_latitude"];
        [location setObject:[NSNumber numberWithDouble:longitude] forKey:@"location_longitude"];
        [params setObject:location forKey:@"location"];
        
    }
    
    if (conatctName.length) [params setObject:conatctName forKey:@"contact_name"];
    NSInteger mediacount = dataSource.count;
    [params setObject:[NSNumber numberWithInteger:mediacount] forKey:@"media_count"];
    
    NSMutableDictionary *jounalValues = [NSMutableDictionary new];
    if ([params count]) {
        [jounalValues setObject:params forKey:@"json_journal"];
    }
    
    if ([awarenessValues count]) {
        [jounalValues setObject:awarenessValues forKey:@"json_awareness"];
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jounalValues options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *json = @{@"json": jsonString};

    AFHTTPRequestOperation *operation = [manager POST:urlString parameters:json constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSInteger index = 1;
        NSString *dataPath = [Utility getMediaSaveFolderPath];
        for (id object in dataSource) {
            NSString *filename = (NSString*)object;
            NSString *filePath = [dataPath stringByAppendingPathComponent:filename];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                if ([[filename pathExtension] isEqualToString:@"jpeg"]){
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                }
                else if ([[filename pathExtension] isEqualToString:@"mp4"]){
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"video/mp4"];
                    UIImage *thumbnail = [Utility getThumbNailFromVideoURL:filePath];
                    NSData *imageData = UIImageJPEGRepresentation(thumbnail,1);
                    if (imageData.length)
                        [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"video_thumb%ld",(long)index] fileName:@"Media" mimeType:@"image/jpeg"];
                }
                else if ([[filename pathExtension] isEqualToString:@"aac"]){
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"media_file%ld",(long)index] fileName:@"Media" mimeType:@"audio/aac"];
                }
                
                index ++;
                
            }
            
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        
        progress(totalBytesWritten,totalBytesExpectedToWrite);
        
    }];
    
}



+ (void)getAllFavouritesByUserID:(NSString*)userID pageNo:(NSInteger)pageNo type:(BOOL)isInspired success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@action=getallfavourites",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"page_no": [NSNumber numberWithInteger:pageNo],
                             @"type" : @"favourite"
                             };
    if (isInspired) {
        params = @{@"user_id": userID,
                   @"page_no": [NSNumber numberWithInteger:pageNo],
                   @"type" : @"inspired"
                   };
    }
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    

}

+ (void)removeFromFavouritesWithUserID:(NSString*)userID favouriteID:(NSString*)favouriteID type:(BOOL)isInspired success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=removefavourite",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"id": favouriteID,
                             @"type": @"favourite",
                             };
    if (isInspired) {
        params = @{@"user_id": userID,
                   @"id": favouriteID,
                   @"type" : @"inspired"
                   };
    }
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)getGemDetailsForEditWithGEMID:(NSString*)gemID gemType:(NSString*)gemType success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=editgem",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"gem_id": gemID,
                             @"gem_type": gemType
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

    
}
+ (void)getGoalDetailsWithGoalID:(NSString*)goalID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getgoaldetails",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             @"goal_id": goalID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

    
}

+ (void)getAllTodaysMemoryWithUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    NSString *urlString = [NSString stringWithFormat:@"%@action=memories",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

    
}

+ (void)getUserProfileWithUserID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=getuserprofile",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)updateUserProfileWithUserID:(NSString*)userID firstName:(NSString*)fname statusMsg:(NSString*)statusMsg image:(UIImage*)image canFollow:(BOOL)canFollow success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=editprofile",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userID forKey:@"user_id"];
    [params setObject:fname forKey:@"firstname"];
    if (statusMsg.length)  [params setObject:statusMsg forKey:@"status"];
    NSData *data;
    if (image) data =  UIImageJPEGRepresentation(image, 0.1);
    [manager POST:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (data.length)
             [formData appendPartWithFileData:data name:@"profileimg" fileName:@"Media" mimeType:@"image/jpeg"];
       
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
        
    }];
    
}

+ (void)updateUserSettingsWithUserID:(NSString*)userID canFollow:(BOOL)canFollow dailyNotification:(BOOL)dailyNotification success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=editsettings",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userID forKey:@"user_id"];
    [params setObject:[NSNumber numberWithBool:canFollow] forKey:@"can_follow"];
    [params setObject:[NSNumber numberWithBool:dailyNotification] forKey:@"daily_notify"];
   
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
}

+ (void)getUserListingsWithGemID:(NSString*)gemID type:(NSString*)listType userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=userlist",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"gem_id": gemID,
                             @"type": listType,
                             @"user_id": userID,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)addEmotionToSupportingEmotionsWithEmotionID:(NSString*)emotionID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=addtosupportemotion",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"emotion_id": emotionID,
                             @"user_id": userID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)deleteEmotionFromSupportingEmotionsWithEmotionID:(NSString*)emotionID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=removesupportemotion",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"emotion_id": emotionID,
                             @"user_id": userID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)copyAGEMToNewGEMWithGEMID:(NSString*)gemID userID:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=copygem",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"gem_id": gemID,
                             @"user_id": userID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}


+ (void)logoutFromAccount:(NSString*)userID success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=logout",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": userID,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)changePasswordWithCurrentPwd:(NSString*)currentPWD newPWD:(NSString*)newPWD confirmPWD:(NSString*)confirmPWD success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=changepassword",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": [User sharedManager].userId,
                             @"oldpass": currentPWD,
                             @"newpass": newPWD,
                             };
    
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}

+ (void)updateBadgeCountWithuserIDOnsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=updatebadge",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"user_id": [User sharedManager].userId,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

}
+ (void)getAllAbuseReasonsOnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=reportquestions",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}

+ (void)postReportAbuseWithUserID:(NSString*)userID gemUserID:(NSString*)gemUserID gemID:(NSString*)gemID option:(NSInteger)option otherInfo:(NSString*)otherInfo success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=sendreportabuse",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (otherInfo.length)[params setObject:otherInfo forKey:@"other_info"];
    [params setObject:userID forKey:@"user_id"];
    [params setObject:gemUserID forKey:@"touser_id"];
    [params setObject:gemID forKey:@"gem_id"];
    if (option >= 0)[params setObject:[NSNumber numberWithInteger:option] forKey:@"abuse_id"];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];

    
}

+ (void)getWebContentWithType:(NSString*)type success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *task, NSError *error))failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@action=webcontent",BaseURLString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    NSDictionary *params = @{@"type": type,
                             };
    
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(operation,responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure (operation,error);
    }];
    
}


@end
