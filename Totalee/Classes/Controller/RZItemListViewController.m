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
    RZDataManager *_dataManager;
    RZTotalFooterView *_footer;
    RZPullToAddView *_pullToAddView;
}

@end

@implementation RZItemListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    swipe.numberOfTouchesRequired = 2;
    swipe.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:swipe];
    
    _footer = [[RZTotalFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];

    if (_sheet) [self initialize];
}

- (void)didSwipeRight
{
    [self.navigationController popViewControllerAnimated:YES];
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
        
        _dataManager = [RZDataManager sharedManager];
        
        if (!_pullToAddView)
        {
            _pullToAddView = [[RZPullToAddView alloc] initWithFrame:CGRectMake(0, -60, self.view.frame.size.width, 60)];
            _pullToAddView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:_pullToAddView];
        }
        
        self.editButtonItem.tintColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
        [self updateTotal];
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataUpdated) name:RZDataManagerDidMakeChangesNotification object:nil];
    }
    else
    {
        self.navigationItem.title = @"";
        self.navigationItem.rightBarButtonItem = nil;
        
        [self updateTotal];
        [self.tableView reloadData];
    }
}

- (void)iCloudDataUpdated
{
    if (_dataManager.connectedToiCloud)
    {
        [self updateTotal];
        [self.tableView reloadData];
    }
}

- (void)updateTotal
{
    float total = 0.0;
    for (RZSheetItem *item in _sheet.sortedItems)
    {
        total += item.total;
    }
    
    _footer.total = total;
    _footer.showTopDivider = _sheet.sortedItems.count > 0;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sheet.sortedItems.count;
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
    
    RZSheetItem *item = _sheet.sortedItems[indexPath.row];
    cell.item = item;
    cell.delegate = self;
    cell.isLastCell = (indexPath.row == _sheet.sortedItems.count - 1);
    
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
        
        [_dataManager deleteSheetItem:_sheet.sortedItems[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
        [self updateTotal];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{    
    [_dataManager moveSheetItem:_sheet.sortedItems[sourceIndexPath.row] toIndex:destinationIndexPath.row];
    
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)cellShouldBeDeleted:(RZItemListCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    [self.tableView beginUpdates];
    
    [_dataManager deleteSheetItem:_sheet.sortedItems[path.row]];
    
    [self.tableView deleteRowsAtIndexPaths:@[ path ] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - Button Actions

- (void)addItem
{
    [_dataManager createSheetItemWithName:@"" total:0.0 inSheet:_sheet];
    
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
    
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
    if (scrollView.contentOffset.y < -_pullToAddView.frame.size.height && _sheet)
    {
        [self addItem];
    }
}

@end
