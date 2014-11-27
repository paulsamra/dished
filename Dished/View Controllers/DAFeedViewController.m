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
#import "DAUserProfileViewController.h"
#import "DAReviewDetailsViewController.h"
#import "DACommentsViewController.h"
#import "DAGlobalDishDetailViewController.h"
#import "UIImageView+DishProgress.h"
#import "DAUserListViewController.h"
#import "DAFeedCollectionViewFlowLayout.h"
#import "NSAttributedString+Dished.h"
#import "DAFeedHeaderCollectionReusableView.h"
#import "DAReviewDetailCollectionViewCell.h"
#import "DAReviewButtonsCollectionViewCell.h"
#import "DAExploreDishResultsViewController.h"

static NSString *const kReviewDetailCellIdentifier  = @"reviewDetailCell";
static NSString *const kReviewButtonsCellIdentifier = @"reviewButtonsCell";


@interface DAFeedViewController() <NSFetchedResultsControllerDelegate, DAFeedCollectionViewCellDelegate, DAFeedHeaderCollectionReusableViewDelegate, DAReviewButtonsCollectionViewCellDelegate, DAReviewDetailCollectionViewCellDelegate>

@property (strong, nonatomic) NSCache                          *feedImageCache;
@property (strong, nonatomic) UIImageView                      *yumTapImageView;
@property (strong, nonatomic) NSMutableArray                   *sectionChanges;
@property (strong, nonatomic) NSMutableArray                   *itemChanges;
@property (strong, nonatomic) DARefreshControl                 *refreshControl;
@property (strong, nonatomic) DAFeedImportManager              *importer;
@property (strong, nonatomic) NSFetchedResultsController       *fetchedResultsController;

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
    
    self.initialLoadActive = YES;
    [self.importer importFeedItemsWithLimit:10 offset:0 completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;
        self.initialLoadActive = NO;
        [self.refreshControl endRefreshing];
        
        self.collectionView.hidden = NO;
        [spinner stopAnimating];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.initialLoadActive && ![self.refreshControl isRefreshing] )
    {
        [self.refreshControl startRefreshing];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isLoadingMore = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFeed) name:kNetworkReachableKey object:nil];
}

