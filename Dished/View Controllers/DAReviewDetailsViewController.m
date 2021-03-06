//
//  DAReviewDetailsViewController.m
//  Dished
//
//  Created by Daryl Stimm on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailsViewController.h"
#import "DAFeedCollectionViewCell.h"
#import "DAReview.h"
#import "DAFeedCollectionViewCell.h"
#import "DACoreDataManager.h"
#import "DAExploreDishResultsViewController.h"
#import "DAUserListViewController.h"
#import "UIViewController+ShareView.h"
#import "UIImageView+DishProgress.h"
#import "DAFeedCollectionViewFlowLayout.h"
#import "DAUserManager.h"
#import "MRProgress.h"
#import "DAExploreViewController.h"
#import "DATabBarController.h"

typedef enum
{
    ReviewDetailsItemDish,
    ReviewDetailsItemComment,
    ReviewDetailsItemYums,
    ReviewDetailsItemHashtags,
    ReviewDetailsItemFooter
} eReviewDetailsItem;

static NSString *const kReviewDetailCellIdentifier  = @"reviewDetailCell";
static NSString *const kReviewButtonsCellIdentifier = @"reviewButtonsCell";
static NSString *const kReviewHeaderIdentifier      = @"titleHeader";


@interface DAReviewDetailsViewController() <DAFeedCollectionViewCellDelegate, DAReviewButtonsCollectionViewCellDelegate, DAReviewDetailCollectionViewCellDelegate, DADishHeaderCollectionReusableViewDelegate>

@property (strong, nonatomic) DAReview *review;
@property (strong, nonatomic) NSURLSessionTask *loadReviewTask;
@property (strong, nonatomic) NSURLSessionTask *refreshReviewTask;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAReviewDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCollectionViewCellNibs];
    
    DAFeedCollectionViewFlowLayout *flowLayout = (DAFeedCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.navigationBar  = self.navigationController.navigationBar;
    
    self.collectionView.hidden = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self showSpinner];
    [self loadData];
}

- (void)showSpinner
{
    if( !self.spinner )
    {
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.spinner.center = self.view.center;
        self.spinner.hidesWhenStopped = YES;
        [self.view addSubview:self.spinner];
    }
    
    [self.spinner startAnimating];
}

- (void)hideSpinner
{
    [self.spinner stopAnimating];
}

- (void)loadData
{
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    
    __weak typeof( self ) weakSelf = self;
    
    self.loadReviewTask = [[DAAPIManager sharedManager] GETRequest:kReviewProfileURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.review = [DAReview reviewWithData:response[kDataKey]];
        weakSelf.review.review_id = weakSelf.feedItem ? [weakSelf.feedItem.item_id integerValue] : weakSelf.reviewID;
        
        NSString *idName = [NSString stringWithFormat:@"%d", (int)reviewID];
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(refreshReview) name:idName object:nil];
        
        [weakSelf.collectionView reloadData];
        
        [weakSelf hideSpinner];
        
        [UIView transitionWithView:weakSelf.collectionView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        weakSelf.collectionView.hidden = NO;
        
        [weakSelf dataLoaded];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadData];
        }
        else
        {
            [weakSelf hideSpinner];
            [weakSelf handleError:error];
        }
    }];
}

- (void)refreshReview
{
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    
    [self.refreshReviewTask cancel];
    
    __weak typeof( self ) weakSelf = self;
    
    self.refreshReviewTask = [[DAAPIManager sharedManager] GETRequest:kReviewProfileURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.review = [DAReview reviewWithData:response[kDataKey]];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf refreshReview];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( self.review )
    {
        [self.collectionView reloadData];
    }
}

- (void)dealloc
{
    [self.loadReviewTask cancel];
    [self.refreshReviewTask cancel];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerCollectionViewCellNibs
{
    [self.collectionView registerClass:[DAReviewDetailCollectionViewCell class] forCellWithReuseIdentifier:kReviewDetailCellIdentifier];
    [self.collectionView registerClass:[DAReviewButtonsCollectionViewCell class] forCellWithReuseIdentifier:kReviewButtonsCellIdentifier];
    [self.collectionView registerClass:[DADishHeaderCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kReviewHeaderIdentifier];
}

- (void)refreshReviewData
{
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
     
    [[DAAPIManager sharedManager] GETRequest:kReviewProfileURL withParameters:parameters
    success:^( id response )
    {
        self.review = [DAReview reviewWithData:response[kDataKey]];
        [self.collectionView reloadData];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self refreshReviewData];
        }
    }];
}

