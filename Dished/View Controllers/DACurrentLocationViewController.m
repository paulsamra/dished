//
//  DACurrentLocationViewController.m
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACurrentLocationViewController.h"
#import <MapKit/MapKit.h>
#import "DALocationManager.h"


@interface DACurrentLocationViewController()

@property (strong, nonatomic) NSArray              *searchResults;
@property (strong, nonatomic) MKLocalSearch        *locationSearch;
@property (strong, nonatomic) MKLocalSearchRequest *locationSearchRequest;

@property (nonatomic) int selectedRadius;

@end


@implementation DACurrentLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResults         = [NSArray array];
    self.locationSearchRequest = [[MKLocalSearchRequest alloc] init];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
}

- (IBAction)cancelChangeLocation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( self.locationSearch )
    {
        [self.locationSearch cancel];
    }
    
    self.locationSearchRequest.naturalLanguageQuery = searchText;
    
    CLLocationCoordinate2D currentLocation = [[DALocationManager sharedManager] currentLocation];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance( currentLocation, 24140, 24140 );
    self.locationSearchRequest.region = region;
    
    self.locationSearch = [[MKLocalSearch alloc] initWithRequest:self.locationSearchRequest];
    
    [self.locationSearch startWithCompletionHandler:^( MKLocalSearchResponse *response, NSError *error )
    {
        if( !error )
        {
            NSPredicate *noBusiness = [NSPredicate predicateWithFormat:@"business.uID == 0"];
            NSMutableArray *itemsWithoutBusinesses = [response.mapItems mutableCopy];
            [itemsWithoutBusinesses filterUsingPredicate:noBusiness];
            
            NSLog(@"%d", (int)[itemsWithoutBusinesses count]);
            self.searchResults = itemsWithoutBusinesses;
            [self.tableView reloadData];
        }
        else
        {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if( indexPath.row == [self.searchResults count] )
    {
        cell.textLabel.text  = @"Current Location";
        cell.imageView.image = [UIImage imageNamed:@"explore_current_location"];
        
        return cell;
    }
    else if( indexPath.row == [self.searchResults count] + 1 )
    {
        cell.textLabel.text       = @"Search Radius";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d mi", self.selectedRadius];
        cell.imageView.image      = nil;
        
        return cell;
    }
    
    MKMapItem *mapItem = [self.searchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = mapItem.name;
    cell.imageView.image = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == [self.searchResults count] )
    {
        
    }
}

@end