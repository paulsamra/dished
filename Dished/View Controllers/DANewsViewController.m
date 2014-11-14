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
#import "DASettingsViewController.h"
#import "DAReviewDetailsViewController.h"
#import "DAUserProfileViewController.h"

#define kUserNewsCellID   @"userNewsCell"
#define kMultiNewsCellID  @"multiNewsCell"
#define kSingleNewsCellID @"singleNewsCell"


@interface DANewsViewController()

@property (weak,   nonatomic) UITableView             *selectedTableView;
@property (strong, nonatomic) NSDictionary            *newsTextAttributes;
@property (strong, nonatomic) NSDictionary            *timeLabelAttributes;
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
    
    self.newsTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:15.0f], NSForegroundColorAttributeName : [UIColor blackColor] };
    
    self.timeLabelAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:11.0f] };

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.center = self.view.center;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];
    
    [DANewsManager sharedManager].newsFinishedLoading ? [self.spinner stopAnimating] : [self.spinner startAnimating];
    
    [self registerCellNibs];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNewsTable) name:kNewsUpdatedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFollowingTable) name:kFollowingUpdatedNotificationKey object:nil];
    
    ![DANewsManager sharedManager].newsFinishedLoading ? self.newsTableView.hidden = YES : [self setFooterForNewsTableView];
    ![DANewsManager sharedManager].followingFinishedLoading ? self.followingTableView.hidden = YES : [self setFooterForFollowingTableView];
}

- (void)registerCellNibs
{
    UINib *userNewsCellNib = [UINib nibWithNibName:@"DAUserNewsTableViewCell" bundle:[NSBundle mainBundle]];
    [self.newsTableView registerNib:userNewsCellNib forCellReuseIdentifier:kUserNewsCellID];
    [self.followingTableView registerNib:userNewsCellNib forCellReuseIdentifier:kUserNewsCellID];
    
    UINib *singleNewsCellNib = [UINib nibWithNibName:@"DASingleNewsTableViewCell" bundle:[NSBundle mainBundle]];
    [self.newsTableView registerNib:singleNewsCellNib forCellReuseIdentifier:kSingleNewsCellID];
    [self.followingTableView registerNib:singleNewsCellNib forCellReuseIdentifier:kSingleNewsCellID];
    
    UINib *multiNewsCellNib = [UINib nibWithNibName:@"DAMultiNewsTableViewCell" bundle:[NSBundle mainBundle]];
    [self.newsTableView registerNib:multiNewsCellNib forCellReuseIdentifier:kMultiNewsCellID];
    [self.followingTableView registerNib:multiNewsCellNib forCellReuseIdentifier:kMultiNewsCellID];
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
    
    if( !self.newsRefreshControl )
    {
        self.newsRefreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
        [self.newsRefreshControl addTarget:self action:@selector(refreshNewsData) forControlEvents:UIControlEventValueChanged];
        [self.newsTableView addSubview:self.newsRefreshControl];
        self.newsRefreshControl.hidden = YES;
    }
    
    if( !self.followingRefreshControl )
    {
        refreshControlWidth  = self.followingTableView.frame.size.width;
        refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
        
        self.followingRefreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
        [self.followingRefreshControl addTarget:self action:@selector(refreshFollowingData) forControlEvents:UIControlEventValueChanged];
        [self.followingTableView addSubview:self.followingRefreshControl];
        self.followingRefreshControl.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.newsTableView deselectRowAtIndexPath:[self.newsTableView indexPathForSelectedRow] animated:YES];
    [self.followingTableView deselectRowAtIndexPath:[self.followingTableView indexPathForSelectedRow] animated:YES];
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
    DANewsTableViewCell *cell = nil;
    
    if( tableView == self.newsTableView )
    {
        cell = [self newsCellAtIndexPath:indexPath];
    }
    else
    {
        cell = [self followingCellAtIndexPath:indexPath];
    }

    return cell;
}

