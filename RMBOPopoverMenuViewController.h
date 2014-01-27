//
//  RMBOPopoverMenuViewController.h
//  RomiboController
//
//  Created by Doug Suriano on 12/7/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMBOPopoverMenuViewController : UITableViewController

@property (nonatomic, strong) NSArray *menuItems;

- (id)initWithStyle:(UITableViewStyle)style romiboConnected:(BOOL)connected;
- (id)initWithStyle:(UITableViewStyle)style romiboConnected:(BOOL)connected showkitLoggedIn:(BOOL)showkit;

@end
