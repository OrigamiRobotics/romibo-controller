//
//  RMBOAction.m
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOAction.h"
#import "RMBOCategory.h"
#import <AVFoundation/AVFoundation.h>

@implementation RMBOAction

@dynamic buttonTitle;
@dynamic buttonColor;
@dynamic buttonTitleColor;
@dynamic speechPhrase;
@dynamic category;
@dynamic threeBasedIndex;
@dynamic speachSpeedRate;

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.buttonColor = [UIColor whiteColor];
    self.buttonTitleColor = [UIColor blackColor];
    self.buttonTitle = @"Untitled button";
    self.speechPhrase = @"";
    self.speachSpeedRate = [NSNumber numberWithFloat:AVSpeechUtteranceDefaultSpeechRate];
    
}



@end
