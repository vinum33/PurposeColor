//
//  GalleryManager.m
//  PurposeColor
//
//  Created by Purpose Code on 26/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "GalleryManager.h"

@implementation GalleryManager

+(void)saveSelectedVideoFileToFolderWithURL:(NSData*)movieData{
    
    NSString *prefixString = @"PurposeColorVideo";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",[Utility getMediaSaveFolderPath],uniqueFileName];
    [movieData writeToFile:outputFile atomically:YES];
    
}

+(void)saveSelectedImageFileToFolderWithImage:(UIImage*)image{
    
    NSData *pngData = UIImageJPEGRepresentation(image, 0.1f);
    NSString *prefixString = @"PurposeColorImage";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.jpeg",[Utility getMediaSaveFolderPath],uniqueFileName];
    [pngData writeToFile:outputFile atomically:YES];
}

+(NSString*)getPathWhereVideoNeedsToBeSaved{
    
    NSString *prefixString = @"PurposeColorVideo";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",[Utility getMediaSaveFolderPath],uniqueFileName];
    return outputFile;
    
    
}




+(void)saveJournalVideoFileToFolderWithURL:(NSData*)movieData{
    
    NSString *prefixString = @"PurposeColorVideo";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",[Utility getJournalMediaSaveFolderPath],uniqueFileName];
    [movieData writeToFile:outputFile atomically:YES];
    
}

+(void)saveJournalImageFileToFolderWithImage:(UIImage*)image{
    
    NSData *pngData = UIImageJPEGRepresentation(image, 0.1f);
    NSString *prefixString = @"PurposeColorImage";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.jpeg",[Utility getJournalMediaSaveFolderPath],uniqueFileName];
    [pngData writeToFile:outputFile atomically:YES];
}
+(NSString*)getPathWhereJournalVideoNeedsToBeSaved{
    
    NSString *prefixString = @"PurposeColorVideo";
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString] ;
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", prefixString, guid];
    NSString *outputFile = [NSString stringWithFormat:@"%@/%@.mp4",[Utility getJournalMediaSaveFolderPath],uniqueFileName];
    return outputFile;
    
    
}


@end
