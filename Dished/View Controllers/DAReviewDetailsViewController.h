//
//  DAReviewDetailsViewController.h
//  Dished
//
//  Created by POST on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAReviewDetailsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSDictionary *reviewDetailsDictionary;
@end
