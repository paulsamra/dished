//
//  DAGlobaelDishDetailViewController.h
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DADishedViewController.h"


@interface DAGlobalDishDetailViewController : DADishedViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic) NSInteger presentingReviewID;
@property (nonatomic) NSInteger dishID;

@end