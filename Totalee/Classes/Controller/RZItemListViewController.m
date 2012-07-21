//
//  RZItemListViewController.m
//  Totalee
//
//  Created by Andy Roth on 7/11/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZItemListViewController.h"

#import "RZSheetItem.h"
#import "RZDataManager.h"
#import "RZTotalFooterView.h"

@interface RZItemListViewController ()
{
@private
    NSMutableArray *_items;
    RZDataManager *_dataManager;
    RZTotalFooterView *_footer;
}

@end

@implementation RZItemListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:25.0/255.0 green:62.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:25.0/255.0 green:62.0/255.0 blue:25.0/255.0 alpha:1.0];

    if (_sheet) [self initialize];
}

- (void)setSheet:(RZSheet *)sheet
{
    _sheet = sheet;
    
    if (self.view)
    {
        [self initialize];
    }
}

- (void)initialize
{
    if (_sheet)
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.navigationItem.title = _sheet.name;
        
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
        self.toolbarItems = @[ add ];
        self.navigationController.toolbarHidden = NO;
        
        _items = [NSMutableArray array];
        [_items addObjectsFromArray:_sheet.sortedItems];
        _dataManager = [RZDataManager sharedManager];
        
        _footer = [[RZTotalFooterView alloc] init];
        _footer.textLabel.text = @"Total";
        
        [self updateTotal];
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataUpdated) name:RZDataManagerDidMakeChangesNotification object:nil];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title = @"";
        self.toolbarItems = nil;
        _footer = nil;
        _items = [NSMutableArray array];
        
        [self updateTotal];
        [self.tableView reloadData];
    }
}

- (void)iCloudDataUpdated
{
    if (_dataManager.connectedToiCloud)
    {
        [_items removeAllObjects];
        [_items addObjectsFromArray:_sheet.sortedItems];
        
        [self updateTotal];
        [self.tableView reloadData];
    }
}

- (void)updateTotal
{
    float total = 0.0;
    for (RZSheetItem *item in _items)
    {
        total += item.total;
    }
    
    _footer.total = total;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _footer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RZItemListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
    
    RZSheetItem *item = _items[indexPath.row];
    cell.item = item;
    cell.delegate = self;
    
    if (indexPath.row == _items.count - 1 && [item.name isEqualToString:@""])
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
        
        [_dataManager deleteSheetItem:_items[indexPath.row]];
        [_items removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
        [self updateTotal];
    }
}

#pragma mark - Button Actions

- (void)addItem
{
    RZSheetItem *newItem = [_dataManager createSheetItemWithName:@"" total:0.0 inSheet:_sheet];
    
    [self.tableView beginUpdates];
    
    [_items addObject:newItem];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:_items.count - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - Cell Delegate

- (void)cellDidChangeItem
{
    [self updateTotal];
}

@end
