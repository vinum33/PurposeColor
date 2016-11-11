//
//  PhotoBrowser.h
//  PurposeColor
//
//  Created by Purpose Code on 08/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



@protocol PhotoBrowserDelegate <NSObject>


/*!
 *This method is invoked when user close the audio player view.
 */

-(void)closePhotoBrowserView;

@end


#import <UIKit/UIKit.h>

@interface PhotoBrowser : UIView

@property (nonatomic,weak)  id<PhotoBrowserDelegate>delegate;

-(void)setUpWithImages:(NSArray*)images;

@end
