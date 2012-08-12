//
//  RZAppDelegate.h
//  Totalee-OSX
//
//  Created by Andy Roth on 8/12/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RZAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
