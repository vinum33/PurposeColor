//
//  PhotoBrowser.h
//  PurposeColor
//
//  Created by Purpose Code on 08/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//



@protocol shareMediasDelegate <NSObject>


/*!
 *This method is invoked when user close the audio player view.
 */

-(void)closeShareMediasView;

@end


#import <UIKit/UIKit.h>

@interface shareMedias : UIView

@property (nonatomic,weak)  id<shareMediasDelegate>delegate;

-(void)setUpWithShareItems:(NSArray*)items text:(NSString*)text;

@end
