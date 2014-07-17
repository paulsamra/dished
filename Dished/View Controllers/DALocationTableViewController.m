//
//  DALocationTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALocationTableViewController.h"
#import "DAFormTableViewController.h"
#import "DAAddPlaceViewController.h"
#import "DAAPIManager.h"
#import "DALocationManager.h"

static NSString *kLocationNameKey     = @"name";
static NSString *kLocationIDKey       = @"id";
static NSString *kLocationDistanceKey = @"distance";


@interface DALocationTableViewController() <UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray    *locationData;
@property (strong, nonatomic) NSURLSessionTask  *searchTask;

@end


@implementation DALocationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1];
    
    self.locationData = [NSMutableArray array];
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
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSArray *navigationStack = self.navigationController.viewControllers;
        DAFormTableViewController *parentController = [navigationStack objectAtIndex:([navigationStack count] -2)];
        [parentController setDetailItem:selectedCell.textLabel.text];
        
        [self.navigationController popViewControllerAnimated:YES];

    }
    else if( indexPath.row == [self.locationData count] )
    {
        [self performSegueWithIdentifier:@"add" sender:nil];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length == 0 )
    {
        self.locationData = [NSMutableArray array];
        [self.tableView reloadData];
        return;
    }
    
    double longitude = [[DALocationManager sharedManager] currentLocation].longitude;
    double latitude  = [[DALocationManager sharedManager] currentLocation].latitude;
    
    if( self.searchTask )
    {
        [self.searchTask cancel];
    }
    
    self.searchTask = [[DAAPIManager sharedManager] locationSearchTaskWithQuery:searchText
    longitude:longitude latitude:latitude completion:^( id responseObject, NSError *error )
    {
        NSArray *searchResults = (NSArray *)responseObject;
        
        if( !searchResults )
        {
            self.locationData = [NSMutableArray array];
        }
        else
        {
            for( NSDictionary *locationInfo in searchResults )
            {
                NSMutableDictionary *location = [NSMutableDictionary dictionary];
                location[kLocationNameKey]    = locationInfo[kLocationNameKey];
                location[kLocationIDKey]      = locationInfo[kLocationIDKey];
                
                if( locationInfo[kLocationDistanceKey] )
                {
                    location[kLocationDistanceKey] = locationInfo[kLocationDistanceKey];
                }
                
                [self.locationData addObject:location];
            }
        }
        
        [self.tableView reloadData];
    }];
}

- (void)setDetailItem:(id)newData
{
    if( _data != newData )
    {
        _data = newData;
    }
}

@end
