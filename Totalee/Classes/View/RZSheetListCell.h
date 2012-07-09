//
//  RZSheetListCell.h
//  Totalee
//
//  Created by Andy Roth on 7/9/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZSheet.h"

@interface RZSheetListCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, strong) RZSheet *sheet;

@end
