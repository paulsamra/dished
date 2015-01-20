//
//  DAExploreDefinedSearchViewController.h
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define kPopularNow   @"dished_popular_now"
#define kEditorsPicks @"dished_editors_picks"


@interface DAExploreDishResultsViewController : DADishedViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *searchTerm;

@property (nonatomic) double                 selectedRadius;
@property (nonatomic) CLLocationCoordinate2D selectedLocation;

@end