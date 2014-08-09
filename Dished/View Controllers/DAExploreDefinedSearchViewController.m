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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface DAExploreDefinedSearchViewController()

@property (strong, nonatomic) NSArray                 *searchResults;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL isLoading;

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
        self.isLoading = YES;
        
        CLLocationCoordinate2D currentLocation = [[DALocationManager sharedManager] currentLocation];
        
        if( [self.searchTerm isEqualToString:@"dished_editors_picks"] )
        {
            self.title = @"Editor's Picks";
            
            [[DAAPIManager sharedManager] getEditorsPicksDishesWithLongitude:currentLocation.longitude
            latitude:currentLocation.latitude completion:^( NSArray *dishes, NSError *error )
            {
                self.isLoading = NO;
                
                if( dishes && ![dishes isEqual:[NSNull null]] )
                {
                    [self setDishes:dishes];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        else if( [self.searchTerm isEqualToString:@"dished_popular"] )
        {
            self.title = @"Popular Now";
            
            [[DAAPIManager sharedManager] getPopularDishesWithLongitude:currentLocation.longitude
            latitude:currentLocation.latitude completion:^( NSArray *dishes, NSError *error )
            {
                self.isLoading = NO;
                
                if( dishes && ![dishes isEqual:[NSNull null]] )
                {
                    [self setDishes:dishes];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        else
        {
            self.title = [NSString stringWithFormat:@"#%@", self.searchTerm];
            
            [[DAAPIManager sharedManager] exploreDishesWithHashtagSearchTaskWithQuery:self.searchTerm
            longitude:currentLocation.longitude latitude:currentLocation.latitude
            completion:^( NSArray *dishes, NSError *error )
            {
                self.isLoading = NO;
                
                if( dishes && ![dishes isEqual:[NSNull null]] )
                {
                    [self setDishes:dishes];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
    }
}

- (void)setDishes:(NSArray *)dishes
{
    NSMutableArray *results = [NSMutableArray array];
    
    for( NSDictionary *dish in dishes )
    {
        DAExploreDishSearchResult *result = [[DAExploreDishSearchResult alloc] init];
        
        result.dishID            = dish[@"id"];
        result.name              = dish[@"name"];
        result.price             = ![dish[@"price"] isEqual:[NSNull null]] ? dish[@"price"] : @"";
        result.type              = dish[@"type"];
        result.totalReviews      = [dish[@"num_reviews"] intValue];
        result.friendReviews     = [dish[@"num_reviews_friends"] intValue];
        result.influencerReviews = [dish[@"num_reviews_influencers"] intValue];
        result.locationID        = dish[@"location"][@"id"];
        result.locationName      = dish[@"location"][@"name"];
        result.grade             = ![dish[@"avg_grade"] isEqual:[NSNull null]] ? dish[@"avg_grade"] : @"No Ratings";
        result.imageURL          = ![dish[@"img"] isEqual:[NSNull null]] ? dish[@"img"] : nil;
        
        [results addObject:result];
    }
    
    self.searchResults = [results copy];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( self.isLoading || [self.searchResults count] == 0 )
    {
        return 1;
    }
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.isLoading || [self.searchResults count] == 0 )
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        
        if( self.isLoading )
        {
            cell.textLabel.text = @"Loading...";
            
            cell.accessoryView = self.spinner;
            [self.spinner startAnimating];
        }
        else
        {
            cell.textLabel.text = @"No Dishes Found";
            
            [self.spinner removeFromSuperview];
        }
        
        return cell;
    }
    
    DAExploreDishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishSearchCellID];
    
    DAExploreDishSearchResult *result = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.dishName.text = result.name;
    [cell.dishName sizeToFit];
    
    cell.grade.text        = result.grade;
    cell.locationName.text = result.locationName;
    
    if( result.imageURL )
    {
        NSURL *url = [NSURL URLWithString:result.imageURL];
        
        [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( [self.searchResults count] == 0 )
    {
        return tableView.rowHeight;
    }
    
    return 97;
}

- (UIActivityIndicatorView *)spinner
{
    if( !_spinner )
    {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _spinner;
}

@end