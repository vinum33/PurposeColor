//
//  LaunchPageViewController.m
//  PurposeColor
//
//  Created by Purpose Code on 15/11/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "LaunchPageViewController.h"
#import "AppDelegate.h"
#import "MenuViewController.h"
#import "Constants.h"
#import "CommunityGEMListingViewController.h"
#import "EmotionalAwarenessViewController.h"
#import "GEMSListingsViewController.h"
#import "GoalsAndDreamsListingViewController.h"
#import "EmotionalIntelligenceViewController.h"
#import "GEMSWithHeaderListingsViewController.h"
#import "GEMSListingsViewController.h"
#import "GEMSWithHeaderListingsViewController.h"
#import "AMPopTip.h"
#import "MyMemmoriesViewController.h"

@interface LaunchPageViewController () <SWRevealViewControllerDelegate>{
    
    IBOutlet UIView *vwContainer;
    UINavigationController *navForTabController;
    
    IBOutlet UIView *vwOverLay;
    
    IBOutlet UIButton *btnAwareness;
    IBOutlet UIButton *btnIntelligence;
    IBOutlet UIButton *btnGoalsAndDreams;
    IBOutlet UIButton *btnGEMs;
    IBOutlet UIButton *btnCommunityGems;
    IBOutlet UIButton *btnSlideMenu;
    
    AMPopTip *popTip;
}

@end

@implementation LaunchPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    [self launchHomePage];
    
    // Do any additional setup after loading the view.
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)customSetup
{
    vwOverLay.hidden = true;
    SWRevealViewController *revealViewController = self.revealViewController;
    revealViewController.delegate = self;
    if ( revealViewController )
    {
        [btnSlideMenu addTarget:self.revealViewController action:@selector(rightRevealToggle:)forControlEvents:UIControlEventTouchUpInside];
        [vwOverLay addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        
    }
    
}



-(void)launchHomePage{
    
    [self resetCurrentNavController];
    GEMSWithHeaderListingsViewController *gemsWithHeader =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMWithHeaderListings];
    navForTabController = [[UINavigationController alloc] init];
    navForTabController.viewControllers = [NSArray arrayWithObjects:gemsWithHeader, nil];
    navForTabController.navigationBarHidden = true;
    [self displayContentController];
}


-(IBAction)showGEMS:(UIButton*)sender{
    
    [self resetCurrentNavController];
    GEMSListingsViewController *gems =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGEMListings];
    navForTabController = [[UINavigationController alloc] init];
    navForTabController.viewControllers = [NSArray arrayWithObjects:gems, nil];
    navForTabController.navigationBarHidden = true;
    [self displayContentController];
    [btnGEMs setImage:[UIImage imageNamed:@"Menu_Gem_Active.png"] forState:UIControlStateNormal];
    if (!sender) return;
    CGPoint p = [sender.superview.superview convertPoint:sender.frame.origin toView:self.view];
    if (popTip) {
        [popTip hide];
        popTip = nil;
    }
    popTip = [AMPopTip popTip];
    [popTip showText:@"Visualization" direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:CGRectMake(p.x, p.y, 50, 50) duration:2];
    
    
}

-(IBAction)showEmoitonalAwareness:(UIButton*)sender{
    
    EmotionalAwarenessViewController *journalList =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForImotionalAwareness];
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.navGeneral = [[UINavigationController alloc] initWithRootViewController:journalList];
    app.navGeneral.navigationBarHidden = true;
    [UIView transitionWithView:app.window
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{  app.window.rootViewController = app.navGeneral; }
                    completion:nil];
    CGPoint p = [sender.superview.superview convertPoint:sender.frame.origin toView:self.view];
    if (popTip) {
        [popTip hide];
    }
    popTip = [AMPopTip popTip];
    [popTip showText:@"Emotional Awareness" direction:AMPopTipDirectionDown maxWidth:200 inView:journalList.view fromFrame:CGRectMake(p.x, p.y, 50, 50) duration:2];

    
    
    /*
    [self resetCurrentNavController];
    EmotionalAwarenessViewController *imotionalAwareness =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForImotionalAwareness];
    navForTabController = [[UINavigationController alloc] init];
    navForTabController.viewControllers = [NSArray arrayWithObjects:imotionalAwareness, nil];
    navForTabController.navigationBarHidden = true;
    [self displayContentController];;
    [btnAwareness setImage:[UIImage imageNamed:@"Menu_Emotion_Active.png"] forState:UIControlStateNormal];
    if (!sender) return;
    CGPoint p = [sender.superview.superview convertPoint:sender.frame.origin toView:self.view];
    if (popTip) {
        [popTip hide];
    }
    popTip = [AMPopTip popTip];
    [popTip showText:@"Emotional Awareness" direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:CGRectMake(p.x, p.y, 50, 50) duration:2];
     */
}

-(IBAction)showEmoitonalIntelligence:(UIButton*)sender{

    [self resetCurrentNavController];
    EmotionalIntelligenceViewController *emotionalIntelligence =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForEmotionalIntelligence];
    navForTabController = [[UINavigationController alloc] init];
    navForTabController.viewControllers = [NSArray arrayWithObjects:emotionalIntelligence, nil];
    navForTabController.navigationBarHidden = true;
    
    [self displayContentController];
    [btnIntelligence setImage:[UIImage imageNamed:@"Menu_Intelligence_Active.png"] forState:UIControlStateNormal];
    if (!sender) return;
    CGPoint p = [sender.superview.superview convertPoint:sender.frame.origin toView:self.view];
    BOOL shouldShow = false;
    if (popTip) {
        [popTip hide];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Intelligence_Show_Count"]){
        
    }else{
        
        NSInteger count = [[[NSUserDefaults standardUserDefaults] objectForKey:@"Intelligence_Show_Count"] integerValue];
        if (count == 2) {
            shouldShow = true;
        }else{
            
        }
    }
    
    if (shouldShow) {
        popTip = [AMPopTip popTip];
        [popTip showText:@"Emotional Intelligence" direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:CGRectMake(p.x , p.y, 50, 50) duration:2];
    }
    
}

