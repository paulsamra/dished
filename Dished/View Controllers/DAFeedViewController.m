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
#import "DAAPIManager.h"
#import "DACoreDataManager.h"
#import "DAFeedImportManager.h"
#import "DARefreshControl.h"
#import "DAReviewDetailsViewController.h"
#import "DACommentsViewController.h"
#import "DAGlobalDishDetailViewController.h"
#import "UIImageView+DishProgress.h"
#import "DAFeedCollectionViewFlowLayout.h"
#import "NSAttributedString+Dished.h"
#import "DAFeedHeaderCollectionReusableView.h"
#import "DAReviewDetailCollectionViewCell.h"


@interface DAFeedViewController() <NSFetchedResultsControllerDelegate, DAFeedCollectionViewCellDelegate, DAFeedHeaderCollectionReusableViewDelegate>

@property (strong, nonatomic) NSCache                          *mainImageCache;
@property (strong, nonatomic) UIImageView                      *yumTapImageView;
@property (strong, nonatomic) NSMutableArray                   *sectionChanges;
@property (strong, nonatomic) NSMutableArray                   *itemChanges;
@property (strong, nonatomic) DARefreshControl                 *refreshControl;
@property (strong, nonatomic) DAFeedImportManager              *importer;
@property (strong, nonatomic) NSFetchedResultsController       *fetchedResultsController;

@property (nonatomic) BOOL    hasMoreData;
@property (nonatomic) BOOL    isLoadingMore;
@property (nonatomic) CGFloat previousScrollViewYOffset;

@end


@implementation DAFeedViewController

- (void)viewDidLoad
{	
    [super viewDidLoad];
    
    [self setupRefreshControl];
    
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
    self.fetchedResultsController = [self.importer fetchFeedItemsWithLimit:10];
    self.fetchedResultsController.delegate = self;
    
    if( self.fetchedResultsController.fetchedObjects.count > 0 )
    {
        [spinner stopAnimating];
        self.collectionView.hidden = NO;
    }
    
    [self.importer importFeedItemsWithLimit:10 offset:0 completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;
        
        if( success )
        {
            self.collectionView.hidden = NO;
            [spinner stopAnimating];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isLoadingMore = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:kNetworkReachableKey object:nil];
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

- (void)refreshFeed
{
    NSInteger limit = self.fetchedResultsController.fetchRequest.fetchLimit;
    
    [self.importer importFeedItemsWithLimit:limit offset:0 completion:^( BOOL success, BOOL hasMoreData )
    {
        [self.refreshControl endRefreshing];
        
        self.hasMoreData = hasMoreData;
    }];
}

- (void)loadMore
{
    self.isLoadingMore = YES;
    
    NSInteger offset = self.fetchedResultsController.fetchRequest.fetchLimit;
    
    [self.importer importFeedItemsWithLimit:10 offset:offset completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;
        
        if( success )
        {
            self.isLoadingMore = NO;
            
            self.fetchedResultsController.fetchRequest.fetchLimit += 10;
            [self.fetchedResultsController performFetch:nil];
            self.fetchedResultsController.delegate = self;
        }
    }];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> resultsSection = self.fetchedResultsController.sections[section];
    NSInteger numberOfObjects = resultsSection.numberOfObjects;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return numberOfObjects + [feedItem.comments count] + 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
    
    if( indexPath.row == 0 )
    {
        DAFeedCollectionViewCell *feedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        [self configureCell:feedCell atIndexPath:indexPath];
        feedCell.delegate = self;
        
        cell = feedCell;
    }
    else if( indexPath.row > 0 && indexPath.row < sectionItems - 1 )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"commentCell" forIndexPath:indexPath];
        
        NSIndexPath *feedItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:feedItemIndexPath];
        
        NSArray *comments = [self dateSortedArrayWithFeedComments:feedItem.comments];
        DAFeedComment *comment = comments[indexPath.row - 1];
        
        commentCell.imageView.hidden = indexPath.row - 1 == 0 ? NO : YES;
        commentCell.detailTextView.attributedText = [self commentStringForComment:comment];
        
        cell = commentCell;
    }
    else if( indexPath.row == sectionItems - 1 )
    {
        DAFeedCollectionViewCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"buttonCell" forIndexPath:indexPath];
        
        NSIndexPath *feedItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:feedItemIndexPath];
        
        NSString *commentString = [NSString stringWithFormat:@"%d comments", [feedItem.num_comments intValue]];
        [buttonCell.commentsButton setTitle:commentString forState:UIControlStateNormal];
        
        [feedItem.caller_yumd boolValue] ? [self yumCell:buttonCell] : [self unyumCell:buttonCell];
        
        buttonCell.delegate = self;
        
        cell = buttonCell;
    }
    
    return cell;
}

