//
//  UIStoryboard+Storyboard.m
//  SmartBP
//
//  Created by vinayan on 27/10/15.
//  Copyright © 2015 Evolve Medical Systems, LLC. All rights reserved.
//

#import "UIStoryboard+Storyboard.h"

@implementation UIStoryboard (Storyboard)

+(id)get_ViewControllerFromStoryboardWithStoryBoardName:(NSString*)storyBoardName Identifier:(NSString*)identifier{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    
    if (storyboard){
        
        UIViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        return myViewController;
        
    }
    
    return nil;
    
    
}


+(id)get_ViewControllerFromStoryboardForSwiftWithStoryBoardName:(NSString*)storyBoardName Identifier:(NSString*)identifier{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyBoardName bundle:nil];
    
    if (storyboard){
        
        UIViewController *myViewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
        return myViewController;
        
    }
    
    return nil;
    
    
}

@end
