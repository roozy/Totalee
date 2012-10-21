//
//  RZTotalFooterView.m
//  Totalee
//
//  Created by Andy Roth on 7/12/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZTotalFooterView.h"

#import "UIFont+CustomFonts.h"

@interface RZTotalFooterView ()
{
@private
    UILabel *_totalTitle;
    UILabel *_totalLabel;
    
    UIImageView *_divider;
    UIImageView *_bottomDivider;
    UIImageView *_topDivider;
}

@end

@implementation RZTotalFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _totalTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 197, 31)];
        _totalTitle.backgroundColor = [UIColor clearColor];
        _totalTitle.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
        _totalTitle.font = [UIFont totaleeBoldFontOfSize:21.0];
        _totalTitle.text = @"Total";
        [self addSubview:_totalTitle];
        
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 96, 15, 86, 30)];
        _totalLabel.backgroundColor = [UIColor clearColor];
        _totalLabel.textColor = [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0];
        _totalLabel.font = [UIFont totaleeFontOfSize:21.0];
        _totalLabel.textAlignment = NSTextAlignmentRight;
        _totalLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_totalLabel];
        
        _divider = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 105, 0, 1, 60)];
        _divider.image = [UIImage imageNamed:@"CellDividerVertical.png"];
        _divider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_divider];
        
        _bottomDivider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 59, frame.size.width, 1)];
        _bottomDivider.image = [UIImage imageNamed:@"CellDivider.png"];
        _bottomDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_bottomDivider];
        
        _topDivider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        _topDivider.image = [UIImage imageNamed:@"CellDivider.png"];
        _topDivider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _topDivider.hidden = YES;
        [self addSubview:_topDivider];
        
        self.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    }
    
    return self;
}

- (void)setTotal:(float)total
{
    _total = total;
    
    _totalLabel.text = [NSString stringWithFormat:@"%.2f", _total];
    _totalLabel.textColor = _total == 0.0 ? [UIColor colorWithRed:100.0/255.0 green:100.0/255.0 blue:100.0/255.0 alpha:1.0] : (_total > 0.0 ? [UIColor colorWithRed:0 green:102.0/255.0 blue:0 alpha:1.0] : [UIColor colorWithRed:153.0/255.0 green:0 blue:0 alpha:1.0]);
}

- (void)setShowTopDivider:(BOOL)showTopDivider
{
    _showTopDivider = showTopDivider;
    
    _topDivider.hidden = !_showTopDivider;
}

@end
