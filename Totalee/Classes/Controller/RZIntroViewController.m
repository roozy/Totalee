//
//  RZIntroViewController.m
//  Totalee
//
//  Created by Andy Roth on 10/26/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZIntroViewController.h"

#import "RZDataManager.h"
#import "UIFont+CustomFonts.h"
#import "MBProgressHUD.h"

#define kStartupSegueAnimated           @"StartupAnimated"
#define kStartupSegueNotAnimated        @"StartupNotAnimated"

@interface RZIntroViewController ()
{
@private
    RZDataManager *_dataManager;
    MBProgressHUD *_hud;
}

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, weak) IBOutlet UILabel *getStartedLabel;

@property (nonatomic, weak) IBOutlet UIButton *iCloudButton;
@property (nonatomic, weak) IBOutlet UIButton *localButton;

- (IBAction)useiCloud:(id)sender;
- (IBAction)useDevice:(id)sender;

@end

@implementation RZIntroViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    // Update fonts
    _welcomeLabel.font = [UIFont totaleeBoldFontOfSize:_welcomeLabel.font.pointSize];
    _getStartedLabel.font = [UIFont totaleeFontOfSize:_getStartedLabel.font.pointSize];
    _iCloudButton.titleLabel.font = [UIFont totaleeFontOfSize:_iCloudButton.titleLabel.font.pointSize];
    _localButton.titleLabel.font = [UIFont totaleeFontOfSize:_localButton.titleLabel.font.pointSize];
    
    // Check iCloud
    _dataManager = [RZDataManager sharedManager];
    
    if (!_dataManager.canConnectToiCloud)
    {
        _iCloudButton.enabled = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    // Check the data state
    RZDataManagerState state = _dataManager.state;
    
    if (state == RZDataManagerStateUsingiCloud)
    {
        _contentView.hidden = YES;
        [self startupWithiCloud:NO];
    }
    else if (state == RZDataManagerStateUsingLocal)
    {
        _contentView.hidden = YES;
        [self startupWithLocal:NO];
    }
}

#pragma mark - Button Actions

- (IBAction)useiCloud:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        _contentView.hidden = YES;
    }];
    
    _dataManager.state = RZDataManagerStateUsingiCloud;
    [self startupWithiCloud:YES];
}

- (IBAction)useDevice:(id)sender
{
    _dataManager.state = RZDataManagerStateUsingLocal;
    [self startupWithLocal:YES];
}

#pragma mark - Options

- (void)startupWithiCloud:(BOOL)animated
{
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.labelText = @"Initializing iCloud";
    [self.view addSubview:_hud];
    [_hud show:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToiCloud) name:RZDataManagerDidConnectToiCloudNotification object:nil];
    [_dataManager setupiCloud];
}

- (void)connectedToiCloud
{
    [_hud hide:YES];
    [self performSegueWithIdentifier:kStartupSegueAnimated sender:nil];
}

- (void)startupWithLocal:(BOOL)animated
{
    [_dataManager setupLocally];
    [self performSegueWithIdentifier:animated ? kStartupSegueAnimated : kStartupSegueNotAnimated sender:nil];
}

@end
