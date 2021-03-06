//
//  DAFeedViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFeedViewController.h"
#import "DAFeedCollectionViewCell.h"
#import "DAFeedItem+Utility.h"
#import "DAFeedImportManager.h"
#import "DARefreshControl.h"
#import "DAExploreViewController.h"
#import "UIImageView+DishProgress.h"
#import "DAUserListViewController.h"
#import "DAFeedCollectionViewFlowLayout.h"
#import "DAFeedHeaderCollectionReusableView.h"
#import "DAExploreDishResultsViewController.h"

static NSString *const kReviewDetailCellIdentifier   = @"reviewDetailCell";
static NSString *const kReviewButtonsCellIdentifier  = @"reviewButtonsCell";
static NSString *const kUserSuggestionCellIdentifier = @"userSuggestionCell";

typedef enum
{
    eFeedCellTypeDish,
    eFeedCellTypeComment,
    eFeedCellTypeMoreComments,
    eFeedCellTypeYums,
    eFeedCellTypeHashtags,
    eFeedCellTypeButtons,
    eFeedCellTypeUserSuggestion
} eFeedCellType;


@interface DAFeedViewController() <DAFeedCollectionViewCellDelegate, DAFeedHeaderCollectionReusableViewDelegate, DAReviewButtonsCollectionViewCellDelegate, DAReviewDetailCollectionViewCellDelegate, DAFoodieCollectionViewCellDelegate>

@property (strong, nonatomic) NSArray                          *feedItems;
@property (strong, nonatomic) NSCache                          *feedImageCache;
@property (strong, nonatomic) NSCache                          *attributedStringCache;
@property (strong, nonatomic) NSCache                          *cellSizeCache;
@property (strong, nonatomic) UIImageView                      *yumTapImageView;
@property (strong, nonatomic) NSDictionary                     *linkedTextAttributes;
@property (strong, nonatomic) DARefreshControl                 *refreshControl;
@property (strong, nonatomic) DAFeedImportManager              *importer;

@property (nonatomic) BOOL    initialLoadActive;
@property (nonatomic) BOOL    hasMoreData;
@property (nonatomic) BOOL    isLoadingMore;
@property (nonatomic) CGFloat previousScrollViewYOffset;

@end


@implementation DAFeedViewController

