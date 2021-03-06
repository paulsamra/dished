//
//  DAReviewDetailsViewController.h
//  Dished
//
//  Created by Daryl Stimm on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAFeedItem+Utility.h"
#import "DADishedViewController.h"


@interface DAReviewDetailsViewController : DADishedViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) DAFeedItem *feedItem;

@property (nonatomic) NSInteger reviewID;

- (void)deleteReview;

@end