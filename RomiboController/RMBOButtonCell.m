//
//  RMBOButtonCell.m
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOButtonCell.h"

@implementation RMBOButtonCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)buttonWasPressed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(buttonCell:userDidTapButton:)]) {
        [_delegate buttonCell:self userDidTapButton:_cellButton];
    }
}

- (void)prepareForReuse
{
    [self setBackgroundColor:[UIColor clearColor]];
}

@end
