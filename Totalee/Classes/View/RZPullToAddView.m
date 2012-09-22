//
//  RZPullToAddView.m
//  Totalee
//
//  Created by Andy Roth on 9/22/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZPullToAddView.h"

#import "UIFont+CustomFonts.h"

@interface RZPullToAddView ()
{
@private
    UILabel *_messageLabel;
}

@end

@implementation RZPullToAddView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 25)];
        _messageLabel.font = [UIFont totaleeFontOfSize:21.0];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
        _messageLabel.center = CGPointMake(_messageLabel.center.x, frame.size.height / 2.0);
        _messageLabel.text = @"Pull down to add item";
        [self addSubview:_messageLabel];
        
        UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 59, 320, 1)];
        divider.image = [UIImage imageNamed:@"CellDivider.png"];
        [self addSubview:divider];
    }
    
    return self;
}

- (void)setState:(RZPullToAddViewState)state
{
    if (_state == state) return;
    
    _state = state;
    
    if (_state == RZPullToAddViewStatePullDown)
    {
        _messageLabel.text = @"Pull down to add item";
    }
    else
    {
        _messageLabel.text = @"Release to add item";
    }
}

@end
