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
#import "UILabel+Dished.h"
#import "DAFeedImportManager.h"
#import "DARefreshControl.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"


@interface DAFeedViewController() <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSArray                    *items;
@property (strong, nonatomic) NSMutableArray             *changes;
@property (strong, nonatomic) DARefreshControl           *refreshControl;
@property (strong, nonatomic) DAFeedImportManager        *importer;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BOOL      hasMoreData;
@property (nonatomic) BOOL      isLoadingMore;
@property (nonatomic) CGFloat   previousScrollViewYOffset;

@end


@implementation DAFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasMoreData   = YES;
    self.isLoadingMore = NO;
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_black_nav"]];
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
    CGFloat refreshControlWidth  = self.collectionView.bounds.size.width;
    CGRect refreshControlRect = CGRectMake( 0, -refreshControlHeight, refreshControlWidth, refreshControlHeight );
    self.refreshControl = [[DARefreshControl alloc] initWithFrame:refreshControlRect];
    [self.refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
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
    
    return feedCell;
}

- (void)configureCell:(DAFeedCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DAFeedItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSString *usernameString = [NSString stringWithFormat:@"@%@", item.creator_username];
    [cell.creatorButton  setTitle:usernameString forState:UIControlStateNormal];
    [cell.titleButton    setTitle:item.name      forState:UIControlStateNormal];
    
    UIImage *locationIcon = [[UIImage imageNamed:@"feed_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [cell.locationButton setTitle:item.loc_name forState:UIControlStateNormal];
    [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
    [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
    
    NSURL *dishImageURL = [NSURL URLWithString:item.img];
    [cell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    cell.gradeLabel.text = [item.grade uppercaseString];
    
    [cell.timeLabel setAttributedTextForFeedItemDate:item.created];
    
    cell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    NSString *commentString = [NSString stringWithFormat:@"%d comments", [item.num_comments intValue]];
    [cell.commentsButton setTitle:commentString forState:UIControlStateNormal];
    
    cell.userImageView.image = [UIImage imageNamed:@"avatar"];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"loadingFooter" forIndexPath:indexPath];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if( !self.hasMoreData )
    {
        return CGSizeZero;
    }
    else
    {
        return CGSizeMake( self.collectionView.frame.size.width, 50 );
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
    [self updateBarButtonItems:(1 - framePercentageHidden)];
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

- (void)updateBarButtonItems:(CGFloat)alpha
{
    [self.navigationItem.leftBarButtonItems enumerateObjectsUsingBlock:^( UIBarButtonItem* item, NSUInteger i, BOOL *stop )
    {
        item.customView.alpha = alpha;
    }];
    
    [self.navigationItem.rightBarButtonItems enumerateObjectsUsingBlock:^( UIBarButtonItem* item, NSUInteger i, BOOL *stop )
    {
        item.customView.alpha = alpha;
    }];
    
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
        [self updateBarButtonItems:alpha];
    }];
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
    [self updateBarButtonItems:1.0f];
}

@end