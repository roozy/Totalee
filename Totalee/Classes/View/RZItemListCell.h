//
//  RZItemListCell.h
//  Totalee
//
//  Created by Andy Roth on 7/11/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZSheetItem.h"

@protocol RZItemListCellDelegate <NSObject>

- (void)cellDidChangeItem;

@end

@interface RZItemListCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id <RZItemListCellDelegate> delegate;
@property (nonatomic, strong) RZSheetItem *item;

- (void)edit;

@end
