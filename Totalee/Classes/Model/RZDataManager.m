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
    // Check the ubiquity identity
    NSFileManager *manager = [NSFileManager defaultManager];
    if (!manager.ubiquityIdentityToken)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"You must be signed into iCloud to use Totalee" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = _managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
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
                                NSPersistentStoreUbiquitousContentURLKey : dataURL };
    
    // Create the persistent store
    NSError *error;
    _iCloudStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil
                                                                       URL:storeURL
                                                                   options:options
                                                                     error:&error];
    
    if (error)
    {
        NSLog(@"Error creating iCloud store : %@", error.localizedDescription);
    }
    
    // Create the managed object context
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:_persistentStoreCoordinator];
}

#pragma mark - iCloud Changes

- (void)iCloudDidPostChanges:(NSPersistentStoreCoordinator *)coordinator
{
    
}

@end
