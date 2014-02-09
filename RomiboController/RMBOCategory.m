//
//  RMBOCategory.m
//  RomiboController
//
//  Created by Doug Suriano on 2/4/14.
//  Copyright (c) 2014 Romibo. All rights reserved.
//

#import "RMBOCategory.h"
#import "RMBOAction.h"


@implementation RMBOCategory

@dynamic displayOrder;
@dynamic name;
@dynamic pageColor;
@dynamic preview;
@dynamic actions;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.name = @"New Palette";
    self.preview = UIImagePNGRepresentation([UIImage imageNamed:@"blank"]);
}

- (NSDictionary *)dictionaryRepresentation
{
    NSArray *actionsArray = [self.actions allObjects];
    
    NSMutableArray *actionDicts = [[NSMutableArray alloc] init];
    
    for (RMBOAction *anAction in actionsArray) {
        [actionDicts addObject:[anAction dictionaryRepresentation]];
    }
    
    return @{@"displayOrder" : self.displayOrder,
             @"name" : self.name,
             @"actions" : actionDicts
             };
}

@end
