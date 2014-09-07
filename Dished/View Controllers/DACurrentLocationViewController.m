//
//  DACurrentLocationViewController.m
//  Dished
//
//  Created by POST on 7/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DACurrentLocationViewController.h"
#import "DALocationManager.h"
#import "SPGooglePlacesAutocomplete.h"
#import "DAExploreViewController.h"

static NSString *kGooglePlacesAPIKey = @"AIzaSyDXXanFsOZUE3ULgpKiNngL-e6B_6TdBfE";


@interface DACurrentLocationViewController()

@property (strong, nonatomic) NSArray                         *searchResults;
@property (strong, nonatomic) NSArray                         *radiusArray;
@property (strong, nonatomic) SPGooglePlacesAutocompleteQuery *placesQuery;

@property (nonatomic) BOOL shouldUpdateResults;
@property (nonatomic) BOOL radiusSelectionVisible;

@end


@implementation DACurrentLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResults          = [NSArray array];
    self.radiusSelectionVisible = NO;
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    
    if( !self.selectedLocationName )
    {
        self.selectedLocationName = @"Current Location";
    }
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
}

- (IBAction)cancelChangeLocation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneChoosingLocation:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length > 0 )
    {
        self.shouldUpdateResults = YES;
        self.placesQuery.input   = searchText;
        
        [self.placesQuery fetchPlaces:^( NSArray *places, NSError *error )
        {
            if( !error && self.shouldUpdateResults )
            {
                self.searchResults = places;
                [self.tableView reloadData];
            }
        }];
    }
    else
    {
        self.shouldUpdateResults = NO;
        self.searchResults = [NSArray array];
        [self.tableView reloadData];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 1 )
    {
        if( self.radiusSelectionVisible )
        {
            return [self.radiusArray count] + 1;
        }
        
        return 1;
    }
    else
    {
        if( [self.selectedLocationName isEqualToString:@"Current Location"] )
        {
            return [self.searchResults count] + 1;
        }
        else
        {
            return [self.searchResults count] + 2;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == [self.searchResults count] )
        {
            cell.textLabel.text       = self.selectedLocationName;
            cell.accessoryType        = UITableViewCellAccessoryCheckmark;
            cell.detailTextLabel.text = @"";
            
            if( [self.selectedLocationName isEqualToString:@"Current Location"] )
            {
                cell.imageView.image = [UIImage imageNamed:@"explore_current_location"];
            }
            else
            {
                cell.imageView.image = nil;
            }
        }
        else if( indexPath.row == [self.searchResults count] + 1 )
        {
            cell.accessoryType        = UITableViewCellAccessoryNone;
            cell.imageView.image      = [UIImage imageNamed:@"explore_current_location"];
            cell.textLabel.text       = @"Current Location";
            cell.detailTextLabel.text = @"";
        }
        else
        {
            SPGooglePlacesAutocompletePlace *place = [self.searchResults objectAtIndex:indexPath.row];
            cell.textLabel.text       = place.name;
            cell.imageView.image      = nil;
            cell.detailTextLabel.text = @"";
            cell.accessoryType        = UITableViewCellAccessoryNone;
        }
    }
    else
    {
        cell.imageView.image = nil;

        if( indexPath.row == 0 )
        {
            cell.textLabel.text = @"Search Radius";
            cell.accessoryType  = UITableViewCellAccessoryNone;
            
            if( self.selectedRadius == 0 )
            {
                cell.detailTextLabel.text = @"No Radius";
            }
            else
            {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f mi", self.selectedRadius];
            }
        }
        else
        {
            double radius = [[self.radiusArray objectAtIndex:indexPath.row - 1] doubleValue];
            
            cell.detailTextLabel.text = @"";
            
            if( radius == self.selectedRadius )
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            if( indexPath.row == [self.radiusArray count] )
            {
                cell.textLabel.text = [self.radiusArray objectAtIndex:indexPath.row - 1];
            }
            else
            {
                cell.textLabel.text = [NSString stringWithFormat:@"%.1f mi", radius];
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    
    if( indexPath.section == 0 )
    {
        self.shouldUpdateResults = NO;
        
        if( indexPath.row == [self.searchResults count] )
        {
            if( [self.selectedLocationName isEqualToString:@"Current Location"] )
            {
                self.selectedLocationName = @"Current Location";
                self.selectedLocation     = [[DALocationManager sharedManager] currentLocation];
            }
            
            if( [self.delegate respondsToSelector:@selector(locationViewControllerDidSelectLocationName:atLocation:radius:)] )
            {
                [self.delegate locationViewControllerDidSelectLocationName:self.selectedLocationName atLocation:self.selectedLocation radius:self.selectedRadius];
            }
            
            self.searchResults = [NSArray array];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if( indexPath.row == [self.searchResults count] + 1 )
        {
            self.selectedLocationName = @"Current Location";
            self.selectedLocation     = [[DALocationManager sharedManager] currentLocation];
            
            if( [self.delegate respondsToSelector:@selector(locationViewControllerDidSelectLocationName:atLocation:radius:)] )
            {
                [self.delegate locationViewControllerDidSelectLocationName:@"Current Location" atLocation:self.selectedLocation radius:self.selectedRadius];
            }
            
            self.searchResults = [NSArray array];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            SPGooglePlacesAutocompletePlace *place = [self.searchResults objectAtIndex:indexPath.row];
            self.selectedLocationName = place.name;
            
            if( [self.delegate respondsToSelector:@selector(locationViewControllerDidSelectLocationName:atLocation:radius:)] )
            {
                id delegate = self.delegate;
                
                [place resolveToPlacemark:^( CLPlacemark *placemark, NSString *addressString, NSError *error )
                {
                    self.selectedLocation = placemark.location.coordinate;
                    
                    if( [self.delegate respondsToSelector:@selector(locationViewControllerDidSelectLocationName:atLocation:radius:)] )
                    {
                        [delegate locationViewControllerDidSelectLocationName:place.name atLocation:self.selectedLocation radius:self.selectedRadius];
                    }
                }];
            }
            
            self.searchResults = [NSArray array];
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else
    {
        if( indexPath.row == 0 )
        {
            self.radiusSelectionVisible = !self.radiusSelectionVisible;
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else
        {
            self.selectedRadius = [[self.radiusArray objectAtIndex:indexPath.row - 1] doubleValue];
            
            if( [self.delegate respondsToSelector:@selector(locationViewControllerDidSelectLocationName:atLocation:radius:)] )
            {
                [self.delegate locationViewControllerDidSelectLocationName:self.selectedLocationName atLocation:self.selectedLocation radius:self.selectedRadius];
            }
            
            [tableView reloadData];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (SPGooglePlacesAutocompleteQuery *)placesQuery
{
    if( !_placesQuery )
    {
        _placesQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:kGooglePlacesAPIKey];
        _placesQuery.location = [[DALocationManager sharedManager] currentLocation];
        _placesQuery.radius = 100.0;
        _placesQuery.types = SPPlaceTypeGeocode;
    }
    
    return _placesQuery;
}

- (NSArray *)radiusArray
{
    if( !_radiusArray )
    {
        _radiusArray = @[ @(1), @(2), @(5), @(10), @(15), @(25), @(50), @"No Radius" ];
    }
    
    return _radiusArray;
}

@end