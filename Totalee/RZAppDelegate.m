//
//  RZAppDelegate.m
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZAppDelegate.h"

#import "RZDataManager.h"
#import "RZRootViewController.h"

@implementation RZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set up iCloud
    [[RZDataManager sharedManager] setupiCloud];
    
    // Create the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    RZRootViewController *root = [[RZRootViewController alloc] init];
    root.view.frame = self.window.bounds;
    
    self.window.rootViewController = root;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[RZDataManager sharedManager] save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[RZDataManager sharedManager] save];
}

@end
