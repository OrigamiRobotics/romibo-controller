//
//  RMBOAction.m
//  RomiboController
//
//  Created by Doug Suriano on 2/4/14.
//  Copyright (c) 2014 Romibo. All rights reserved.
//

#import "RMBOAction.h"
#import "RMBOCategory.h"


@implementation RMBOAction

@dynamic buttonColor;
@dynamic buttonTitle;
@dynamic buttonTitleColor;
@dynamic speachSpeedRate;
@dynamic speechPhrase;
@dynamic threeBasedIndex;
@dynamic category;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.buttonColor = [UIColor whiteColor];
    self.buttonTitleColor = [UIColor blackColor];
    self.buttonTitle = @"Untitled button";
    self.speechPhrase = @"";
    self.speachSpeedRate = [NSNumber numberWithFloat:AVSpeechUtteranceDefaultSpeechRate];
}

- (NSDictionary *)dictionaryRepresentation
{
    return @{@"buttonTitle" : self.buttonTitle,
             @"speechSpeedRate" : self.speachSpeedRate,
             @"speechPhrase" : self.speechPhrase,
             @"threeBasedIndex" : self.threeBasedIndex
             };
}

@end