-(IBAction)showGoalsAndDreams:(UIButton*)sender{
    
     [self resetCurrentNavController];
    GoalsAndDreamsListingViewController *goalsAndDreams =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForGoalsDreams];
    navForTabController = [[UINavigationController alloc] init];
    navForTabController.viewControllers = [NSArray arrayWithObjects:goalsAndDreams, nil];
    navForTabController.navigationBarHidden = true;
    
    [self displayContentController];
    [btnGoalsAndDreams setImage:[UIImage imageNamed:@"Menu_Goals_Active.png"] forState:UIControlStateNormal];
    if (!sender) return;
    CGPoint p = [sender.superview.superview convertPoint:sender.frame.origin toView:self.view];
    if (popTip) {
        [popTip hide];
    }
    popTip = [AMPopTip popTip];
    [popTip showText:@"Goals & Dreams" direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:CGRectMake(p.x, p.y, 50, 50) duration:2];
}

-(IBAction)showCommunityGems:(UIButton*)sender{
    
    [self resetCurrentNavController];
    navForTabController = [[UINavigationController alloc] init];
    
//     MyMemmoriesViewController *gemListingVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:ChatDetailsStoryBoard Identifier:StoryBoardIdentifierForMyMemmories];
    
    CommunityGEMListingViewController *gemListingVC =  [UIStoryboard get_ViewControllerFromStoryboardWithStoryBoardName:GEMDetailsStoryBoard Identifier:StoryBoardIdentifierForCommunityGEMListings];
    navForTabController.viewControllers = [NSArray arrayWithObjects:gemListingVC, nil];
    navForTabController.navigationBarHidden = true;
    
    [self displayContentController];;
   [btnCommunityGems setImage:[UIImage imageNamed:@"Menu_CommunityGem_Active.png"] forState:UIControlStateNormal];
    if (!sender) return;
    
    CGPoint p = [sender.superview.superview convertPoint:sender.frame.origin toView:self.view];
    if (popTip) {
        [popTip hide];
    }
    popTip = [AMPopTip popTip];
    [popTip showText:@"Inspiring GEM" direction:AMPopTipDirectionDown maxWidth:200 inView:self.view fromFrame:CGRectMake(p.x, p.y, 50, 50) duration:2];
}


-(void)resetCurrentNavController{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.navRootVC = nil;
    [navForTabController willMoveToParentViewController:nil];
    [navForTabController.view removeFromSuperview];
    [navForTabController removeFromParentViewController];
    navForTabController = nil;
    
    [btnAwareness setImage:[UIImage imageNamed:@"Menu_Emotion.png"] forState:UIControlStateNormal];
    [btnIntelligence setImage:[UIImage imageNamed:@"Menu_Intelligence.png"] forState:UIControlStateNormal];
    [btnGEMs setImage:[UIImage imageNamed:@"Menu_Gem.png"] forState:UIControlStateNormal];
    [btnCommunityGems setImage:[UIImage imageNamed:@"Menu_CommunityGem.png"] forState:UIControlStateNormal];
    [btnGoalsAndDreams setImage:[UIImage imageNamed:@"Menu_Goal.png"] forState:UIControlStateNormal];
    
}


- (void) displayContentController {

    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.navRootVC = navForTabController;
    [self addChildViewController:navForTabController];
    [navForTabController didMoveToParentViewController:self];
    navForTabController.view.frame = vwContainer.bounds;
    [vwContainer addSubview:navForTabController.view];
    navForTabController.navigationBarHidden = true;
        
    
}

#pragma mark - Slider View Setup and Delegates Methods

- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position{
    UINavigationController *nav = (UINavigationController*)revealController.rearViewController;
    if ([[nav.viewControllers objectAtIndex:0] isKindOfClass:[MenuViewController class]]) {
        MenuViewController *root = (MenuViewController*)[nav.viewControllers objectAtIndex:0];
        [root resetTable];
    }
    if (position == FrontViewPositionLeft) {
        [self setVisibilityForOverLayIsHide:YES];
    }else{
        [self setVisibilityForOverLayIsHide:NO];
    }
    
}
-(IBAction)hideSlider:(id)sender{
    [self.revealViewController rightRevealToggle:nil];
}

-(void)setVisibilityForOverLayIsHide:(BOOL)isHide{
    
    if (isHide) {
        [UIView transitionWithView:vwOverLay
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            vwOverLay.alpha = 0.0;
                        }
                        completion:^(BOOL finished) {
                            
                            vwOverLay.hidden = true;
                        }];
        
        
    }else{
        
        vwOverLay.hidden = false;
        [UIView transitionWithView:vwOverLay
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            vwOverLay.alpha = 0.7;
                        }
                        completion:^(BOOL finished) {
                            
                        }];
        
    }
}


#pragma mark state preservation / restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}


- (void)applicationFinishedRestoringState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Call whatever function you need to visually restore
    [self customSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