- (void)viewDidLoad
{	
    [super viewDidLoad];
    
    [self registerCollectionViewCellNibs];
    [self setupRefreshControl];
    [self setupCaches];
    
    self.linkedTextAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
    
    DAFeedCollectionViewFlowLayout *flowLayout = (DAFeedCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.navigationBar  = self.navigationController.navigationBar;
    flowLayout.refreshControl = self.refreshControl;
    
    self.hasMoreData   = YES;
    self.isLoadingMore = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_nav_gray"]];
    self.collectionView.hidden = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    self.importer = [[DAFeedImportManager alloc] init];
    [self.importer fetchFeedItemsInBackgroundWithLimit:10 completion:^( NSArray *feedItems )
    {
        if( feedItems.count > 0 )
        {
            self.feedItems = feedItems;
            [spinner stopAnimating];
            [self.collectionView reloadDataAnimated:YES];
            self.collectionView.hidden = NO;
        }
    }];
        
    self.initialLoadActive = YES;
    [self.importer importFeedItemsWithLimit:10 offset:0 completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;
        
        [self.importer fetchFeedItemsInBackgroundWithLimit:10 completion:^( NSArray *feedItems )
        {
            if( feedItems.count > 0 )
            {
                self.feedItems = feedItems;
                [spinner stopAnimating];
                [self.collectionView reloadDataAnimated:NO];
            }
            
            self.initialLoadActive = NO;
            [self.refreshControl endRefreshing];
            
            [spinner stopAnimating];
            self.collectionView.hidden = NO;
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:kNetworkReachableKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNavigationBar) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewDeleted) name:kReviewDeletedNotification object:nil];
}

- (BOOL)shouldShowGetSocialView
{
    static NSNumber *numLaunches = nil;
    
    if( numLaunches )
    {
        return NO;
    }
    
    int launches = [[[NSUserDefaults standardUserDefaults] objectForKey:@"launches"] intValue];
    numLaunches = @(launches);
    
    BOOL shouldShow = NO;
    
    if( launches == 0 || launches == 2 || launches == 6 || launches == 10 || launches == 20 || launches == 30 )
    {
        shouldShow = YES;
    }
    
    launches++;
    [[NSUserDefaults standardUserDefaults] setObject:@(launches) forKey:@"launches"];
    
    return shouldShow;
}

- (void)showGetSocialView
{
    DAGetSocialViewController *socialViewController = [[DAGetSocialViewController alloc] init];
    socialViewController.showsSkipButton = YES;
    UINavigationController *socialNav = [[UINavigationController alloc] initWithRootViewController:socialViewController];
    [self presentViewController:socialNav animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.refreshControl shouldRestartAnimation];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( self.initialLoadActive && ![self.refreshControl isRefreshing] )
    {
        [self.refreshControl startRefreshingAnimated:YES];
    }
    
    if( [self shouldShowGetSocialView] )
    {
        [self showGetSocialView];
    }
}

- (void)registerCollectionViewCellNibs
{
    [self.collectionView registerClass:[DAReviewDetailCollectionViewCell class] forCellWithReuseIdentifier:kReviewDetailCellIdentifier];
    [self.collectionView registerClass:[DAReviewButtonsCollectionViewCell class] forCellWithReuseIdentifier:kReviewButtonsCellIdentifier];
    [self.collectionView registerClass:[DAFoodieCollectionViewCell class] forCellWithReuseIdentifier:kUserSuggestionCellIdentifier];
}

- (void)setupRefreshControl
{
    CGFloat refreshControlHeight = 40;
    CGFloat refreshControlWidth  = self.view.bounds.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.refreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.hidden = YES;
}

- (void)setupCaches
{
    self.attributedStringCache = [[NSCache alloc] init];
    self.attributedStringCache.name = @"feedAttributedStrings";
    
    self.feedImageCache = [[NSCache alloc] init];
    self.feedImageCache.name = @"feedImageCache";
    
    self.cellSizeCache = [[NSCache alloc] init];
    self.cellSizeCache.name = @"feedCellSizes";
}

- (void)refreshFeed
{
    if( self.initialLoadActive )
    {
        return;
    }
    
    NSInteger limit = self.feedItems.count;
    limit = limit > 20 ? 20 : limit;
    
    [self.importer importFeedItemsWithLimit:limit offset:0 completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;

        [self.importer fetchFeedItemsInBackgroundWithLimit:limit completion:^( NSArray *feedItems )
        {
            if( feedItems.count > 0 )
            {
                self.feedItems = feedItems;
                [self.collectionView reloadDataAnimated:NO];
            }
             
            [self.refreshControl endRefreshing];
        }];
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)loadMore
{
    self.isLoadingMore = YES;
    
    NSInteger offset = self.feedItems.count;
    
    [self.importer importFeedItemsWithLimit:10 offset:offset completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;
        
        [self.importer fetchFeedItemsInBackgroundWithLimit:(offset + 10) completion:^( NSArray *feedItems )
        {
            if( feedItems.count > 0 )
            {
                self.feedItems = feedItems;
                [self.collectionView reloadDataAnimated:NO];
            }
             
            [self.refreshControl endRefreshing];
            self.isLoadingMore = NO;
        }];
    }];
}

- (void)reviewDeleted
{
    [self.importer fetchFeedItemsInBackgroundWithLimit:self.feedItems.count completion:^( NSArray *feedItems )
    {
        if( feedItems.count > 0 )
        {
            self.feedItems = feedItems;
            [self.collectionView reloadDataAnimated:NO];
        }
    }];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:section];

    BOOL hasYums = [feedItem.num_yums integerValue] > 0;
    BOOL hasHashtags = feedItem.hashtags.count > 0;
    BOOL hasMoreComments = [feedItem.num_comments integerValue] > 3;
    BOOL hasUserSuggestion = feedItem.user_suggestion != nil;
    
    return 1 + [feedItem.comments count] + ( hasYums ? 1 : 0 ) + ( hasHashtags ? 1 : 0 ) + ( hasMoreComments ? 1 : 0 ) + 1 + ( hasUserSuggestion ? 1 : 0 );
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger numberOfSections = self.feedItems.count;
    
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

- (eFeedCellType)feedCellTypeForIndexPath:(NSIndexPath *)indexPath
{
    eFeedCellType type = eFeedCellTypeDish;
    NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    BOOL hasYums = [feedItem.num_yums integerValue] > 0;
    BOOL hasHashtags = feedItem.hashtags.count > 0;
    BOOL hasMoreComments = [feedItem.num_comments integerValue] > 3;
    BOOL hasUserSuggestion = feedItem.user_suggestion != nil;
    
    NSUInteger yumRows = hasYums ? 1 : 0;
    NSUInteger hashtagRows = hasHashtags ? 1 : 0;
    NSUInteger userSuggestions = hasUserSuggestion ? 1 : 0;
    
    if( indexPath.row == 0 )
    {
        type = eFeedCellTypeDish;
    }
    else if( indexPath.row == sectionItems - 1 - userSuggestions )
    {
        type = eFeedCellTypeButtons;
    }
    else if( indexPath.row == sectionItems - 1 && hasUserSuggestion )
    {
        type = eFeedCellTypeUserSuggestion;
    }
    else if( indexPath.row == 1 && hasYums )
    {
        type = eFeedCellTypeYums;
    }
    else if( indexPath.row == yumRows + 1 && hasHashtags )
    {
        type = eFeedCellTypeHashtags;
    }
    else if( indexPath.row == yumRows + hashtagRows + 1 )
    {
        type = eFeedCellTypeComment;
    }
    else if( indexPath.row == yumRows + hashtagRows + 2 && hasMoreComments )
    {
        type = eFeedCellTypeMoreComments;
    }
    else
    {
        type = eFeedCellTypeComment;
    }
    
    return type;
}

- (NSUInteger)commentIndexForIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    BOOL hasYums = [feedItem.num_yums integerValue] > 0;
    BOOL hasHashtags = feedItem.hashtags.count > 0;
    BOOL hasMoreComments = [feedItem.num_comments integerValue] > 3;
    
    NSUInteger yumRows = hasYums ? 1 : 0;
    NSUInteger hashtagRows = hasHashtags ? 1 : 0;
    
    NSUInteger commentIndex = indexPath.row - 1 - yumRows - hashtagRows;
    commentIndex = hasMoreComments && commentIndex > 0 ? commentIndex - 1 : commentIndex;
    
    return commentIndex;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    eFeedCellType cellType = [self feedCellTypeForIndexPath:indexPath];
    
    if( cellType == eFeedCellTypeDish )
    {
        DAFeedCollectionViewCell *feedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        [self configureCell:feedCell atIndexPath:indexPath];
        feedCell.delegate = self;
        
        cell = feedCell;
    }
    else if( cellType == eFeedCellTypeYums )
    {
        DAReviewDetailCollectionViewCell *yumCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        yumCell.iconImageView.image = [UIImage imageNamed:@"yum_icon"];
        
        NSString *yumsString = [NSString stringWithFormat:@"%d YUMs", (int)[feedItem.num_yums integerValue]];
        yumCell.textView.attributedText = [[NSAttributedString alloc] initWithString:yumsString attributes:self.linkedTextAttributes];
        
        yumCell.delegate = self;
        
        cell = yumCell;
    }
    else if( cellType == eFeedCellTypeHashtags )
    {
        DAReviewDetailCollectionViewCell *hashtagCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        hashtagCell.iconImageView.image = [UIImage imageNamed:@"hashtag_icon"];
        
        NSAttributedString *hashtagString = [self hashtagStringForFeedItem:feedItem];
        [hashtagCell.textView setAttributedText:hashtagString withAttributes:self.linkedTextAttributes knownUsernames:nil useCache:YES];
        
        hashtagCell.delegate = self;
        
        cell = hashtagCell;
    }
    else if( cellType == eFeedCellTypeMoreComments )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        commentCell.iconImageView.hidden = YES;
        
        NSString *commentString = [NSString stringWithFormat:@"View all %d comments...", [feedItem.num_comments intValue] - 1];
        commentCell.textView.attributedText = [[NSAttributedString alloc] initWithString:commentString attributes:self.linkedTextAttributes];
        
        commentCell.delegate = self;
        
        cell = commentCell;
    }
    else if( cellType == eFeedCellTypeComment )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        NSUInteger commentIndex = [self commentIndexForIndexPath:indexPath];
        NSArray *comments = [self dateSortedArrayWithFeedComments:feedItem.comments];
        DAManagedComment *comment = comments[commentIndex];
        
        commentCell.iconImageView.image = [UIImage imageNamed:@"comments_icon"];
        commentCell.iconImageView.hidden = commentIndex == 0 ? NO : YES;
        
        NSAttributedString *commentString = [self commentStringForComment:comment];
        
        NSArray *usernameMentions = [self usernameStringArrayWithUsernames:comment.usernames creator:comment.creator_username];
        
        [commentCell.textView setAttributedText:commentString withAttributes:self.linkedTextAttributes knownUsernames:usernameMentions useCache:NO];
        
        commentCell.delegate = self;
        
        cell = commentCell;
    }
    else if( cellType == eFeedCellTypeButtons )
    {
        DAReviewButtonsCollectionViewCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewButtonsCellIdentifier forIndexPath:indexPath];
        
        NSInteger numComments = [feedItem.num_comments intValue] - 1;
        [buttonCell setNumberOfComments:numComments];
        [feedItem.caller_yumd boolValue] ? [buttonCell setYummed] : [buttonCell setUnyummed];
        buttonCell.delegate = self;
        
        cell = buttonCell;
    }
    else if( cellType == eFeedCellTypeUserSuggestion )
    {
        DAFoodieCollectionViewCell *foodieCell = [collectionView dequeueReusableCellWithReuseIdentifier:kUserSuggestionCellIdentifier forIndexPath:indexPath];
        
        DAManagedUserSuggestion *userSuggestion = feedItem.user_suggestion;
        [foodieCell configureWithUserSuggestion:userSuggestion];
        foodieCell.delegate = self;
        [foodieCell.usernameButton addTarget:self action:@selector(tappedFoodieUsernameButton:) forControlEvents:UIControlEventTouchUpInside];
        [foodieCell.followButton addTarget:self action:@selector(tappedFoodieFollowButton:) forControlEvents:UIControlEventTouchUpInside];
        
        cell = foodieCell;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (void)tappedFoodieUsernameButton:(UIButton *)button
{
    NSIndexPath *indexPath = [self.collectionView indexPathForView:button];
    if( indexPath )
    {
        DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
        [self pushUserProfileWithUserID:[feedItem.user_suggestion.user_id integerValue]];
    }
}

- (void)tappedFoodieFollowButton:(UIButton *)button
{
    NSIndexPath *indexPath = [self.collectionView indexPathForView:button];
    if( indexPath )
    {
        DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
        
        if( [feedItem.user_suggestion.following boolValue] == NO )
        {
            [DAAPIManager followUserID:[feedItem.user_suggestion.user_id integerValue]];
            feedItem.user_suggestion.following = @(YES);
        }
        else
        {
            [DAAPIManager unfollowUserID:[feedItem.user_suggestion.user_id integerValue]];
            feedItem.user_suggestion.following = @(NO);
        }
        
        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
    }
}

- (void)didTapImageAtIndex:(NSInteger)index inFoodieCollectionViewCell:(DAFoodieCollectionViewCell * __nonnull)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    NSArray *reviews = feedItem.user_suggestion.reviews;
    if( index <= [reviews count] )
    {
        NSDictionary *review = reviews[index];
        [self pushReviewDetailsViewWithReviewID:[review[kIDKey] integerValue]];
    }
}

