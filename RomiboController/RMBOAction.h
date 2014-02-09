//
//  RMBOAction.h
//  RomiboController
//
//  Created by Doug Suriano on 2/4/14.
//  Copyright (c) 2014 Romibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@import AVFoundation;

@class RMBOCategory;

@interface RMBOAction : NSManagedObject

@property (nonatomic, retain) id buttonColor;
@property (nonatomic, retain) NSString * buttonTitle;
@property (nonatomic, retain) id buttonTitleColor;
@property (nonatomic, retain) NSNumber * speachSpeedRate;
@property (nonatomic, retain) NSString * speechPhrase;
@property (nonatomic, retain) NSNumber * threeBasedIndex;
@property (nonatomic, retain) RMBOCategory *category;

- (NSDictionary *)dictionaryRepresentation;

@end
