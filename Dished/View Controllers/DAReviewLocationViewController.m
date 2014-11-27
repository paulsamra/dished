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
#import "DALocationManager.h"


@interface DAReviewLocationViewController() <UISearchBarDelegate>

@property (strong, nonatomic) NSArray                 *locationData;
@property (strong, nonatomic) NSURLSessionTask        *searchTask;
@property (strong, nonatomic) UIActivityIndicatorView *searchSpinner;

@end


@implementation DAReviewLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
    
    self.locationData = self.suggestedLocations;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.searchSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.searchSpinner.hidesWhenStopped = YES;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:self.searchSpinner];
    self.navigationItem.rightBarButtonItem = barButton;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.locationData.count <= 0 )
    {
        return self.searchBar.text.length == 0 ? 0 : 1;
    }
    else
    {
        if( self.locationData == self.suggestedLocations )
        {
            return self.locationData.count;
        }
        else
        {
            return self.locationData.count + 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( indexPath.row == [self.locationData count] || ( self.locationData.count == 0 && self.searchBar.text.length > 0 ) )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"newPlaceCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
        
        cell.textLabel.text       = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kNameKey];
        cell.detailTextLabel.text = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kDistanceKey];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row < [self.locationData count] )
    {
        self.review.locationName = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kNameKey];
        self.review.locationID = 0;
        self.review.googleID   = 0;
        self.review.dishID     = 0;
        
        if( [[self.locationData objectAtIndex:indexPath.row] objectForKey:kIDKey] )
        {
            self.review.locationID = [[[self.locationData objectAtIndex:indexPath.row] objectForKey:kIDKey] integerValue];
        }
        else if( [[self.locationData objectAtIndex:indexPath.row] objectForKey:kGoogleIDKey] )
        {
            self.review.googleID = [[self.locationData objectAtIndex:indexPath.row] objectForKey:kGoogleIDKey];
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
        self.locationData = self.suggestedLocations;
        [self.tableView reloadData];
        [self.searchSpinner stopAnimating];
        return;
    }
    
    double longitude = [[DALocationManager sharedManager] currentLocation].longitude;
    double latitude  = [[DALocationManager sharedManager] currentLocation].latitude;
    
    [self.searchTask cancel];
    
    NSDictionary *parameters = @{ kQueryKey : searchText, kLongitudeKey : @(longitude), kLatitudeKey : @(latitude) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    [self.searchSpinner startAnimating];
    
    self.searchTask = [[DAAPIManager sharedManager] GET:kExploreLocationsURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        [self.searchSpinner stopAnimating];
        self.locationData = [DAReviewLocationViewController locationsFromResponse:responseObject];
        [self.tableView reloadData];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^
            {
                [self searchBar:searchBar textDidChange:searchText];
            }];
        }
    }];
}

+ (NSArray *)locationsFromResponse:(id)response
{
    NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey );
    NSArray *locations = nilOrJSONObjectForKey( data, @"locations" );
    NSMutableArray *newLocations = [NSMutableArray array];
    
    for( NSDictionary *locationInfo in locations )
    {
        NSMutableDictionary *location = [NSMutableDictionary dictionary];
        location[kNameKey] = locationInfo[kNameKey];
        
        if( nilOrJSONObjectForKey( locationInfo, kDistanceKey ) )
        {
            location[kDistanceKey] = locationInfo[kDistanceKey];
        }
        
        NSString *type = nilOrJSONObjectForKey( locationInfo, kTypeKey );
        
        if( [type isEqualToString:@"system"] )
        {
            location[kIDKey] = locationInfo[kIDKey];
        }
        else if( [type isEqualToString:@"google"] )
        {
            location[kGoogleIDKey] = locationInfo[kGoogleIDKey];
        }
        
        [newLocations addObject:location];
    }
    
    return [newLocations copy];
}

@end