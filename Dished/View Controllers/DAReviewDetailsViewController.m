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


@interface DAReviewDetailsViewController()

@property (strong, nonatomic) DAReview *review;

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
    return 3 + 11;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        DAFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        NSString *usernameString = [NSString stringWithFormat:@"@%@", self.review.creator_username];
        [cell.creatorButton  setTitle:usernameString     forState:UIControlStateNormal];
        [cell.titleButton    setTitle:self.review.name forState:UIControlStateNormal];
        
        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [cell.locationButton setTitle:self.review.loc_name forState:UIControlStateNormal];
        [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        NSURL *dishImageURL = [NSURL URLWithString:self.review.img];
        [cell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        cell.commentsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        NSString *commentString = [NSString stringWithFormat:@"%d comments", (int)self.review.num_comments];
        [cell.commentsButton setTitle:commentString forState:UIControlStateNormal];
        
        return cell;
    }
    else if( indexPath.row == 11 + 2 )
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        return cell;
    }
    else if( indexPath.row == 1 )
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"users" forIndexPath:indexPath];
        
        return cell;
    }
    else if( indexPath.row == 2 )
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tags" forIndexPath:indexPath];
        
        return cell;
    }
    else
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comment" forIndexPath:indexPath];
        
        return cell;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        return CGSizeMake(self.collectionView.frame.size.width, 375.000000-44);
    }
	else if (indexPath.row == 11 + 2)
	{
        return CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
    else
    {
        return CGSizeMake(self.collectionView.frame.size.width, 44.0);
    }
}

@end