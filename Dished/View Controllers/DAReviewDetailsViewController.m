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
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAReviewDetailCollectionViewCell.h"
#import "DAFeedCollectionViewCell.h"
#import "DACommentsViewController.h"
#import "DAGlobalDishDetailViewController.h"
#import "DACoreDataManager.h"
#import "NSAttributedString+Dished.h"
#import "DAUserProfileViewController.h"
#import "DAReviewDetailCollectionViewCell.h"
#import "DAReviewButtonsCollectionViewCell.h"
#import "DAExploreDishResultsViewController.h"
#import "DAUserListViewController.h"
#import "UIViewController+ShareView.h"
#import "UIImageView+DishProgress.h"
#import "MRProgress.h"

typedef enum
{
    ReviewDetailsItemDish,
    ReviewDetailsItemComment,
    ReviewDetailsItemYums,
    ReviewDetailsItemHashtags,
    ReviewDetailsItemFooter
}
ReviewDetailsItem;

static NSString *const kReviewDetailCellIdentifier  = @"reviewDetailCell";
static NSString *const kReviewButtonsCellIdentifier = @"reviewButtonsCell";


@interface DAReviewDetailsViewController() <DAFeedCollectionViewCellDelegate, DAReviewButtonsCollectionViewCellDelegate, DAReviewDetailCollectionViewCellDelegate>

@property (strong, nonatomic) DAReview *review;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAReviewDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCollectionViewCellNibs];
    
    self.collectionView.hidden = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self loadReview];
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

- (void)loadReview
{
    [self showSpinner];
    
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
     
    [[DAAPIManager sharedManager] GET:kReviewProfileURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        self.review = [DAReview reviewWithData:responseObject[kDataKey]];
        self.review.review_id = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
        [self.collectionView reloadData];
        
        [self hideSpinner];
        
        [UIView transitionWithView:self.collectionView
                          duration:0.4
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.collectionView.hidden = NO;
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^
            {
                [self loadReview];
            }];
        }
    }];
}

- (void)registerCollectionViewCellNibs
{
    UINib *reviewDetailCellNib = [UINib nibWithNibName:NSStringFromClass( [DAReviewDetailCollectionViewCell class] ) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:reviewDetailCellNib forCellWithReuseIdentifier:kReviewDetailCellIdentifier];
    
    UINib *reviewButtonsCellNib = [UINib nibWithNibName:NSStringFromClass( [DAReviewButtonsCollectionViewCell class] ) bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:reviewButtonsCellNib forCellWithReuseIdentifier:kReviewButtonsCellIdentifier];
}

- (void)refreshReviewData
{
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    
    NSDictionary *parameters = @{ kIDKey : @(reviewID) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
     
    [[DAAPIManager sharedManager] GET:kReviewProfileURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        self.review = [DAReview reviewWithData:responseObject[kDataKey]];
        [self.collectionView reloadData];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^
            {
                [self refreshReviewData];
            }];
        }
    }];
}

