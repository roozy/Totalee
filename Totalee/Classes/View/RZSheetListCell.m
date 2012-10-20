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

@interface RZSheetListCell () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UIImageView *divider;

@end

@implementation RZSheetListCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(edit)];
        longPress.delegate = self;
        [self addGestureRecognizer:longPress];
    }
    
    return self;
}

- (void)prepareForReuse
{
    _textField.userInteractionEnabled = NO;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_divider removeFromSuperview];
    [self addSubview:_divider];
    
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
    [_textField resignFirstResponder];
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0)
    {
        if ([_delegate respondsToSelector:@selector(cellShouldBeDeleted:)])
        {
            [_delegate cellShouldBeDeleted:self];
        }
    }
    else
    {
        _textField.userInteractionEnabled = NO;
        _sheet.name = _textField.text;
        [[RZDataManager sharedManager] save];
    }
}

- (void)edit
{
    _textField.userInteractionEnabled = YES;
    [_textField becomeFirstResponder];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (state & UITableViewCellStateShowingDeleteConfirmationMask || state & UITableViewCellStateShowingEditControlMask)
    {
        [_textField resignFirstResponder];
        _textField.userInteractionEnabled = NO;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return !self.editing;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}

@end
