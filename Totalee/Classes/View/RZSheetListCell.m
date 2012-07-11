//
//  RZSheetListCell.m
//  Totalee
//
//  Created by Andy Roth on 7/9/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSheetListCell.h"

#import "RZDataManager.h"

@interface RZSheetListCell ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation RZSheetListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _textField.delegate = self;
}

- (void)setSheet:(RZSheet *)sheet
{
    _sheet = sheet;
    
    _textField.text = _sheet.name;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    _sheet.name = _textField.text;
    [[RZDataManager sharedManager] save];
    
    return NO;
}

- (void)edit
{
    [_textField becomeFirstResponder];
}

@end
