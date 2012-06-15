//
//  RZDataManager.h
//  Totalee
//
//  Created by Andy Roth on 6/15/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RZDataManager : NSObject

+ (RZDataManager *)sharedManager;

- (void)setupiCloud;
- (void)saveContext;

@end
