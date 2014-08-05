//
//  DAExploreDefinedSearchViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreDefinedSearchViewController.h"
#import "DAAPIManager.h"
#import "DAExploreDishTableViewCell.h"
#import "DALocationManager.h"
#import "DAExploreDishSearchResult.h"


@interface DAExploreDefinedSearchViewController()

@property (strong, nonatomic) NSArray                 *searchResults;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAExploreDefinedSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResults = [NSArray array];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAExploreDishTableViewCell" bundle:nil];
    [self.tableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    if( self.searchTerm )
    {
        if( [self.searchTerm isEqualToString:@"editorsPicks"] )
        {
            self.title = @"Editor's Picks";
            
            CLLocationCoordinate2D currentLocation = [[DALocationManager sharedManager] currentLocation];
            
            [[DAAPIManager sharedManager] getEditorsPicksDishesWithLongitude:currentLocation.longitude
            latitude:currentLocation.latitude completion:^( id responseData, NSError *error )
            {
                if( responseData )
                {
                    NSMutableArray *results = [NSMutableArray array];
                    
                    for( NSDictionary *dish in responseData )
                    {
                        DAExploreDishSearchResult *result = [[DAExploreDishSearchResult alloc] init];
                        
                        result.dishID            = dish[@"id"];
                        result.name              = dish[@"name"];
                        result.price             = dish[@"price"];
                        result.type              = dish[@"type"];
                        result.totalReviews      = [dish[@"num_reviews"] intValue];
                        result.friendReviews     = [dish[@"num_reviews_friends"] intValue];
                        result.influencerReviews = [dish[@"num_reviews_influencers"] intValue];
                        result.locationID        = dish[@"location"][@"id"];
                        result.locationName      = dish[@"location"][@"name"];
                        
                        if( ![dish[@"avg_grade"] isEqual:[NSNull null]] )
                        {
                            result.grade = dish[@"avg_grade"];
                        }
                        else
                        {
                            result.grade = @"";
                        }
                        
                        [results addObject:result];
                    }
                    
                    self.searchResults = [results copy];
                    [self.tableView reloadData];
                }
            }];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if( [self.searchResults count] == 0 )
//    {
//        return 1;
//    }
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAExploreDishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishSearchCellID];
    
    DAExploreDishSearchResult *result = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.dishName.text     = result.name;
    cell.grade.text        = result.grade;
    cell.locationName.text = result.locationName;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 97;
}

@end