//
//  RMBOColorPickerViewController.h
//  RomiboController
//
//  Created by Doug Suriano on 11/24/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+RMBOColors.h"

@protocol RMBOColorPickerDelegate <NSObject>

@optional
- (void)userDidPickColor:(UIColor *)color fromPicker:(id)sender;

@end

@interface RMBOColorPickerViewController : UITableViewController

@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, weak) id <RMBOColorPickerDelegate> colorPickerDelegate;

@end