- (void)didDismissCell:(DAFoodieCollectionViewCell * __nonnull)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    [self.collectionView performBatchUpdates:^
    {
        feedItem.user_suggestion.dismissed = @(YES);
        feedItem.user_suggestion = nil;
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    }
    completion:nil];
}

- (void)didTapUserImageViewInCell:(DAFoodieCollectionViewCell * __nonnull)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    DAManagedUserSuggestion *userSuggestion = feedItem.user_suggestion;
    [self pushUserProfileWithUserID:[userSuggestion.user_id integerValue]];
}

- (NSArray *)usernameStringArrayWithUsernames:(NSSet *)usernames creator:(NSString *)creator
{
    NSMutableArray *usernameMentions = [NSMutableArray array];
    
    if( creator )
    {
        [usernameMentions addObject:creator];
    }
    
    for( DAManagedUsername *managedUsername in usernames )
    {
        [usernameMentions addObject:managedUsername.username];
    }
    
    return usernameMentions;
}

- (NSAttributedString *)hashtagStringForFeedItem:(DAFeedItem *)feedItem
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    int index = 0;
    for( DAManagedHashtag *hashtag in feedItem.hashtags )
    {
        if( index++ == 0 )
        {
            [string appendFormat:@"#%@", hashtag.name];
        }
        else
        {
            [string appendFormat:@", #%@", hashtag.name];
        }
    }
    
    NSDictionary *plainTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
    NSAttributedString *hashtagString = [[NSAttributedString alloc] initWithString:string attributes:plainTextAttributes];
    
    return hashtagString;
}

