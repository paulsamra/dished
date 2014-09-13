//
//  DAFeedViewController.h
//  Dished
//
//  Created by Ryan Khalili on 8/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAFeedViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (void)scrollFeedToTop;

@end