- (void)registerCollectionViewCellNibs
{
    UINib *reviewDetailCellNib = [UINib nibWithNibName:NSStringFromClass( [DAReviewDetailCollectionViewCell class] ) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:reviewDetailCellNib forCellWithReuseIdentifier:kReviewDetailCellIdentifier];
    
    UINib *reviewButtonsCellNib = [UINib nibWithNibName:NSStringFromClass( [DAReviewButtonsCollectionViewCell class] ) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:reviewButtonsCellNib forCellWithReuseIdentifier:kReviewButtonsCellIdentifier];
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
    self.fetchedResultsController.fetchRequest.fetchLimit += 10;
    
    [self.importer importFeedItemsWithLimit:10 offset:offset completion:^( BOOL success, BOOL hasMoreData )
    {
        self.hasMoreData = hasMoreData;
        
        if( success )
        {
            self.isLoadingMore = NO;
        }
    }];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> resultsSection = self.fetchedResultsController.sections[section];
    NSInteger numberOfObjects = resultsSection.numberOfObjects;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return numberOfObjects + [feedItem.comments count] + ( [feedItem.num_yums integerValue] > 0 ? 2 : 1 ) + ( [feedItem.num_comments integerValue] > 3 ? 1 : 0 );
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger numberOfSections = self.fetchedResultsController.sections.count;
    
    NSLog(@"%d", (int)numberOfSections);
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
    NSIndexPath *feedItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:feedItemIndexPath];
    NSInteger num_yums = [feedItem.num_yums integerValue];
    
    if( indexPath.row == 0 )
    {
        DAFeedCollectionViewCell *feedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        [feedCell layoutIfNeeded];
        [self configureCell:feedCell atIndexPath:indexPath];
        feedCell.delegate = self;
        
        cell = feedCell;
    }
    else if( num_yums > 0 && indexPath.row == 1 )
    {
        DAReviewDetailCollectionViewCell *yumCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        yumCell.iconImageView.image = [UIImage imageNamed:@"yum_icon"];
        
        NSString *yumsString = [NSString stringWithFormat:@"%d YUMs", (int)[feedItem.num_yums integerValue]];
        yumCell.textView.attributedText = [[NSAttributedString alloc] initWithString:yumsString attributes:[DAReviewDetailCollectionViewCell linkedTextAttributes]];
        
        yumCell.delegate = self;
        
        cell = yumCell;
    }
    else if( indexPath.row > ( num_yums > 0 ? 1 : 0 ) && indexPath.row < sectionItems - 1 )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        if( [feedItem.num_comments integerValue] > 3 && indexPath.row == ( num_yums > 0 ? 2 : 1 ) + 1 )
        {
            commentCell.iconImageView.hidden = YES;
            
            NSString *commentString = [NSString stringWithFormat:@"View all %d comments...", [feedItem.num_comments intValue] - 1];
            commentCell.textView.attributedText = [[NSAttributedString alloc] initWithString:commentString attributes:[DAReviewDetailCollectionViewCell linkedTextAttributes]];
            
            commentCell.delegate = self;
            
            cell = commentCell;
        }
        else
        {
            NSInteger commentIndex = indexPath.row - ( num_yums > 0 ? 2 : 1 );
            commentIndex = [feedItem.num_comments integerValue] > 3 && commentIndex > 0 ? commentIndex - 1 : commentIndex;
            NSArray *comments = [self dateSortedArrayWithFeedComments:feedItem.comments];
            DAManagedComment *comment = comments[commentIndex];
            
            commentCell.iconImageView.image = [UIImage imageNamed:@"comments_icon"];
            
            commentCell.iconImageView.hidden = indexPath.row - ( num_yums > 0 ? 2 : 1 ) == 0 ? NO : YES;
            
            NSAttributedString *commentString = [self commentStringForComment:comment];
            NSMutableArray *usernameMentions = [NSMutableArray array];
            [usernameMentions addObject:comment.creator_username];
            
            for( DAManagedUsername *managedUsername in comment.usernames )
            {
                [usernameMentions addObject:managedUsername.username];
            }
            
            [commentCell.textView setAttributedText:commentString withAttributes:[NSAttributedString linkedTextAttributesWithFontSize:14.0f] delimiter:nil knownUsernames:usernameMentions];
            
            commentCell.delegate = self;
            
            cell = commentCell;
        }
    }
    else if( indexPath.row == sectionItems - 1 )
    {
        DAReviewButtonsCollectionViewCell *buttonCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewButtonsCellIdentifier forIndexPath:indexPath];
        
        NSIndexPath *feedItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
        DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:feedItemIndexPath];
        
        NSInteger numComments = [feedItem.num_comments intValue] - 1;
        NSString *format = numComments == 0 ? @" No comments" : numComments == 1 ? @" %d comment" : @" %d comments";
        NSString *commentString = [NSString stringWithFormat:format, numComments];
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
    
    UIImage *image = [self.feedImageCache objectForKey:item.img];
    if( image )
    {
        [cell.dishImageView removeProgressView];
        cell.dishImageView.image = image;
    }
    else
    {
        cell.dishImageView.image = nil;
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
    
    if( item.created )
    {
        cell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:item.created];
    }
    
    NSURL *userImageURL = [NSURL URLWithString:item.creator_img_thumb];
    [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
}

- (NSAttributedString *)commentStringForComment:(DAManagedComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSDictionary *attributes = [DAReviewDetailCollectionViewCell linkedTextAttributes];
    NSAttributedString *attributedUsername = [[NSAttributedString alloc] initWithString:usernameString attributes:attributes];
    NSMutableAttributedString *labelString = [attributedUsername mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [labelString appendAttributedString:influencerIconString];
    }
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:comment.comment attributes:[DAReviewDetailCollectionViewCell textAttributes]];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:commentString];
    
    return labelString;
}

