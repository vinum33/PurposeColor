//
//  GemDetailsCustomTableViewCell.m
//  PurposeColor
//
//  Created by Purpose Code on 18/07/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//


#define kSectionCount               1
#define kSuccessCode                200
#define kMinimumCellCount           1
#define kHeaderHeight               0
#define kCellHeight                 45
#define kEmptyHeaderAndFooter       0
#define kCellHeightForCompleted     190


#import "GoalsAndDreamsCustomCell.h"
#import "InnerTableCustomCell.h"

@interface GoalsAndDreamsCustomCell (){
    
    BOOL isDataAvailable;
}

@end

@implementation GoalsAndDreamsCustomCell

- (void)awakeFromNib {
    // Initialization code
    _lblDescription.systemURLStyle = YES;
    
    // Attach block for handling taps on usenames
    _lblDescription.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        [self attemptOpenURL:[NSURL URLWithString:string]];
    };

    
    
 }

-(void)updateStatus:(UIButton*)btnStatus{
    
    if ([self.delegate respondsToSelector:@selector(updatePendingStatusByIndex:actionIndex:)]) {
        [self.delegate updatePendingStatusByIndex:self.row actionIndex:btnStatus.tag];
    }
    
}

-(IBAction)goalDetailButtonClicked:(UIButton*)btnStatus{
    
    if ([self.delegate respondsToSelector:@selector(goalDetailsClickedWith:)]) {
        [self.delegate goalDetailsClickedWith:self.row];
    }
    
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

@end


