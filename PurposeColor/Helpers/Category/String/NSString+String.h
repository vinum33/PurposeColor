//
//  NSString+String.h
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (String)


- (BOOL)isValidEmail;
-(NSString *) stringByStrippingHTML;

@end