- (eReviewDetailsItem)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yumsRows = self.review.num_yums > 0 ? 1 : 0;
    NSUInteger hashtagsRows = self.review.hashtags.count > 0 ? 1 : 0;
    NSUInteger commentsRows = self.review.comments.count;
    
    if( indexPath.row == 0 )
    {
        return ReviewDetailsItemDish;
    }
    else if( indexPath.row == commentsRows + yumsRows + hashtagsRows + 1 )
    {
        return ReviewDetailsItemFooter;
    }
    else if( indexPath.row == 1 && yumsRows > 0 )
    {
        return ReviewDetailsItemYums;
    }
    else if( indexPath.row == yumsRows + 1 && hashtagsRows > 0 )
    {
        return ReviewDetailsItemHashtags;
    }
    else
    {
        return ReviewDetailsItemComment;
    }
}

- (NSUInteger)commentIndexForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yumsRows     = self.review.num_yums > 0 ? 1 : 0;
    NSUInteger hashtagsRows = self.review.hashtags.count > 0 ? 1 : 0;
    return indexPath.row - 1 - yumsRows - hashtagsRows;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger yumsRows     = self.review.num_yums > 0 ? 1 : 0;
    NSUInteger hashtagsRows = self.review.hashtags.count > 0 ? 1 : 0;
    NSUInteger commentsRows = self.review.comments.count;
    
    return yumsRows + hashtagsRows + commentsRows + 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    eReviewDetailsItem itemType = [self itemTypeForIndexPath:indexPath];
    
    if( itemType == ReviewDetailsItemDish )
    {
        DAFeedCollectionViewCell *dishCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        dishCell.delegate = self;
        
        NSString *usernameString = [NSString stringWithFormat:@"@%@", self.review.creator_username];
        if( [self.review.creator_type isEqualToString:kInfluencerUserType] )
        {
            usernameString = [NSString stringWithFormat:@" %@", usernameString];
            [dishCell.creatorButton setImage:[UIImage imageNamed:@"influencer"] forState:UIControlStateNormal];
        }
        
        [dishCell.creatorButton setTitle:usernameString   forState:UIControlStateNormal];
        
        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [dishCell.locationButton setTitle:self.review.loc_name forState:UIControlStateNormal];
        [dishCell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [dishCell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        NSURL *dishImageURL = [NSURL URLWithString:self.review.img];
        [dishCell.dishImageView setImageUsingProgressViewWithURL:dishImageURL];

        dishCell.gradeLabel.text = [self.review.grade uppercaseString];
        
        NSURL *userImageURL = [NSURL URLWithString:self.review.creator_img_thumb];
        [dishCell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
        
        if( self.review.created )
        {
            dishCell.timeLabel.attributedText = [self.review.created attributedTimeStringWithAttributes:nil];
        }

        cell = dishCell;
    }
    else if( itemType == ReviewDetailsItemFooter )
    {
        DAReviewButtonsCollectionViewCell *footerCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewButtonsCellIdentifier forIndexPath:indexPath];
        
        footerCell.delegate = self;
        
        NSInteger numComments = self.review.num_comments - 1;
        [footerCell setNumberOfComments:numComments];
        self.review.caller_yumd ? [footerCell setYummed] : [footerCell setUnyummed];
        
        cell = footerCell;
    }
    else if( itemType == ReviewDetailsItemYums )
    {
        DAReviewDetailCollectionViewCell *yumsCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        NSDictionary *linkedAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
        
        yumsCell.iconImageView.image = [UIImage imageNamed:@"yum_icon"];
        
        if( !self.review.yums || self.review.num_yums > 10 )
        {
            NSString *yumsString = [NSString stringWithFormat:@"%d YUMs", (int)self.review.num_yums];
            yumsCell.textView.attributedText = [[NSAttributedString alloc] initWithString:yumsString attributes:linkedAttributes];
        }
        else
        {
            NSAttributedString *yumString = [self yumStringWithUsernames:self.review.yums];
            [yumsCell.textView setAttributedText:yumString withAttributes:linkedAttributes knownUsernames:self.review.yums useCache:YES];
        }
        
        yumsCell.delegate = self;
        
        cell = yumsCell;
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        DAReviewDetailCollectionViewCell *tagsCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];

        NSAttributedString *hashtagString = [self hashtagStringWithHashtags:self.review.hashtags];
        NSDictionary *linkedAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
        
        [tagsCell.textView setAttributedText:hashtagString withAttributes:linkedAttributes knownUsernames:nil useCache:YES];
        tagsCell.iconImageView.image = [UIImage imageNamed:@"hashtag_icon"];
        
        tagsCell.delegate = self;
        
        cell = tagsCell;
    }
    else if( itemType == ReviewDetailsItemComment )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];

        DAComment *comment = [self.review.comments objectAtIndex:[self commentIndexForIndexPath:indexPath]];
        
        NSAttributedString *commentString = [self commentStringForComment:comment atIndexPath:indexPath];
        NSDictionary *linkedAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
        NSArray *usernameMentions = [comment.usernameMentions arrayByAddingObject:comment.creator_username];
        
        NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
        BOOL useCache = [[SDWebImageManager sharedManager] cachedImageExistsForURL:userImageURL] ? YES : NO;
        
        [commentCell.textView setAttributedText:commentString withAttributes:linkedAttributes knownUsernames:usernameMentions useCache:useCache];
        commentCell.iconImageView.image = [UIImage imageNamed:@"comments_icon"];
        commentCell.iconImageView.hidden = [self commentIndexForIndexPath:indexPath] == 0 ? NO : YES;
        
        commentCell.delegate = self;
        
        cell = commentCell;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if( kind == UICollectionElementKindSectionHeader )
    {
        DADishHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kReviewHeaderIdentifier forIndexPath:indexPath];
        
        header.delegate = self;
        
        [header.titleButton setTitle:self.review.name forState:UIControlStateNormal];
        
        if( [self.review.price floatValue] > 0 )
        {
            NSString *priceString = [NSString stringWithFormat:@"$%@", self.review.price];
            header.sideLabel.text = priceString;
        }
        
        return header;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake( self.collectionView.frame.size.width, 40 );
}

