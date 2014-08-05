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
#import "UIImageView+WebCache.h"
#import "DALocationManager.h"
#import "DAExploreLiveSearchResult.h"
#import "DAExploreDishTableViewCell.h"
#import "DAExploreDefinedSearchViewController.h"


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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchDisplayController setDisplaysSearchBarInNavigationBar:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if( searchText.length > 0 )
    {
        if( self.liveSearchTask )
        {
            [self.liveSearchTask cancel];
        }
        
        if( [searchText characterAtIndex:0] == '#' )
        {
            CLLocationCoordinate2D currentLocation = [[DALocationManager sharedManager] currentLocation];
            NSString *query = [searchText substringFromIndex:1];
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreDishesWithHashtagSearchTaskWithQuery:query
            longitude:currentLocation.longitude latitude:currentLocation.latitude
            completion:^( id responseData, NSError *error )
            {
                if( responseData )
                {
                    
                }
            }];
        }
        
        if( [searchText characterAtIndex:0] == '@' && searchText.length > 1 )
        {
            NSString *query = [searchText substringFromIndex:1];
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreUsernameSearchTaskWithQuery:query
            competion:^( id responseData, NSError *error )
            {
                if( responseData )
                {
                    NSArray *searchResults = (NSArray *)responseData;
                    NSMutableArray *usernames = [NSMutableArray array];
                    
                    for( NSDictionary *username in searchResults )
                    {
                        DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
                        
                        searchResult.name = username[@"username"];
                        searchResult.resultID = username[@"id"];
                        searchResult.resultType = eUsernameSearchResult;
                        
                        [usernames addObject:searchResult];
                    }
                    
                    self.liveSearchResults = [usernames copy];
                    [self.searchDisplayController.searchResultsTableView reloadData];
                }
            }];
        }
    }
    else
    {
        [self.liveSearchTask cancel];
        self.liveSearchResults = [NSArray array];
    }
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
    
    DAExploreLiveSearchResult *searchResult = [self.liveSearchResults objectAtIndex:indexPath.row];
    
    if( tableView == self.searchDisplayController.searchResultsTableView )
    {
        if( self.searchDisplayController.active )
        {
            switch( searchResult.resultType )
            {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"searchResultCell"];
                    cell.textLabel.text = [NSString stringWithFormat:@"@%@", searchResult.name];
                    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
                    
                case eUsernameSearchResult:
                {
                    cell.imageView.image = [UIImage imageNamed:@"explore_search_user"];
                }
                    break;
                case eHashtagSearchResult:
                {
                    cell.imageView.image = nil;
                }
                    break;
                case eLocationSearchResult:
                {
                    cell.imageView.image = [UIImage imageNamed:@"explore_search_place"];
                }
                    break;
                case eDishSearchResult:
                {
                    cell.imageView.image = [UIImage imageNamed:@"explore_search_food"];
                }
                    break;
            }
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
        if( indexPath.row == 0 )
        {
            [self performSegueWithIdentifier:@"definedSearch" sender:nil];
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.hashtags count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAExploreCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSURL *url = [NSURL URLWithString:self.imageURLs[indexPath.row]];
    [cell.imageView sd_setImageWithURL:url];
    
    DAHashtag *hashtag = [self.hashtags objectAtIndex:indexPath.row];
    cell.hashtagLabel.text = [NSString stringWithFormat:@"#%@", hashtag.name];
    
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self performSegueWithIdentifier:@"definedSearch" sender:nil];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"definedSearch"] )
    {
        DAExploreDefinedSearchViewController *dest = segue.destinationViewController;
        dest.searchTerm = @"editorsPicks";
    }
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