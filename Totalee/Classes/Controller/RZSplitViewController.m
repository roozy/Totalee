//
//  RZSplitViewController.m
//  Totalee
//
//  Created by Andy Roth on 7/13/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSplitViewController.h"

@interface RZSplitViewController ()

@end

@implementation RZSplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{

}

@end
