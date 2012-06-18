//
//  RZSheetItem.h
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RZSheet;

enum
{
    RZSheetItemCategoryNone = 0,
    RZSheetItemCategoryFood,
    RZSheetItemCategoryEntertainment,
    RZSheetItemCategoryBills
};
typedef int16_t RZSheetItemCategory;

@interface RZSheetItem : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic) float total;
@property (nonatomic) RZSheetItemCategory category;
@property (nonatomic) int16_t order;

@property (nonatomic, retain) RZSheet *sheet;

@end