- (void)titleButtonTappedOnFeedHeaderCollectionReusableView:(DADishHeaderCollectionReusableView *)cell
{
    [self pushGlobalDishViewWithDishID:self.review.dish_id];
}

- (NSAttributedString *)commentStringForComment:(DAComment *)comment atIndexPath:(NSIndexPath *)indexPath
{
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSDictionary *attributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
    NSAttributedString *attributedUsername = [[NSAttributedString alloc] initWithString:usernameString attributes:attributes];
    NSMutableAttributedString *labelString = [attributedUsername mutableCopy];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    if( comment.img_thumb && comment.img_thumb.length > 0 )
    {
        [labelString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
        
        NSTextAttachment *avatarIcon = [[NSTextAttachment alloc] init];
        CGRect userImageRect = CGRectMake( 0, 0, 15, 15 );
        CGFloat cornerRadius = userImageRect.size.width / 2;
        
        NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
        NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:userImageURL];
        UIImage *userImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:cacheKey];
        
        if( userImage )
        {
            avatarIcon.image = [self scaleImage:userImage toFrame:userImageRect withCornerRadius:cornerRadius];
        }
        else
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:userImageURL options:SDWebImageHighPriority progress:nil
            completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL )
            {
                if( image && finished )
                {
                    [[SDWebImageManager sharedManager] saveImageToCache:image forURL:userImageURL];
                    
                    dispatch_async( dispatch_get_main_queue(), ^
                    {
                        [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
                    });
                }
            }];
            
            UIImage *placeholderImage = [UIImage imageNamed:@"profile_image"];
            avatarIcon.image = [self scaleImage:placeholderImage toFrame:userImageRect withCornerRadius:cornerRadius];
        }
        
        NSAttributedString *avatarIconString = [NSAttributedString attributedStringWithAttachment:avatarIcon];
        [labelString insertAttributedString:avatarIconString atIndex:0];
    }

    if( [comment.creator_type isEqualToString:kInfluencerUserType] )
    {
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:[[DAInfluencerTextAttachment alloc] init]];

        [labelString appendAttributedString:influencerIconString];
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    NSDictionary *plainTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:comment.comment attributes:plainTextAttributes];
    [labelString appendAttributedString:commentString];
    
    return labelString;
}

- (NSAttributedString *)yumStringWithUsernames:(NSArray *)usernames
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [self.review.yums enumerateObjectsUsingBlock:^( NSString *username, NSUInteger index, BOOL *stop )
    {
        if( index == 0 )
        {
            [string appendString:[NSString stringWithFormat:@"@%@", username]];
        }
        else
        {
            [string appendString:[NSString stringWithFormat:@", @%@", username]];
        }
    }];
    
    NSDictionary *plainTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
    
    NSAttributedString *yumString = [[NSAttributedString alloc] initWithString:string attributes:plainTextAttributes];
    
    return yumString;
}

