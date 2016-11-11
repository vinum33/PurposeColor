//
//  MenuViewController.h
//  RevealControllerStoryboardExample
//
//  Created by Nick Hodapp on 1/9/13.
//  Copyright (c) 2013 CoDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ProfilePageViewController : UIViewController


@property (nonatomic,assign) BOOL canEdit;
@property (nonatomic,weak) IBOutlet UIButton *btnSlideMenu;
@property (nonatomic,weak) IBOutlet UIButton *btnBack;

-(void)loadUserProfileWithUserID:(NSString*)userID showBackButton:(BOOL)showBckButton;

@end
