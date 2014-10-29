//
//  DAReviewDetailsViewController.m
//  Dished
//
//  Created by Daryl Stimm on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewDetailsViewController.h"
#import "DAFeedCollectionViewCell.h"
#import "DAAPIManager.h"
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
#import "DATabBarController.h"

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

@end


@implementation DAReviewDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCollectionViewCellNibs];
    
    self.collectionView.hidden = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    NSInteger reviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kIDKey : @(reviewID) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        [[DAAPIManager sharedManager] GET:kReviewProfileURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            self.review = [DAReview reviewWithData:responseObject[kDataKey]];
            [self.collectionView reloadData];
            
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            
            [UIView transitionWithView:self.collectionView
                              duration:0.4
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
            
            self.collectionView.hidden = NO;
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            
        }];
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
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
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
              
        }];
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
        if( [self.review.creator_type isEqualToString:@"influencer"] )
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
        [dishCell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

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
        
        footerCell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *commentFormat = self.review.num_comments == 1 ? @"%d comment" : @"%d comments";
        NSString *commentString = [NSString stringWithFormat:commentFormat, (int)self.review.num_comments];
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
            [yumsCell.textView setAttributedText:[self yumStringWithUsernames:self.review.yums] withDelimiter:@", "];
        }
        
        yumsCell.delegate = self;
        
        cell = yumsCell;
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        DAReviewDetailCollectionViewCell *tagsCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];

        [tagsCell.textView setAttributedText:[self hashtagStringWithHashtags:self.review.hashtags] withDelimiter:@", "];
        tagsCell.iconImageView.image = [UIImage imageNamed:@"hashtag_icon"];
        
        tagsCell.delegate = self;
        
        cell = tagsCell;
    }
    else if( itemType == ReviewDetailsItemComment )
    {
        DAReviewDetailCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:kReviewDetailCellIdentifier forIndexPath:indexPath];

        DAComment *comment = [self.review.comments objectAtIndex:[self commentIndexForIndexPath:indexPath]];
        
        commentCell.textView.attributedText = [self commentStringForComment:comment];
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
    NSDictionary *attributes = [DAReviewDetailCollectionViewCell linkedTextAttributes];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:attributes];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    
    if( comment.img_thumb && comment.img_thumb.length > 0 )
    {
        [labelString insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:0];
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
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

    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];

        [labelString appendAttributedString:influencerIconString];
    }
    
    NSArray *words = [comment.comment componentsSeparatedByString:@" "];
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:comment.comment attributes:[DAReviewDetailCollectionViewCell textAttributes]];
    
    for( NSString *word in words )
    {
        if( [word hasPrefix:@"#"] || [word hasPrefix:@"@"] )
        {
            NSRange matchRange = [comment.comment rangeOfString:word];
            [commentString setAttributes:[DAReviewDetailCollectionViewCell linkedTextAttributes] range:matchRange];
        }
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
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
    
    NSAttributedString *yumString = [[NSAttributedString alloc] initWithString:[string copy] attributes:[DAReviewDetailCollectionViewCell linkedTextAttributes]];
    
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
    
    NSAttributedString *hashtagString = [[NSAttributedString alloc] initWithString:[string copy] attributes:[DAReviewDetailCollectionViewCell linkedTextAttributes]];
    
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
            
            CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 38, CGFLOAT_MAX );
            CGRect stringRect   = [yumString boundingRectWithSize:boundingSize
                                                          options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                                          context:nil];
            
            CGFloat textHeight = ceilf( stringRect.size.height ) + 1;
            itemSize = CGSizeMake( collectionView.frame.size.width, textHeight );
        }
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        NSAttributedString *hashtagString = [self hashtagStringWithHashtags:self.review.hashtags];
        
        CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 50, CGFLOAT_MAX );
        CGRect stringRect   = [hashtagString boundingRectWithSize:boundingSize
                                    options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                    context:nil];
        
        CGFloat minimumCellHeight = ceilf( stringRect.size.height ) + 1;
        itemSize = CGSizeMake( collectionView.frame.size.width, minimumCellHeight );
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
        
        CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 38, CGFLOAT_MAX );
        CGRect commentRect = [commentString boundingRectWithSize:boundingSize
                                    options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                    context:nil];
        
        CGFloat minimumCellHeight = ceilf( commentRect.size.height ) + 1;
        itemSize = CGSizeMake( collectionView.frame.size.width, minimumCellHeight );
    }
    
    return itemSize;
}

- (void)titleButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self performSegueWithIdentifier:@"globalDish" sender:nil];
}

- (void)commentsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self performSegueWithIdentifier:@"commentsSegue" sender:self.review];
}

- (void)moreReviewsButtonTappedOnReviewButtonsCollectionViewCell:(DAReviewButtonsCollectionViewCell *)cell
{
    [self performSegueWithIdentifier:@"globalDish" sender:nil];
}

- (void)textViewTappedAtCharacterIndex:(NSUInteger)characterIndex inCell:(DAReviewDetailCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSUInteger yumsRows = self.review.num_yums > 0 ? 1 : 0;
    
    if( indexPath.row == 1 && yumsRows > 0 )
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
            DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
            userProfileViewController.username = [cell.textView linkedTextForCharacterAtIndex:characterIndex];
            userProfileViewController.isRestaurant = NO;
            [self.navigationController pushViewController:userProfileViewController animated:YES];
        }
    }
}

- (void)creatorButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userProfileViewController.username = self.review.creator_username;
    userProfileViewController.user_id  = self.review.creator_id;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)locationButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userProfileViewController.username = self.review.loc_name;
    userProfileViewController.user_id  = self.review.loc_id;
    userProfileViewController.isRestaurant = YES;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
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
    [[DAAPIManager sharedManager] yumReviewID:reviewID completion:^( BOOL success )
    {
        if( success )
        {
            [[DACoreDataManager sharedManager] saveDataInManagedContextUsingBlock:nil];
            [self refreshReviewData];
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
            [self refreshReviewData];
        }
        else
        {
            [self.collectionView reloadData];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"commentsSegue"] )
    {
        DACommentsViewController *dest = segue.destinationViewController;
        
        if( self.feedItem )
        {
            dest.feedItem = self.feedItem;
        }
        else
        {
            dest.reviewID = self.reviewID;
        }
    }
    
    if( [segue.identifier isEqualToString:@"globalDish"] )
    {
        DAGlobalDishDetailViewController *dest = segue.destinationViewController;
        dest.dishID = self.review.dish_id;
        dest.presentingReviewID = self.feedItem ? [self.feedItem.item_id integerValue] : self.reviewID;
    }
}

- (IBAction)shareButtonPressed:(UIBarButtonItem *)sender
{
    DATabBarController *tabBarController = (DATabBarController *)self.tabBarController;
    [tabBarController showShareView];
}

@end