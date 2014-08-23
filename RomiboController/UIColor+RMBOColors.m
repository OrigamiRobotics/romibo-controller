//
//  UIColor+RMBOColors.m
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//
// Colors from flatuicolors.com/

#import "UIColor+RMBOColors.h"

@implementation UIColor (RMBOColors)

+ (UIColor *)rmbo_turquoiseColor
{
    return [UIColor colorWithRed:0.102f green:0.737f blue:0.612f alpha:1.0f];
}

+ (UIColor *)rmbo_emeraldColor
{
    return [UIColor colorWithRed:0.18f green:0.8f blue:0.443f alpha:1.0f];
}

+ (UIColor *)rmbo_peterRiverColor
{
    return [UIColor colorWithRed:0.204f green:0.596f blue:0.859f alpha:1.0f];
}

+ (UIColor *)rmbo_amethystColor
{
    return [UIColor colorWithRed:0.608f green:0.349f blue:0.714f alpha:1.0f];
}

+ (UIColor *)rmbo_wetAsphaltColor
{
    return [UIColor colorWithRed:0.204f green:0.286f blue:0.369f alpha:1.0f];
}

+ (UIColor *)rmbo_greenSeaColor
{
    return [UIColor colorWithRed:0.086f green:0.627f blue:0.522f alpha:1.0f];
}

+ (UIColor *)rmbo_nephritisColor
{
    return [UIColor colorWithRed:0.153f green:0.682f blue:0.376f alpha:1.0f];
}

+ (UIColor *)rmbo_belizeHoleColor
{
    return [UIColor colorWithRed:0.161f green:0.502f blue:0.725f alpha:1.0f];
}

+ (UIColor *)rmbo_wisteriaColor
{
    return [UIColor colorWithRed:0.557f green:0.267f blue:0.678f alpha:1.0f];
}

+ (UIColor *)rmbo_midnightBlueColor
{
    return [UIColor colorWithRed:0.173f green:0.243f blue:0.314f alpha:1.0f];
}

+ (UIColor *)rmbo_sunFlowerColor
{
    return [UIColor colorWithRed:0.945f green:0.769f blue:0.059f alpha:1.0f];
}

+ (UIColor *)rmbo_carrotColor
{
    return [UIColor colorWithRed:0.902f green:0.494f blue:0.133f alpha:1.0f];
}

+ (UIColor *)rmbo_alizarinColor
{
    return [UIColor colorWithRed:0.906f green:0.298f blue:0.235f alpha:1.0f];
}

+ (UIColor *)rmbo_cloudsColor
{
    return [UIColor colorWithRed:0.925f green:0.941f blue:0.945f alpha:1.0f];
}

+ (UIColor *)rmbo_concreteColor
{
    return [UIColor colorWithRed:0.584f green:0.647f blue:0.651f alpha:1.0f];
}

+ (UIColor *)rmbo_orangeColor
{
    return [UIColor colorWithRed:0.953f green:0.612f blue:0.071f alpha:1.0f];
}

+ (UIColor *)rmbo_pumpkinColor
{
    return [UIColor colorWithRed:0.827f green:0.329f blue:0 alpha:1.0f];
}

+ (UIColor *)rmbo_pomegranateColor
{
    return [UIColor colorWithRed:0.753f green:0.224f blue:0.169f alpha:1.0f];
}

+ (UIColor *)rmbo_silverColor
{
    return [UIColor colorWithRed:0.741f green:0.765f blue:0.78f alpha:1.0f];
}

+ (UIColor *)rmbo_asbestosColor
{
    return [UIColor colorWithRed:0.498f green:0.549f blue:0.553f alpha:1.0f];
}

+ (UIColor *)rmbo_greyGrandientColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

+ (UIColor *)rmbo_greyBorderColor
{
    return [UIColor colorWithRed:0.75f green:0.705882f blue:0.709803f alpha:1.0f];
}

+ (NSArray *)rmbo_sortedColorPallet
{
    return @[
             [UIColor rmbo_turquoiseColor],
             [UIColor rmbo_greenSeaColor],
             [UIColor rmbo_emeraldColor],
             [UIColor rmbo_nephritisColor],
             [UIColor rmbo_peterRiverColor],
             [UIColor rmbo_belizeHoleColor],
             [UIColor rmbo_amethystColor],
             [UIColor rmbo_wisteriaColor],
             [UIColor rmbo_wetAsphaltColor],
             [UIColor rmbo_midnightBlueColor],
             [UIColor rmbo_sunFlowerColor],
             [UIColor rmbo_orangeColor],
             [UIColor rmbo_carrotColor],
             [UIColor rmbo_pumpkinColor],
             [UIColor rmbo_alizarinColor],
             [UIColor rmbo_pomegranateColor],
             [UIColor rmbo_cloudsColor],
             [UIColor rmbo_silverColor],
             [UIColor rmbo_concreteColor],
             [UIColor rmbo_asbestosColor],
             [UIColor blackColor]
             ];
}

+ (UIColor *)rmbo_blueStarBackground
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"starBack"]];
}

@end