- (NSArray *)dateSortedArrayWithFeedComments:(NSSet *)comments
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    NSArray *sortDescriptors = @[ sortDescriptor ];
    
    return [comments sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)configureCell:(DAFeedCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", item.creator_username];
    if( [item.creator_type isEqualToString:@"influencer"] )
    {
        usernameString = [NSString stringWithFormat:@" %@", usernameString];
        [cell.creatorButton setImage:[UIImage imageNamed:@"influencer"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.creatorButton setImage:nil forState:UIControlStateNormal];
    }
    
    [cell.creatorButton  setTitle:usernameString forState:UIControlStateNormal];
    [cell.titleButton    setTitle:item.name      forState:UIControlStateNormal];
    
    UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [cell.locationButton setTitle:item.loc_name forState:UIControlStateNormal];
    [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
    [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
    
    UIImage *image = [self.mainImageCache objectForKey:item.img];
    if( image )
    {
        [cell.dishImageView removeProgressView];
        cell.dishImageView.image = image;
    }
    else
    {
        cell.dishImageView.image = nil;
        NSURL *dishImageURL = [NSURL URLWithString:item.img];
        [cell.dishImageView setImageUsingProgressViewWithURL:dishImageURL placeholderImage:nil
        completion:^( UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL )
        {
            if( image )
            {
                [self.mainImageCache setObject:image forKey:item.img];
            }
        }];
    }
    
    cell.gradeLabel.text = [item.grade uppercaseString];
    
    if( item.created )
    {
        cell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:item.created];
    }
    
    NSURL *userImageURL = [NSURL URLWithString:item.creator_img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
}

- (NSAttributedString *)commentStringForComment:(DAFeedComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSDictionary *attributes = [DAReviewDetailCollectionViewCell linkedTextAttributes];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:attributes];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        
        [labelString appendAttributedString:influencerIconString];
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:comment.comment attributes:[DAReviewDetailCollectionViewCell textAttributes]]];
    
    return labelString;
}

- (void)yumCell:(DAFeedCollectionViewCell *)cell
{
    [cell.yumButton setBackgroundImage:[UIImage imageNamed:@"yum_button_background"] forState:UIControlStateNormal];
    [cell.yumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)unyumCell:(DAFeedCollectionViewCell *)cell
{
    [cell.yumButton setBackgroundImage:[UIImage imageNamed:@"unyum_button_background"] forState:UIControlStateNormal];
    [cell.yumButton setTitleColor:[UIColor commentButtonTextColor] forState:UIControlStateNormal];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if( kind == UICollectionElementKindSectionHeader )
    {
        DAFeedHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"titleHeader" forIndexPath:indexPath];
        DAFeedItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        [header.titleButton setTitle:item.name forState:UIControlStateNormal];
        
        if( item.created )
        {
            header.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:item.created];
        }
        
        header.indexPath = indexPath;
        header.delegate = self;
        
        reusableView = header;
    }
    else
    {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"loadingFooter" forIndexPath:indexPath];
    }
    
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if( section != self.fetchedResultsController.sections.count - 1 )
    {
        return CGSizeZero;
    }
    
    return !self.hasMoreData ? CGSizeZero : CGSizeMake( self.collectionView.frame.size.width, 50 );
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize itemSize = CGSizeZero;
    NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
    
    if( indexPath.row == 0 )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        
        itemSize = CGSizeMake( collectionView.frame.size.width, flowLayout.itemSize.height );
    }
    else if( indexPath.row > 0 && indexPath.row < sectionItems - 1 )
    {
        NSIndexPath *feedItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        
        DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:feedItemIndexPath];
        NSArray *comments = [self dateSortedArrayWithFeedComments:feedItem.comments];
        DAFeedComment *comment = comments[indexPath.row - 1];
        
        CGSize cellSize = CGSizeZero;
        CGFloat textViewWidth = collectionView.frame.size.width - 38;
        cellSize.width = collectionView.frame.size.width;
        
        NSAttributedString *commentString = [self commentStringForComment:comment];
        
        CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
        CGRect stringRect   = [commentString boundingRectWithSize:boundingSize
                                                          options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                                          context:nil];
        
        CGFloat textViewHeight = ceilf( stringRect.size.height ) + 1;
        cellSize.height += textViewHeight;
        
        itemSize = cellSize;
    }
    else if( indexPath.row == sectionItems - 1 )
    {
        itemSize = CGSizeMake( collectionView.frame.size.width, 65 );
    }
    
    return itemSize;
}

