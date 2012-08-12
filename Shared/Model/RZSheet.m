//
//  RZSheet.m
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import "RZSheet.h"

#import "RZSheetItem.h"

@implementation RZSheet

@dynamic name;
@dynamic items;
@dynamic order;

- (NSArray *)sortedItems
{
    return [self.items sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES] ]];
}

@end
