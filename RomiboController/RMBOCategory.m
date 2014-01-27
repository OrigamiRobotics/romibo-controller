//
//  RMBOCategory.m
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOCategory.h"

@implementation RMBOCategory

@dynamic name;
@dynamic preview;
@dynamic displayOrder;
@dynamic pageColor;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.name = @"New Palette";
    self.preview = UIImagePNGRepresentation([UIImage imageNamed:@"blank"]);
}

@end
