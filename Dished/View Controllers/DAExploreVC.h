//
//  DAExploreVC.h
//  Dished
//
//  Created by Ryan Khalili on 7/31/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAExploreVC : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,
                                           UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *editorsPicksButton;
@property (weak, nonatomic) IBOutlet UIButton *popularNowButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end