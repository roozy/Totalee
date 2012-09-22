//
//  RZSheetListCell.m
//  Totalee
//
//  Created by Andy Roth on 7/9/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSheetListCell.h"

#import "RZDataManager.h"
#import "UIFont+CustomFonts.h"

@interface RZSheetListCell ()

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end

@implementation RZSheetListCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(edit)];
        [self addGestureRecognizer:longPress];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _textField.font = [UIFont totaleeFontOfSize:_textField.font.pointSize];
    _textField.delegate = self;
    _textField.userInteractionEnabled = NO;
}

- (void)setSheet:(RZSheet *)sheet
{
    _sheet = sheet;
    
    _textField.text = _sheet.name;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    _textField.userInteractionEnabled = NO;
    _sheet.name = _textField.text;
    [[RZDataManager sharedManager] save];
    
    return NO;
}

- (void)edit
{
    _textField.userInteractionEnabled = YES;
    [_textField becomeFirstResponder];
}

@end
