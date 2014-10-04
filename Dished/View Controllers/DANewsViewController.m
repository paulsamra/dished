//
//  DANewsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsViewController.h"
#import "DARefreshControl.h"
#import "DANewsManager.h"
#import "UIImageView+WebCache.h"


@interface DANewsViewController()

@property (weak,   nonatomic) UITableView             *selectedTableView;
@property (strong, nonatomic) DARefreshControl        *newsRefreshControl;
@property (strong, nonatomic) DARefreshControl        *followingRefreshControl;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL isLoadingMoreNews;
@property (nonatomic) BOOL isLoadingMoreFollowing;

@end


@implementation DANewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isLoadingMoreNews = NO;
    self.isLoadingMoreFollowing = NO;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    
    [DANewsManager sharedManager].newsFinishedLoading ? [self.spinner stopAnimating] : [self.spinner startAnimating];
    
    CGFloat estimatedCellHeight = 44.0;
    self.newsTableView.estimatedRowHeight = estimatedCellHeight;
    self.followingTableView.estimatedRowHeight = estimatedCellHeight;
    self.newsTableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.followingTableView.rowHeight = UITableViewAutomaticDimension;
    
    UINib *cellNib = [UINib nibWithNibName:@"DANewsTableViewCell" bundle:[NSBundle mainBundle]];
    [self.newsTableView registerNib:cellNib forCellReuseIdentifier:@"newsCell"];
    [self.followingTableView registerNib:cellNib forCellReuseIdentifier:@"newsCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewsTable) name:kNewsUpdatedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFollowingTable) name:kFollowingUpdatedNotificationKey object:nil];
    
    ![DANewsManager sharedManager].newsFinishedLoading ? self.newsTableView.hidden = YES : [self setFooterForNewsTableView];
    ![DANewsManager sharedManager].followingFinishedLoading ? self.followingTableView.hidden = YES : [self setFooterForFollowingTableView];
}

- (void)setFooterForNewsTableView
{
    if( [DANewsManager sharedManager].hasMoreNewsNotifications )
    {
        [self addActivityIndicatorFooterToTableView:self.newsTableView];
    }
    else
    {
        self.newsTableView.tableFooterView = [[UIView alloc] init];
    }
}

- (void)setFooterForFollowingTableView
{
    if( [DANewsManager sharedManager].hasMoreFollowingNotifications )
    {
        [self addActivityIndicatorFooterToTableView:self.followingTableView];
    }
    else
    {
        self.followingTableView.tableFooterView = [[UIView alloc] init];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupRefreshControls];
}

- (void)setupRefreshControls
{
    CGFloat refreshControlHeight = 40.0f;
    CGFloat refreshControlWidth  = self.newsTableView.frame.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.newsRefreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.newsRefreshControl addTarget:self action:@selector(refreshNewsData) forControlEvents:UIControlEventValueChanged];
    [self.newsTableView addSubview:self.newsRefreshControl];
    self.newsRefreshControl.hidden = YES;
    
    refreshControlWidth  = self.followingTableView.frame.size.width;
    refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.followingRefreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.followingRefreshControl addTarget:self action:@selector(refreshFollowingData) forControlEvents:UIControlEventValueChanged];
    [self.followingTableView addSubview:self.followingRefreshControl];
    self.followingRefreshControl.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.newsRefreshControl shouldRestartAnimation];
    [self.followingRefreshControl shouldRestartAnimation];
}

- (void)refreshNewsData
{
    [[DANewsManager sharedManager] refreshNewsWithCompletion:^( BOOL success )
     {
         [self.newsRefreshControl endRefreshing];
         [self reloadNewsTable];
     }];
}

- (void)loadMoreNewsData
{
    self.isLoadingMoreNews = YES;
    
    [[DANewsManager sharedManager] loadMoreNewsWithCompletion:^( BOOL success )
    {
        [self reloadNewsTable];
        self.isLoadingMoreNews = NO;
    }];
}

- (void)refreshFollowingData
{
    [[DANewsManager sharedManager] refreshFollowingWithCompletion:^( BOOL success )
    {
        [self.followingRefreshControl endRefreshing];
        [self reloadFollowingTable];
    }];
}

