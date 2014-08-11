//
//  DAExploreDefinedSearchViewController.h
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface DAExploreDishResultsViewController : UITableViewController

@property (strong, nonatomic) NSString *searchTerm;

@property (nonatomic) double                 selectedRadius;
@property (nonatomic) CLLocationCoordinate2D selectedLocation;

@end