- (void)yumCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [cell.yumButton setBackgroundImage:[UIImage imageNamed:@"yum_button_background"] forState:UIControlStateNormal];
    [cell.yumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)unyumCell:(DAReviewButtonsCollectionViewCell *)cell
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
    NSIndexPath *feedItemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:feedItemIndexPath];
    NSInteger num_yums = [feedItem.num_yums integerValue];
    
    if( indexPath.row == 0 )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        
        itemSize = CGSizeMake( collectionView.frame.size.width, flowLayout.itemSize.height );
    }
    else if( num_yums > 0 && indexPath.row == 1 )
    {
        itemSize = CGSizeMake( collectionView.frame.size.width, 18 );
    }
    else if( indexPath.row > ( num_yums > 0 ? 1 : 0 ) && indexPath.row < sectionItems - 1 )
    {
        if( [feedItem.num_comments integerValue] > 3 && indexPath.row == ( num_yums > 0 ? 2 : 1 ) + 1 )
        {
            itemSize = CGSizeMake( collectionView.frame.size.width, 18 );
        }
        else
        {
            NSInteger commentIndex = indexPath.row - ( num_yums > 0 ? 2 : 1 );
            commentIndex = [feedItem.num_comments integerValue] > 3 && commentIndex > 0 ? commentIndex - 1 : commentIndex;
            NSArray *comments = [self dateSortedArrayWithFeedComments:feedItem.comments];
            DAManagedComment *comment = comments[commentIndex];
            
            static DAReviewDetailCollectionViewCell *sizingCell;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^
            {
                 sizingCell = [DAReviewDetailCollectionViewCell sizingCell];
            });
            
            CGFloat textViewRightMargin = sizingCell.frame.size.width - ( sizingCell.textView.frame.origin.x + sizingCell.textView.frame.size.width );
            CGFloat textViewWidth = collectionView.frame.size.width - sizingCell.textView.frame.origin.x - textViewRightMargin;
            
            CGSize cellSize = CGSizeZero;
            cellSize.width = collectionView.frame.size.width;
            
            NSAttributedString *commentString = [self commentStringForComment:comment];
            sizingCell.textView.attributedText = commentString;
            CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
            CGSize stringSize = [sizingCell.textView sizeThatFits:boundingSize];
            
            CGFloat textViewTopMargin = sizingCell.textView.frame.origin.y;
            CGFloat textViewBottomMargin = sizingCell.frame.size.height - ( sizingCell.textView.frame.origin.y + sizingCell.textView.frame.size.height );
            CGFloat textViewHeight = ceilf( stringSize.height );
            
            CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
            cellSize.height = calculatedHeight;
            
            itemSize = cellSize;
        }
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

- (void)commentsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
    
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
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self pushUserProfileWithUsername:feedItem.creator_username];
}

- (void)moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
    
    [self pushGlobalDishWithDishID:[feedItem.dish_id integerValue]];
}

- (void)textViewTappedAtCharacterIndex:(NSUInteger)characterIndex inCell:(DAReviewDetailCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
    NSInteger num_yums = [feedItem.num_yums integerValue];
    
    if( num_yums > 0 && indexPath.row == 1 )
    {
        DAUserListViewController *userListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userList"];
        userListViewController.listContent = eUserListContentYums;
        userListViewController.object_id = [feedItem.item_id integerValue];
        
        [self.navigationController pushViewController:userListViewController animated:YES];
    }
    else if( indexPath.row > ( num_yums > 0 ? 1 : 0 ) && indexPath.row < sectionItems - 1 )
    {
        if( [feedItem.num_comments integerValue] > 3 && indexPath.row == ( num_yums > 0 ? 2 : 1 ) + 1 )
        {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
            DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
            
            [self pushCommentsViewWithFeedItem:feedItem showKeyboard:NO];
        }
        else
        {
            eLinkedTextType linkedTextType = [cell.textView linkedTextTypeForCharacterAtIndex:characterIndex];
            
            if( linkedTextType == eLinkedTextTypeHashtag )
            {
                DAExploreDishResultsViewController *exploreResultsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreResults"];
                exploreResultsViewController.searchTerm = [cell.textView linkedTextForCharacterAtIndex:characterIndex];
                [self.navigationController pushViewController:exploreResultsViewController animated:YES];
            }
            else if( linkedTextType == eLinkedTextTypeUsername )
            {
                NSString *username = [cell.textView linkedTextForCharacterAtIndex:characterIndex];
                
                [self pushUserProfileWithUsername:username];
            }
        }
    }
}