- (void)titleButtonTappedOnFeedHeaderCollectionReusableView:(DAFeedHeaderCollectionReusableView *)header
{
    NSIndexPath *indexPath = header.indexPath;
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"reviewDetails" sender:feedItem];
}

- (void)commentButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
    
    [self performSegueWithIdentifier:@"commentsSegue" sender:feedItem];
}

- (void)yumButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)imageDoubleTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if( !self.yumTapImageView )
    {
        UIImage *image = [UIImage imageNamed:@"yum_tap"];
        self.yumTapImageView = [[UIImageView alloc] initWithImage:image];
    }
    
    CGSize imageSize = self.yumTapImageView.image.size;
    CGFloat x = ( self.view.frame.size.width  / 2 ) - ( imageSize.width  / 2 );
    CGFloat y = ( cell.dishImageView.frame.size.height / 2 ) - ( imageSize.height / 2 );
    CGFloat width  = imageSize.width;
    CGFloat height = imageSize.height;
    self.yumTapImageView.frame = CGRectMake( x, y, width, height );
    self.yumTapImageView.alpha = 1;
    
    [cell.dishImageView addSubview:self.yumTapImageView];
    
    self.yumTapImageView.transform = CGAffineTransformMakeScale( 0, 0 );
    
    [UIView animateWithDuration:0.3 animations:^
    {
        self.yumTapImageView.transform = CGAffineTransformMakeScale( 1, 1 );
    }
    completion:^( BOOL finished )
    {
        if( finished )
        {
            [UIView animateWithDuration:0.3 animations:^
            {
                self.yumTapImageView.alpha = 0;
            }
            completion:^( BOOL finished )
            {
                feedItem.caller_yumd = @(YES);
                
                if( finished )
                {
                    [self.yumTapImageView removeFromSuperview];
                }
            }];
        }
    }];
    
    if( ![feedItem.caller_yumd boolValue] )
    {
        NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
        NSIndexPath *buttonIndexPath = [NSIndexPath indexPathForItem:sectionItems - 1 inSection:indexPath.section];
        DAFeedCollectionViewCell *buttonCell = (DAFeedCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:buttonIndexPath];
        [self yumCell:buttonCell];
        [self yumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
}

- (void)changeYumStatusForCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
    
    if( [feedItem.caller_yumd boolValue] )
    {
        [self unyumCell:cell];
        feedItem.caller_yumd = @(NO);
        
        [self unyumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
    else
    {
        [self yumCell:cell];
        feedItem.caller_yumd = @(YES);
        
        [self yumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
}

- (void)yumFeedItemWithReviewID:(NSInteger)reviewID
{
    [[DAAPIManager sharedManager] yumReviewID:reviewID completion:^( BOOL success )
    {
        if( success )
        {
            [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:nil];
        }
        else
        {
            [self.collectionView reloadData];
        }
    }];
}

- (void)unyumFeedItemWithReviewID:(NSInteger)reviewID
{
    [[DAAPIManager sharedManager] unyumReviewID:reviewID completion:^( BOOL success )
    {
        if( success )
        {
            [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:nil];
        }
        else
        {
            [self.collectionView reloadData];
        }
    }];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"commentsSegue"] )
    {
        DAFeedItem *feedItem = sender;
        
        DACommentsViewController *dest = segue.destinationViewController;
        dest.reviewID = [feedItem.item_id integerValue];
        
        return;
    }
    
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
    self.refreshControl.hidden = scrollPosition > 0 ? YES : NO;
    
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
    
    if( ![self.refreshControl isRefreshing] )
    {
        
    }
    
    [self.navigationController.navigationBar setFrame:frame];
    [self updateNavigationBarToAlpha:(1 - framePercentageHidden)];
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
    [self resetNavigationBar];
    
    [super viewDidDisappear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resetNavigationBar];
    
    [super viewWillDisappear:animated];
}

- (void)resetNavigationBar
{
    CGRect frame = self.navigationController.navigationBar.frame;
    frame.origin.y = 20;
    [self.navigationController.navigationBar setFrame:frame];
    [self updateNavigationBarToAlpha:1.0f];
}

- (NSCache *)mainImageCache
{
    if( !_mainImageCache )
    {
        _mainImageCache = [[NSCache alloc] init];
        [_mainImageCache setName:@"maincache"];
    }
    
    return _mainImageCache;
}

@end