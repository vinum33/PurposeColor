//
//  UIColor+Color.m
//  SignSpot
//
//  Created by Purpose Code on 11/05/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "UIColor+Color.h"

@implementation UIColor (Color)



+ (UIColor*)getThemeColor{
    
     return [UIColor colorWithRed:31.f/255.f green:129.f/255.f blue:209.f/255.f alpha:1];
}
+ (UIColor*)getSeperatorColor{
    
     return [UIColor colorWithRed:215.f/255.f green:215.f/255.f blue:215.f/255.f alpha:1];
}

+ (UIColor*)getBackgroundOffWhiteColor{
    
    return [UIColor colorWithRed:250.f/255.f green:250.f/255.f blue:250.f/255.f alpha:1];
}
+ (UIColor*)getHeaderOffBlackColor{
    
    return [UIColor colorWithRed:77.f/255.f green:77.f/255.f blue:77.f/255.f alpha:1];
}
+ (UIColor *)randomColor {
    return [self colorWithRed:((float)rand() / RAND_MAX)
                        green:((float)rand() / RAND_MAX)
                         blue:((float)rand() / RAND_MAX)
                        alpha:1.0f];
}
@end
