//
//  RZPullToAddView.h
//  Totalee
//
//  Created by Andy Roth on 9/22/12.
//  Copyright (c) 2012 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    RZPullToAddViewStatePullDown = 0,
    RZPullToAddViewStateRelease
} RZPullToAddViewState;

@interface RZPullToAddView : UIView

@property (nonatomic) RZPullToAddViewState state;

@end
