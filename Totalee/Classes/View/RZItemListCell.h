//
//  RZItemListCell.h
//  Totalee
//
//  Created by Andy Roth on 7/11/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZSheetItem.h"

@interface RZItemListCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) RZSheetItem *item;

- (void)edit;

@end
