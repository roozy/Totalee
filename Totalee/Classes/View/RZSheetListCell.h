//
//  RZSheetListCell.h
//  Totalee
//
//  Created by Andy Roth on 7/9/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZSheet.h"

@protocol RZSheetListCellDelegate <NSObject>

- (void)cellDidSelectSheet:(RZSheet *)sheet;

@end

@interface RZSheetListCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) id <RZSheetListCellDelegate> delegate;
@property (nonatomic, strong) RZSheet *sheet;

- (void)edit;
- (void)stopEditing;

@end
