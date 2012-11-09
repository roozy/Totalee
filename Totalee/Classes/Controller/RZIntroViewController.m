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

@interface RZIntroViewController () <UIActionSheetDelegate>
{
@private
    RZDataManager *_dataManager;
    MBProgressHUD *_hud;
}

@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UILabel *welcomeLabel;
@property (nonatomic, weak) IBOutlet UIButton *getStartedButton;

@end

@implementation RZIntroViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    // Update fonts
    _welcomeLabel.font = [UIFont totaleeBoldFontOfSize:_welcomeLabel.font.pointSize];
    _getStartedButton.titleLabel.font = [UIFont totaleeFontOfSize:_getStartedButton.titleLabel.font.pointSize];
    
    // Check iCloud
    _dataManager = [RZDataManager sharedManager];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Check the data state
    RZDataManagerMode mode = _dataManager.mode;
    
    if (mode == RZDataManagerModeUsingiCloud)
    {
        _contentView.hidden = YES;
        [self startupWithiCloud:NO];
    }
    else if (mode == RZDataManagerModeUsingLocal)
    {
        _contentView.hidden = YES;
        [self startupWithLocal:NO];
    }
}

#pragma mark - Button Actions

- (IBAction)getStarted:(id)sender
{
    if (!_dataManager.canConnectToiCloud)
    {
        [self useDevice];
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Get Started" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Use iCloud", @"Don't Use iCloud", nil];
    sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [sheet showInView:self.view];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self useiCloud];
    }
    else if (buttonIndex == 1)
    {
        [self useDevice];
    }
}

- (void)useiCloud
{
    [UIView animateWithDuration:0.2 animations:^{
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        _contentView.hidden = YES;
    }];
    
    _dataManager.mode = RZDataManagerModeUsingiCloud;
    [self startupWithiCloud:YES];
}

- (void)useDevice
{
    _dataManager.mode = RZDataManagerModeUsingLocal;
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
