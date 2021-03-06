//
//  DAExploreViewController.h
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAExploreViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource,
                                                       UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
                                                       UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UISearchBar      *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView      *tableView;

+ (double)storedRadius;
+ (CLLocationCoordinate2D)storedLocation;

@end