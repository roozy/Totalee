//
//  UIFont+CustomFonts.m
//  Totalee
//
//  Created by Andy Roth on 9/22/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "UIFont+CustomFonts.h"

@implementation UIFont (CustomFonts)

+ (UIFont *)totaleeFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"EuphemiaUCAS" size:size];
}

+ (UIFont *)totaleeBoldFontOfSize:(CGFloat)size
{
    return [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:size];
}

@end
