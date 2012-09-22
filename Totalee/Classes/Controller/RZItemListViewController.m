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
#import "RZPullToAddView.h"

@interface RZItemListViewController ()
{
@private
    NSMutableArray *_items;
    RZDataManager *_dataManager;
    RZTotalFooterView *_footer;
    RZPullToAddView *_pullToAddView;
}

@end

@implementation RZItemListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];

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
        self.navigationItem.title = _sheet.name;
        
        _items = [NSMutableArray array];
        [_items addObjectsFromArray:_sheet.sortedItems];
        _dataManager = [RZDataManager sharedManager];
        
        if (!_footer)
        {
            _footer = [[RZTotalFooterView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        }
        
        if (!_pullToAddView)
        {
            _pullToAddView = [[RZPullToAddView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
            [self.view addSubview:_pullToAddView];
        }
        
        [self updateTotal];
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataUpdated) name:RZDataManagerDidMakeChangesNotification object:nil];
    }
    else
    {
        self.navigationItem.title = @"";
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 60;
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
    
    if (indexPath.row == 0 && [item.name isEqualToString:@""])
    {
        [cell performSelector:@selector(edit) withObject:nil afterDelay:0.1];
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
    
    [_items insertObject:newItem atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - Cell Delegate

- (void)cellDidChangeItem
{
    [self updateTotal];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -_pullToAddView.frame.size.height)
    {
        _pullToAddView.state = RZPullToAddViewStateRelease;
    }
    else
    {
        _pullToAddView.state = RZPullToAddViewStatePullDown;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -_pullToAddView.frame.size.height)
    {
        [self addItem];
    }
}

@end
