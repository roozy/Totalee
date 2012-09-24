//
//  RZSheetListCell.h
//  Totalee
//
//  Created by Andy Roth on 7/9/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZSheet.h"

@class RZSheetListCell;

@protocol RZSheetListCellDelegate <NSObject>

- (void)cellShouldBeDeleted:(RZSheetListCell *)cell;

@end

@interface RZSheetListCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id <RZSheetListCellDelegate> delegate;
@property (nonatomic, strong) RZSheet *sheet;

- (void)edit;

@end