- (NSArray *)dateSortedArrayWithFeedComments:(NSSet *)comments
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];
    
    return [comments sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)configureCell:(DAFeedCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *item = [self.feedItems objectAtIndex:indexPath.section];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", item.creator_username];
    if( [item.creator_type isEqualToString:kInfluencerUserType] )
    {
        usernameString = [NSString stringWithFormat:@" %@", usernameString];
        [cell.creatorButton setImage:[UIImage imageNamed:@"influencer"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.creatorButton setImage:nil forState:UIControlStateNormal];
    }
    
    [cell.creatorButton setTitle:usernameString forState:UIControlStateNormal];
    
    UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [cell.locationButton setTitle:item.loc_name forState:UIControlStateNormal];
    [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
    [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
    
    UIImage *image = [self.feedImageCache objectForKey:item.img];
    if( image )
    {
        [cell.dishImageView removeProgressView];
        cell.dishImageView.image = image;
    }
    else
    {
        [cell layoutIfNeeded];
        cell.tag = indexPath.section;
        NSURL *dishImageURL = [NSURL URLWithString:item.img];
        
        [cell.dishImageView loadImageUsingProgressViewWithURL:dishImageURL
        completion:^( UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL )
        {
            if( image && cell.tag == indexPath.section )
            {
                cell.dishImageView.image = image;
                [self.feedImageCache setObject:image forKey:item.img];
            }
        }];
    }
    
    cell.gradeLabel.text = [item.grade uppercaseString];
    
    NSURL *userImageURL = [NSURL URLWithString:item.creator_img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
}

- (NSAttributedString *)commentStringForComment:(DAManagedComment *)comment
{
    NSAttributedString *cachedString = [self.attributedStringCache objectForKey:comment.comment];
    if( cachedString )
    {
        return cachedString;
    }
    
    NSAttributedString *commentString = [comment attributedCommentStringWithFont:[UIFont fontWithName:kHelveticaNeueLightFont size:14.0f]];
    
    [self.attributedStringCache setObject:commentString forKey:comment.comment];
    
    return commentString;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if( kind == UICollectionElementKindSectionHeader )
    {
        DAFeedHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"titleHeader" forIndexPath:indexPath];
        DAFeedItem *item = [self.feedItems objectAtIndex:indexPath.section];
        
        [header.titleButton setTitle:item.name forState:UIControlStateNormal];
        
        NSAttributedString *timeText = [item.created attributedTimeStringWithAttributes:nil];
        header.timeLabel.attributedText = timeText;
        
        header.indexPath = indexPath;
        header.delegate = self;
        
        reusableView = header;
    }
    else
    {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"loadingFooter" forIndexPath:indexPath];
    }
    
    reusableView.layer.shouldRasterize = YES;
    reusableView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if( section != self.feedItems.count - 1 )
    {
        return CGSizeZero;
    }
    
    return !self.hasMoreData ? CGSizeZero : CGSizeMake( self.collectionView.frame.size.width, 50 );
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = CGSizeZero;
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    eFeedCellType cellType = [self feedCellTypeForIndexPath:indexPath];
    
    if( cellType == eFeedCellTypeDish )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        
        itemSize = CGSizeMake( collectionView.frame.size.width, flowLayout.itemSize.height );
    }
    else if( cellType == eFeedCellTypeYums )
    {
        itemSize = CGSizeMake( collectionView.frame.size.width, 18 );
    }
    else if( cellType == eFeedCellTypeMoreComments )
    {
        itemSize = CGSizeMake( collectionView.frame.size.width, 18 );
    }
    else if( cellType == eFeedCellTypeHashtags || cellType == eFeedCellTypeComment )
    {
        static DAReviewDetailCollectionViewCell *sizingCell;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^
        {
            sizingCell = [DAReviewDetailCollectionViewCell sizingCell];
        });
        
        CGFloat textViewRightMargin = sizingCell.frame.size.width - ( sizingCell.textView.frame.origin.x + sizingCell.textView.frame.size.width );
        CGFloat textViewWidth = collectionView.frame.size.width - sizingCell.textView.frame.origin.x - textViewRightMargin;
        CGFloat textViewTopMargin = sizingCell.textView.frame.origin.y;
        CGFloat textViewBottomMargin = sizingCell.frame.size.height - ( sizingCell.textView.frame.origin.y + sizingCell.textView.frame.size.height );
        
        CGSize cellSize = CGSizeZero;
        cellSize.width = collectionView.frame.size.width;
        
        if( cellType == eFeedCellTypeHashtags )
        {
            NSAttributedString *hashtagString = [self hashtagStringForFeedItem:feedItem];
            
            sizingCell.textView.attributedText = hashtagString;
            CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
            CGSize stringSize = [sizingCell.textView sizeThatFits:boundingSize];
            
            CGFloat textViewHeight = ceilf( stringSize.height );
            
            CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
            cellSize.height = calculatedHeight;
            
            itemSize = cellSize;
        }
        else if( cellType == eFeedCellTypeComment )
        {
            NSUInteger commentIndex = [self commentIndexForIndexPath:indexPath];
            NSArray *comments = [self dateSortedArrayWithFeedComments:feedItem.comments];
            DAManagedComment *comment = comments[commentIndex];
            
            NSValue *cachedSize = [self.cellSizeCache objectForKey:comment.comment_id];
            if( cachedSize )
            {
                CGSize size = [cachedSize CGSizeValue];
                return size;
            }
            
            NSAttributedString *commentString = [self commentStringForComment:comment];
            sizingCell.textView.attributedText = commentString;
            CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
            CGSize stringSize = [sizingCell.textView sizeThatFits:boundingSize];
            
            CGFloat textViewHeight = ceilf( stringSize.height );
            
            CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
            cellSize.height = calculatedHeight;
            
            itemSize = cellSize;
            
            [self.cellSizeCache setObject:[NSValue valueWithCGSize:itemSize] forKey:comment.comment_id];
        }
    }
    else if( cellType == eFeedCellTypeButtons )
    {
        CGFloat height = feedItem.user_suggestion != nil ? 70.0 : 40.0;
        itemSize = CGSizeMake( collectionView.frame.size.width, height );
    }
    else if( cellType == eFeedCellTypeUserSuggestion )
    {
        itemSize = CGSizeMake( collectionView.frame.size.width, 175.0 );
    }
    
    return itemSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:section];
    
    if( feedItem.user_suggestion != nil )
    {
        return UIEdgeInsetsMake(0, 0, 40.0, 0);
    }
    else
    {
        return UIEdgeInsetsMake(0, 0, 25.0, 0);
    }
}

