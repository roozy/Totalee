//
//  RZItemListCell.m
//  Totalee
//
//  Created by Andy Roth on 7/11/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZItemListCell.h"

#import "RZDataManager.h"

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
}

- (void)setItem:(RZSheetItem *)item
{
    _item = item;
    
    _nameTextField.text = item.name;
    _totalTextField.text = item.total == 0.0 ? @"" : [NSString stringWithFormat:@"%.2f", item.total];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    _item.name = _nameTextField.text;
    _item.total = [_totalTextField.text floatValue];
    _totalTextField.text = _item.total == 0.0 ? @"" : [NSString stringWithFormat:@"%.2f", _item.total];
    
    [[RZDataManager sharedManager] save];
    
    return NO;
}

- (void)edit
{
    [_nameTextField becomeFirstResponder];
}

@end
