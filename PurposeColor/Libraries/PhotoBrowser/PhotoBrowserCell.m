//
//  PhotoBrowserCell.m
//  PurposeColor
//
//  Created by Purpose Code on 16/09/16.
//  Copyright © 2016 Purpose Code. All rights reserved.
//

#import "PhotoBrowserCell.h"
#define MAXIMUM_SCALE 3.0
#define MINIMUM_SCALE    1.0
#define ZOOM_STEP 1.5

@interface PhotoBrowserCell()<UIScrollViewDelegate>{
    
    UIImageView *imgView;
}

@end

@implementation PhotoBrowserCell


- (void)setup {
    
    UIImageView *imageView;
    if ([self.scrollview viewWithTag:101]) {
       imageView = (UIImageView*)[self.scrollview viewWithTag:101];
        [imageView removeFromSuperview];
        imageView = nil;
    }
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollview addSubview:imageView];
    }
   // CGSize size = [self aspectScaledImageSizeForImageView:nil image:self.image];
    UIImage *newImage = [Utility imageWithImage:self.image scaledToWidth:self.frame.size.width];
    imageView.tag = 101;
    imageView.image = _image;
    imageView.frame = CGRectMake(0, self.center.y - newImage.size.height/2, newImage.size.width, newImage.size.height);
    imageView.userInteractionEnabled = true;
    imgView = imageView;
    self.scrollview.delegate = self;
    self.scrollview.clipsToBounds = YES;
    self.scrollview.contentSize = imageView.frame.size;
    self.scrollview.zoomScale = 1.0;
    self.scrollview.maximumZoomScale = 10.0;
    self.scrollview.minimumZoomScale = 1.0;
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTap];
    [imageView bringSubviewToFront:_indicator];
    
}

-(void)resetCell{
    if ([self.scrollview viewWithTag:101]) {
        imgView = (UIImageView*)[self.scrollview viewWithTag:101];
        [imgView removeFromSuperview];
        imgView = nil;
    }
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
    // double tap zooms in
    float newScale = 10;
    if ( self.scrollview.zoomScale == 10) {
         newScale = 1;
    }else{
        newScale = 10;
    }
       
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [self.scrollview zoomToRect:zoomRect animated:YES];
}

#pragma  mark  - Scrollview Delegate Method

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    UIView *subView = imgView;
    CGSize boundsSize = self.scrollview.bounds.size;
    CGRect contentsFrame = subView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    subView.frame = contentsFrame;
    
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_scrollview frame].size.height / scale;
    zoomRect.size.width  = [_scrollview frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imgView;
}

//-----------------------------------------------------------------------

#pragma mark - Custom Methods



- (CGSize) aspectScaledImageSizeForImageView:(UIImageView *)iv image:(UIImage *)im {
    
    float x,y;
    float a,b;
    x = self.frame.size.width;
    y = self.frame.size.height;
    a = im.size.width;
    b = im.size.height;
    
    if ( x == a && y == b ) {           // image fits exactly, no scaling required
        // return iv.frame.size;
    }
    else if ( x > a && y > b ) {         // image fits completely within the imageview frame
        if ( x-a > y-b ) {              // image height is limiting factor, scale by height
            a = y/b * a;
            b = y;
        } else {
            b = x/a * b;                // image width is limiting factor, scale by width
            a = x;
        }
    }
    else if ( x < a && y < b ) {        // image is wider and taller than image view
        if ( a - x > b - y ) {          // height is limiting factor, scale by height
            a = y/b * a;
            b = y;
        } else {                        // width is limiting factor, scale by width
            b = x/a * b;
            a = x;
        }
    }
    else if ( x < a && y > b ) {        // image is wider than view, scale by width
        b = x/a * b;
        a = x;
    }
    else if ( x > a && y < b ) {        // image is taller than view, scale by height
        a = y/b * a;
        b = y;
    }
    else if ( x == a ) {
        a = y/b * a;
        b = y;
    } else if ( y == b ) {
        b = x/a * b;
        a = x;
    }
    return CGSizeMake(a,b);
    
}


- (void)awakeFromNib {
    // Initialization code
}

@end
