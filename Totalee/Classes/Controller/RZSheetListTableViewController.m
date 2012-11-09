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

@interface RZSheetListTableViewController () <RZSheetListCellDelegate, UIActionSheetDelegate>
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
    
    self.navigationItem.title = @"Sheets";
    self.navigationController.navigationBar.clipsToBounds = NO;
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    back.tintColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    self.navigationItem.backBarButtonItem = back;
    
    _dataManager = [RZDataManager sharedManager];
    [self initialize];
}

#pragma mark - Initialization

- (void)initialize
{
    _pullToAddView = [[RZPullToAddView alloc] initWithFrame:CGRectMake(0, -60, 320, 60)];
    [self.view addSubview:_pullToAddView];
    
    self.editButtonItem.tintColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (_dataManager.canConnectToiCloud)
    {
        UIBarButtonItem *iCloudButton = [[UIBarButtonItem alloc] initWithTitle:@"iCloud" style:UIBarButtonItemStyleBordered target:self action:@selector(showiCloudOptions)];
        iCloudButton.tintColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
        self.navigationItem.leftBarButtonItem = iCloudButton;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataUpdated) name:RZDataManagerDidMakeChangesNotification object:nil];
    
    [self updateData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.itemListViewController && _dataManager.sheets.count > 0)
    {
        self.itemListViewController.sheet = _dataManager.sheets[0];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
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

- (void)showiCloudOptions
{
    NSString *toggleButtonTitle = _dataManager.mode == RZDataManagerModeUsingLocal ? @"Use iCloud" : @"Don't Use iCloud";
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"iCloud Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:toggleButtonTitle, nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if (_dataManager.mode == RZDataManagerModeUsingLocal)
        {
            [_dataManager mergeFromLocalToiCloud];
        }
        else
        {
            [_dataManager mergeFromiCloudToLocal];
        }
        
        [self updateData];
    }
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
