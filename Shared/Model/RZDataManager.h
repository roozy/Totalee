//
//  RZDataManager.h
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "RZSheet.h"
#import "RZSheetItem.h"

@interface RZDataManager : NSObject

@property (nonatomic) BOOL connectedToiCloud;
@property (nonatomic, readonly) NSArray *sheets;

// Initialization
+ (RZDataManager *)sharedManager;
- (void)setupiCloud;
- (void)save;

// Insert/Delete Methods
- (RZSheet *)createSheetWithName:(NSString *)name;
- (void)deleteSheet:(RZSheet *)sheet;
- (void)moveSheet:(RZSheet *)sheet toIndex:(int)index;

- (RZSheetItem *)createSheetItemWithName:(NSString *)name total:(float)total inSheet:(RZSheet *)sheet;
- (void)deleteSheetItem:(RZSheetItem *)sheetItem;

@end

static NSString *RZDataManagerDidConnectToiCloudNotification = @"RZDataManagerDidConnectToiCloudNotification";
static NSString *RZDataManagerDidMakeChangesNotification = @"RZDataManagerDidMakeChangesNotification";