- (DANewsTableViewCell *)newsCellAtIndexPath:(NSIndexPath *)indexPath
{
    DANewsTableViewCell *cell = nil;
    
    DAUserNews *userNews = [[DANewsManager sharedManager].newsNotifications objectAtIndex:indexPath.row];
    
    switch( userNews.notificationType )
    {
        case eUserNewsNotificationTypeFollow:
        case eUserNewsNotificationTypeUnknown:
            cell = [self.newsTableView dequeueReusableCellWithIdentifier:kUserNewsCellID];
            [self configureCell:cell withNews:userNews];
            break;
            
        case eUserNewsNotificationTypeReviewMention:
        case eUserNewsNotificationTypeComment:
        case eUserNewsNotificationTypeCommentMention:
        case eUserNewsNotificationTypeYum:
        {
            cell = [self.newsTableView dequeueReusableCellWithIdentifier:kSingleNewsCellID];
            [self configureCell:cell withNews:userNews];
            
            DASingleNewsTableViewCell *singleNewsCell = (DASingleNewsTableViewCell *)cell;
            NSURL *url = [NSURL URLWithString:userNews.review_img_thumb];
            [singleNewsCell.newsImageView sd_setImageWithURL:url];
        }
        break;
    }
    
    return cell;
}

- (DANewsTableViewCell *)followingCellAtIndexPath:(NSIndexPath *)indexPath
{
    DANewsTableViewCell *cell = nil;
    
    DAFollowingNews *followingNews = [[DANewsManager sharedManager].followingNotifications objectAtIndex:indexPath.row];
    
    switch( followingNews.notificationType )
    {
        case eFollowingNewsNotificationTypeFollow:
        case eFollowingNewsNotificationTypeUnknown:
            cell = [self.followingTableView dequeueReusableCellWithIdentifier:kUserNewsCellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureCell:cell withNews:followingNews];
            break;
            
        case eFollowingNewsNotificationTypeCreateReview:
        {
            cell = [self.followingTableView dequeueReusableCellWithIdentifier:kSingleNewsCellID];
            [self configureCell:cell withNews:followingNews];
            
            if( followingNews.review_images.count > 0 )
            {
                DASingleNewsTableViewCell *singleNewsCell = (DASingleNewsTableViewCell *)cell;
                NSURL *url = [NSURL URLWithString:[followingNews.review_images objectAtIndex:0]];
                [singleNewsCell.newsImageView sd_setImageWithURL:url];
            }
        }
        break;
            
        case eFollowingNewsNotificationTypeYum:
        {
            switch( followingNews.notificationSubtype )
            {
                case eFollowingNewsYumNotificationSubtypeTwoUserYum:
                case eFollowingNewsYumNotificationSubtypeSingleUserSingleYum:
                case eFollowingNewsYumNotificationSubtypeMultiUserYum:
                case eFollowingNewsYumNotificationSubtypeUnknown:
                {
                    cell = [self.followingTableView dequeueReusableCellWithIdentifier:kSingleNewsCellID];
                    [self configureCell:cell withNews:followingNews];
                    DASingleNewsTableViewCell *singleNewsCell = (DASingleNewsTableViewCell *)cell;
                    NSURL *url = [NSURL URLWithString:followingNews.review_image];
                    [singleNewsCell.newsImageView sd_setImageWithURL:url];
                }
                break;
                    
                case eFollowingNewsYumNotificationSubtypeSingleUserMultiYum:
                {
                    cell = [self.followingTableView dequeueReusableCellWithIdentifier:kSingleNewsCellID];
                    [self configureCell:cell withNews:followingNews];
                    DASingleNewsTableViewCell *multiNewsCell = (DASingleNewsTableViewCell *)cell;
                    NSURL *url = [NSURL URLWithString:[followingNews.review_images objectAtIndex:0]];
                    [multiNewsCell.newsImageView sd_setImageWithURL:url];
                }
                break;
            }
        }
        break;
    }
    
    return cell;
}

