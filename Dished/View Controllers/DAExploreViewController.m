//
//  DAExploreViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAHashtag.h"
#import "DARefreshControl.h"
#import "DALocationManager.h"
#import "DAExploreViewController.h"
#import "DAExploreLiveSearchResult.h"
#import "DADishTableViewCell.h"
#import "DAExploreCollectionViewCell.h"
#import "DAUserProfileViewController.h"
#import "DACurrentLocationViewController.h"
#import "DAExploreDishResultsViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

static NSString *const kSearchResultCellIdentifier = @"exploreSearchCell";


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
    
    self.tableView.contentInset = UIEdgeInsetsMake( -35, 0, 0, 0 );
    self.collectionView.alwaysBounceVertical = YES;
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    
    [self loadExploreContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationUpdated) name:kLocationUpdateNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServicesDenied) name:kLocationServicesDeniedKey object:nil];
    
    [self loadLocationSettings];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
}

- (void)loadLocationSettings
{
    NSDictionary *locationSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"locationSettings"];
    
    if( locationSettings )
    {
        NSString *locationName = locationSettings[@"locationName"];
        self.selectedLocationName = locationName ? locationName : @"Current Location";
        self.selectedRadius = [locationSettings[@"radius"] doubleValue];
        
        double longitude = [locationSettings[@"longitude"] doubleValue];
        double latitude  = [locationSettings[@"latitude"]  doubleValue];
        self.selectedLocation = CLLocationCoordinate2DMake( latitude, longitude );
    }
    else
    {
        self.selectedLocationName = @"Current Location";
        self.selectedRadius = 0;
        
        NSDictionary *locationSettings = @{ @"locationName" : self.selectedLocationName, @"radius" : @(self.selectedRadius) };
        [[NSUserDefaults standardUserDefaults] setObject:locationSettings forKey:@"locationSettings"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSegueWithIdentifier:@"currentLocation" sender:@(YES)];
    }
}

- (void)loadExploreContent
{
    [[DAAPIManager sharedManager] GETRequest:kHashtagsExploreURL withParameters:nil
    success:^( id response )
    {
        [self.refreshControl endRefreshing];
        
        self.imageURLs = [self imageURLsFromResponse:response];
        self.hashtags  = [self hashtagsFromResponse:response];
        
        [self.collectionView reloadData];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self loadExploreContent];
        }
    }];
}

