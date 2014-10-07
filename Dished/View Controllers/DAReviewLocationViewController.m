//
//  DALocationTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewLocationViewController.h"
#import "DAReviewFormViewController.h"
#import "DAAddPlaceViewController.h"
#import "DAAPIManager.h"
#import "DALocationManager.h"

static NSString *kLocationNameKey     = @"name";
static NSString *kLocationIDKey       = @"id";
static NSString *kLocationDistanceKey = @"distance";
static NSString *kLocationGoogleIDKey = @"google_id";
static NSString *kLocationTypeKey     = @"type";


@interface DAReviewLocationViewController() <UISearchBarDelegate>

@property (strong, nonatomic) NSArray           *locationData;
@property (strong, nonatomic) NSString          *currentTaskID;
@property (strong, nonatomic) NSURLSessionTask  *searchTask;

@end


@implementation DAReviewLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
    
    self.locationData = [NSArray array];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.locationData count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( indexPath.row == [self.locationData count] )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newPlaceCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
        
        cell.textLabel.text       = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationNameKey];
        cell.detailTextLabel.text = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationDistanceKey];
    }
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, 0.5)];
    separatorLineView.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:separatorLineView];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    double height = 0.0;
    
	if( indexPath.row == ( [self.locationData count] + 1 ) )
    {
        height = 300.0;
    }
    else
    {
        height = 44.0;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row < [self.locationData count] )
    {
        self.review.locationName = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationNameKey];
        self.review.locationID = 0;
        self.review.googleID   = 0;
        
        if( [[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationIDKey] )
        {
            self.review.locationID = [[[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationIDKey] integerValue];
        }
        else if( [[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationGoogleIDKey] )
        {
            self.review.googleID = [[[self.locationData objectAtIndex:indexPath.row] objectForKey:kLocationGoogleIDKey] integerValue];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if( indexPath.row == [self.locationData count] )
    {
        [self.view endEditing:YES];
        
        if( ![[DALocationManager sharedManager] locationServicesEnabled] )
        {
            [[[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"To be able to add a place, Dished needs your current location. Please enable location services for Dished in your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
        else
        {
            [self performSegueWithIdentifier:@"add" sender:nil];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"add"] )
    {
        DAAddPlaceViewController *dest = segue.destinationViewController;
        dest.review = self.review;
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length == 0 )
    {
        [self.searchTask cancel];
        self.locationData  = [NSMutableArray array];
        [self.tableView reloadData];
        return;
    }
    
    double longitude = [[DALocationManager sharedManager] currentLocation].longitude;
    double latitude  = [[DALocationManager sharedManager] currentLocation].latitude;
    
    if( self.searchTask )
    {
        [self.searchTask cancel];
    }
    
    self.searchTask = [[DAAPIManager sharedManager] exploreLocationSearchTaskWithQuery:searchText
    longitude:longitude latitude:latitude completion:^( id response, NSError *error )
    {
        self.locationData = [self locationsFromResponse:response];
        
        [self.tableView reloadData];
    }];
}

- (NSArray *)locationsFromResponse:(id)response
{
    NSArray *locations = response[@"data"][@"locations"];
    NSMutableArray *newLocations = [NSMutableArray array];
    
    if( locations && ![locations isEqual:[NSNull null]] )
    {
        for( NSDictionary *locationInfo in locations )
        {
            NSMutableDictionary *location = [NSMutableDictionary dictionary];
            location[kLocationNameKey] = locationInfo[kLocationNameKey];
            
            if( [locationInfo[kLocationTypeKey] isEqualToString:@"system"] )
            {
                location[kLocationIDKey] = locationInfo[kLocationIDKey];
            }
            else if( [locationInfo[kLocationTypeKey] isEqualToString:@"google"] )
            {
                location[kLocationGoogleIDKey] = locationInfo[kLocationGoogleIDKey];
            }
            
            if( locationInfo[kLocationDistanceKey] )
            {
                location[kLocationDistanceKey] = locationInfo[kLocationDistanceKey];
            }
            
            [newLocations addObject:location];
        }
    }
    
    return [newLocations copy];
}

@end