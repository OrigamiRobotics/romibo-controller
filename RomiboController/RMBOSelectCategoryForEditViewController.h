//
//  RMBOSelectCategoryForEditViewController.h
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMBOSelectCategoryForEditViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSArray *fetchedCategories;

- (void)loadCategoriesFromPersistentStore;
- (IBAction)doneEditingAction:(id)sender;
- (IBAction)createNewCategoryAction:(id)sender;
@end
