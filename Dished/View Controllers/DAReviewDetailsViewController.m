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

@interface DAReviewDetailsViewController()

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
    return 2 + [self.review.yums count] + [self.review.hashtags count] + [self.review.comments count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        DAFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        NSString *usernameString = [NSString stringWithFormat:@"@%@", self.review.creator_username];
        [cell.creatorButton  setTitle:usernameString     forState:UIControlStateNormal];
        [cell.titleButton    setTitle:self.review.name forState:UIControlStateNormal];
        [cell.priceLabel    setTitle:[NSString stringWithFormat:@"$%f", [self.review.price floatValue] / 100] forState:UIControlStateNormal];

        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [cell.locationButton setTitle:self.review.loc_name forState:UIControlStateNormal];
        [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        NSURL *dishImageURL = [NSURL URLWithString:self.review.img];
        [cell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        cell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *commentString = [NSString stringWithFormat:@"%d comments", (int)self.review.num_comments];
        [cell.commentsButton setTitle:commentString forState:UIControlStateNormal];
        
        NSURL *userImageURL = [NSURL URLWithString:self.review.creator_img_thumb];
        [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];

        
        
        return cell;
    }
    else if( indexPath.row == [self.review.comments count] + 1 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0) )
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"footer" forIndexPath:indexPath];
        
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
                [usernames appendString:[NSString stringWithFormat:@" %@", obj.username]];
            }];
            
            cell.commentLabel.text = usernames;
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
            DAComment *comment = [self.review.comments objectAtIndex:indexPath.row - 1 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0)];
            
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
    NSString *usernameString = [NSString stringWithFormat:@"@%@", comment.creator_username];
    NSAttributedString *attributedUsernameString = [[NSAttributedString alloc] initWithString:usernameString attributes:@{ NSForegroundColorAttributeName : [UIColor dishedColor], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] }];
    NSMutableAttributedString *labelString = [attributedUsernameString mutableCopy];
    
    if( [comment.creator_type isEqualToString:@"influencer"] )
    {
        [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSTextAttachment *avatarIcon = [[NSTextAttachment alloc] init];
        avatarIcon.image = [UIImage imageNamed:@"avatar-small"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        NSAttributedString *avatarIconString = [NSAttributedString attributedStringWithAttachment:avatarIcon];

        [labelString appendAttributedString:influencerIconString];
        [labelString insertAttributedString:avatarIconString atIndex:0];
    }
    
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    [labelString appendAttributedString:[[NSAttributedString alloc] initWithString:comment.comment attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f] }]];
    
    return labelString;
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
            DAComment *comment = [self.review.comments objectAtIndex:indexPath.row - 1 + ([self.review.yums count] > 0 ? 1 : 0) + ([self.review.hashtags count] > 0 ? 1 : 0)];
            
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

@end