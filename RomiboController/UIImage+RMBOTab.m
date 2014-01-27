//
//  UIImage+RMBOTab.m
//  RomiboController
//
//  Created by Doug Suriano on 12/15/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "UIImage+RMBOTab.h"

@implementation UIImage (RMBOTab)

+ (UIImage *)rmbo_tabImageWithSize:(CGSize)size andColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [color setFill];
    
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.0, 0.0, size.width, size.height) byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: CGSizeMake(10, 10)];
    [roundedRectanglePath closePath];
    [roundedRectanglePath fill];

    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return backgroundImage;
}

@end
