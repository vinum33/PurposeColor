//
//  ActionDetailsCustomCell.m
//  PurposeColor
//
//  Created by Purpose Code on 22/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "ActionDetailsCustomCell.h"

@interface ActionDetailsCustomCell(){
    
    IBOutlet UIView *vwSelection;
    IBOutlet UIView *vwContainer;
    IBOutlet UILabel *lblPending;
    IBOutlet UILabel *lblCompleted;
    
    BOOL isLaunch;
    
    
}

@end

@implementation ActionDetailsCustomCell

- (void)awakeFromNib {
    // Initialization code
        vwSelection.frame = CGRectMake(0, 0, 150, 40);
        vwSelection.backgroundColor = [UIColor getThemeColor];
        vwContainer.layer.cornerRadius = 20;
        vwContainer.layer.borderWidth = 1.f;
        vwContainer.layer.borderColor = [UIColor getSeperatorColor].CGColor;
       _lblDescription.systemURLStyle = YES;
       _lblDescription.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        [self attemptOpenURL:[NSURL URLWithString:string]];
    };
}

- (void)attemptOpenURL:(NSURL *)url
{
    
    
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (!safariCompatible) {
        
        NSString *urlString = url.absoluteString;
        urlString = [NSString stringWithFormat:@"http://%@",url.absoluteString];
        url = [NSURL URLWithString:urlString];
        
    }
    safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problem"
                                                        message:@"The selected link cannot be opened."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUp{
    
    isLaunch = true;
    if (_isStatusPending)
        [self performSelector:@selector(switchToPending:) withObject:nil afterDelay:0];
    else
        [self performSelector:@selector(switchToComplete:) withObject:nil afterDelay:0];
}

-(IBAction)switchToComplete:(id)sender{
    
    if(isLaunch){
        
        vwSelection.backgroundColor = [UIColor getThemeColor];
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = vwSelection.frame;
            frame.origin.x = 75;
            vwSelection.frame = frame;
            vwContainer.backgroundColor = [UIColor getBackgroundOffWhiteColor];
        }completion:^(BOOL finished) {
            lblPending.textColor = [UIColor blackColor];
            lblCompleted.textColor = [UIColor whiteColor];
            isLaunch = false;
            if (sender)[self updateActionStatus];
            
        }];
        
    }else{
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        UINavigationController *nav = delegate.navGeneral;
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Action"
                                                                       message:@"Do you want to change this action to Complete ?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  vwSelection.backgroundColor = [UIColor getThemeColor];
                                                                  [UIView animateWithDuration:0.3 animations:^{
                                                                      CGRect frame = vwSelection.frame;
                                                                      frame.origin.x = 75;
                                                                      vwSelection.frame = frame;
                                                                      vwContainer.backgroundColor = [UIColor getBackgroundOffWhiteColor];
                                                                     
                                                                  }completion:^(BOOL finished) {
                                                                      
                                                                      lblPending.textColor = [UIColor blackColor];
                                                                      lblCompleted.textColor = [UIColor whiteColor];
                                                                      if (sender)[self updateActionStatus];
                                                                      [self popToGoalsAndDreams];
                                                                      
                                                                  }];
                                                                  
                                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
        UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        [alert addAction:firstAction];
        [alert addAction:second];
        [nav presentViewController:alert animated:YES completion:nil];
        
    }
}

-(IBAction)switchToPending:(id)sender{
    
    if(isLaunch){
        vwSelection.backgroundColor = [UIColor getThemeColor];
        [UIView animateWithDuration:.3 animations:^{
            CGRect frame = vwSelection.frame;
            frame.origin.x = 0;
            vwSelection.frame = frame;
            vwContainer.backgroundColor = [UIColor whiteColor];
            
        }completion:^(BOOL finished) {
            
            lblPending.textColor = [UIColor whiteColor];
            lblCompleted.textColor = [UIColor blackColor];
            isLaunch = false;
            if (sender)[self updateActionStatus];
        }];
        
    }else{
        
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        UINavigationController *nav = delegate.navGeneral;
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Action"
                                                                       message:@"Do you want to change this action to Pending?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *firstAction = [UIAlertAction actionWithTitle:@"YES"
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  
                                                                  vwSelection.backgroundColor = [UIColor getThemeColor];
                                                                  [UIView animateWithDuration:.3 animations:^{
                                                                      CGRect frame = vwSelection.frame;
                                                                      frame.origin.x = 0;
                                                                      vwSelection.frame = frame;
                                                                      vwContainer.backgroundColor = [UIColor whiteColor];
                                                                      
                                                                      
                                                                  }completion:^(BOOL finished) {
                                                                      
                                                                      lblPending.textColor = [UIColor whiteColor];
                                                                      lblCompleted.textColor = [UIColor blackColor];
                                                                      if (sender)[self updateActionStatus];
                                                                       [self popToGoalsAndDreams];
                                                                  }];
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  
                                                              }];
        UIAlertAction *second = [UIAlertAction actionWithTitle:@"NO"
                                                         style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                             
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        [alert addAction:firstAction];
        [alert addAction:second];
        [nav presentViewController:alert animated:YES completion:nil];
        
    }
    
    
    
}

-(void)updateActionStatus{
    
    if ([self.delegate respondsToSelector:@selector(updateGoalActionStatus)]) {
        [self.delegate updateGoalActionStatus];
    }
}

-(IBAction)editButtonClicked:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(editButtonClicked)]) {
        [self.delegate editButtonClicked];
    }
}


-(void)popToGoalsAndDreams{
    if ([self.delegate respondsToSelector:@selector(actionStatusChanged)]) {
        [self.delegate actionStatusChanged];
    }
}


@end
