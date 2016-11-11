//
//  TextFieldCustomInset.m
//  SignSpot
//
//  Created by Purpose Code on 08/06/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "TextFieldCustomInset.h"

@implementation TextFieldCustomInset

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

@end
