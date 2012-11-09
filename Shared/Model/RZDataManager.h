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

typedef enum
{
    RZDataManagerModeUninitialized = 0,
    RZDataManagerModeUsingiCloud,
    RZDataManagerModeUsingLocal
} RZDataManagerMode;

@interface RZDataManager : NSObject

@property (nonatomic) RZDataManagerMode mode;

@property (nonatomic, readonly) BOOL canConnectToiCloud;
@property (nonatomic, readonly) BOOL connectedToiCloud;
@property (nonatomic, readonly) NSArray *sheets;

// Initialization
+ (RZDataManager *)sharedManager;
- (void)setupLocally;
- (void)setupiCloud;
- (void)save;

- (void)mergeFromLocalToiCloud;
- (void)mergeFromiCloudToLocal;

// Insert/Delete Methods
- (RZSheet *)createSheetWithName:(NSString *)name;
- (void)deleteSheet:(RZSheet *)sheet;
- (void)moveSheet:(RZSheet *)sheet toIndex:(int)index;

- (RZSheetItem *)createSheetItemWithName:(NSString *)name total:(float)total inSheet:(RZSheet *)sheet;
- (void)deleteSheetItem:(RZSheetItem *)sheetItem;
- (void)moveSheetItem:(RZSheetItem *)sheetItem toIndex:(int)index;

@end

static NSString *RZDataManagerDidConnectToiCloudNotification = @"RZDataManagerDidConnectToiCloudNotification";
static NSString *RZDataManagerDidMakeChangesNotification = @"RZDataManagerDidMakeChangesNotification";