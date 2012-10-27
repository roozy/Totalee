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
    NSPersistentStore *_localStore;
    
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

#pragma mark - Application Properties

- (RZDataManagerState)state
{
    int currentState = [[NSUserDefaults standardUserDefaults] integerForKey:@"dataManagerState"];
    
    return currentState;
}

- (void)setState:(RZDataManagerState)state
{
    [[NSUserDefaults standardUserDefaults] setInteger:state forKey:@"dataManagerState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Local Initialization

- (void)setupLocally
{
    [self createPersistentStoreWithLocalURL];
}

#pragma mark - iCloud Initialization

- (BOOL)canConnectToiCloud
{
    NSFileManager *manager = [NSFileManager defaultManager];

    return manager.ubiquityIdentityToken != nil;
}

- (void)setupiCloud
{
    _connectedToiCloud = NO;
    
    // Check the ubiquity identity
    if (!self.canConnectToiCloud)
    {
        NSLog(@"Error: Must be logged in to iCloud.");
        
        return;
    }
    
    // Register for iCloud changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDidPostChanges:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:nil];
    
    // Get the ubiquitous container URL on a separate queue
    __weak RZDataManager *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSFileManager *manager = [NSFileManager defaultManager];
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
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Error saving context : %@", error);
        } 
    }
    
    [self refresh];
}

- (RZSheet *)createSheetWithName:(NSString *)name
{
    RZSheet *sheet = [NSEntityDescription insertNewObjectForEntityForName:@"Sheet" inManagedObjectContext:_managedObjectContext];
    sheet.name = name;
    sheet.order = 0;
    
    for (RZSheet *sheet in _sheets)
    {
        sheet.order++;
    }
    
    [self save];
    
    return sheet;
}

- (void)deleteSheet:(RZSheet *)sheet
{
    NSArray *items = [sheet.items allObjects];
    for (int i = 0; i < items.count; i++)
    {
        [self deleteSheetItem:items[i]];
    }
    
    for (int i=[_sheets indexOfObject:sheet] + 1; i < _sheets.count; i++)
    {
        RZSheet *sheet = _sheets[i];
        sheet.order--;
    }
    
    [_managedObjectContext deleteObject:sheet];
    
    [self save];
}

- (void)moveSheet:(RZSheet *)sheet toIndex:(int)index
{
    int originalOrder = sheet.order;
    sheet.order = index;
    
    if (index < originalOrder)
    {
        for (int i=index; i < originalOrder; i++)
        {
            RZSheet *sheet = _sheets[i];
            sheet.order++;
        }
    }
    else
    {
        for (int i=originalOrder + 1; i <= index; i++)
        {
            RZSheet *sheet = _sheets[i];
            sheet.order--;
        }
    }
    
    [self save];
}

- (RZSheetItem *)createSheetItemWithName:(NSString *)name total:(float)total inSheet:(RZSheet *)sheet
{
    RZSheetItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"SheetItem" inManagedObjectContext:_managedObjectContext];
    item.name = name;
    item.total = total;
    item.order = 0;
    
    for (RZSheetItem *sheetItem in sheet.items)
    {
        sheetItem.order++;
    }
    
    [sheet addItemsObject:item];
    
    [self save];
    
    return item;
}

- (void)deleteSheetItem:(RZSheetItem *)sheetItem
{
    NSArray *sortedItems = sheetItem.sheet.sortedItems;
    for (int i=[sortedItems indexOfObject:sheetItem] + 1; i < sortedItems.count; i++)
    {
        RZSheetItem *item = sortedItems[i];
        item.order--;
    }
    
    [sheetItem.sheet removeItemsObject:sheetItem];
    [_managedObjectContext deleteObject:sheetItem];
    
    [self save];
}

- (void)moveSheetItem:(RZSheetItem *)sheetItem toIndex:(int)index
{
    NSArray *sortedItems = sheetItem.sheet.sortedItems;
    
    int originalOrder = sheetItem.order;
    sheetItem.order = index;
    
    if (index < originalOrder)
    {
        for (int i=index; i < originalOrder; i++)
        {
            RZSheetItem *item = sortedItems[i];
            item.order++;
        }
    }
    else
    {
        for (int i=originalOrder + 1; i <= index; i++)
        {
            RZSheetItem *item = sortedItems[i];
            item.order--;
        }
    }
    
    [self save];
}

#pragma mark - Core Data & iCloud Stack

- (void)createPersistentStoreWithLocalURL
{
    NSURL *documentsDirectory = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
    
    // Create the managed object model and persistent store coordinator
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Totalee" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
    
    // Get the store URL (not synced) and the URL for the ubiquitous content (change logs)
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:@"Totalee.sqlite"];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES] };
    
    // Create the persistent store
    NSError *error = nil;
    _localStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil
                                                                       URL:storeURL
                                                                   options:options
                                                                     error:&error];
    
    if (error)
    {
        NSLog(@"Error creating local store : %@", error);
    }
    
    // Create the managed object context
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
    
    [self refresh];
}

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
                            NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES]};
    
    // Create the persistent store
    NSError *error = nil;
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
    
    [self refresh];
    
    _connectedToiCloud = YES;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:RZDataManagerDidConnectToiCloudNotification object:nil]];
}

#pragma mark - iCloud Changes

- (void)iCloudDidPostChanges:(NSNotification *)note
{
    [self refresh];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:RZDataManagerDidMakeChangesNotification object:nil]];
}

- (void)refresh
{
    // Create the fetch request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Sheet"];
    NSSortDescriptor *orderDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    fetchRequest.sortDescriptors = @[ orderDescriptor ];
    
    _sheets = [_managedObjectContext executeFetchRequest:fetchRequest error:NULL];
}

@end