- (void)titleButtonTappedOnFeedHeaderCollectionReusableView:(DAFeedHeaderCollectionReusableView *)header
{
    NSIndexPath *indexPath = header.indexPath;
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    [self performSegueWithIdentifier:@"reviewDetails" sender:feedItem];
}

- (void)commentsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    [self pushCommentsViewWithFeedItem:feedItem showKeyboard:YES];
}

- (void)userImageTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self goToUserProfileAtIndexPath:indexPath];
}

- (void)creatorButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [self goToUserProfileAtIndexPath:indexPath];
}

- (void)goToUserProfileAtIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    [self pushUserProfileWithUsername:feedItem.creator_username];
}

- (void)moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    [self pushGlobalDishViewWithDishID:[feedItem.dish_id integerValue]];
}

- (void)textViewTappedOnText:(NSString *)text withTextType:(eLinkedTextType)textType inCell:(DAReviewDetailCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    eFeedCellType cellType = [self feedCellTypeForIndexPath:indexPath];
    
    if( cellType == eFeedCellTypeYums )
    {
        DAUserListViewController *userListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userList"];
        userListViewController.listContent = eUserListContentYums;
        userListViewController.object_id = [feedItem.item_id integerValue];
        
        [self.navigationController pushViewController:userListViewController animated:YES];
    }
    else if( cellType == eFeedCellTypeMoreComments )
    {
        [self pushCommentsViewWithFeedItem:feedItem showKeyboard:NO];
    }
    else if( cellType == eFeedCellTypeHashtags )
    {
        DAExploreDishResultsViewController *exploreResultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreResults"];
        exploreResultsViewController.searchTerm = text;
        exploreResultsViewController.selectedLocation = [DAExploreViewController storedLocation];
        exploreResultsViewController.selectedRadius = [DAExploreViewController storedRadius];
        [self.navigationController pushViewController:exploreResultsViewController animated:YES];
    }
    else if( cellType == eFeedCellTypeComment )
    {
        if( textType == eLinkedTextTypeHashtag )
        {
            DAExploreDishResultsViewController *exploreResultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreResults"];
            exploreResultsViewController.searchTerm = text;
            exploreResultsViewController.selectedLocation = [DAExploreViewController storedLocation];
            exploreResultsViewController.selectedRadius = [DAExploreViewController storedRadius];
            [self.navigationController pushViewController:exploreResultsViewController animated:YES];
        }
        else if( textType == eLinkedTextTypeUsername )
        {
            [self pushUserProfileWithUsername:text];
        }
    }
}

