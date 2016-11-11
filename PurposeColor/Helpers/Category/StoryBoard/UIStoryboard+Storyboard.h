//
//  UIStoryboard+Storyboard.h
//  SmartBP
//
//  Created by vinayan on 27/10/15.
//  Copyright © 2015 Evolve Medical Systems, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Storyboard)

+(id)get_ViewControllerFromStoryboardWithStoryBoardName:(NSString*)storyBoardName Identifier:(NSString*)identifier;

@end
