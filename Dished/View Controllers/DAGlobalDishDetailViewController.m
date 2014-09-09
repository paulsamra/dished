//
//  DAGlobaelDishDetailViewController.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalDishDetailViewController.h"
#import "DAFeedCollectionViewCell.h"
#import "DAAPIManager.h"
#import "DADishProfile.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAComment.h"
#import "DAReviewDetailCommentCollectionViewCell.h"
#import "DAUsername.h"
#import "DAFeedCollectionViewCell.h"
#import "DAGradeGraphCollectionViewCell.h"


@interface DAGlobalDishDetailViewController ()

@property (strong, nonatomic) DADishProfile 		  *dishProfile;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end


@implementation DAGlobalDishDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.hidden = YES;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    [[DAAPIManager sharedManager] getGlobalDishInfoForDishID:self.dishID completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
             
        }
        else
        {
            NSLog(@"%@", response);
            self.dishProfile = [DADishProfile profileWithData:response[@"data"]];
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            [self.collectionView reloadData];
            self.collectionView.hidden = NO;
        }
    }];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        DAFeedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
//        NSString *usernameString = [NSString stringWithFormat:@"@%@", self.review.creator_username];
//        [cell.creatorButton  setTitle:usernameString     forState:UIControlStateNormal];
//        [cell.titleButton    setTitle:self.review.name forState:UIControlStateNormal];
//        if (![self.review.price isKindOfClass:[NSNull class]]) {
//            [cell.priceLabel    setTitle:[NSString stringWithFormat:@"$%d", [self.review.price intValue]] forState:UIControlStateNormal];
//        }
//        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        [cell.locationButton setTitle:self.review.loc_name forState:UIControlStateNormal];
//        [cell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
//        [cell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
//        
//        NSURL *dishImageURL = [NSURL URLWithString:self.review.img];
//        [cell.dishImageView setImageWithURL:dishImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        
//        cell.gradeLabel.text = [self.review.grade uppercaseString];
//        
//        NSURL *userImageURL = [NSURL URLWithString:self.review.creator_img_thumb];
//        [cell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
        
        return cell;
    }
    else if( indexPath.row == 1 )
    {
        
        DAGradeGraphCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gradeGraph" forIndexPath:indexPath];
        
        [cell.control sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else
    {
        DAReviewDetailCommentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"comment" forIndexPath:indexPath];
        
        return cell;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        return CGSizeMake(self.collectionView.frame.size.width, 500.0);
    }
    if( indexPath.row == 1 )
    {
        return CGSizeMake(self.collectionView.frame.size.width, 209.0);
    }
    else
    {
        return CGSizeMake(self.collectionView.frame.size.width, 88.0);
    }
}

@end