- (ReviewDetailsItem)itemTypeForIndexPath:(NSIndexPath *)indexPath
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
    
    ReviewDetailsItem itemType = [self itemTypeForIndexPath:indexPath];
    
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
        [dishCell.titleButton   setTitle:self.review.name forState:UIControlStateNormal];
        
        if( [self.review.price floatValue] > 0 )
        {
            NSString *priceString = [NSString stringWithFormat:@"$%@", self.review.price];
            dishCell.priceLabel.text = priceString;
        }
        
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
            dishCell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:self.review.created];
        }

        cell = dishCell;
    }
    else if( itemType == ReviewDetailsItemFooter )
    {
        DAReviewButtonsCollectionViewCell *footerCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewButtonsCellIdentifier forIndexPath:indexPath];
        
        footerCell.delegate = self;
        
        NSInteger numComments = self.review.num_comments - 1;
        NSString *commentFormat = numComments == 0 ? @" No comments" : numComments == 1 ? @" %d comment" : @" %d comments";
        NSString *commentString = [NSString stringWithFormat:commentFormat, numComments];
        [footerCell.commentsButton setTitle:commentString forState:UIControlStateNormal];
        
        self.review.caller_yumd ? [self yumCell:footerCell] : [self unyumCell:footerCell];
        
        cell = footerCell;
    }
    else if( itemType == ReviewDetailsItemYums )
    {
        DAReviewDetailCollectionViewCell *yumsCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];
        
        yumsCell.iconImageView.image = [UIImage imageNamed:@"yum_icon"];
        
        if( !self.review.yums || self.review.num_yums > 10 )
        {
            NSString *yumsString = [NSString stringWithFormat:@"%d YUMs", (int)self.review.num_yums];
            yumsCell.textView.attributedText = [[NSAttributedString alloc] initWithString:yumsString attributes:[DAReviewDetailCollectionViewCell linkedTextAttributes]];
        }
        else
        {
            NSAttributedString *yumString = [self yumStringWithUsernames:self.review.yums];
            NSDictionary *linkedAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
            
            [yumsCell.textView setAttributedText:yumString withAttributes:linkedAttributes delimiter:@", " knownUsernames:[self.review yumsStringArray]];
        }
        
        yumsCell.delegate = self;
        
        cell = yumsCell;
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        DAReviewDetailCollectionViewCell *tagsCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];

        NSAttributedString *hashtagString = [self hashtagStringWithHashtags:self.review.hashtags];
        NSDictionary *linkedAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
        
        [tagsCell.textView setAttributedText:hashtagString withAttributes:linkedAttributes delimiter:@", " knownUsernames:nil];
        tagsCell.iconImageView.image = [UIImage imageNamed:@"hashtag_icon"];
        
        tagsCell.delegate = self;
        
        cell = tagsCell;
    }
    else if( itemType == ReviewDetailsItemComment )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];

        DAComment *comment = [self.review.comments objectAtIndex:[self commentIndexForIndexPath:indexPath]];
        
        NSAttributedString *commentString = [self commentStringForComment:comment];
        NSDictionary *linkedAttributes = [NSAttributedString linkedTextAttributesWithFontSize:14.0f];
        NSArray *usernameMentions = [comment.usernameMentions arrayByAddingObject:comment.creator_username];
        
        [commentCell.textView setAttributedText:commentString withAttributes:linkedAttributes delimiter:nil knownUsernames:usernameMentions];
        commentCell.iconImageView.image = [UIImage imageNamed:@"comments_icon"];
        commentCell.iconImageView.hidden = [self commentIndexForIndexPath:indexPath] == 0 ? NO : YES;
        
        commentCell.delegate = self;
        
        cell = commentCell;
    }
    
    return cell;
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

- (NSAttributedString *)commentStringForComment:(DAComment *)comment
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
        
        UIImage *userImage = [[[SDWebImageManager sharedManager] imageCache] imageFromDiskCacheForKey:comment.img_thumb];
        
        if( userImage )
        {
            avatarIcon.image = [self scaleImage:userImage toFrame:userImageRect withCornerRadius:cornerRadius];
        }
        else
        {
            NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:userImageURL options:SDWebImageHighPriority progress:nil
            completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL )
            {
                dispatch_async( dispatch_get_main_queue(), ^
                {
                    comment.creator_img = image;
                    [self.collectionView reloadData];
                });
            }];
            
            avatarIcon.image = [self scaleImage:[[UIImage alloc] init] toFrame:userImageRect withCornerRadius:cornerRadius];
        }
        
        NSAttributedString *avatarIconString = [NSAttributedString attributedStringWithAttachment:avatarIcon];
        [labelString insertAttributedString:avatarIconString atIndex:0];
    }

    if( [comment.creator_type isEqualToString:kInfluencerUserType] )
    {
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];

        [labelString appendAttributedString:influencerIconString];
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
    
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:comment.comment attributes:[DAReviewDetailCollectionViewCell textAttributes]];
    [labelString appendAttributedString:commentString];
    
    return labelString;
}

