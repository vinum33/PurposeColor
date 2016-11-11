//
//  GalleryManager.h
//  PurposeColor
//
//  Created by Purpose Code on 26/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GalleryManager : NSObject

+(void)saveSelectedVideoFileToFolderWithURL:(NSData*)movieData;
+(void)saveSelectedImageFileToFolderWithImage:(UIImage*)info;
+(NSString*)getPathWhereVideoNeedsToBeSaved;
@end
