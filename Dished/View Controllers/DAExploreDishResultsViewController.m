//
//  DAExploreDefinedSearchViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreDishResultsViewController.h"
#import "DADishTableViewCell.h"
#import "DALocationManager.h"
#import "DADish.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAGlobalDishDetailViewController.h"
#import "DAUserProfileViewController.h"

#define kRowLimit 20

static NSString *const kDishSearchCellID = @"dishCell";


@interface DAExploreDishResultsViewController() <DADishTableViewCellDelegate>

@property (strong, nonatomic) NSArray          *searchResults;
@property (strong, nonatomic) NSURLSessionTask *searchTask;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL hasMoreData;
@property (nonatomic) BOOL isLoadingMore;

@end


@implementation DAExploreDishResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasMoreData = YES;
    
    self.searchResults = [NSArray array];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DADishTableViewCell" bundle:nil];
    [self.tableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
        
    self.isLoading = YES;
    
    [self createTableViewFooter];
    [self loadData];
}

- (void)createTableViewFooter
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 70 )];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = footerView.center;
    [spinner startAnimating];
    
    [footerView addSubview:spinner];
    
    self.tableView.tableFooterView = footerView;
}

- (void)loadData
{
    if( self.searchTerm )
    {
        if( [self.searchTerm isEqualToString:kEditorsPicks] )
        {
            self.title = @"Editor's Picks";
            
            [self loadSearchResultsWithURL:kEditorsPicksURL query:nil queryKey:nil];
        }
        else if( [self.searchTerm isEqualToString:kPopularNow] )
        {
            self.title = @"Popular Now";
            
            [self loadSearchResultsWithURL:kPopularNowURL query:nil queryKey:nil];
        }
        else if( [self.searchTerm characterAtIndex:0] == '#' )
        {
            self.searchTerm = [self.searchTerm substringFromIndex:1];
            self.title = [NSString stringWithFormat:@"#%@", self.searchTerm];
            
            [self loadSearchResultsWithURL:kExploreHashtagsURL query:self.searchTerm queryKey:kHashtagKey];
        }
        else
        {
            self.title = self.searchTerm;
            
            [self loadSearchResultsWithURL:kExploreDishesURL query:self.searchTerm queryKey:kQueryKey];
        }
    }
}

- (void)loadSearchResultsWithURL:(NSString *)url query:(NSString *)query queryKey:(NSString *)key
{
    __weak typeof( self ) weakSelf = self;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[kLongitudeKey] = @(weakSelf.selectedLocation.longitude);
    parameters[kLatitudeKey]  = @(weakSelf.selectedLocation.latitude);
    parameters[kRadiusKey]    = @(weakSelf.selectedRadius);
    parameters[kRowOffsetKey] = @(weakSelf.searchResults.count);
    parameters[kRowLimitKey]  = @(kRowLimit);
    
    if( query && key )
    {
        parameters[key] = query;
    }
    
    NSDictionary *authParameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    weakSelf.searchTask = [[DAAPIManager sharedManager] GETRequest:url withParameters:authParameters
    success:^( id response )
    {
        weakSelf.isLoading = NO;
        
        NSArray *newResults = [weakSelf dishesFromResponse:response];
        weakSelf.searchResults = [weakSelf.searchResults arrayByAddingObjectsFromArray:newResults];
        
        weakSelf.hasMoreData = newResults.count < kRowLimit ? NO : YES;
        
        if( weakSelf.isLoadingMore )
        {
            [weakSelf.tableView reloadData];
        }
        else
        {
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if( !weakSelf.hasMoreData )
        {
            weakSelf.tableView.tableFooterView = [[UIView alloc] init];
        }
        
        weakSelf.isLoadingMore = NO;
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadSearchResultsWithURL:url query:query queryKey:key];
        }
        else
        {
            weakSelf.isLoading = NO;
            weakSelf.isLoadingMore = NO;
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)dealloc
{
    [self.searchTask cancel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (NSArray *)dishesFromResponse:(id)response
{
    NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey);
    NSDictionary *dishes = nilOrJSONObjectForKey( data, @"dishes" );
    
    NSMutableArray *results = [NSMutableArray array];
    
    if( dishes )
    {
        for( NSDictionary *dish in dishes )
        {
            DADish *result = [DADish dishWithData:dish];
            [results addObject:result];
        }
    }
    
    return results;
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
        
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17];
        
        if( self.isLoading )
        {
            cell.textLabel.text = @"Searching...";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            
            cell.userInteractionEnabled = NO;
        }
        else
        {
            cell.textLabel.text = @"No Dishes Found";
            cell.textLabel.textAlignment = NSTextAlignmentLeft;

            cell.userInteractionEnabled = NO;
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
    cell.delegate = self;
    
    if( result.imageURL )
    {
        NSURL *url = [NSURL URLWithString:result.imageURL];
        [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return cell;
}

- (void)locationButtonTappedOnDishTableViewCell:(DADishTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DADish *result = [self.searchResults objectAtIndex:indexPath.row];
    
    [self pushRestaurantProfileWithLocationID:result.locationID username:result.locationName];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DADish *result = [self.searchResults objectAtIndex:indexPath.row];
    
    [self pushGlobalDishWithDishID:result.dishID];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if( bottomEdge >= scrollView.contentSize.height && self.hasMoreData && !self.isLoadingMore )
    {
        self.isLoadingMore = YES;
        [self loadData];
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

@end