- (void)loadMoreFollowingData
{
    self.isLoadingMoreFollowing = YES;
    
    [[DANewsManager sharedManager] loadMoreFollowingWithCompletion:^( BOOL success )
    {
        [self reloadFollowingTable];
        self.isLoadingMoreFollowing = NO;
    }];
}

- (void)reloadNewsTable
{
    [self.spinner stopAnimating];
    [self.newsTableView reloadData];
    
    if( self.segmentedControl.selectedSegmentIndex == 0 )
    {
        self.newsTableView.hidden = NO;
    }
    
    [self setFooterForNewsTableView];
}

- (void)reloadFollowingTable
{
    [self.spinner stopAnimating];
    [self.followingTableView reloadData];

    if( self.segmentedControl.selectedSegmentIndex == 1 )
    {
        self.followingTableView.hidden = NO;
    }
    
    [self setFooterForFollowingTableView];
}

- (void)addActivityIndicatorFooterToTableView:(UITableView *)tableView
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    tableView.tableFooterView = spinner;
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
    
    [self.view addSubview:tableView];
    self.selectedTableView = tableView;
    
    if( tableView == self.newsTableView )
    {
        BOOL finishedLoading = [DANewsManager sharedManager].newsFinishedLoading;
        finishedLoading ? self.newsTableView.hidden = NO : [self hideAllTableViews];
    }
    else if( tableView == self.followingTableView )
    {
        BOOL finishedLoading = [DANewsManager sharedManager].followingFinishedLoading;
        finishedLoading ? self.followingTableView.hidden = NO : [self hideAllTableViews];
    }
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
        rows = [DANewsManager sharedManager].newsNotifications.count;
    }
    else if( tableView == self.followingTableView )
    {
        rows = [DANewsManager sharedManager].followingNotifications.count;
    }
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DANewsTableViewCell *newsCell = (DANewsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    
    if( tableView == self.newsTableView )
    {
        DAUserNews *news = [[DANewsManager sharedManager].newsNotifications objectAtIndex:indexPath.row];
        [self configureCell:newsCell withNews:news];
    }
    else if( tableView == self.followingTableView )
    {
        DAFollowingNews *news = [[DANewsManager sharedManager].followingNotifications objectAtIndex:indexPath.row];
        [self configureCell:newsCell withNews:news];
    }

    return newsCell;
}

- (void)configureCell:(DANewsTableViewCell *)cell withNews:(DANews *)news
{
    UIImage *profileImage = [UIImage imageNamed:@"profile_image"];
    NSURL *url = [NSURL URLWithString:news.img];
    [cell.userImageView sd_setImageWithURL:url placeholderImage:profileImage];
    
    NSAttributedString *newsText = [[NSAttributedString alloc] initWithString:[news formattedString] attributes:[DANewsTableViewCell newsLabelAttributes]];
    cell.newsTextView.attributedText = newsText;
    
    cell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:news.created attributes:[DANewsTableViewCell timeLabelAttributes]];
    
    cell.backgroundColor = !news.viewed ? [UIColor unviewedNewsColor] : [UIColor whiteColor];
    
    [cell layoutIfNeeded];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.newsTableView )
    {
        DAUserNews *news = [[DANewsManager sharedManager].newsNotifications objectAtIndex:indexPath.row];
        [self didSelectUserNews:news];
    }
}

- (void)didSelectUserNews:(DAUserNews *)news
{
    switch( news.notificationType )
    {
        case eUserNewsNotificationTypeYum: break;
        case eUserNewsNotificationTypeFollow: break;
        case eUserNewsNotificationTypeComment: break;
        case eUserNewsNotificationTypeCommentMention: break;
        case eUserNewsNotificationTypeUnknown: break;
    }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if( bottomEdge >= scrollView.contentSize.height )
    {
        if( scrollView == self.newsTableView && [DANewsManager sharedManager].hasMoreNewsNotifications && !self.isLoadingMoreNews )
        {
            [self loadMoreNewsData];
        }
        
        if( scrollView == self.followingTableView && [DANewsManager sharedManager].hasMoreFollowingNotifications && !self.isLoadingMoreFollowing )
        {
            [self loadMoreFollowingData];
        }
    }
}

@end