//
//  DANewsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsViewController.h"
#import "DAAppDelegate.h"
#import "DAAPIManager.h"
#import "UIImageView+DishProgress.h"
#import "DAUserNews.h"
#import "DAFollowingNews.h"
#import "NSAttributedString+Dished.h"
#import "DARefreshControl.h"


@interface DANewsViewController()

@property (strong, nonatomic) NSArray                 *newsData;
@property (strong, nonatomic) NSArray                 *followingData;
@property (weak,   nonatomic) UITableView             *selectedTableView;
@property (strong, nonatomic) DARefreshControl        *newsRefreshControl;
@property (strong, nonatomic) DARefreshControl        *followingRefreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL newsFinishedLoading;
@property (nonatomic) BOOL followingFinishedLoading;

@end


@implementation DANewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.newsFinishedLoading = NO;
    self.followingFinishedLoading = NO;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
    
    CGFloat estimatedCellHeight = 44.0;
    self.newsTableView.estimatedRowHeight = estimatedCellHeight;
    self.followingTableView.estimatedRowHeight = estimatedCellHeight;
    self.newsTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.followingTableView.rowHeight = UITableViewAutomaticDimension;
    
    self.newsTableView.hidden = YES;
    self.followingTableView.hidden = YES;
    
    [[DAAPIManager sharedManager] getNewsNotificationsWithCompletion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            
        }
        else
        {
            self.newsData = [self newsDataWithData:response];
            [self.newsTableView reloadData];
        }
        
        self.newsFinishedLoading = YES;
        
        if( self.segmentedControl.selectedSegmentIndex == 0 )
        {
            [self.spinner stopAnimating];
            self.newsTableView.hidden = NO;
            [self makeTableViewActive:self.newsTableView];
        }
    }];
    
    [[DAAPIManager sharedManager] getFollowingNotificationsWithCompletion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            
        }
        else
        {
            self.followingData = [self followingDataWithData:response];
            [self.followingTableView reloadData];
        }
        
        self.followingFinishedLoading = YES;
        
        if( self.segmentedControl.selectedSegmentIndex == 1 )
        {
            [self.spinner stopAnimating];
            self.followingTableView.hidden = NO;
            [self makeTableViewActive:self.followingTableView];
        }
    }];
    
    UINib *cellNib = [UINib nibWithNibName:@"DANewsTableViewCell" bundle:[NSBundle mainBundle]];
    [self.newsTableView registerNib:cellNib forCellReuseIdentifier:@"newsCell"];
    [self.followingTableView registerNib:cellNib forCellReuseIdentifier:@"newsCell"];
}

- (void)setupRefreshControls
{
    CGFloat refreshControlHeight = 40.0f;
    CGFloat refreshControlWidth  = self.newsTableView.frame.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.newsRefreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.newsRefreshControl addTarget:self action:@selector(refreshNews) forControlEvents:UIControlEventValueChanged];
    [self.newsTableView addSubview:self.newsRefreshControl];
    self.newsRefreshControl.hidden = YES;
    
    refreshControlWidth  = self.followingTableView.frame.size.width;
    refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.followingRefreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.followingRefreshControl addTarget:self action:@selector(refreshFollowing) forControlEvents:UIControlEventValueChanged];
    [self.followingTableView addSubview:self.followingRefreshControl];
    self.followingRefreshControl.hidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupRefreshControls];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.newsRefreshControl shouldRestartAnimation];
    [self.followingRefreshControl shouldRestartAnimation];
}

- (void)refreshNews
{
    [[DAAPIManager sharedManager] getNewsNotificationsWithCompletion:^( id response, NSError *error )
    {
        [self.newsRefreshControl endRefreshing];
        
        if( !response || error )
        {
            
        }
        else
        {
            self.newsData = [self newsDataWithData:response];
            [self.newsTableView reloadData];
        }
    }];
}

- (void)refreshFollowing
{
    [[DAAPIManager sharedManager] getFollowingNotificationsWithCompletion:^( id response, NSError *error )
    {
        [self.followingRefreshControl endRefreshing];
        
        if( !response || error )
        {
            
        }
        else
        {
            self.followingData = [self followingDataWithData:response];
            [self.followingTableView reloadData];
        }
    }];
}

