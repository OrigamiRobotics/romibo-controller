//
//  RMBOActionDataSource.m
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOActionDataSource.h"
#import "RMBOAction.h"
#import "UIImage+RMBOTintImage.h"
#import "RMBORobotControlViewController.h"

@implementation RMBOActionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_fetchedButtons count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RMBOButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"buttonCell" forIndexPath:indexPath];
    
    RMBOAction *action = _fetchedButtons[[indexPath row]];
    
    [[cell cellButton] setTitle:[action buttonTitle] forState:UIControlStateNormal];
    [[cell cellButton] setTag:[indexPath row]];
    UIImage *buttonImage = [UIImage imageNamed:@"smActionButton" withTintColor:[action buttonColor]];
    [[cell cellButton] setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [[cell cellButton] setTintColor:[action buttonTitleColor]];
    [cell setDelegate:self];
    
    if (cell.selected) {
        [cell setBackgroundColor:[UIColor yellowColor]];
    }
    else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath
{
    if ([_delegate respondsToSelector:@selector(cellIsBeingMovedInDataSource:)]) {
        [_delegate cellIsBeingMovedInDataSource:self];
    }

    
    RMBOAction *action = [_fetchedButtons objectAtIndex:fromIndexPath.item];
    
    [_fetchedButtons removeObjectAtIndex:fromIndexPath.item];
    [_fetchedButtons insertObject:action atIndex:toIndexPath.item];
    
    [self updateActionItemsPosition];
    
    if ([_delegate respondsToSelector:@selector(cellDoneBeingMovedInDataSource:)]) {
        [_delegate cellDoneBeingMovedInDataSource:self];
    }
    
}

- (void)updateActionItemsPosition
{
    for (NSUInteger i = 0; i < [_fetchedButtons count]; i++) {
        if ([_fetchedButtons[i] isKindOfClass:[RMBOAction class]]) {
            [_fetchedButtons[i] setThreeBasedIndex:@(i)];
        }
    }
}

- (void)buttonCell:(RMBOButtonCell *)cell userDidTapButton:(UIButton *)button
{
    if ([_delegate respondsToSelector:@selector(actionDataSource:userWantsRobotToSpeakPhrase:atRate:)]) {
        
        NSIndexPath *path = [_collectionView indexPathForCell:cell];
        RMBOAction *action = _fetchedButtons[path.row];
        [_delegate actionDataSource:self userWantsRobotToSpeakPhrase:[action speechPhrase] atRate:[[action speachSpeedRate] floatValue]];
    }
    
    if ([_delegate respondsToSelector:@selector(actionDataSource:userSelectedButton:atIndexPath:withAction:)]) {
        NSIndexPath *path = [_collectionView indexPathForCell:cell];
        RMBOAction *action = _fetchedButtons[path.row];
        [_delegate actionDataSource:self userSelectedButton:button atIndexPath:path withAction:action];
    }
}

- (void)addActionToFetchedActions:(RMBOAction *)action
{
    [_fetchedButtons addObject:action];
}

@end
