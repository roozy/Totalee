//
//  RZRootViewController.m
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZRootViewController.h"

#import "RZDataManager.h"

@interface RZRootViewController ()

@end

@implementation RZRootViewController

- (void)viewDidLoad
{
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addSheet)];
    [self.view addGestureRecognizer:tapper];
}

- (void)addSheet
{
    [[RZDataManager sharedManager] createSheetWithName:@"MyTestSheet"];
    [[RZDataManager sharedManager] save];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Created a new sheet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
