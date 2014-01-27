//
//  RMBOActionCategoryCell.h
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMBOActionDataSource;

@interface RMBOActionCategoryCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) RMBOActionDataSource *dataSource;

@end
