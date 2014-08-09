//
//  DAExploreViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreViewController.h"
#import "DAExploreCollectionViewCell.h"
#import "DAAPIManager.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DALocationManager.h"
#import "DAExploreLiveSearchResult.h"
#import "DAExploreDishTableViewCell.h"
#import "DAExploreDishResultsViewController.h"


@interface DAExploreViewController()

@property (strong, nonatomic) NSArray          *rowTitles;
@property (strong, nonatomic) NSArray          *imageURLs;
@property (strong, nonatomic) NSArray          *hashtags;
@property (strong, nonatomic) NSArray          *liveSearchResults;
@property (strong, nonatomic) NSURLSessionTask *liveSearchTask;

@end


@implementation DAExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAExploreSearchTableViewCell" bundle:nil];
    [self.searchDisplayController.searchResultsTableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    [[DAAPIManager sharedManager] getExploreTabContentWithCompletion:
    ^( NSArray *hashtags, NSArray *imageURLs, NSError *error )
    {
        if( !error )
        {
            self.imageURLs = imageURLs;
            self.hashtags = hashtags;
             
            [self.collectionView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length > 0 )
    {
        if( self.liveSearchTask )
        {
            [self.liveSearchTask cancel];
        }
        
        CLLocationCoordinate2D currentLocation = [[DALocationManager sharedManager] currentLocation];
        
        if( [searchText characterAtIndex:0] == '#' )
        {
            NSString *query = [searchText substringFromIndex:1];
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreDishesWithHashtagSearchTaskWithQuery:query
            longitude:currentLocation.longitude latitude:currentLocation.latitude
            completion:^( NSArray *dishes, NSError *error )
            {
                if( dishes )
                {
                    NSMutableArray *dishResults = [NSMutableArray array];
                    
                    if( [dishes isEqual:[NSNull null]] )
                    {
                        for( NSDictionary *dish in dishes )
                        {
                            DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
                            
                            searchResult.name     = dish[@"name"];
                            searchResult.resultID = dish[@"id"];
                            searchResult.rating   = ![dish[@"avg_grade"] isEqual:[NSNull null]] ? dish[@"avg_grade"] : @"";
                            searchResult.resultType = eDishSearchResult;
                            
                            [dishResults addObject:searchResult];
                        }
                    }
                    
                    self.liveSearchResults = [dishResults copy];
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }
            }];
        }
        else if( [searchText characterAtIndex:0] == '@' && searchText.length > 1 )
        {
            NSString *query = [searchText substringFromIndex:1];
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreUsernameSearchTaskWithQuery:query
            competion:^( NSArray *usernames, NSError *error )
            {
                if( usernames )
                {
                    NSMutableArray *searchResults = [NSMutableArray array];
                    
                    if( [usernames isEqual:[NSNull null]] )
                    {
                        for( NSDictionary *username in usernames )
                        {
                            DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
                            
                            searchResult.name = username[@"username"];
                            searchResult.resultID = username[@"id"];
                            searchResult.resultType = eUsernameSearchResult;
                            
                            [searchResults addObject:searchResult];
                        }
                    }
                    
                    self.liveSearchResults = [searchResults copy];
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }
            }];
        }
        else
        {
            NSString *query = searchText;
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreDishAndLocationSearchTaskWithQuery:query
            longitude:currentLocation.longitude latitude:currentLocation.latitude radius:15
            completion:^( NSArray *dishes, NSArray *locations, NSError *error )
            {
                NSMutableArray *searchResults = [NSMutableArray array];
                
                if( ![dishes isEqual:[NSNull null]] )
                {
                    for( NSDictionary *dish in dishes )
                    {
                        DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
                        
                        searchResult.name       = dish[@"name"];
                        searchResult.resultID   = dish[@"id"];
                        searchResult.rating     = ![dish[@"avg_grade"] isEqual:[NSNull null]] ? dish[@"avg_grade"] : @"";
                        searchResult.resultType = eDishSearchResult;
                        
                        [searchResults addObject:searchResult];
                    }
                }
                
                if( ![locations isEqual:[NSNull null]] )
                {
                    for( NSDictionary *location in locations )
                    {
                        DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
                        
                        searchResult.name       = location[@"name"];
                        searchResult.resultID   = location[@"id"];
                        searchResult.resultType = eLocationSearchResult;
                        
                        [searchResults addObject:searchResult];
                    }
                }
                
                self.liveSearchResults = [searchResults copy];
                [self.searchDisplayController.searchResultsTableView reloadData];
            }];
        }
    }
    else
    {
        [self.liveSearchTask cancel];
        self.liveSearchResults = [NSArray array];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.liveSearchResults = [NSArray array];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        return [self.liveSearchResults count];
    }
    
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        DAExploreLiveSearchResult *searchResult = [self.liveSearchResults objectAtIndex:indexPath.row];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"searchResultCell"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        
        switch( searchResult.resultType )
        {
            case eHashtagSearchResult:
            {
                cell.imageView.image = nil;
                cell.textLabel.text  = searchResult.name;
            }
            break;
            case eUsernameSearchResult:
            {
                cell.imageView.image = [UIImage imageNamed:@"explore_search_user"];
                cell.textLabel.text  = [NSString stringWithFormat:@"@%@", searchResult.name];
            }
            break;
            case eLocationSearchResult:
            {
                cell.imageView.image = [UIImage imageNamed:@"explore_search_place"];
                cell.textLabel.text  = searchResult.name;
            }
            break;
            case eDishSearchResult:
            {
                cell.imageView.image      = [UIImage imageNamed:@"explore_search_food"];
                cell.textLabel.text       = searchResult.name;
                cell.detailTextLabel.text = searchResult.rating;
            }
            break;
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = self.rowTitles[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tableView )
    {
        switch( indexPath.row )
        {
            case 0: [self performSegueWithIdentifier:@"definedSearch" sender:@"dished_editors_picks"]; break;
            case 1: [self performSegueWithIdentifier:@"definedSearch" sender:@"dished_popular"]; break;
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.imageURLs count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAExploreCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if( [self.imageURLs[indexPath.row] isEqual:[NSNull null]] )
    {
        cell.hashtagLabel.text = @"";
        
        [cell.activityIndicatorView startAnimating];
        
        return cell;
    }
    
    NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.row]];
    
    [cell.imageView sd_setImageWithURL:url
    completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL )
    {
        [cell.activityIndicatorView stopAnimating];
        cell.activityIndicatorView.hidden = YES;
        
        DAHashtag *hashtag = [self.hashtags objectAtIndex:indexPath.row];
        cell.hashtagLabel.text = [NSString stringWithFormat:@"#%@", hashtag.name];
        
        [UIView transitionWithView:cell.imageView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve
        animations:^
        {
            [cell.imageView setImage:image];
        }
        completion:nil];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAHashtag *selectedHashtag = self.hashtags[indexPath.row];
    
    [self performSegueWithIdentifier:@"definedSearch" sender:selectedHashtag.name];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"definedSearch"] )
    {
        DAExploreDishResultsViewController *dest = segue.destinationViewController;
        dest.searchTerm = (NSString *)sender;
    }
}

- (NSArray *)imageURLs
{
    if( !_imageURLs )
    {
        NSMutableArray *nullArray = [NSMutableArray array];
        
        for( int i = 0; i < 12; i++ )
        {
            [nullArray addObject:[NSNull null]];
        }
        
        _imageURLs = [nullArray copy];
    }
    
    return _imageURLs;
}

- (NSArray *)rowTitles
{
    if( !_rowTitles )
    {
        _rowTitles = @[ @"Editor's Picks", @"Popular Now" ];
    }
    
    return _rowTitles;
}

@end