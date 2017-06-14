//
//  Utility.m
//  SignSpot
//
//  Created by Purpose Code on 24/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#define kTagForNodataScreen    1111

#import "Utility.h"
#import "Constants.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@import GoogleMaps;
@import GooglePlacePicker;

@implementation Utility

+ (void)saveUserObject:(id)object key:(NSString *)key {
    
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

+(void)setUpGoogleMapConfiguration{
    
    [GMSServices provideAPIKey:GoogleMapAPIKey];
    [GMSPlacesClient provideAPIKey:GoogleMapAPIKey];
}

+(void)showNoDataScreenOnView:(UIView*)view withTitle:(NSString*)title{
    
    UIView *noDataScreen =[UIView new];
    noDataScreen.tag = kTagForNodataScreen;
    noDataScreen.backgroundColor = [UIColor whiteColor];
    noDataScreen.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:noDataScreen];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-65-[noDataScreen]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noDataScreen)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[noDataScreen]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(noDataScreen)]];
    
    UILabel *lblTitle = [UILabel new];
    lblTitle.text = title;
    lblTitle.translatesAutoresizingMaskIntoConstraints = NO;
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:CommonFont size:17];
    lblTitle.textColor = [UIColor lightGrayColor];
    [noDataScreen addSubview:lblTitle];
    [noDataScreen addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
    [noDataScreen addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[lblTitle]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lblTitle)]];
   
}

+(void)removeNoDataScreen:(UIView*)_view{
    
    if ([_view viewWithTag:kTagForNodataScreen]) {
        
        [[_view viewWithTag:kTagForNodataScreen] removeFromSuperview];
    }
}
+(UITableViewCell *)getNoDataCustomCellWith:(UITableView*)aTableView withTitle:(NSString*)title{
    
    static NSString *MyIdentifier = @"MyIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:MyIdentifier];
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont fontWithName:CommonFont_New size:17];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0];;
    cell.textLabel.numberOfLines = 0;
    cell.backgroundColor = [UIColor getBackgroundOffWhiteColor];
    return cell;
}

+(void)removeAViewControllerFromNavStackWithType:(Class)vc from:(NSArray*)array{
    
    for(UIViewController *tempVC in array)
    {
        if([tempVC isKindOfClass:vc])
        {
            [tempVC removeFromParentViewController];
        }
    }

    
}

+(NSString*)getJournalMediaSaveFolderPath{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/PurposeColorJournalMedia"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    return dataPath;
    
}



+(NSString*)getMediaSaveFolderPath{
    
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/PurposeColorMedia"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    return dataPath;
    
}


+(UIImage*)getThumbNailFromVideoURL:(NSString*)videoURL{
    
    NSURL *url = [NSURL fileURLWithPath:videoURL];
    AVAsset *asset = [AVAsset assetWithURL:url];
    //  Get thumbnail at the very start of the video
    CMTime thumbnailTime = [asset duration];
    thumbnailTime.value = 0;
    //  Get image from the video at the given time
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = true;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:thumbnailTime actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

+(NSString*)getDaysBetweenTwoDatesWith:(double)timeInSeconds{
    
    NSDate * today = [NSDate date];
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDate *fromDate;
    NSDate *toDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:refDate];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:today];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute
                                               fromDate:fromDate toDate:toDate options:0];
    
    NSString *msgDate;
    NSInteger days = [difference day];
    if (days > 7) {
        NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
        [dateformater setDateFormat:@"d MMM,yyyy"];
        msgDate = [dateformater stringFromDate:refDate];
    }
    else if (days <= 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm a"];
        NSDate *date = refDate;
        msgDate = [dateFormatter stringFromDate:date];
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EE h:mm a"];
        msgDate = [dateFormatter stringFromDate:refDate];
    }
    
    return msgDate;
    
}

+(NSString*)getDateStringFromSecondsWith:(double)timeInSeconds withFormat:(NSString*)format{
    
    NSDate * refDate = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDateFormatter *dateformater = [[NSDateFormatter alloc]init];
    [dateformater setDateFormat:format];
    return [dateformater stringFromDate:refDate];;
    
}

+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:
                             NSCalendarIdentifierGregorian];
    
    unsigned unitFlagsDate = NSCalendarUnitYear | NSCalendarUnitMonth
    |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [gregorian components:unitFlagsDate
                                                    fromDate:date];
    unsigned unitFlagsTime = NSCalendarUnitHour | NSCalendarUnitMinute
    |  NSCalendarUnitSecond;
    NSDateComponents *timeComponents = [gregorian components:unitFlagsTime
                                                    fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [gregorian dateFromComponents:dateComponents];   
    
    return combDate;
}

+ (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

+(float)getSizeOfLabelWithText:(NSString*)text width:(float)width font:(UIFont*)font{
    
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size;
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:font}
                                                      context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    return size.height;
}


+(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = i_width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(BOOL)isStringContainsURLInString:(NSString*)string
{
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                               error:&error];
    NSArray *matches = [detector matchesInString:string
                                         options:0
                                           range:NSMakeRange(0, [string length])];
    if (matches.count > 0) {
        return true;
    }
    return false;
}

+ (BOOL)isEquivalentURLOne:(NSURL *)urlOne URLTwo:(NSURL *)URLTwo {
    
    if (urlOne && URLTwo) {
        
        if ([urlOne isEqual:URLTwo]) return YES;
        if ([[urlOne scheme] caseInsensitiveCompare:[URLTwo scheme]] != NSOrderedSame) return NO;
        if ([[urlOne host] caseInsensitiveCompare:[URLTwo host]] != NSOrderedSame) return NO;
        
        // NSURL path is smart about trimming trailing slashes
        // note case-sensitivty here
        if ([[urlOne path] compare:[URLTwo path]] != NSOrderedSame) return NO;
        
        // at this point, we've established that the urls are equivalent according to the rfc
        // insofar as scheme, host, and paths match
        
        // according to rfc2616, port's can weakly match if one is missing and the
        // other is default for the scheme, but for now, let's insist on an explicit match
        if ([urlOne port] || [URLTwo port]) {
            if (![[urlOne port] isEqual:[URLTwo port]]) return NO;
            if (![[urlOne query] isEqual:[URLTwo query]]) return NO;
        }
        return YES;
    }
    return NO;
   
    // for things like user/pw, fragment, etc., seems sensible to be
    // permissive about these.
    
}


@end
