#import <UIKit/UIKit.h>

@protocol IntroDelegate <NSObject>


@optional


/*!
 *This method is invoked when user Clicks "FAVOURITE" Button
 */
-(void)introSkipToHomePage ;





@end

@interface ExampleViewController : UIViewController
@property (nonatomic,weak)  id<IntroDelegate>delegate;

@end
