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
#import "DAReviewDetailCommentCollectionViewCell.h"
#import "DAFeedCollectionViewCell.h"
#import "DACommentsViewController.h"
#import "DAGlobalDishDetailViewController.h"


typedef enum
{
    ReviewDetailsItemDish,
    ReviewDetailsItemComment,
    ReviewDetailsItemYums,
    ReviewDetailsItemHashtags,
    ReviewDetailsItemFooter
}
ReviewDetailsItem;


@interface DAReviewDetailsViewController() <DAFeedCollectionViewCellDelegate>

@property (strong, nonatomic) DAReview                *review;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAReviewDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.hidden = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    [[DAAPIManager sharedManager] getProfileForReviewID:self.reviewID completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            
        }
        else
        {
            self.review = [DAReview reviewWithData:response[@"data"]];
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            [self.collectionView reloadData];
            self.collectionView.hidden = NO;
        }
    }];    
}

- (ReviewDetailsItem)itemTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger yumsRows = self.review.yums.count > 0 ? 1 : 0;
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
    NSUInteger yumsRows     = self.review.yums.count > 0 ? 1 : 0;
    NSUInteger hashtagsRows = self.review.hashtags.count > 0 ? 1 : 0;
    return indexPath.row - 1 - yumsRows - hashtagsRows;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger yumsRows     = self.review.yums.count > 0 ? 1 : 0;
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
        [dishCell.creatorButton  setTitle:usernameString    forState:UIControlStateNormal];
        [dishCell.titleButton    setTitle:self.review.name forState:UIControlStateNormal];
        
        if( ![self.review.price isKindOfClass:[NSNull class]] )
        {
            [dishCell.priceLabel setTitle:[NSString stringWithFormat:@"$%d", [self.review.price intValue]] forState:UIControlStateNormal];
        }
        
        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [dishCell.locationButton setTitle:self.review.loc_name forState:UIControlStateNormal];
        [dishCell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [dishCell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        NSURL *dishImageURL = [NSURL URLWithString:self.review.img];
        [dishCell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        dishCell.gradeLabel.text = [self.review.grade uppercaseString];
        
        NSURL *userImageURL = [NSURL URLWithString:self.review.creator_img_thumb];
        [dishCell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];

        cell = dishCell;
    }
    else if( itemType == ReviewDetailsItemFooter )
    {
        DAFeedCollectionViewCell *footerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        footerCell.delegate = self;
        
        footerCell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *commentFormat = self.review.num_comments == 1 ? @"%d comment" : @"%d comments";
        NSString *commentString = [NSString stringWithFormat:commentFormat, (int)self.review.num_comments];
        [footerCell.commentsButton setTitle:commentString forState:UIControlStateNormal];
        
        cell = footerCell;
    }
    else if( itemType == ReviewDetailsItemYums )
    {
        DAReviewDetailCommentCollectionViewCell *yumsCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"yums" forIndexPath:indexPath];
        
        yumsCell.commentLabel.attributedText = [self yumStringWithUsernames:self.review.yums];
        
        cell = yumsCell;
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        DAReviewDetailCommentCollectionViewCell *tagsCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tags" forIndexPath:indexPath];
        
        tagsCell.commentLabel.attributedText = [self hashtagStringWithHashtags:self.review.hashtags];
        
        cell = tagsCell;
    }
    else if( itemType == ReviewDetailsItemComment )
    {
        DAReviewDetailCommentCollectionViewCell *commentCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comment" forIndexPath:indexPath];
        
        if( self.review.comments > 0 && self.review )
        {
            DAComment *comment = [self.review.comments objectAtIndex:[self commentIndexForIndexPath:indexPath]];
            
            commentCell.commentLabel.attributedText = [self commentStringForComment:comment];
            
            if( [self commentIndexForIndexPath:indexPath] == 0 )
            {
                [commentCell.imageView setHidden:NO];
            }
            else
            {
                [commentCell.imageView setHidden:YES];
            }
        }
        
        cell = commentCell;
    }
    
    return cell;
}
- (NSAttributedString *)commentStringForComment:(DAComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@" @%@", comment.creator_username];
    NSDictionary *attributes = [DAReviewDetailCommentCollectionViewCell textAttributes];
    
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:attributes];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
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

    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];

        [labelString appendAttributedString:influencerIconString];
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:comment.comment attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] }]];
    
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
    
    NSAttributedString *yumString = [[NSAttributedString alloc] initWithString:[string copy] attributes:[DAReviewDetailCommentCollectionViewCell textAttributes]];
    
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
    
    NSAttributedString *hashtagString = [[NSAttributedString alloc] initWithString:[string copy] attributes:[DAReviewDetailCommentCollectionViewCell textAttributes]];
    
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
    }
    else if( itemType == ReviewDetailsItemYums )
    {
        NSAttributedString *yumString = [self yumStringWithUsernames:self.review.yums];
        
        CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 60, CGFLOAT_MAX );
        CGRect stringRect   = [yumString boundingRectWithSize:boundingSize
                                    options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                    context:nil];
        
        CGFloat minimumCellHeight = ceilf( stringRect.size.height + 1 );
        itemSize = CGSizeMake( collectionView.frame.size.width, minimumCellHeight );
    }
    else if( itemType == ReviewDetailsItemHashtags )
    {
        NSAttributedString *hashtagString = [self hashtagStringWithHashtags:self.review.hashtags];
        
        CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 60, CGFLOAT_MAX );
        CGRect stringRect   = [hashtagString boundingRectWithSize:boundingSize
                                    options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                    context:nil];
        
        CGFloat minimumCellHeight = ceilf( stringRect.size.height + 1 );
        itemSize = CGSizeMake( collectionView.frame.size.width, minimumCellHeight );
    }
    else if( itemType == ReviewDetailsItemFooter )
    {
        itemSize = CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
    else if( itemType == ReviewDetailsItemComment )
    {
        DAComment *comment = [self.review.comments objectAtIndex:[self commentIndexForIndexPath:indexPath]];
        
        NSAttributedString *commentString = [self commentStringForComment:comment];
        
        CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 60, CGFLOAT_MAX );
        CGRect commentRect = [commentString boundingRectWithSize:boundingSize
                                    options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                    context:nil];
        
        CGFloat minimumCellHeight = ceilf( commentRect.size.height + 1 );
        itemSize = CGSizeMake( collectionView.frame.size.width, minimumCellHeight );
    }
    
    return itemSize;
}

- (void)titleButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self performSegueWithIdentifier:@"globalReview" sender:nil];
}

- (void)commentButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    [self performSegueWithIdentifier:@"commentsSegue" sender:self.review];
}

- (void)yumButtonTappedOnFeedCollectionViewCell:(DAFeedCollectionViewCell *)cell
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"commentsSegue"] )
    {
        DACommentsViewController *dest = segue.destinationViewController;
        dest.reviewID = self.reviewID ;
    }
    
    if( [segue.identifier isEqualToString:@"globalReview"] )
    {
        DAGlobalDishDetailViewController *dest = segue.destinationViewController;
        dest.dishID = 85;
    }
}

@end