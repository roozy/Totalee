//
//  RZDataManager.m
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZDataManager.h"

@interface RZDataManager ()
{
@private
    NSURL *_ubiquitousContainerURL;
    
    NSPersistentStore *_iCloudStore;
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@end

@implementation RZDataManager

#pragma mark - Singleton

static RZDataManager *_instance;

+ (RZDataManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _instance = [[RZDataManager alloc] init];
    });
    
    return _instance;
}

#pragma mark - iCloud Initialization

- (void)setupiCloud
{
    _connectedToiCloud = NO;
    
    // Check the ubiquity identity
    NSFileManager *manager = [NSFileManager defaultManager];
    if (!manager.ubiquityIdentityToken)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You must be signed into iCloud to use Totalee." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    // Register for iCloud changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDidPostChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    
    // Get the ubiquitous container URL on a separate queue
    __weak RZDataManager *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSURL *containerURL = [manager URLForUbiquityContainerIdentifier:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [weakSelf createPersistentStoreWithContainerURL:containerURL];
        });
    });
}

#pragma mark - Core Data Helpers

- (void)save
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges]) NSLog(@"has changes, saving");
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Error saving context : %@", error);
        } 
    }
}

- (RZSheet *)createSheetWithName:(NSString *)name
{
    RZSheet *sheet = [NSEntityDescription insertNewObjectForEntityForName:@"Sheet" inManagedObjectContext:_managedObjectContext];
    sheet.name = name;
    sheet.order = ((RZSheet *)[_fetchedSheetsController.fetchedObjects lastObject]).order + 1;
    
    [self save];
    
    return sheet;
}

- (RZSheetItem *)createSheetItemWithName:(NSString *)name total:(float)total inSheet:(RZSheet *)sheet
{
    RZSheetItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"SheetItem" inManagedObjectContext:_managedObjectContext];
    item.name = name;
    item.total = total;
    item.order = ((RZSheetItem *)[sheet.sortedItems lastObject]).order + 1;
    
    [sheet addItemsObject:item];
    
    [self save];
    
    return item;
}

- (void)deleteSheetItem:(RZSheetItem *)sheetItem
{
    [sheetItem.sheet removeItemsObject:sheetItem];
    [_managedObjectContext deleteObject:sheetItem];
    
    [self save];
}

- (void)deleteSheet:(RZSheet *)sheet
{
    NSArray *items = [sheet.items allObjects];
    for (int i = 0; i < items.count; i++)
    {
        [self deleteSheetItem:items[i]];
    }
    
    [_managedObjectContext deleteObject:sheet];
    
    [self save];
}

#pragma mark - Core Data & iCloud Stack

- (void)createPersistentStoreWithContainerURL:(NSURL *)url
{
    _ubiquitousContainerURL = url;
    
    // Create the managed object model and persistent store coordinator
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Totalee" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    // Create a nosync folder to hold the sqlite file
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeDirectory = [_ubiquitousContainerURL URLByAppendingPathComponent:@"Totalee.nosync"];
    if (![fileManager fileExistsAtPath:[storeDirectory path]])
    {
        BOOL success = [fileManager createDirectoryAtPath:[storeDirectory path] withIntermediateDirectories:YES attributes:nil error:NULL];
        
        if (!success) NSLog(@"Could not create nosync directory");
    }
    
    // Get the store URL (not synced) and the URL for the ubiquitous content (change logs)
    NSURL *storeURL = [storeDirectory URLByAppendingPathComponent:@"Totalee.sqlite"];
    NSURL *dataURL = [_ubiquitousContainerURL URLByAppendingPathComponent:@"TotaleeData"];
    
    NSDictionary *options = @{ NSPersistentStoreUbiquitousContentNameKey : @"TotaleeStore",
                                NSPersistentStoreUbiquitousContentURLKey : dataURL,
                            NSMigratePersistentStoresAutomaticallyOption : @YES};
    
    // Create the persistent store
    NSError *error;
    _iCloudStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil
                                                                       URL:storeURL
                                                                   options:options
                                                                     error:&error];
    
    if (error)
    {
        NSLog(@"Error creating iCloud store : %@", error);
    }
    
    // Create the managed object context
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
    // Create the fetched results controller
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Sheet"];
    NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    fetchRequest.sortDescriptors = @[ orderDescriptor ];
    
    _fetchedSheetsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [_fetchedSheetsController performFetch:NULL];
    
    _connectedToiCloud = YES;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:RZDataManagerDidConnectToiCloudNotification object:nil]];
}

#pragma mark - iCloud Changes

- (void)iCloudDidPostChanges:(NSNotification *)note
{
    [_fetchedSheetsController performFetch:NULL];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:RZDataManagerDidMakeChangesNotification object:nil]];
}

@end
