//
//  RMBOCategory.h
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface RMBOCategory : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSData *preview;
@property (nonatomic, strong) NSNumber *displayOrder;
@property (nonatomic, strong) UIColor *pageColor;

@end
