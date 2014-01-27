//
//  RMBOPopoverMenuViewController.m
//  RomiboController
//
//  Created by Doug Suriano on 12/7/13.
//  Copyright (c) 2013 Romibo. All rights reserved.
//

#import "RMBOPopoverMenuViewController.h"

#define kRMBONumberOfMenuOptions 3

@interface RMBOPopoverMenuViewController ()

@end

@implementation RMBOPopoverMenuViewController

- (id)initWithStyle:(UITableViewStyle)style romiboConnected:(BOOL)connected
{
    self = [super initWithStyle:style];
    if (self) {
        if (connected) {
            _menuItems = @[@"Disconnect from Romibo", @"Editor"];
        }
        else {
            _menuItems = @[@"Connect to Romibo" , @"Editor"];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style romiboConnected:(BOOL)connected showkitLoggedIn:(BOOL)showkit
{
    self = [super initWithStyle:style];
    if (self) {
        NSMutableArray *tempMenuItems = [[NSMutableArray alloc] init];
        [tempMenuItems addObject:@"Editor"];
        
        if (connected) {
            [tempMenuItems addObject:@"Disconnect from Romibo"];
        }
        else {
            [tempMenuItems addObject:@"Connect to Romibo"];
        }
        
        if (showkit) {
            [tempMenuItems addObject:@"Logout from Video Sharing"];
        }
        else {
            [tempMenuItems addObject:@"Login to Video Sharing"];
        }
        _menuItems = [[NSArray alloc] initWithArray:(NSArray *)tempMenuItems];
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return kRMBONumberOfMenuOptions;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [[cell textLabel] setText:_menuItems[indexPath.row]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Welcome to Romibo";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end
