//
//  RZItemListViewController.h
//  Totalee
//
//  Created by Andy Roth on 7/11/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RZSheet.h"
#import "RZItemListCell.h"

@interface RZItemListViewController : UITableViewController <RZItemListCellDelegate>

@property (nonatomic, strong) RZSheet *sheet;

@end
