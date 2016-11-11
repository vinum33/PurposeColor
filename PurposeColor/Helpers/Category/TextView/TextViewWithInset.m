//
//  TextViewWithInset.m
//  SignSpot
//
//  Created by Purpose Code on 08/06/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "TextViewWithInset.h"

@implementation TextViewWithInset

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}


@end
