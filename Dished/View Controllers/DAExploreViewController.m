//
//  DAExploreViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAHashtag.h"
#import "DAAPIManager.h"
#import "DARefreshControl.h"
#import "DALocationManager.h"
#import "DAExploreViewController.h"
#import "DAExploreLiveSearchResult.h"
#import "DAExploreDishTableViewCell.h"
#import "DAExploreCollectionViewCell.h"
#import "DACurrentLocationViewController.h"
#import "DAExploreDishResultsViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface DAExploreViewController() <DACurrentLocationViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSArray          *rowTitles;
@property (strong, nonatomic) NSArray          *imageURLs;
@property (strong, nonatomic) NSArray          *hashtags;
@property (strong, nonatomic) NSArray          *liveSearchResults;
@property (strong, nonatomic) NSString         *selectedLocationName;
@property (strong, nonatomic) NSMutableArray   *images;
@property (strong, nonatomic) DARefreshControl *refreshControl;
@property (strong, nonatomic) NSURLSessionTask *liveSearchTask;

@property (nonatomic) double                 selectedRadius;
@property (nonatomic) CLLocationCoordinate2D selectedLocation;

@end


@implementation DAExploreViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    self.collectionView.alwaysBounceVertical = YES;
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DAExploreSearchTableViewCell" bundle:nil];
    [self.searchDisplayController.searchResultsTableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    
    [self loadExploreContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadExploreContent) name:kNetworkReachableKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated) name:kLocationUpdateNotificationKey object:nil];
    
    self.selectedLocationName = @"Current Location";
    
    self.selectedRadius = 5;
    
    CGFloat refreshControlHeight = 40.0f;
    CGFloat refreshControlWidth  = self.collectionView.bounds.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.refreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.refreshControl addTarget:self action:@selector(loadExploreContent) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.hidden = YES;
}

