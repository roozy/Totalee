//
//  RZSheetListTableViewController.m
//  Totalee
//
//  Created by Andy Roth on 6/16/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSheetListTableViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "RZDataManager.h"
#import "RZSheetListCell.h"
#import "RZItemListViewController.h"
#import "RZPullToAddView.h"

@interface RZSheetListTableViewController () <RZSheetListCellDelegate>
{
@private
    RZDataManager *_dataManager;
    RZSheet *_selectedSheet;
    UIView *_loadingView;
    RZItemListViewController *_itemListViewController;
    RZPullToAddView *_pullToAddView;
}

- (RZItemListViewController *)itemListViewController;

@end

@implementation RZSheetListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:226.0/255.0 green:226.0/255.0 blue:226.0/255.0 alpha:1.0];
    self.navigationItem.title = @"Sheets";
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    back.tintColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = back;
    
    //TODO: Remove and add local store support
    if (![NSFileManager defaultManager].ubiquityIdentityToken) return;
    
    _dataManager = [RZDataManager sharedManager];
    if (!_dataManager.connectedToiCloud)
    {
        self.view.userInteractionEnabled = NO;
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
        _loadingView.center = CGPointMake(320.0 / 2.0, (460.0 / 2.0) - 44.0);
        _loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        _loadingView.layer.cornerRadius = 10.0;
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.text = @"Connecting to iCloud";
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.textColor = [UIColor whiteColor];
        [_loadingView addSubview:loadingLabel];
        
        [self.view addSubview:_loadingView];
        
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

- (RZItemListViewController *)itemListViewController
{
    if (!_itemListViewController)
    {
        if (self.splitViewController)
        {
            NSArray *controllers = self.splitViewController.viewControllers;
            for (UINavigationController *controller in controllers)
            {
                UIViewController *child = controller.topViewController;
                if ([child isKindOfClass:[RZItemListViewController class]])
                {
                    _itemListViewController = (RZItemListViewController *)child;
                }
            }
        }
        else
        {
            return nil;
        }
    }
    
    return _itemListViewController;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataManager.sheets.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] init];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SheetCell";
    RZSheetListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RZSheet *sheet = _dataManager.sheets[indexPath.row];
    cell.sheet = sheet;
    cell.delegate = self;
    
    if (indexPath.row == 0 && [sheet.name isEqualToString:@""])
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
        
        [_dataManager deleteSheet:_dataManager.sheets[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
        if (self.itemListViewController)
        {
            self.itemListViewController.sheet = nil;
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [_dataManager moveSheet:_dataManager.sheets[sourceIndexPath.row] toIndex:destinationIndexPath.row];
    NSLog(@"move em");
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RZSheet *sheet = [_dataManager.sheets objectAtIndex:indexPath.row];
    _selectedSheet = sheet;
    
    if (self.itemListViewController)
    {
        self.itemListViewController.sheet = sheet;
    }
    else
    {
        [self performSegueWithIdentifier:@"ShowItems" sender:nil];
    }
}

- (void)cellShouldBeDeleted:(RZSheetListCell *)cell
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    [self.tableView beginUpdates];
    
    [_dataManager deleteSheet:_dataManager.sheets[path.row]];
    [self.tableView deleteRowsAtIndexPaths:@[ path ] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView endUpdates];
}

#pragma mark - Button Actions

- (void)addSheet
{    
    [self.tableView beginUpdates];
    
    [_dataManager createSheetWithName:@""];
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];   
}

#pragma mark - iCloud

- (void)iCloudConnected
{
    [_loadingView removeFromSuperview];
    _loadingView = nil;
    
    self.view.userInteractionEnabled = YES;
    
    _pullToAddView = [[RZPullToAddView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
    [self.view addSubview:_pullToAddView];
    
    self.editButtonItem.tintColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    [self.tableView reloadData];
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
        [self addSheet];
    }
}

@end
