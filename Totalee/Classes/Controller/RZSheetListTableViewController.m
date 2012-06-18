//
//  RZSheetListTableViewController.m
//  Totalee
//
//  Created by Andy Roth on 6/16/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSheetListTableViewController.h"

#import "RZDataManager.h"

@interface RZSheetListTableViewController ()
{
    NSMutableArray *_sheets;
}

@end

@implementation RZSheetListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSheet)];
    self.navigationItem.leftBarButtonItem = add;
    
    _sheets = [NSMutableArray arrayWithArray:[RZDataManager sharedManager].fetchedSheetsController.fetchedObjects];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataUpdated) name:RZDataManagerDidMakeChangesNotification object:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sheets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RZSheet *sheet = _sheets[indexPath.row];
    cell.textLabel.text = sheet.name;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    
    return cell;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Button Actions

- (void)addSheet
{
    RZSheet *newSheet = [[RZDataManager sharedManager] createSheetWithName:@"New Sheet"];
    
    [self.tableView beginUpdates];
    
    [_sheets addObject:newSheet];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:_sheets.count - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - iCloud

- (void)iCloudDataUpdated
{
    // Use a fetched view controller instead
    NSError *error;
    [[RZDataManager sharedManager].fetchedSheetsController performFetch:&error];
    
    if (error)
    {
        NSLog(@"error : %@", error);
    }
    else
    {
        NSLog(@"data is updated : %d", [RZDataManager sharedManager].fetchedSheetsController.fetchedObjects.count);
    }
}

@end
