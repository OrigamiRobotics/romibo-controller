//
//  RMBOAction.h
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <CoreData/CoreData.h>

@class RMBOCategory;

@interface RMBOAction : NSManagedObject

@property (nonatomic, strong) NSString *buttonTitle;
@property (nonatomic, strong) UIColor *buttonColor;
@property (nonatomic, strong) UIColor *buttonTitleColor;
@property (nonatomic, strong) NSString *speechPhrase;

@property (nonatomic, strong) NSNumber *threeBasedIndex;
@property (nonatomic, strong) RMBOCategory *category;
@property (nonatomic, strong) NSNumber *speachSpeedRate;

@end
