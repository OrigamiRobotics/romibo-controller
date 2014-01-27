//
//  UIImage+RMBOTintImage.m
//  RomiboController
//
//  Created by Doug Suriano on 12/5/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "UIImage+RMBOTintImage.h"

@implementation UIImage (RMBOTintImage)

+ (UIImage *)imageNamed:(NSString *)name withTintColor:(UIColor *)color
{
    UIImage *image = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
    
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
    
    CGContextClipToMask(context, rect, image.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImage;
}
@end
