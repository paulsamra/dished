//
//  DACollectionViewFlowLayout.h
//  Dished
//
//  Created by Ryan Khalili on 9/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DARefreshControl.h"


@interface DAFeedCollectionViewFlowLayout : UICollectionViewFlowLayout

@property (weak, nonatomic) UINavigationBar  *navigationBar;
@property (weak, nonatomic) DARefreshControl *refreshControl;

@end