- (void)locationButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [self pushRestaurantProfileWithLocationID:[feedItem.loc_id integerValue] username:feedItem.loc_name];
}

- (void)yumButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)imageDoubleTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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
        NSInteger sectionItems = [self numberOfItemsInSection:indexPath.section];
        NSIndexPath *buttonIndexPath = [NSIndexPath indexPathForItem:sectionItems - 1 inSection:indexPath.section];
        DAReviewButtonsCollectionViewCell *buttonCell = (DAReviewButtonsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:buttonIndexPath];
        [self yumCell:buttonCell];
        [self yumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
}

- (void)changeYumStatusForCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.section];
    DAFeedItem *feedItem = [self.fetchedResultsController objectAtIndexPath:itemIndexPath];
    
    if( [feedItem.caller_yumd boolValue] )
    {
        [self unyumCell:cell];
        feedItem.caller_yumd = @(NO);
        feedItem.num_yums = @([feedItem.num_yums integerValue] - 1);
        
        [self unyumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
    else
    {
        [self yumCell:cell];
        feedItem.caller_yumd = @(YES);
        feedItem.num_yums = @([feedItem.num_yums integerValue] + 1);
        
        [self yumFeedItemWithReviewID:[feedItem.item_id integerValue]];
    }
}

- (void)yumFeedItemWithReviewID:(NSInteger)reviewID
{
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    [[DAAPIManager sharedManager] POST:kYumReviewURL parameters:parameters success:nil
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^
            {
                [self yumFeedItemWithReviewID:reviewID];
            }];
        }
    }];
}

- (void)unyumFeedItemWithReviewID:(NSInteger)reviewID
{
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    [[DAAPIManager sharedManager] POST:kUnyumReviewURL parameters:parameters success:nil
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^
            {
                [self unyumFeedItemWithReviewID:reviewID];
            }];
        }
    }];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.itemChanges    = [[NSMutableArray alloc] init];
    self.sectionChanges = [[NSMutableArray alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [self.sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    
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
    
    [self.itemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [UIView animateWithDuration:0 animations:^
    {
        [self.collectionView performBatchUpdates:^
        {
            for( NSDictionary *change in self.sectionChanges )
            {
                [change enumerateKeysAndObjectsUsingBlock:^( id key, id obj, BOOL *stop )
                {
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    
                    switch( type )
                    {
                        case NSFetchedResultsChangeInsert:
                        {
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        }
                        break;
                            
                        case NSFetchedResultsChangeDelete:
                        {
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                        }
                        break;
                        
                        case NSFetchedResultsChangeMove:
                        case NSFetchedResultsChangeUpdate:
                            break;
                    }
                }];
            }
            
            for( NSDictionary *change in self.itemChanges )
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
                            break;
                            
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:((NSIndexPath *) obj).section]];
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
            self.itemChanges    = nil;
            self.sectionChanges = nil;
            
            [self.collectionView.collectionViewLayout invalidateLayout];
        }];
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

- (NSCache *)feedImageCache
{
    if( !_feedImageCache )
    {
        _feedImageCache = [[NSCache alloc] init];
        [_feedImageCache setName:@"feedImageCache"];
    }
    
    return _feedImageCache;
}

@end