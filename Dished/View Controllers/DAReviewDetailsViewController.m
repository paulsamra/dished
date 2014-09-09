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
#import "DAComment.h"
#import "DAReviewDetailCommentCollectionViewCell.h"
#import "DAUsername.h"
#import "DAFeedCollectionViewCell.h"
#import "DACommentsViewController.h"
#import "ImageManipulator.h"

@interface DAReviewDetailsViewController() <DAFeedCollectionViewCellDelegate>

@property (strong, nonatomic) DAReview 						*review;
@property (strong, nonatomic) UIActivityIndicatorView       *spinner;

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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0) + [self.review.comments count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        DAFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        NSString *usernameString = [NSString stringWithFormat:@"@%@", self.review.creator_username];
        [cell.creatorButton  setTitle:usernameString     forState:UIControlStateNormal];
        [cell.titleButton    setTitle:self.review.name forState:UIControlStateNormal];
        if (![self.review.price isKindOfClass:[NSNull class]]) {
            [cell.priceLabel    setTitle:[NSString stringWithFormat:@"$%d", [self.review.price intValue]] forState:UIControlStateNormal];
        }
        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [cell.locationButton setTitle:self.review.loc_name forState:UIControlStateNormal];
        [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        NSURL *dishImageURL = [NSURL URLWithString:self.review.img];
        [cell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        cell.gradeLabel.text = [self.review.grade uppercaseString];
        
        NSURL *userImageURL = [NSURL URLWithString:self.review.creator_img_thumb];
        [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];

        
        
        return cell;
    }
    else if( indexPath.row == [self.review.comments count] + 1 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0) )
    {
        DAFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        cell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *commentString;
        
        if ((int)self.review.num_comments == 1)
        {
            commentString = [NSString stringWithFormat:@"%lu comment", (unsigned long)[self.review.comments count]];

        }
        else
        {
            commentString = [NSString stringWithFormat:@"%lu comments", (unsigned long)[self.review.comments count]];

        }
        [cell.commentsButton setTitle:commentString forState:UIControlStateNormal];


        
        return cell;
    }
    else if( indexPath.row == 1 && [self.review.yums count] > 0 )
    {
        DAReviewDetailCommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"yums" forIndexPath:indexPath];
        
        if( self.review )
        {
            NSMutableString *usernames = [[NSMutableString alloc] init];
            
            [self.review.yums enumerateObjectsUsingBlock:^(DAUsername *obj, NSUInteger idx, BOOL *stop)
            {
                if (idx == 0)
                {
                	[usernames appendString:[NSString stringWithFormat:@"@%@", obj.username]];

                }
                else
                {
                    [usernames appendString:[NSString stringWithFormat:@", @%@", obj.username]];

                }
            }];
            
            cell.commentLabel.text = usernames;
            cell.commentLabel.textColor = [UIColor dishedColor];
        }
        
        return cell;
    }
    else if( indexPath.row == 2 && [self.review.hashtags count] > 0 )
    {
        DAReviewDetailCommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tags" forIndexPath:indexPath];
        
        return cell;
    }
    else
    {
        DAReviewDetailCommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comment" forIndexPath:indexPath];
        
        if( self.review.comments > 0 && self.review )
        {
            DAComment *comment = [self.review.comments objectAtIndex:indexPath.row - (1 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0))];
            
            cell.commentLabel.attributedText = [self commentStringForComment:comment];
            
            if( indexPath.row != [self.review.yums count] + [self.review.hashtags count] + 1 )
            {
                [cell.imageView setHidden:YES];
            }
            else
            {
                [cell.imageView setHidden:NO];
            }
        }
        
        return cell;
    }
}
- (NSAttributedString *)commentStringForComment:(DAComment *)comment
{
    NSString *usernameString = [NSString stringWithFormat:@" @%@", comment.creator_username];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:@{ NSForegroundColorAttributeName : [UIColor dishedColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] }];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    
    
    NSTextAttachment *avatarIcon = [[NSTextAttachment alloc] init];
    UIImageView *temp = [[UIImageView alloc] init];
    NSURL *userImageURL = [NSURL URLWithString:comment.img_thumb];
#warning these images look awful, let's ask Nathan to scale these images on the server.

    [temp sd_setImageWithURL:userImageURL placeholderImage:[self image:[UIImage imageNamed:@"avatar-small"] scaledToSize:CGSizeMake(12, 12)]];
    avatarIcon.image = [ImageManipulator makeRoundCornerImage:[self image:temp.image scaledToSize:CGSizeMake(15, 15)] : 8 : 8];
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

- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        return flowLayout.itemSize;
    }
    else if( indexPath.row == 1 && [self.review.yums count] > 0 )
    {
        return CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
    else if (indexPath.row == 2 && [self.review.hashtags count] > 0)
    {
        return CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
    else if (indexPath.row == [self.review.comments count] + 1 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0))
    {
        return CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
    else
    {
        if( [self.review.comments count] > 0 )
        {
            DAComment *comment = [self.review.comments objectAtIndex:indexPath.row - (([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0) + 1)];
            
            NSAttributedString *commentString = [self commentStringForComment:comment];
            
            CGSize boundingSize = CGSizeMake( collectionView.frame.size.width - 60, CGFLOAT_MAX );
            CGRect commentRect = [commentString boundingRectWithSize:boundingSize
                                        options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                        context:nil];
            
            CGFloat minimumCellHeight = ceilf( commentRect.size.height + 1 );
            CGFloat ret = minimumCellHeight < 33 ? 33 : minimumCellHeight;
            
            return CGSizeMake( collectionView.frame.size.width, ret );
        }
        else
        {
            return CGSizeZero;
        }
    }
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
        
        return;
    }
}


@end