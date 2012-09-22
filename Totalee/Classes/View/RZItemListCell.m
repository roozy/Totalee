//
//  RZItemListCell.m
//  Totalee
//
//  Created by Andy Roth on 7/11/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZItemListCell.h"

#import "RZDataManager.h"
#import "UIFont+CustomFonts.h"

@interface RZItemListCell ()

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *totalTextField;

@end

@implementation RZItemListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _nameTextField.delegate = self;
    _totalTextField.delegate = self;
    
    _nameTextField.font = [UIFont totaleeFontOfSize:_nameTextField.font.pointSize];
    _totalTextField.font = [UIFont totaleeFontOfSize:_totalTextField.font.pointSize];
}

- (void)setItem:(RZSheetItem *)item
{
    _item = item;
    
    [self updateColors];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self updateData];
    
    return NO;
}

- (void)updateData
{
    _item.name = _nameTextField.text;
    _item.total = [_totalTextField.text floatValue];
    
    [self updateColors];
    
    [[RZDataManager sharedManager] save];
    [_delegate cellDidChangeItem];
}

- (void)updateColors
{
    _nameTextField.text = _item.name;
    _totalTextField.text = _item.total == 0.0 ? @"" : [NSString stringWithFormat:@"%.2f", _item.total];
    _totalTextField.textColor = _item.total > 0 ? [UIColor colorWithRed:0 green:102.0/255.0 blue:0 alpha:1.0] : [UIColor colorWithRed:153.0/255.0 green:0 blue:0 alpha:1.0];
}

- (void)edit
{
    [_nameTextField becomeFirstResponder];
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    if (UITableViewCellStateShowingDeleteConfirmationMask)
    {
        [_nameTextField resignFirstResponder];
        [_totalTextField resignFirstResponder];
    }
}

@end
