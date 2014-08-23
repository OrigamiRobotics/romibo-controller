//
//  AppDelegate.m
//  RomiboController
//
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "AppDelegate.h"

#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "RMBOAction.h"
#import "RMBOCategory.h"
#import "RMBORobotControlViewController.h"
#import "UIColor+RMBOColors.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"RomiboController" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"RomiboController.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,
                              NSInferMappingModelAutomaticallyOption : @YES};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Import Pallet?" message:@"Do you want to import this pallet into your library?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil];
        [alertView show];
        _jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSError *error = nil;
        NSData *data = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
//        NSDictionary * paletteDict = jsonDict[@"palette"];
        NSDictionary * paletteDict = jsonDict;
        NSDictionary * actionsDict = paletteDict[@"actions"];
       
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext:_managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entity];
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"displayOrder" ascending:YES];
        [request setSortDescriptors:@[descriptor]];
        
        NSArray *fetchedCategories = [_managedObjectContext executeFetchRequest:request error:&error];
        
        RMBOCategory *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:_managedObjectContext];
        
        [category setDisplayOrder:@(fetchedCategories.count + 1)];
        [category setName:paletteDict[@"name"]];
        
        for (NSDictionary *actionDict in actionsDict) {
            NSLog(@"actionDict: %@", actionDict);
            NSLog(@"buttonTitle    : %@", actionDict[@"buttonTitle"] );
            NSLog(@"speechPhrase   : %@", actionDict[@"speechPhrase"] );
            NSLog(@"speechSpeedRate: %@", actionDict[@"speechSpeedRate"] );
            NSLog(@"threeBasedIndex: %@", actionDict[@"threeBasedIndex"] );

            RMBOAction *action = [NSEntityDescription insertNewObjectForEntityForName:@"Action" inManagedObjectContext:_managedObjectContext];
            [action setSpeechPhrase:actionDict[@"speechPhrase"]];
            [action setThreeBasedIndex:actionDict[@"threeBasedIndex"]];
            [action setButtonTitle:actionDict[@"buttonTitle"]];
            [action setSpeachSpeedRate:actionDict[@"speechSpeedRate"]];

            [action setCategory:category];
            [category addActionsObject:action];
            NSLog(@"        action: %@", action);
        }
        
        [_managedObjectContext save:nil];
        
        RMBORobotControlViewController *rootViewController = (RMBORobotControlViewController *)self.window.rootViewController;
        [rootViewController reloadCategoriesAndActions];
    }
}


@end