- (NSAttributedString *)hashtagStringWithHashtags:(NSArray *)hashtags
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [self.review.hashtags enumerateObjectsUsingBlock:^( DAHashtag *hashtag, NSUInteger index, BOOL *stop )
    {
        if( index == 0 )
        {
            [string appendString:[NSString stringWithFormat:@"#%@", hashtag.name]];
        }
        else
        {
            [string appendString:[NSString stringWithFormat:@", #%@", hashtag.name]];
        }
    }];
    
    NSDictionary *plainTextAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14.0f] };
    
    NSAttributedString *hashtagString = [[NSAttributedString alloc] initWithString:string attributes:plainTextAttributes];
    
    return hashtagString;
}

- (UIImage *)scaleImage:(UIImage *)image toFrame:(CGRect)frame withCornerRadius:(CGFloat)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions( frame.size, NO, 0 );
    [[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius] addClip];
    [image drawInRect:frame];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
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
    
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    
    CGSize itemSize = CGSizeZero;
    
    eReviewDetailsItem itemType = [self itemTypeForIndexPath:indexPath];
    
    if( itemType == ReviewDetailsItemDish )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        
        itemSize = flowLayout.itemSize;
        itemSize.width = collectionView.frame.size.width;
    }
    else if( itemType == ReviewDetailsItemYums )
    {
        if( !self.review.yums || self.review.num_yums > 10 )
        {
            itemSize = CGSizeMake( collectionView.frame.size.width, 18 );
        }
        else
        {
            NSAttributedString *yumString = [self yumStringWithUsernames:self.review.yums];
            
            sizingCell.textView.attributedText = yumString;
            
            CGSize stringSize = [sizingCell.textView sizeThatFits:boundingSize];
            
            CGFloat textViewHeight = ceilf( stringSize.height );
            
            CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
            cellSize.height = calculatedHeight;
            
            itemSize = cellSize;
        }
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        NSAttributedString *hashtagString = [self hashtagStringWithHashtags:self.review.hashtags];
        
        sizingCell.textView.attributedText = hashtagString;
        
        CGSize stringSize = [sizingCell.textView sizeThatFits:boundingSize];
        
        CGFloat textViewHeight = ceilf( stringSize.height );
        
        CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
        cellSize.height = calculatedHeight;
        
        itemSize = cellSize;
    }
    else if( itemType == ReviewDetailsItemFooter )
    {
        itemSize = CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
    else if( itemType == ReviewDetailsItemComment )
    {
        NSInteger commentIndex = [self commentIndexForIndexPath:indexPath];
        DAComment *comment = [self.review.comments objectAtIndex:commentIndex];
        NSAttributedString *commentString = [self commentStringForComment:comment atIndexPath:indexPath];
        
        sizingCell.textView.attributedText = commentString;

        CGSize stringSize = [sizingCell.textView sizeThatFits:boundingSize];
        
        CGFloat textViewHeight = ceilf( stringSize.height );
        
        CGFloat calculatedHeight = textViewHeight + textViewTopMargin + textViewBottomMargin;
        cellSize.height = calculatedHeight;
        
        itemSize = cellSize;
    }
    
    return itemSize;
}

- (void)titleButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self pushGlobalDishViewWithDishID:self.review.dish_id];
}

- (void)commentsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    if( self.feedItem )
    {
        [self pushCommentsViewWithFeedItem:self.feedItem showKeyboard:YES];
    }
    else
    {
        [self pushCommentsViewWithReviewID:self.reviewID showKeyboard:YES];
    }
}

- (void)moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self pushGlobalDishViewWithDishID:self.review.dish_id];
}

- (void)textViewTappedOnText:(NSString *)text withTextType:(eLinkedTextType)textType inCell:(DAReviewDetailCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSUInteger yumsRows = self.review.num_yums > 0 ? 1 : 0;
    
    if( indexPath.row == 1 && yumsRows > 0 && self.review.num_yums > 10 )
    {
        DAUserListViewController *userListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userList"];
        userListViewController.listContent = eUserListContentYums;
        userListViewController.object_id = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
        
        [self.navigationController pushViewController:userListViewController animated:YES];
    }
    else
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

- (void)creatorButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self pushUserProfileWithUsername:self.review.creator_username];
}

