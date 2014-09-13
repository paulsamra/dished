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


@interface DAFeedViewController() <NSFetchedResultsControllerDelegate, DAFeedCollectionViewCellDelegate>

@property (strong, nonatomic) NSCache                    *mainImageCache;
@property (strong, nonatomic) NSMutableArray             *changes;
@property (strong, nonatomic) DARefreshControl           *refreshControl;
@property (strong, nonatomic) DAFeedImportManager        *importer;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BOOL    hasMoreData;
@property (nonatomic) BOOL    isLoadingMore;
@property (nonatomic) CGFloat previousScrollViewYOffset;

@end


@implementation DAFeedViewController

- (void)viewDidLoad
{	
    [super viewDidLoad];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:kNetworkReachableKey object:nil];
    
    CGFloat refreshControlHeight = 40.0f;
    CGFloat refreshControlWidth  = self.view.bounds.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.refreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isLoadingMore = NO;
}

- (void)refreshFeed
{
    NSInteger limit = self.fetchedResultsController.fetchRequest.fetchLimit;
    
    [self.importer importFeedItemsWithLimit:limit offset:0 completion:^( BOOL success, BOOL hasMoreData )
    {
        [self.refreshControl endRefreshing];
        
        self.hasMoreData = hasMoreData;
        [self.collectionView reloadData];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> resultsSection = self.fetchedResultsController.sections[section];
    return resultsSection.numberOfObjects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAFeedCollectionViewCell *feedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
    
    [self configureCell:feedCell atIndexPath:indexPath];
    feedCell.delegate = self;
    
    return feedCell;
}

- (void)configureCell:(DAFeedCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", item.creator_username];
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
        cell.timeLabel.attributedText = [DAFeedCollectionViewCell attributedTimeStringWithDate:item.created];
    }
    
    cell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    NSString *commentString = [NSString stringWithFormat:@"%d comments", [item.num_comments intValue]];
    [cell.commentsButton setTitle:commentString forState:UIControlStateNormal];
    
    NSURL *userImageURL = [NSURL URLWithString:item.creator_img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    if( [item.caller_yumd boolValue] )
    {
        [self yumCell:cell];
    }
    else
    {
        [self unyumCell:cell];
    }
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
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"loadingFooter" forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return !self.hasMoreData ? CGSizeZero : CGSizeMake( self.collectionView.frame.size.width, 50 );
}

- (void)commentButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"commentsSegue" sender:feedItem];
}

- (void)titleButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self performSegueWithIdentifier:@"reviewDetails" sender:feedItem];
}

- (void)yumButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)imageDoubleTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)changeYumStatusForCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if( [feedItem.caller_yumd boolValue] )
    {
        [self unyumCell:cell];
        feedItem.caller_yumd = @(NO);
        
        [[DAAPIManager sharedManager] unyumReviewID:[feedItem.item_id integerValue] completion:^( BOOL success )
        {
            if( success )
            {
                [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:nil];
            }
        }];
    }
    else
    {
        [self yumCell:cell];
        feedItem.caller_yumd = @(YES);
        
        [[DAAPIManager sharedManager] yumReviewID:[feedItem.item_id integerValue] completion:^( BOOL success )
        {
            if( success )
            {
                [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:nil];
            }
        }];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.changes = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    
    switch( type )
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
            
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
            
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    
    [self.changes addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{    
    [self.collectionView performBatchUpdates:^
    {
        for( NSDictionary *change in self.changes )
        {
            [change enumerateKeysAndObjectsUsingBlock:^( id key, id obj, BOOL *stop )
            {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                
                switch( type )
                {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                        
                    case NSFetchedResultsChangeMove:
                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                        break;
                }
            }];
        }
    }
    completion:^( BOOL finished )
    {
        self.changes = nil;
    }];
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
        dest.reviewID = [feedItem.item_id integerValue];
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
    
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat size = frame.size.height - 21;
    CGFloat framePercentageHidden = ( ( 20 - frame.origin.y ) / ( frame.size.height - 1 ) );
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
    [self updateNavigationBarToAlpha:(1 - framePercentageHidden)];
    self.previousScrollViewYOffset = scrollOffset;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.refreshControl containingScrollViewDidEndDragging:scrollView];
    
    if( !decelerate )
    {
        [self stoppedScrolling];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if( self.hasMoreData && !self.isLoadingMore && bottomEdge >= scrollView.contentSize.height )
    {
        [self loadMore];
    }
    
    [self stoppedScrolling];
}

- (void)stoppedScrolling
{
    CGRect frame = self.navigationController.navigationBar.frame;
    if( frame.origin.y < 20 )
    {
        [self animateNavBarTo:-( frame.size.height - 21 )];
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