//
//  RMBOActionDataSource.h
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "RMBOButtonCell.h"
@class RMBORobotControlViewController;
@class RMBOActionDataSource;
@class RMBOAction;

@protocol RMBOActionDataSourceDelegate <NSObject>

@optional
- (void)actionDataSource:(RMBOActionDataSource *)dataSource userWantsRobotToSpeakPhrase:(NSString *)phrase atRate:(float)speechRate;
- (void)actionDataSource:(RMBOActionDataSource *)dataSource userSelectedButton:(id)sender atIndexPath:(NSIndexPath *)indexPath withAction:(RMBOAction *)action;
- (void)cellIsBeingMovedInDataSource:(RMBOActionDataSource *)dataSource;
- (void)cellDoneBeingMovedInDataSource:(RMBOActionDataSource *)dataSource;

@end

@interface RMBOActionDataSource : NSObject <LXReorderableCollectionViewDataSource, RMBOButtonCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *fetchedButtons;
@property (nonatomic, weak) IBOutlet id <RMBOActionDataSourceDelegate> delegate;

- (void)updateActionItemsPosition;
- (void)addActionToFetchedActions:(RMBOAction *)action;

@end
