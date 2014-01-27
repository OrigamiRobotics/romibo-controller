//
//  RMBOSelectCategoryForEditViewController.m
//  RomiboController
//
//  Created by Doug Suriano on 11/22/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOSelectCategoryForEditViewController.h"
#import "RMBOCategoryCollectionViewCell.h"
#import "AppDelegate.h"
#import "RMBOCategory.h"
#import "RMBOCategoryEditorViewController.h"

@interface RMBOSelectCategoryForEditViewController ()

@end

@implementation RMBOSelectCategoryForEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *bannerImage = [UIImage imageNamed:@"rmtoolbarLogo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bannerImage];
    self.navigationItem.titleView = imageView;
    
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"toolbar"] forBarMetrics:UIBarMetricsDefault];
    [self.view setBackgroundColor:[UIColor rmbo_blueStarBackground]];
    
	if (!_mainContext) {
        AppDelegate *del = [[UIApplication sharedApplication] delegate];
        _mainContext = [del managedObjectContext];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadCategoriesFromPersistentStore];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_fetchedCategories count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RMBOCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
    
    RMBOCategory *category = _fetchedCategories[[indexPath row]];
    
    [[cell categoryName] setText:[category name]];
    [[cell categoryImageView] setImage:[UIImage imageWithData:[category preview]]];
    return cell;
}

- (void)loadCategoriesFromPersistentStore
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:_mainContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
    [request setSortDescriptors:@[descriptor]];
    
    _fetchedCategories = [_mainContext executeFetchRequest:request error:&error];
    
    [self.collectionView reloadData];
}

- (IBAction)doneEditingAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createNewCategoryAction:(id)sender
{
    RMBOCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:_mainContext];
    
    [category setDisplayOrder:[NSNumber numberWithInteger:_fetchedCategories.count + 1]];
    
    NSError *error;
    [_mainContext save:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    [self loadCategoriesFromPersistentStore];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    RMBOCategoryEditorViewController *vc = [segue destinationViewController];
    [vc setMainContext:_mainContext];
    [vc setCategory:_fetchedCategories[[indexPath row]]];
}




@end
