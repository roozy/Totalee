//
//  RZTotalFooterView.m
//  Totalee
//
//  Created by Andy Roth on 7/12/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZTotalFooterView.h"

@interface RZTotalFooterView ()
{
@private
    UILabel *_totalLabel;
    UIView *_divider;
}

@end

@implementation RZTotalFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalLabel.backgroundColor = [UIColor clearColor];
        _totalLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [self.contentView addSubview:_totalLabel];
        
        _divider = [[UIView alloc] initWithFrame:CGRectZero];
        _divider.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_divider];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _totalLabel.frame = CGRectMake(self.frame.size.width - 76.0, 0, 70, self.contentView.frame.size.height);
    _divider.frame = CGRectMake(self.frame.size.width - 85.0, 0, 1, self.contentView.frame.size.height);
}

- (void)setTotal:(float)total
{
    _total = total;
    
    _totalLabel.text = [NSString stringWithFormat:@"%.2f", _total];
    _totalLabel.textColor = _total == 0.0 ? [UIColor blackColor] : (_total > 0.0 ? [UIColor colorWithRed:0 green:102.0/255.0 blue:0 alpha:1.0] : [UIColor colorWithRed:153.0/255.0 green:0 blue:0 alpha:1.0]);
}

@end