- (void)locationButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];

    [self pushRestaurantProfileWithLocationID:[feedItem.loc_id integerValue] username:feedItem.loc_name];
}

- (void)yumButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)imageDoubleTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
    
    UIImage *image = [UIImage imageNamed:@"yum_tap"];
    UIImageView *yumTapImageView = [[UIImageView alloc] initWithImage:image];
    
    CGSize imageSize = yumTapImageView.image.size;
    CGFloat x = ( self.view.frame.size.width  / 2 ) - ( imageSize.width  / 2 );
    CGFloat y = ( cell.dishImageView.frame.size.height / 2 ) - ( imageSize.height / 2 );
    CGFloat width  = imageSize.width;
    CGFloat height = imageSize.height;
    yumTapImageView.frame = CGRectMake( x, y, width, height );
    yumTapImageView.alpha = 1;
    
    [cell.dishImageView addSubview:yumTapImageView];
    
    yumTapImageView.transform = CGAffineTransformMakeScale( 0, 0 );
    
    [UIView animateWithDuration:0.3 animations:^
    {
        yumTapImageView.transform = CGAffineTransformMakeScale( 1, 1 );
    }
    completion:^( BOOL finished )
    {
        if( finished )
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                yumTapImageView.alpha = 0;
            }
            completion:^( BOOL finished )
            {
                if( ![feedItem.caller_yumd boolValue] )
                {
                    feedItem.caller_yumd = @(YES);
                    feedItem.num_yums = @([feedItem.num_yums integerValue] + 1);
                    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] animated:NO];
                }
                
                if( finished )
                {
                    [yumTapImageView removeFromSuperview];
                }
            }];
        }
    }];
    
    if( ![feedItem.caller_yumd boolValue] )
    {
        DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];
        NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
        BOOL hasUserSuggestion = feedItem.user_suggestion != nil;
        NSInteger section = hasUserSuggestion ? sectionItems - 2 : sectionItems - 1;
        
        NSIndexPath *buttonIndexPath = [NSIndexPath indexPathForItem:section inSection:indexPath.section];
        DAReviewButtonsCollectionViewCell *buttonCell = (DAReviewButtonsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:buttonIndexPath];
        [buttonCell setYummed];
        [self yumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
}

