//
//  RMBOCategory.h
//  RomiboController
//
//  Created by Doug Suriano on 2/4/14.
//  Copyright (c) 2014 Romibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RMBOAction;

@interface RMBOCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id pageColor;
@property (nonatomic, retain) NSData * preview;
@property (nonatomic, retain) NSSet *actions;
@end

@interface RMBOCategory (CoreDataGeneratedAccessors)

- (void)addActionsObject:(RMBOAction *)value;
- (void)removeActionsObject:(RMBOAction *)value;
- (void)addActions:(NSSet *)values;
- (void)removeActions:(NSSet *)values;

- (NSDictionary *)dictionaryRepresentation;

@end
