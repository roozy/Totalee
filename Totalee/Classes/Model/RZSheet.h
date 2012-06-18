//
//  RZSheet.h
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RZSheetItem;

@interface RZSheet : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic) int16_t order;

@property (nonatomic, readonly) NSArray *sortedItems;

@end

@interface RZSheet (CoreDataGeneratedAccessors)

- (void)addItemsObject:(RZSheetItem *)value;
- (void)removeItemsObject:(RZSheetItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
