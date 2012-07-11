//
//  RZSheetListTableViewController.m
//  Totalee
//
//  Created by Andy Roth on 6/16/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSheetListTableViewController.h"

#import "RZDataManager.h"
#import "RZSheetListCell.h"
#import "RZItemListViewController.h"

@interface RZSheetListTableViewController ()
{
@private
    NSMutableArray *_sheets;
    RZDataManager *_dataManager;
    RZSheet *_selectedSheet;
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
    
    _dataManager = [RZDataManager sharedManager];
    if (!_dataManager.connectedToiCloud)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudConnected) name:RZDataManagerDidConnectToiCloudNotification object:nil];
    }
    else
    {
        [self iCloudConnected];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowItems"])
    {
        RZItemListViewController *itemList = (RZItemListViewController *)segue.destinationViewController;
        itemList.sheet = _selectedSheet;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sheets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SheetCell";
    RZSheetListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RZSheet *sheet = _sheets[indexPath.row];
    cell.sheet = sheet;
    
    if (indexPath.row == _sheets.count - 1 && [sheet.name isEqualToString:@""])
    {
        [cell edit];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView beginUpdates];
        
        [_dataManager deleteSheet:_sheets[indexPath.row]];
        [_sheets removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
    }
}

#pragma mark - Button Actions

- (void)addSheet
{
    RZSheet *newSheet = [_dataManager createSheetWithName:@""];
    
    [self.tableView beginUpdates];
    
    [_sheets addObject:newSheet];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:_sheets.count - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    RZSheet *sheet = [_sheets objectAtIndex:indexPath.row];
    _selectedSheet = sheet;
    
    [self performSegueWithIdentifier:@"ShowItems" sender:nil];
}

#pragma mark - iCloud
         
- (void)iCloudConnected
{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSheet)];
    self.toolbarItems = @[ add ];
    self.navigationController.toolbarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataUpdated) name:RZDataManagerDidMakeChangesNotification object:nil];
    
    [self updateData];
}

- (void)iCloudDataUpdated
{
    if (_dataManager.connectedToiCloud)
    {
        [self updateData];
    }
}

- (void)updateData
{
    _sheets = [NSMutableArray arrayWithArray:_dataManager.fetchedSheetsController.fetchedObjects];
    [self.tableView reloadData];
}

@end