- (NSArray *)newsDataWithData:(id)data
{
    NSArray *response = data[@"data"][@"activity_user"];
    NSMutableArray *news = [NSMutableArray array];
    
    if( response && ![response isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in response )
        {
            [news addObject:[DAUserNews userNewsWithData:dataObject]];
        }
    }
    
    return news;
}

- (NSArray *)followingDataWithData:(id)data
{
    NSArray *response = data[@"data"][@"activity_following"];
    NSMutableArray *following = [NSMutableArray array];
    
    if( response && ![response isEqual:[NSNull null]] )
    {
        for( NSDictionary *dataObject in response )
        {
            [following addObject:[DAFollowingNews followingNewsWithData:dataObject]];
        }
    }
    
    return following;
}

- (IBAction)selectedNewsType
{
    NSInteger index = self.segmentedControl.selectedSegmentIndex;
    
    switch( index )
    {
        case 0: [self makeTableViewActive:self.newsTableView];      break;
        case 1: [self makeTableViewActive:self.followingTableView]; break;
    }
}

- (void)makeTableViewActive:(UITableView *)tableView
{
    self.selectedTableView.hidden = YES;
    
    if( tableView == self.newsTableView )
    {
        self.newsFinishedLoading ? [self showTableView:self.newsTableView] : [self hideAllTableViews];
    }
    else if( tableView == self.followingTableView )
    {
        self.followingFinishedLoading ? [self showTableView:self.followingTableView] : [self hideAllTableViews];
    }
}

- (void)showTableView:(UITableView *)tableView
{
    tableView.hidden = NO;
    [self.view addSubview:tableView];
    self.selectedTableView = tableView;
}

- (void)hideAllTableViews
{
    self.newsTableView.hidden = YES;
    self.followingTableView.hidden = YES;
    [self.spinner startAnimating];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    if( tableView == self.newsTableView )
    {
        rows = self.newsData.count;
    }
    else if( tableView == self.followingTableView )
    {
        rows = self.followingData.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DANewsTableViewCell *newsCell = (DANewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    
    if( tableView == self.newsTableView )
    {
        DAUserNews *news = [self.newsData objectAtIndex:indexPath.row];
        [self configureCell:newsCell withNews:news];
    }
    else if( tableView == self.followingTableView )
    {
        DAFollowingNews *news = [self.followingData objectAtIndex:indexPath.row];
        [self configureCell:newsCell withNews:news];
    }

    return newsCell;
}

- (void)configureCell:(DANewsTableViewCell *)cell withNews:(DANews *)news
{
    if( news.img_thumb )
    {
        NSURL *url = [NSURL URLWithString:news.img_thumb];
        [cell.userImageView sd_setImageWithURL:url];
    }
    else
    {
        cell.userImageView.image = [UIImage imageNamed:@"avatar"];
    }
    
    cell.newsLabel.text = [news formattedString];
    
    cell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:news.created attributes:[DANewsTableViewCell timeLabelAttributes]];
    
    cell.backgroundColor = !news.viewed ? [UIColor unviewedNewsColor] : [UIColor whiteColor];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( scrollView == self.newsTableView )
    {
        CGFloat scrollPosition = scrollView.contentOffset.y + scrollView.contentInset.top;
        self.newsRefreshControl.hidden = scrollPosition > 0 ? YES : NO;
        
        [self.newsRefreshControl containingScrollViewDidScroll:scrollView];
    }
    else if( scrollView == self.followingTableView )
    {
        CGFloat scrollPosition = scrollView.contentOffset.y + scrollView.contentInset.top;
        self.followingRefreshControl.hidden = scrollPosition > 0 ? YES : NO;
        
        [self.followingRefreshControl containingScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if( scrollView == self.newsTableView )
    {
        [self.newsRefreshControl containingScrollViewDidEndDragging:scrollView];
    }
    else if( scrollView == self.followingTableView )
    {
        [self.followingRefreshControl containingScrollViewDidEndDragging:scrollView];
    }
}

@end