- (void)loadExploreContent
{
    [[DAAPIManager sharedManager] getExploreTabContentWithCompletion:^( id response, NSError *error )
    {
        if( !error )
        {
            [self.refreshControl endRefreshing];
            
            self.imageURLs = [self imageURLsFromResponse:response];
            self.hashtags  = [self hashtagsFromResponse:response];
             
            [self.collectionView reloadData];
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)locationUpdated
{
    if( [self.selectedLocationName isEqualToString:@"Current Location"] )
    {
        self.selectedLocation = [[DALocationManager sharedManager] currentLocation];
    }
}

- (NSArray *)hashtagsFromResponse:(id)response
{
    NSArray *data = response[@"data"];
    NSMutableArray *hashtags = [NSMutableArray array];
    
    if( data && ![data isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in data )
        {
            DAHashtag *hashtag = [[DAHashtag alloc] init];
            hashtag.name = dataObject[@"name"];
            hashtag.hashtagID = dataObject[@"id"];
            [hashtags addObject:hashtag];
        }
    }
    
    return [hashtags copy];
}

- (NSArray *)imageURLsFromResponse:(id)response
{
    NSArray *data = response[@"data"];
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    if( data && ![data isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in data )
        {
            NSString *imageURL = dataObject[@"image_thumb"];
            [imageURLs addObject:imageURL];
        }
    }
    
    return [imageURLs copy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (IBAction)showCurrentLocationView
{
    [self performSegueWithIdentifier:@"currentLocation" sender:nil];
}

- (void)locationViewControllerDidSelectLocationName:(NSString *)locationName atLocation:(CLLocationCoordinate2D)location radius:(double)radius
{
    self.selectedLocation     = location;
    self.selectedLocationName = locationName;
    self.selectedRadius       = radius;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length > 0 )
    {
        if( self.liveSearchTask )
        {
            [self.liveSearchTask cancel];
        }
        
        if( [searchText characterAtIndex:0] == '#' && searchText.length > 1 )
        {
            NSString *query = [searchText substringFromIndex:1];
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreHashtagSuggestionsTaskWithQuery:query
            completion:^(id response, NSError *error)
            {
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.liveSearchResults = [self hashtagResultsFromResponse:response];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
            }];
        }
        else if( [searchText characterAtIndex:0] == '@' && searchText.length > 1 )
        {
            NSString *query = [searchText substringFromIndex:1];
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreUsernameSearchTaskWithQuery:query
            competion:^( id response, NSError *error )
            {
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.liveSearchResults = [self usernameResultsFromResponse:response];
                }
                
                [self.searchDisplayController.searchResultsTableView reloadData];
            }];
        }
        else
        {
            NSString *query = searchText;
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreDishAndLocationSuggestionsTaskWithQuery:query
            longitude:self.selectedLocation.longitude latitude:self.selectedLocation.latitude radius:15
            completion:^( id response, NSError *error )
            {
                if( response && ![response isEqual:[NSNull null]] )
                {
                    self.liveSearchResults = [self dishAndLocationResultsFromResponse:response];
                }
                
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

- (NSArray *)usernameResultsFromResponse:(id)response
{
    NSArray *usernames = response[@"data"];
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if( usernames && ![usernames isEqual:[NSNull null]] )
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
    
    return [searchResults copy];
}

- (NSArray *)hashtagResultsFromResponse:(id)response
{
    NSArray *hashtags = response[@"data"];
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if( hashtags && ![hashtags isEqual:[NSNull null]] )
    {
        for( NSDictionary *hashtag in hashtags )
        {
            DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
            
            searchResult.name = hashtag[@"name"];
            searchResult.resultID = hashtag[@"id"];
            searchResult.resultType = eHashtagSearchResult;
            
            [searchResults addObject:searchResult];
        }
    }
    
    return searchResults;
}

- (NSArray *)dishAndLocationResultsFromResponse:(id)response
{
    NSArray *dishes = response[@"data"][@"dishes"];
    NSArray *locations = response[@"data"][@"locations"];
    NSMutableArray *searchResults = [NSMutableArray array];
    
    if( dishes && ![dishes isEqual:[NSNull null]] )
    {
        for( NSDictionary *dish in dishes )
        {
            DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
            
            searchResult.name       = dish[@"name"];
            searchResult.dishType   = dish[@"type"];
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
    
    return searchResults;
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
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResultCell"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        
        switch( searchResult.resultType )
        {
            case eHashtagSearchResult:
            {
                cell.imageView.image = nil;
                cell.textLabel.text  = [NSString stringWithFormat:@"#%@", searchResult.name];
            }
            break;
            case eUsernameSearchResult:
            {
                cell.imageView.image = [UIImage imageNamed:@"user_search_result"];
                cell.textLabel.text  = [NSString stringWithFormat:@"@%@", searchResult.name];
            }
            break;
            case eLocationSearchResult:
            {
                cell.imageView.image = [UIImage imageNamed:@"dish_location"];
                cell.textLabel.text  = searchResult.name;
            }
            break;
            case eDishSearchResult:
            {
                cell.textLabel.text = searchResult.name;
                
                if( [searchResult.dishType isEqualToString:kFood] )
                {
                    cell.imageView.image = [UIImage imageNamed:@"food_dish_outline"];
                }
                else if( [searchResult.dishType isEqualToString:kCocktail] )
                {
                    cell.imageView.image = [UIImage imageNamed:@"cocktail_dish_outline"];
                }
                else if( [searchResult.dishType isEqualToString:kWine] )
                {
                    cell.imageView.image = [UIImage imageNamed:@"wine_dish_outline"];
                }
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
            case 0: [self performSegueWithIdentifier:@"dishResults" sender:@"dished_editors_picks"]; break;
            case 1: [self performSegueWithIdentifier:@"dishResults" sender:@"dished_popular"]; break;
        }
    }
    else
    {
        DAExploreLiveSearchResult *searchResult = [self.liveSearchResults objectAtIndex:indexPath.row];
        
        switch( searchResult.resultType )
        {
            case eHashtagSearchResult:
            {
                [self performSegueWithIdentifier:@"dishResults" sender:searchResult.name];
            }
            break;
            case eDishSearchResult:
            {
                [self performSegueWithIdentifier:@"dishResults" sender:searchResult.name];
            }
            break;
            case eLocationSearchResult:
            {
                
            }
            break;
            case eUsernameSearchResult:
            {
                
            }
            break;
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

    if( [[self.images objectAtIndex:indexPath.row] isEqual:[NSNull null]] )
    {
        NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.row]];
        
        [cell.imageView sd_setImageWithURL:url
        completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL )
        {
            self.images[indexPath.row] = image;
            
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
    }
    else
    {
        [cell.imageView setImage:self.images[indexPath.row]];
        
        DAHashtag *hashtag = [self.hashtags objectAtIndex:indexPath.row];
        cell.hashtagLabel.text = [NSString stringWithFormat:@"#%@", hashtag.name];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAHashtag *selectedHashtag = self.hashtags[indexPath.row];
    
    [self performSegueWithIdentifier:@"dishResults" sender:selectedHashtag.name];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollPosition = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.refreshControl.hidden = scrollPosition > 0 ? YES : NO;
    
    [self.refreshControl containingScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshControl containingScrollViewDidEndDragging:scrollView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"dishResults"] )
    {
        DAExploreDishResultsViewController *dest = segue.destinationViewController;
        dest.searchTerm       = (NSString *)sender;
        dest.selectedRadius   = self.selectedRadius;
        dest.selectedLocation = self.selectedLocation;
    }
    
    if( [segue.identifier isEqualToString:@"currentLocation"] )
    {
        UINavigationController *nav = segue.destinationViewController;
        DACurrentLocationViewController *dest = nav.viewControllers[0];
        dest.delegate             = self;
        dest.selectedLocationName = self.selectedLocationName;
        dest.selectedRadius       = self.selectedRadius;
        dest.selectedLocation     = self.selectedLocation;
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

- (NSMutableArray *)images
{
    if( !_images )
    {
        NSMutableArray *nullArray = [NSMutableArray array];
        
        for( int i = 0; i < 12; i++ )
        {
            [nullArray addObject:[NSNull null]];
        }
        
        _images = nullArray;
    }
    
    return _images;
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