- (void)changeYumStatusForCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.feedItems objectAtIndex:indexPath.section];

    if( [feedItem.caller_yumd boolValue] )
    {
        [cell setUnyummed];
        feedItem.caller_yumd = @(NO);
        feedItem.num_yums = @([feedItem.num_yums integerValue] - 1);
        
        [self unyumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
    else
    {
        [cell setYummed];
        feedItem.caller_yumd = @(YES);
        feedItem.num_yums = @([feedItem.num_yums integerValue] + 1);
        
        [self yumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
    
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] animated:NO];
}

- (void)yumFeedItemWithReviewID:(NSInteger)reviewID
{
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    
    [[DAAPIManager sharedManager] POSTRequest:kYumReviewURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self yumFeedItemWithReviewID:reviewID];
        }
    }];
}

- (void)unyumFeedItemWithReviewID:(NSInteger)reviewID
{
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    
    [[DAAPIManager sharedManager] POSTRequest:kUnyumReviewURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self unyumFeedItemWithReviewID:reviewID];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if( [segue.identifier isEqualToString:@"reviewDetails"] )
    {
        DAFeedItem *feedItem = sender;
        
        DAReviewDetailsViewController *dest = segue.destinationViewController;
        dest.feedItem = feedItem;
    }
}

- (void)scrollFeedToTop
{
    [self.collectionView setContentOffset:CGPointMake( 0, -self.collectionView.contentInset.top ) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollPosition = scrollView.contentOffset.y + scrollView.contentInset.top;
    self.refreshControl.hidden = scrollPosition > 0 && ![self.refreshControl isRefreshing] ? YES : NO;
    
    [self.refreshControl containingScrollViewDidScroll:scrollView];
    
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - statusBarHeight - 1;
    CGFloat framePercentageHidden = ( ( statusBarHeight - frame.origin.y ) / ( frame.size.height - 1 ) );
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    CGFloat scrollHeight = scrollView.frame.size.height;
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.bottom;
    
    if( scrollOffset <= -scrollView.contentInset.top )
    {
        frame.origin.y = 20;
    }
    else if( ( scrollOffset + scrollHeight ) >= scrollContentSizeHeight )
    {
        frame.origin.y = -size;
    }
    else
    {
        frame.origin.y = MIN( 20, MAX( -size, frame.origin.y - scrollDiff ) );
    }
        
    [self.navigationController.navigationBar setFrame:frame];
    [self updateNavigationBarToAlpha:( 1 - framePercentageHidden )];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshControl containingScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if( self.hasMoreData && !self.isLoadingMore && bottomEdge >= scrollView.contentSize.height )
    {
        [self loadMore];
    }
}

- (void)updateNavigationBarToAlpha:(CGFloat)alpha
{
    self.navigationItem.titleView.alpha = alpha;
    self.navigationController.navigationBar.tintColor = [self.navigationController.navigationBar.tintColor colorWithAlphaComponent:alpha];
}

- (void)animateNavBarTo:(CGFloat)y
{    
    [UIView animateWithDuration:0.2 animations:^
    {
        CGRect frame = self.navigationController.navigationBar.frame;
        CGFloat alpha = (frame.origin.y >= y ? 0 : 1);
        frame.origin.y = y;
        [self.navigationController.navigationBar setFrame:frame];
        [self updateNavigationBarToAlpha:alpha];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self resetNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self resetNavigationBar];
}

- (void)resetNavigationBar
{
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = 20;
    [self.navigationController.navigationBar setFrame:frame];
    [self updateNavigationBarToAlpha:1.0f];
}

@end