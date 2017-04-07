//
//  AwarenessMediaViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 05/04/17.
//  Copyright © 2017 Purpose Code. All rights reserved.
//

@protocol AwarenessMediaDelegate <NSObject>



/*!
 *This method is invoked when user Clicks "PLAY MEDIA" Button
 */
-(void)closeButtonAppliedWithChangedArray:(NSMutableArray*)array;

@end



@interface AwarenessMediaViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *arrMedias;
@property (nonatomic,weak)  id<AwarenessMediaDelegate>delegate;

@end
