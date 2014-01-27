//
//  CategoryCollectionViewCell.h
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMBOCategoryCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *categoryName;
@property (nonatomic, weak) IBOutlet UIImageView *categoryImageView;

@end