- (void)locationServicesDenied
{
    [[[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Dished needs your current location to search for places near you. Please enable location services for Dished in your iPhone settings or set your current location manually." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
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
    NSArray *data = nilOrJSONObjectForKey( response, kDataKey );
    NSMutableArray *hashtags = [NSMutableArray array];
    
    if( data )
    {
        for( NSDictionary *dataObject in data )
        {
            DAHashtag *hashtag = [DAHashtag hashtagWithData:dataObject];
            [hashtags addObject:hashtag];
        }
    }
    
    return [hashtags copy];
}

- (NSArray *)imageURLsFromResponse:(id)response
{
    NSArray *data = nilOrJSONObjectForKey( response, kDataKey );
    NSMutableArray *imageURLs = [NSMutableArray array];
    
    if( data )
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadExploreContent) name:kNetworkReachableKey object:nil];
    
    [self setupRefreshControl];
}

- (void)setupRefreshControl
{
    CGFloat refreshControlHeight = 40.0f;
    CGFloat refreshControlWidth  = self.view.frame.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.refreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.refreshControl addTarget:self action:@selector(loadExploreContent) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.hidden = YES;
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
    
    NSDictionary *locationSettings = @{ kLongitudeKey : @(location.longitude), kLatitudeKey : @(location.latitude),
                                        @"locationName" : locationName, @"radius" : @(radius) };
    [[NSUserDefaults standardUserDefaults] setObject:locationSettings forKey:@"locationSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if( searchBar.text.length > 0 )
    {
        if( [searchBar.text characterAtIndex:0] != '@' )
        {
            [self performSegueWithIdentifier:@"dishResults" sender:searchBar.text];
        }
        else
        {
            [searchBar resignFirstResponder];
        }
    }
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
            
            [self searchWithURL:kHashtagsURL query:query queryKey:kNameKey resultType:eHashtagSearchResult];
        }
        else if( [searchText characterAtIndex:0] == '@' && searchText.length > 1 )
        {
            NSString *query = [searchText substringFromIndex:1];
            
            [self searchWithURL:kExploreUsernamesURL query:query queryKey:kUsernameKey resultType:eUsernameSearchResult];
        }
        else
        {
            NSString *query = searchText;
            
            self.liveSearchTask = [[DAAPIManager sharedManager] exploreDishAndLocationSuggestionsTaskWithQuery:query
            longitude:self.selectedLocation.longitude latitude:self.selectedLocation.latitude radius:self.selectedRadius
            completion:^( id response, NSError *error )
            {
                NSArray *dishes    = [self resultsFromResponse:response withType:eDishSearchResult];
                NSArray *locations = [self resultsFromResponse:response withType:eLocationSearchResult];
                self.liveSearchResults = [dishes arrayByAddingObjectsFromArray:locations];
                
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

- (void)searchWithURL:(NSString *)url query:(NSString *)query queryKey:(NSString *)key resultType:(eExploreSearchResultType)type
{
    NSDictionary *parameters = @{ key : query };
    
    self.liveSearchTask = [[DAAPIManager sharedManager] GETRequest:url withParameters:parameters
    success:^( id response )
    {
        self.liveSearchResults = [self resultsFromResponse:response withType:type];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self searchWithURL:url query:query queryKey:key resultType:type];
        }
    }];
}

- (NSArray *)resultsFromResponse:(id)response withType:(eExploreSearchResultType)type
{
    NSArray *results = nil;
    NSMutableArray *searchResults = [NSMutableArray array];
    
    switch( type )
    {
        case eUsernameSearchResult:
        case eHashtagSearchResult:
            results = nilOrJSONObjectForKey( response, kDataKey );
            break;
            
        case eDishSearchResult:
        {
            NSDictionary *dishData = nilOrJSONObjectForKey( response, kDataKey );
            if( dishData )
            {
                results = nilOrJSONObjectForKey( dishData, @"dishes" );
            }
        }
        break;
            
        case eLocationSearchResult:
        {
            NSDictionary *locationData = nilOrJSONObjectForKey( response, kDataKey );
            if( locationData )
            {
                results = nilOrJSONObjectForKey( locationData, @"locations" );
            }
        }
        break;
            
        default:
            results = nilOrJSONObjectForKey( response, kDataKey );
            break;
    }
    
    if( results )
    {
        for( NSDictionary *result in results )
        {
            [searchResults addObject:[DAExploreLiveSearchResult liveSearchResultWithData:result type:type]];
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
        
        cell = [tableView dequeueReusableCellWithIdentifier:kSearchResultCellIdentifier];
        
        if( !cell )
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSearchResultCellIdentifier];
        }
        
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17];
        
        switch( searchResult.resultType )
        {
            case eHashtagSearchResult:
                cell.imageView.image = nil;
                cell.textLabel.text  = [NSString stringWithFormat:@"#%@", searchResult.name];
                break;
                
            case eUsernameSearchResult:
                cell.imageView.image = [UIImage imageNamed:@"user_search_result"];
                cell.textLabel.text  = [NSString stringWithFormat:@"@%@", searchResult.name];
                break;
                
            case eLocationSearchResult:
                cell.imageView.image = [UIImage imageNamed:@"dish_location"];
                cell.textLabel.text  = searchResult.name;
                break;
                
            case eDishSearchResult:
                cell.textLabel.text = searchResult.name;
                
                if( [searchResult.dishType isEqualToString:kFood] )
                {
                    cell.imageView.image = [UIImage imageNamed:@"food_dish_gray"];
                }
                else if( [searchResult.dishType isEqualToString:kCocktail] )
                {
                    cell.imageView.image = [UIImage imageNamed:@"cocktail_dish_gray"];
                }
                else if( [searchResult.dishType isEqualToString:kWine] )
                {
                    cell.imageView.image = [UIImage imageNamed:@"wine_dish_gray"];
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
            case 0: [self performSegueWithIdentifier:@"dishResults" sender:kEditorsPicks]; break;
            case 1: [self performSegueWithIdentifier:@"dishResults" sender:kPopularNow]; break;
        }
    }
    else
    {
        DAExploreLiveSearchResult *searchResult = [self.liveSearchResults objectAtIndex:indexPath.row];
        
        switch( searchResult.resultType )
        {
            case eUsernameSearchResult:
                [self goToUserProfileForSearchResult:searchResult];
                break;
                
            case eHashtagSearchResult:
                [self performSegueWithIdentifier:@"dishResults" sender:[NSString stringWithFormat:@"#%@", searchResult.name]];
                break;
                
            case eDishSearchResult:
                [self performSegueWithIdentifier:@"dishResults" sender:searchResult.name];
                break;
                
            case eLocationSearchResult:
                [self goToUserProfileForSearchResult:searchResult];
                break;
        }
    }
}

- (void)goToUserProfileForSearchResult:(DAExploreLiveSearchResult *)searchResult
{
    if( searchResult.resultType == eUsernameSearchResult )
    {
        [self pushUserProfileWithUsername:searchResult.name];
    }
    else if( searchResult.resultType == eLocationSearchResult )
    {
        [self pushRestaurantProfileWithLocationID:searchResult.resultID username:searchResult.name];
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
            if( image )
            {
                self.images[indexPath.row] = image;
            }
            
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    CGFloat width = collectionView.frame.size.width;
    CGFloat sectionInsetSpacing = flowLayout.sectionInset.right + flowLayout.sectionInset.left;
    CGFloat availableWidth = width - ( 2 * flowLayout.minimumInteritemSpacing ) - sectionInsetSpacing;
    CGFloat itemWidth = availableWidth / 3;
    
    CGFloat widthPercentIncrease = itemWidth / flowLayout.itemSize.width;
    CGFloat itemHeight = flowLayout.itemSize.height * widthPercentIncrease;
    
    CGSize itemSize = CGSizeMake( itemWidth, itemHeight );
    
    return itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAHashtag *selectedHashtag = self.hashtags[indexPath.row];
    
    [self performSegueWithIdentifier:@"dishResults" sender:[NSString stringWithFormat:@"#%@", selectedHashtag.name]];
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
        
        if( [sender boolValue] == YES )
        {
            dest.navigationItem.title = @"Select Location";
        }
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