- (void)locationButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self pushRestaurantProfileWithLocationID:self.review.loc_id username:self.review.loc_name];
}

- (void)userImageTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self pushUserProfileWithUsername:self.review.creator_username];
}

- (void)imageDoubleTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
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
    
    BOOL callerYumd = self.feedItem ? [self.feedItem.caller_yumd boolValue] : self.review.caller_yumd;

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
                if( !callerYumd )
                {
                    self.feedItem.caller_yumd = @(YES);
                    self.review.caller_yumd = YES;
                    [self addCurrentUserYumToReview];
                }
                  
                if( finished )
                {
                    [yumTapImageView removeFromSuperview];
                }
            }];
        }
    }];
    
    if( !callerYumd )
    {
        NSInteger row = [self.collectionView numberOfItemsInSection:0] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        DAReviewButtonsCollectionViewCell *buttonCell = (DAReviewButtonsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [buttonCell setYummed];
        [self yumFeedItemWithReviewID:self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID];
    }
}

- (void)yumButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)changeYumStatusForCell:(DAReviewButtonsCollectionViewCell *)cell
{
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.review.review_id;

    if( [self.feedItem.caller_yumd boolValue] || self.review.caller_yumd )
    {
        [cell setUnyummed];
        self.feedItem.caller_yumd = @(NO);
        self.review.caller_yumd = NO;
        [self removeCurrentUserYumFromReview];
        
        [self unyumFeedItemWithReviewID:reviewID];
    }
    else
    {
        [cell setYummed];
        self.feedItem.caller_yumd = @(YES);
        self.review.caller_yumd = YES;
        [self addCurrentUserYumToReview];
        
        [self yumFeedItemWithReviewID:reviewID];
    }
}

- (void)removeCurrentUserYumFromReview
{
    NSMutableArray *yums = [self.review.yums mutableCopy];
    [yums removeObject:[DAUserManager sharedManager].username];
    self.review.yums = yums;
    [self.collectionView reloadData];
}

- (void)addCurrentUserYumToReview
{
    NSMutableArray *yums = [self.review.yums mutableCopy];
    [yums addObject:[DAUserManager sharedManager].username];
    self.review.yums = yums;
    [self.collectionView reloadData];
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

- (void)deleteReview
{
    NSDictionary *parameters = @{ kReviewIDKey : @(self.review.review_id) };
    
    [[DAAPIManager sharedManager] POSTRequest:kReviewDeleteURL withParameters:parameters
    success:^( id response )
    {
        NSManagedObjectContext *mainContext = [[DACoreDataManager sharedManager] mainManagedContext];
        
        if( self.feedItem )
        {
            [[DACoreDataManager sharedManager] deleteEntity:self.feedItem inManagedObjectContext:mainContext];
            [[[DACoreDataManager sharedManager] mainManagedContext] save:nil];

            [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kReviewDeletedNotification object:nil];
                [(DATabBarController *)self.tabBarController resetToHomeFeed];
            }];
        }
        else
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"item_id", @(self.reviewID)];
            NSString *entityName = [DAFeedItem entityName];
            NSArray *matchingItems = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:nil predicate:predicate inManagedObjectContext:mainContext];
            
            if( matchingItems.count > 0 )
            {
                [[DACoreDataManager sharedManager] deleteEntity:[matchingItems objectAtIndex:0] inManagedObjectContext:mainContext];
                [[[DACoreDataManager sharedManager] mainManagedContext] save:nil];
                
                [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReviewDeletedNotification object:nil];
                    [(DATabBarController *)self.tabBarController resetToHomeFeed];
                }];
            }
            else
            {
                [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
                {
                    [(DATabBarController *)self.tabBarController resetToHomeFeed];
                }];
            }
        }
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self deleteReview];
        }
        else
        {
            [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
            {
                [[[UIAlertView alloc] initWithTitle:@"Error Deleting Review" message:@"There was a problem deleting your review. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }];
        }
    }];
}

- (void)socialCollectionViewControllerDidDeleteReview:(DASocialCollectionViewController *)controller
{
    [self dismissShareView];
    
    [MRProgressOverlayView showOverlayAddedTo:self.view.window title:@"Deleting..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];

    [self deleteReview];
}

- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller
{
    [self dismissShareView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (IBAction)shareButtonPressed:(UIBarButtonItem *)sender
{
    [self showShareViewWithReview:self.review];
    sender.enabled = NO;
}

@end