//
//  RZAppDelegate.m
//  Totalee-OSX
//
//  Created by Andy Roth on 8/12/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZAppDelegate.h"

#import "RZDataManager.h"

@implementation RZAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Set up iCloud
    [[RZDataManager sharedManager] setupiCloud];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}

@end