- (NSAttributedString *)yumStringWithUsernames:(NSArray *)usernames
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    [self.review.yums enumerateObjectsUsingBlock:^( DAUsername *username, NSUInteger index, BOOL *stop )
    {
        if( index == 0 )
        {
            [string appendString:[NSString stringWithFormat:@"@%@", username.username]];
        }
        else
        {
            [string appendString:[NSString stringWithFormat:@", @%@", username.username]];
        }
    }];
    
    NSAttributedString *yumString = [[NSAttributedString alloc] initWithString:string attributes:[DAReviewDetailCollectionViewCell textAttributes]];
    
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
    
    NSAttributedString *hashtagString = [[NSAttributedString alloc] initWithString:string attributes:[DAReviewDetailCollectionViewCell textAttributes]];
    
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
    
    ReviewDetailsItem itemType = [self itemTypeForIndexPath:indexPath];
    
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
        NSAttributedString *commentString = [self commentStringForComment:comment];
        
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
    [self pushGlobalDishWithDishID:self.review.dish_id];
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
    [self pushGlobalDishWithDishID:self.review.dish_id];
}

- (void)textViewTappedAtCharacterIndex:(NSUInteger)characterIndex inCell:(DAReviewDetailCollectionViewCell *)cell
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

- (void)creatorButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self pushUserProfileWithUsername:self.review.creator_username];
}

- (void)locationButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self pushRestaurantProfileWithLocationID:self.review.loc_id username:self.review.loc_name];
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
                if( self.feedItem )
                {
                    self.feedItem.caller_yumd = @(YES);
                }
                  
                if( finished )
                {
                    [yumTapImageView removeFromSuperview];
                }
            }];
        }
    }];
    
    if( ![self.feedItem.caller_yumd boolValue] || !self.review.caller_yumd )
    {
        NSInteger row = [self.collectionView numberOfItemsInSection:0] - 1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        DAReviewButtonsCollectionViewCell *buttonCell = (DAReviewButtonsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        [self yumCell:buttonCell];
        [self yumFeedItemWithReviewID:self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID];
    }
}

- (void)yumButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self changeYumStatusForCell:cell];
}

- (void)changeYumStatusForCell:(DAReviewButtonsCollectionViewCell *)cell
{
    if( [self.feedItem.caller_yumd boolValue] || self.review.caller_yumd )
    {
        [self unyumCell:cell];
        self.feedItem.caller_yumd = @(NO);
        
        [self unyumFeedItemWithReviewID:[self.feedItem.item_id integerValue]];
    }
    else
    {
        [self yumCell:cell];
        self.feedItem.caller_yumd = @(YES);
        
        [self yumFeedItemWithReviewID:[self.feedItem.item_id integerValue]];
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

- (void)deleteReview
{
    [MRProgressOverlayView showOverlayAddedTo:self.view.window title:@"Deleting..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
    
    NSDictionary *parameters = @{ kReviewIDKey : @(self.review.review_id) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    [[DAAPIManager sharedManager] POST:kReviewDeleteURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        if( self.feedItem )
        {
            [[DACoreDataManager sharedManager] deleteEntity:self.feedItem];
            
            [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:^( BOOL saved, NSError *error )
            {
                [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }];
        }
        else
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"item_id", @(self.reviewID)];
            NSString *entityName = [DAFeedItem entityName];
            NSArray *matchingItems = [[DACoreDataManager sharedManager] fetchEntitiesWithName:entityName sortDescriptors:nil predicate:predicate];
            
            if( matchingItems.count > 0 )
            {
                [[DACoreDataManager sharedManager] deleteEntity:[matchingItems objectAtIndex:0]];
                
                [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:^( BOOL saved, NSError *error )
                {
                    [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
                    {
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }];
            }
            else
            {
                [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
                {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^
            {
                [self deleteReview];
            }];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Error Deleting Review" message:@"There was a problem deleting your review. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

- (void)socialCollectionViewControllerDidDeleteReview:(DASocialCollectionViewController *)controller
{
    [self dismissShareView];
    [self deleteReview];
}

- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller
{
    [self dismissShareView];
}

- (IBAction)shareButtonPressed:(UIBarButtonItem *)sender
{
    [self showShareViewWithReview:self.review];
}

@end