- (void)configureCell:(DANewsTableViewCell *)cell withNews:(DANews *)news
{
    UIImage *profileImage = [UIImage imageNamed:@"profile_image"];
    NSURL *url = [NSURL URLWithString:news.user_img_thumb];
    [cell.userImageView sd_setImageWithURL:url placeholderImage:profileImage];
    
    NSAttributedString *newsText = [[NSAttributedString alloc] initWithString:[news formattedString] attributes:self.newsTextAttributes];
    cell.newsTextView.attributedText = newsText;
    
    cell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:news.created
                                                                          attributes:self.timeLabelAttributes];
    
    cell.backgroundColor = !news.viewed ? [UIColor unviewedNewsColor] : [UIColor whiteColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static DASingleNewsTableViewCell *singleNewsCell;
    static dispatch_once_t singleNewsOnceToken;
    dispatch_once( &singleNewsOnceToken, ^
    {
        singleNewsCell = [tableView dequeueReusableCellWithIdentifier:kSingleNewsCellID];
    });
    
    static DAUserNewsTableViewCell *userNewsCell;
    static dispatch_once_t userNewsOnceToken;
    dispatch_once( &userNewsOnceToken, ^
    {
        userNewsCell = [tableView dequeueReusableCellWithIdentifier:kUserNewsCellID];
    });
    
    static DAMultiNewsTableViewCell *multiNewsCell;
    static dispatch_once_t multiNewsOnceToken;
    dispatch_once( &multiNewsOnceToken, ^
    {
        multiNewsCell = [tableView dequeueReusableCellWithIdentifier:kMultiNewsCellID];
    });
    
    UITableViewCell *sizingCell = nil;
    UITextView *textView = nil;
    DANews *news = nil;
    
    if( tableView == self.newsTableView )
    {
        news = [[DANewsManager sharedManager].newsNotifications objectAtIndex:indexPath.row];
        
        switch( ((DAUserNews *)news).notificationType )
        {
            case eUserNewsNotificationTypeFollow:
            case eUserNewsNotificationTypeUnknown:
                sizingCell = userNewsCell;
                textView = userNewsCell.newsTextView;
                break;
            
            case eUserNewsNotificationTypeReviewMention:
            case eUserNewsNotificationTypeComment:
            case eUserNewsNotificationTypeCommentMention:
            case eUserNewsNotificationTypeYum:
                sizingCell = singleNewsCell;
                textView = singleNewsCell.newsTextView;
                break;
        }
    }
    else
    {
        news = [[DANewsManager sharedManager].followingNotifications objectAtIndex:indexPath.row];
        
        switch( ((DAFollowingNews *)news).notificationType )
        {
            case eFollowingNewsNotificationTypeFollow:
            case eFollowingNewsNotificationTypeUnknown:
                sizingCell = userNewsCell;
                textView = userNewsCell.newsTextView;
                break;
                
            case eFollowingNewsNotificationTypeCreateReview:
            case eFollowingNewsNotificationTypeYum:
                sizingCell = singleNewsCell;
                textView = singleNewsCell.newsTextView;
                break;
        }
    }
    
    CGFloat textViewRightMargin = sizingCell.frame.size.width - ( textView.frame.origin.x + textView.frame.size.width );
    CGFloat textViewWidth = tableView.frame.size.width - textView.frame.origin.x - textViewRightMargin;
    
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    textView.attributedText = [[NSAttributedString alloc] initWithString:[news formattedString] attributes:self.newsTextAttributes];
    CGSize stringSize = [textView sizeThatFits:boundingSize];
    
    CGFloat textViewTopMargin = textView.frame.origin.y;
    CGFloat textViewBottomMargin = sizingCell.frame.size.height - ( textView.frame.origin.y + textView.frame.size.height );
    CGFloat textViewHeight = ceilf( stringSize.height );
    
    CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
    
    if( calculatedHeight < 46.0 )
    {
        calculatedHeight = 46.0;
    }
    
    return calculatedHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    if( tableView == self.newsTableView )
    {
        DAUserNews *news = [[DANewsManager sharedManager].newsNotifications objectAtIndex:indexPath.row];
        [self didSelectUserNews:news];
    }
    else if( tableView == self.followingTableView )
    {
        DAFollowingNews *news = [[DANewsManager sharedManager].followingNotifications objectAtIndex:indexPath.row];
        [self didSelectFollowingNews:news];
    }
}

- (void)didSelectUserNews:(DAUserNews *)news
{
    switch( news.notificationType )
    {
        case eUserNewsNotificationTypeFollow:
            [self pushUserProfileWithUsername:news.username];
            break;
            
        case eUserNewsNotificationTypeYum:
        case eUserNewsNotificationTypeReviewMention:
        case eUserNewsNotificationTypeComment:
        case eUserNewsNotificationTypeCommentMention:
            [self pushReviewDetailsWithReviewID:news.review_id];
            break;
            
        case eUserNewsNotificationTypeUnknown:
            break;
    }
}

- (void)didSelectFollowingNews:(DAFollowingNews *)news
{
    switch( news.notificationType )
    {
        case eFollowingNewsNotificationTypeFollow:
        case eFollowingNewsNotificationTypeUnknown:
            break;
            
        case eFollowingNewsNotificationTypeCreateReview:
        case eFollowingNewsNotificationTypeYum:
            break;
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

- (IBAction)settingsButtonTapped:(id)sender
{
    [self pushSettingsView];
}

@end