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
    return [UIColor colorWithRed:0.102 green:0.737 blue:0.612 alpha:1];
}

+ (UIColor *)rmbo_emeraldColor
{
    return [UIColor colorWithRed:0.18 green:0.8 blue:0.443 alpha:1];
}

+ (UIColor *)rmbo_peterRiverColor
{
    return [UIColor colorWithRed:0.204 green:0.596 blue:0.859 alpha:1];
}

+ (UIColor *)rmbo_amethystColor
{
    return [UIColor colorWithRed:0.608 green:0.349 blue:0.714 alpha:1];
}

+ (UIColor *)rmbo_wetAsphaltColor
{
    return [UIColor colorWithRed:0.204 green:0.286 blue:0.369 alpha:1];
}

+ (UIColor *)rmbo_greenSeaColor
{
    return [UIColor colorWithRed:0.086 green:0.627 blue:0.522 alpha:1];
}

+ (UIColor *)rmbo_nephritisColor
{
    return [UIColor colorWithRed:0.153 green:0.682 blue:0.376 alpha:1];
}

+ (UIColor *)rmbo_belizeHoleColor
{
    return [UIColor colorWithRed:0.161 green:0.502 blue:0.725 alpha:1];
}

+ (UIColor *)rmbo_wisteriaColor
{
    return [UIColor colorWithRed:0.557 green:0.267 blue:0.678 alpha:1];
}

+ (UIColor *)rmbo_midnightBlueColor
{
    return [UIColor colorWithRed:0.173 green:0.243 blue:0.314 alpha:1];
}

+ (UIColor *)rmbo_sunFlowerColor
{
    return [UIColor colorWithRed:0.945 green:0.769 blue:0.059 alpha:1];
}

+ (UIColor *)rmbo_carrotColor
{
    return [UIColor colorWithRed:0.902 green:0.494 blue:0.133 alpha:1];
}

+ (UIColor *)rmbo_alizarinColor
{
    return [UIColor colorWithRed:0.906 green:0.298 blue:0.235 alpha:1];
}

+ (UIColor *)rmbo_cloudsColor
{
    return [UIColor colorWithRed:0.925 green:0.941 blue:0.945 alpha:1];
}

+ (UIColor *)rmbo_concreteColor
{
    return [UIColor colorWithRed:0.584 green:0.647 blue:0.651 alpha:1];
}

+ (UIColor *)rmbo_orangeColor
{
    return [UIColor colorWithRed:0.953 green:0.612 blue:0.071 alpha:1];
}

+ (UIColor *)rmbo_pumpkinColor
{
    return [UIColor colorWithRed:0.827 green:0.329 blue:0 alpha:1];
}

+ (UIColor *)rmbo_pomegranateColor
{
    return [UIColor colorWithRed:0.753 green:0.224 blue:0.169 alpha:1];
}

+ (UIColor *)rmbo_silverColor
{
    return [UIColor colorWithRed:0.741 green:0.765 blue:0.78 alpha:1];
}

+ (UIColor *)rmbo_asbestosColor
{
    return [UIColor colorWithRed:0.498 green:0.549 blue:0.553 alpha:1];
}

+ (UIColor *)rmbo_greyGrandientColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

+ (UIColor *)rmbo_greyBorderColor
{
    return [UIColor colorWithRed:0.75 green:.705882 blue:.709803 alpha:1.0];
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
