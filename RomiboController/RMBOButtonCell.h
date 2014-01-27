//
//  RMBOButtonCell.h
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RMBOButtonCell;
@protocol RMBOButtonCellDelegate <NSObject>

@optional
- (void)buttonCell:(RMBOButtonCell *)cell userDidTapButton:(UIButton *)button;

@end

@interface RMBOButtonCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIButton *cellButton;
@property (nonatomic, weak) id <RMBOButtonCellDelegate> delegate;

- (IBAction)buttonWasPressed:(id)sender;

@end
