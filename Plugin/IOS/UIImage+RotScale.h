// WBImage.h -- extra UIImage methods
// by allen brunson  march 29 2009
// http://www.platinumball.net/blog/2010/01/31/iphone-uiimage-rotation-and-scaling/
// Modified by Andy Bower to place into RotScale protocol.

#import <UIKit/UIKit.h>

@interface UIImage (RotScale)

// rotate UIImage to any angle
-(UIImage*)rotate:(UIImageOrientation)orient;

// rotate and scale image from iphone camera
-(UIImage*)rotateAndScaleFromCameraWithMaxSize:(CGFloat)maxSize;

// scale this image to a given maximum width and height
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize;
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize
 quality:(CGInterpolationQuality)quality;

@end
