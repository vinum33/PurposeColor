//
//  JournalGalleryViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 22/02/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JournalGalleryViewController : UIViewController

@property (nonatomic,strong) NSArray* arrMedia;

-(void)filterMedias;
@end
