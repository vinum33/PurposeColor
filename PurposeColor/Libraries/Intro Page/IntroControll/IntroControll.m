#import "IntroControll.h"

@implementation IntroControll


- (id)initWithFrame:(CGRect)frame pages:(NSArray*)pagesArray
{
    self = [super initWithFrame:frame];
    if(self != nil) {
        
        islandscape = NO;
        
        //Initial Background images
        
        self.backgroundColor = [UIColor blackColor];
        
        backgroundImage1 = [[UIImageView alloc] initWithFrame:frame];
        [backgroundImage1 setContentMode:UIViewContentModeScaleAspectFill];
        [backgroundImage1 setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self addSubview:backgroundImage1];

        backgroundImage2 = [[UIImageView alloc] initWithFrame:frame];
        [backgroundImage2 setContentMode:UIViewContentModeScaleAspectFill];
        [backgroundImage2 setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self addSubview:backgroundImage2];
        
        //Initial shadow
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]];
        shadowImageView.contentMode = UIViewContentModeScaleToFill;
        shadowImageView.frame = CGRectMake(0, frame.size.height-300, frame.size.width, 300);
        [shadowImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:shadowImageView];
        
        //Initial ScrollView
        scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        scrollView.backgroundColor = [UIColor clearColor];
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.delegate = self;
        //[scrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:scrollView];
        
        //Initial PageView
        pageControl = [[UIPageControl alloc] init];
        pageControl.numberOfPages = pagesArray.count;
        [pageControl sizeToFit];
        [pageControl setCenter:CGPointMake(frame.size.width/2.0, frame.size.height-50)];
        [pageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self addSubview:pageControl];
        
        //Create pages
        pages = pagesArray;
        
        scrollView.contentSize = CGSizeMake(pages.count * frame.size.width, frame.size.height);
        
        currentPhotoNum = -1;
        
        //insert TextViews into ScrollView
        for(int i = 0; i <  pages.count; i++) {
            IntroView *view = [[IntroView alloc] initWithFrame:frame model:[pages objectAtIndex:i]];
            view.frame = CGRectOffset(view.frame, i*frame.size.width, 0);
            [scrollView addSubview:view];
        }
            
        //start timer
        timer =  [NSTimer scheduledTimerWithTimeInterval:3.0
                        target:self
                        selector:@selector(tick)
                        userInfo:nil
                        repeats:YES];
        
        [self initShow];
    }
    
    return self;
}

- (void) updateView:(CGRect)frame {
    
    scrollView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    scrollView.contentSize = CGSizeMake(frame.size.width * pages.count, frame.size.height);
    
    // remove previous views from superview
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    //insert TextViews into ScrollView
    for(int i = 0; i <  pages.count; i++) {
        IntroView *view = [[IntroView alloc] initWithFrame:frame model:[pages objectAtIndex:i]];
        view.frame = CGRectOffset(view.frame, i*frame.size.width, 0);
        [scrollView addSubview:view];
    }
    
    // normal screen size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (screenSize.width == frame.size.width) {
        islandscape = NO;
    }
    else {
        islandscape = YES;
    }
    
    // scroll to the correct page after rotation
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // Update the scroll view to the appropriate page
	CGRect updateFrame;
	updateFrame.origin.x = scrollView.frame.size.width * pageControl.currentPage;
	updateFrame.origin.y = 0;
	updateFrame.size = scrollView.frame.size;
	[scrollView scrollRectToVisible:updateFrame animated:YES];

}

- (void) tick {
    
    [scrollView setContentOffset:CGPointMake((currentPhotoNum+1 == pages.count ? 0 : currentPhotoNum+1)*self.frame.size.width, 0) animated:YES];
}

- (void) initShow {
    
    CGRect windowFrame = self.frame;
    
    // normal screen size
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if (islandscape) {
        windowFrame = CGRectMake(0, 0, screenSize.height, screenSize.width);
    }
    else {
        windowFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    }
                       
    [backgroundImage1 setFrame:windowFrame];
    [backgroundImage2 setFrame:windowFrame];
    
    int scrollPhotoNumber = MAX(0, MIN(pages.count-1, (int)(scrollView.contentOffset.x / windowFrame.size.width)));
    
    if(scrollPhotoNumber != currentPhotoNum) {
        currentPhotoNum = scrollPhotoNumber;
        
        //backgroundImage1.image = currentPhotoNum != 0 ? [(IntroModel*)[pages objectAtIndex:currentPhotoNum-1] image] : nil;
        backgroundImage1.image = [(IntroModel*)[pages objectAtIndex:currentPhotoNum] image];
        backgroundImage2.image = currentPhotoNum+1 != [pages count] ? [(IntroModel*)[pages objectAtIndex:currentPhotoNum+1] image] : nil;
    }
    
    float offset =  scrollView.contentOffset.x - (currentPhotoNum * windowFrame.size.width);
    
    
    //left
    if(offset < 0) {
        pageControl.currentPage = 0;
        
        offset = windowFrame.size.width - MIN(-offset, windowFrame.size.width);
        backgroundImage2.alpha = 0;
        backgroundImage1.alpha = (offset / windowFrame.size.width);
    
    //other
    } else if(offset != 0) {
        //last
        if(scrollPhotoNumber == pages.count-1) {
            pageControl.currentPage = pages.count-1;
            
            backgroundImage1.alpha = 1.0 - (offset / windowFrame.size.width);
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"IntroCompleted" object:nil userInfo:nil];

        } else {
            
            pageControl.currentPage = (offset > windowFrame.size.width/2) ? currentPhotoNum+1 : currentPhotoNum;
            
            backgroundImage2.alpha = offset / windowFrame.size.width;
            backgroundImage1.alpha = 1.0 - backgroundImage2.alpha;
        }
    //stable
    } else {
        pageControl.currentPage = currentPhotoNum;
        backgroundImage1.alpha = 1;
        backgroundImage2.alpha = 0;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    [self initShow];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scroll {
    if(timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [self initShow];
}

@end
