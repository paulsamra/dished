//
//  DAGlobaelDishDetailViewController.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalDishDetailViewController.h"
#import "DAAPIManager.h"
#import "DADishProfile.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DAComment.h"
#import "DAReviewDetailCollectionViewCell.h"
#import "DAUsername.h"
#import "DAGlobalDishCollectionViewCell.h"
#import "DAGradeGraphCollectionViewCell.h"
#import "DAGlobalReviewCollectionViewCell.h"


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
            self.dishProfile = [DADishProfile profileWithData:response[@"data"]];
            
            [spinner stopAnimating];
            [spinner removeFromSuperview];
            
            [self.collectionView reloadData];
            
            [UIView transitionWithView:self.collectionView
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
            
            self.collectionView.hidden = NO;
        }
    }];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2 + self.dishProfile.reviews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if( indexPath.row == 0 )
    {
        DAGlobalDishCollectionViewCell *mainCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"feedCell" forIndexPath:indexPath];
        
        mainCell.titleLabel.text = self.dishProfile.name;
        
        if( [self.dishProfile.price integerValue] != 0 )
        {
            mainCell.priceLabel.text = [NSString stringWithFormat:@"$%@", self.dishProfile.price];
        }
        
        [mainCell setPagedImages:self.dishProfile.images];
        
        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [mainCell.locationButton setTitle:self.dishProfile.loc_name forState:UIControlStateNormal];
        [mainCell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [mainCell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        mainCell.gradeLabel.text = self.dishProfile.grade;
        
        mainCell.descriptionTextView.text = self.dishProfile.desc;
        
        cell = mainCell;
    }
    else if( indexPath.row == 1 )
    {
        DAGradeGraphCollectionViewCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gradeGraph" forIndexPath:indexPath];
        
        [graphCell.control sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        cell = graphCell;
    }
    else if( indexPath.row > 1 )
    {
        DAGlobalReviewCollectionViewCell *reviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"review" forIndexPath:indexPath];
        DAGlobalReview *review = [self.dishProfile.reviews objectAtIndex:indexPath.row - 2];
        
        reviewCell.usernameLabel.text = [NSString stringWithFormat:@"@%@", review.creator_username];
        
        NSURL *userImageURL = [NSURL URLWithString:review.creator_img_thumb];
        [reviewCell.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"avatar"]];
        
        NSString *grade = [review.grade substringToIndex:1];
        UIColor *gradeColor = [self colorWithGrade:grade];
        reviewCell.gradeView.layer.borderColor = gradeColor.CGColor;
        reviewCell.gradeView.layer.borderWidth = 1;
        
        reviewCell.gradeLabel.text = review.grade;
        reviewCell.gradeLabel.textColor = gradeColor;
        
        reviewCell.commentTextView.text = review.comment;
        
        cell = reviewCell;
    }
    
    return cell;
}

- (UIColor *)colorWithGrade:(NSString *)grade
{
    grade = [grade lowercaseString];
    
    if( [grade isEqualToString:@"a"] )
    {
        return [UIColor greenGradeColor];
    }
    else if( [grade isEqualToString:@"b"] || [grade isEqualToString:@"c"] )
    {
        return [UIColor yellowGradeColor];
    }
    else
    {
        return [UIColor redGradeColor];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 0 )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        
        return flowLayout.itemSize;
    }
    if( indexPath.row == 1 )
    {
        return CGSizeMake(self.collectionView.frame.size.width, 209.0);
    }
    else
    {
        return CGSizeMake(self.collectionView.frame.size.width, 100.0);
    }
}

@end