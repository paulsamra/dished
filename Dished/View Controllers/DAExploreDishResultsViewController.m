//
//  DAExploreDefinedSearchViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreDishResultsViewController.h"
#import "DAAPIManager.h"
#import "DADishTableViewCell.h"
#import "DALocationManager.h"
#import "DADish.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAGlobalDishDetailViewController.h"


@interface DAExploreDishResultsViewController()

@property (strong, nonatomic) NSArray                 *searchResults;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL isLoading;

@end


@implementation DAExploreDishResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchResults = [NSArray array];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DADishTableViewCell" bundle:nil];
    [self.tableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    if( self.searchTerm )
    {
        self.isLoading = YES;
        
        if( [self.searchTerm isEqualToString:@"dished_editors_picks"] )
        {
            self.title = @"Editor's Picks";
            
            [[DAAPIManager sharedManager] getEditorsPicksDishesWithLongitude:self.selectedLocation.longitude
            latitude:self.selectedLocation.latitude radius:self.selectedRadius completion:^( id response, NSError *error )
            {
                self.isLoading = NO;
                
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.searchResults = [self dishesFromResponse:response];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        else if( [self.searchTerm isEqualToString:@"dished_popular"] )
        {
            self.title = @"Popular Now";
            
            [[DAAPIManager sharedManager] getPopularDishesWithLongitude:self.selectedLocation.longitude
            latitude:self.selectedLocation.latitude radius:self.selectedRadius completion:^( id response, NSError *error )
            {
                self.isLoading = NO;
                
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.searchResults = [self dishesFromResponse:response];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        else if( [self.searchTerm characterAtIndex:0] == '#' )
        {
            self.searchTerm = [self.searchTerm substringFromIndex:1];
            self.title = [NSString stringWithFormat:@"#%@", self.searchTerm];
            
            [[DAAPIManager sharedManager] exploreDishesWithHashtagSearchTaskWithQuery:self.searchTerm
            longitude:self.selectedLocation.longitude latitude:self.selectedLocation.latitude radius:self.selectedRadius
            completion:^( id response, NSError *error )
            {
                self.isLoading = NO;
                
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.searchResults = [self dishesFromResponse:response];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
        else
        {
            self.title = self.searchTerm;
            
            [[DAAPIManager sharedManager] exploreDishesWithQuery:self.searchTerm longitude:self.selectedLocation.longitude
            latitude:self.selectedLocation.latitude radius:self.selectedRadius completion:^( id response, NSError *error )
            {
                self.isLoading = NO;
                
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.searchResults = [self dishesFromResponse:response];
                }
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (NSArray *)dishesFromResponse:(id)response
{
    NSArray *dishes = response[@"data"][@"dishes"];
    NSMutableArray *results = [NSMutableArray array];
    
    if( dishes && ![dishes isEqual:[NSNull null]] )
    {
        for( NSDictionary *dish in dishes )
        {
            DADish *result = [DADish dishWithData:dish];
            
            [results addObject:result];
        }
    }
    
    return [results copy];
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
            cell.userInteractionEnabled = NO;
            [self.spinner startAnimating];
        }
        else
        {
            cell.textLabel.text = @"No Dishes Found";
            
            cell.userInteractionEnabled = NO;
            [self.spinner removeFromSuperview];
        }
        
        return cell;
    }
    
    DADishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishSearchCellID];
    
    DADish *result = [self.searchResults objectAtIndex:indexPath.row];
    
    cell.dishNameLabel.text          = result.name;
    cell.gradeLabel.text             = result.avg_grade;
    cell.leftNumberLabel.text        = [NSString stringWithFormat:@"%d", (int)result.totalReviews];
    cell.middleNumberLabel.text      = [NSString stringWithFormat:@"%d", (int)result.friendReviews];
    cell.rightNumberLabel.text       = [NSString stringWithFormat:@"%d", (int)result.influencerReviews];
    [cell.locationButton setTitle:result.locationName forState:UIControlStateNormal];
    cell.isExplore = YES;
    
    if( result.imageURL )
    {
        NSURL *url = [NSURL URLWithString:result.imageURL];
        [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DADish *result = [self.searchResults objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"dishDetails" sender:result];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"dishDetails"] )
    {
        DADish *result = sender;
        DAGlobalDishDetailViewController *dest = segue.destinationViewController;
        dest.dishID = result.dishID;
    }
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