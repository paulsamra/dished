//
//  DACurrentLocationViewController.h
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@class DACurrentLocationViewController;


@protocol DACurrentLocationViewControllerDelegate <NSObject>

- (void)locationViewControllerDidSelectLocationName:(NSString *)locationName atLocation:(CLLocationCoordinate2D)location radius:(double)radius;

@end


@interface DACurrentLocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (weak, nonatomic) id<DACurrentLocationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSString *selectedLocationName;

@property (nonatomic) double selectedRadius;

@end