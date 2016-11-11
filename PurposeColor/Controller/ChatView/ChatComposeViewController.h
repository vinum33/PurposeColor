//
//  ChatComposeViewController.h
//  PurposeColor
//
//  Created by Purpose Code on 02/08/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatComposeViewController : UIViewController

@property (nonatomic,strong) NSDictionary *chatUserInfo;

-(void)newChatHasReceivedWithDetails:(NSDictionary*)details;

@end
