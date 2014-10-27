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
#import "DAGlobalDishCollectionViewCell.h"
#import "DAGradeGraphCollectionViewCell.h"
#import "DAGlobalReviewCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSAttributedString+Dished.h"
#import "DAReviewDetailsViewController.h"
#import "DAUserProfileViewController.h"
#import "DATabBarController.h"


@interface DAGlobalDishDetailViewController() <DAGlobalDishCollectionViewCellDelegate, DAGlobalReviewCollectionViewCellDelegate>

@property (strong, nonatomic) DADishProfile                    *dishProfile;
@property (strong, nonatomic) UIActivityIndicatorView          *spinner;
@property (strong, nonatomic) DAGlobalDishCollectionViewCell   *referenceDishCell;
@property (strong, nonatomic) DAGlobalReviewCollectionViewCell *referenceReviewCell;

@property (nonatomic) BOOL   graphAnimated;
@property (nonatomic) CGRect keyboardFrame;

@end


@implementation DAGlobalDishDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.graphAnimated = NO;
    
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

    self.referenceDishCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"dishCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.referenceReviewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
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
        DAGlobalDishCollectionViewCell *mainCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"dishCell" forIndexPath:indexPath];
        
        mainCell.delegate = self;
        
        mainCell.titleLabel.text = self.dishProfile.name;
        
        if( self.dishProfile.price && [self.dishProfile.price integerValue] > 0 )
        {
            mainCell.priceLabel.text = [NSString stringWithFormat:@"$%@", self.dishProfile.price];
        }
        else
        {
            mainCell.priceLabel.text = @"";
        }
        
        [mainCell setPagedImages:self.dishProfile.images];
        
        UIImage *locationIcon = [[UIImage imageNamed:@"dish_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [mainCell.locationButton setTitle:self.dishProfile.loc_name forState:UIControlStateNormal];
        [mainCell.locationButton setImage:locationIcon  forState:UIControlStateNormal];
        [mainCell.locationButton setTitleEdgeInsets:UIEdgeInsetsMake( 0, 5, 0, 0 )];
        
        NSString *photosNumberString = [NSString stringWithFormat:@"%d", (int)self.dishProfile.num_images];
        [mainCell.photosNumberButton setTitle:photosNumberString forState:UIControlStateNormal];
        
        mainCell.gradeLabel.text = self.dishProfile.grade;
        
        if( self.dishProfile.desc )
        {
            mainCell.descriptionTextView.attributedText = [self attributedDishDescriptionTextWithDescription:self.dishProfile.desc];
        }
        
        NSString *yumsNumberString = [NSString stringWithFormat:@"%d", (int)self.dishProfile.num_yums];
        [mainCell.yumsNumberButton setTitle:yumsNumberString forState:UIControlStateNormal];
        
        cell = mainCell;
    }
    else if( indexPath.row == 1 )
    {
        DAGradeGraphCollectionViewCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gradeGraph" forIndexPath:indexPath];
        
        graphCell.control.gradeValues = self.dishProfile.num_grades;
        
        cell = graphCell;
    }
    else if( indexPath.row > 1 )
    {
        DAGlobalReviewCollectionViewCell *reviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:indexPath];
        DAGlobalReview *review = [self.dishProfile.reviews objectAtIndex:indexPath.row - 2];
        
        NSString *usernameString = [NSString stringWithFormat:@"@%@", review.creator_username];
        if( [review.creator_type isEqualToString:@"influencer"] )
        {
            usernameString = [NSString stringWithFormat:@" %@", usernameString];
            [reviewCell.usernameButton setImage:[UIImage imageNamed:@"influencer"] forState:UIControlStateNormal];
        }
        [reviewCell.usernameButton setTitle:usernameString forState:UIControlStateNormal];
        
        UIImage *placeholderImage = [UIImage imageNamed:@"profile_image"];
        NSURL *userImageURL = [NSURL URLWithString:review.creator_img_thumb];
        [reviewCell.userImageView sd_setImageWithURL:userImageURL placeholderImage:placeholderImage];
        reviewCell.userImageView.backgroundColor = self.collectionView.backgroundColor;
        
        NSString *grade = [review.grade substringToIndex:1];
        UIColor *gradeColor = [self colorWithGrade:grade];
        reviewCell.gradeView.layer.borderColor = gradeColor.CGColor;
        reviewCell.gradeView.layer.borderWidth = 1;
        
        reviewCell.gradeLabel.text = review.grade;
        reviewCell.gradeLabel.textColor = gradeColor;
        
        reviewCell.commentTextView.text = review.comment;
        reviewCell.commentTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        
        reviewCell.timeLabel.attributedText = [NSAttributedString attributedTimeStringWithDate:review.created];
        
        reviewCell.delegate = self;
        
        cell = reviewCell;
    }
    
    return cell;
}

- (NSAttributedString *)attributedDishDescriptionTextWithDescription:(NSString *)description
{
    return [[NSAttributedString alloc] initWithString:description attributes:[DAGlobalDishCollectionViewCell descriptionTextAttributes]];
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
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    
    if( !self.dishProfile )
    {
        return flowLayout.itemSize;
    }
    
    if( indexPath.row == 0 )
    {
        CGSize cellSize = flowLayout.itemSize;
        cellSize.width = collectionView.frame.size.width;
        cellSize.height -= self.referenceDishCell.descriptionTextView.frame.size.height;
        
        if( !self.dishProfile.desc )
        {
            return cellSize;
        }
        
        NSAttributedString *descriptionString = [self attributedDishDescriptionTextWithDescription:self.dishProfile.desc];
        
        CGSize boundingSize = CGSizeMake( self.referenceDishCell.descriptionTextView.frame.size.width, CGFLOAT_MAX );
        CGRect stringRect   = [descriptionString boundingRectWithSize:boundingSize
                                                      options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                                      context:nil];
        
        CGFloat textViewHeight = ceilf( stringRect.size.height );
        cellSize.height += textViewHeight;
        
        return cellSize;
    }
    if( indexPath.row == 1 )
    {
        return CGSizeMake(self.collectionView.frame.size.width, 209.0);
    }
    else
    {
        DAGlobalReview *review = [self.dishProfile.reviews objectAtIndex:indexPath.row - 2];
        
        CGSize cellSize = self.referenceReviewCell.frame.size;
        CGRect textViewRect = self.referenceReviewCell.commentTextView.frame;
        cellSize.width = collectionView.frame.size.width;
        cellSize.height = textViewRect.origin.y + textViewRect.size.height;
        CGSize referenceSize = cellSize;
        
        if( !review.comment )
        {
            return cellSize;
        }
        
        cellSize.height -= textViewRect.size.height;
        
        NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:review.comment attributes:[DAGlobalReviewCollectionViewCell commentTextAttributes]];
        
        CGSize boundingSize = CGSizeMake( textViewRect.size.width, CGFLOAT_MAX );
        CGRect stringRect   = [commentString boundingRectWithSize:boundingSize
                                                          options:( NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading )
                                                          context:nil];
        
        CGFloat textViewHeight = ceilf( stringRect.size.height );
        cellSize.height += textViewHeight;
        
        cellSize.height = cellSize.height < referenceSize.height ? referenceSize.height : cellSize.height;
        
        return cellSize;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == 1 && !self.graphAnimated )
    {
        DAGradeGraphCollectionViewCell *graphCell = (DAGradeGraphCollectionViewCell *)cell;
        
        graphCell.control.gradeValues = self.dishProfile.num_grades;
        [graphCell.control sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( !self.graphAnimated )
    {
        CGFloat navigtionBarHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat staturBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        CGFloat scrollOffset = scrollView.contentOffset.y + navigtionBarHeight + staturBarHeight;
        
        if( scrollOffset > self.view.frame.size.height / 2 )
        {
            NSIndexPath *graphIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
            DAGradeGraphCollectionViewCell *graphCell = (DAGradeGraphCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:graphIndexPath];
            [graphCell.control sendActionsForControlEvents:UIControlEventTouchUpInside];
            
            self.graphAnimated = YES;
        }
    }
}

- (void)locationButtonTappedOnGlobalDishCollectionViewCell:(DAGlobalDishCollectionViewCell *)cell
{
    DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userProfileViewController.username = self.dishProfile.loc_name;
    userProfileViewController.user_id  = self.dishProfile.loc_id;
    userProfileViewController.isRestaurant = YES;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)addReviewButtonTappedOnGlobalDishCollectionViewCell:(DAGlobalDishCollectionViewCell *)cell
{
    DATabBarController *tabBarController = (DATabBarController *)self.tabBarController;
    [tabBarController startAddReviewProcessWithDishProfile:self.dishProfile];
}

- (void)usernameButtonTappedOnGlobalReviewCollectionViewCell:(DAGlobalReviewCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAGlobalReview *review = [self.dishProfile.reviews objectAtIndex:indexPath.row - 2];
    
    DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userProfileViewController.username = review.creator_username;
    userProfileViewController.user_id  = review.creator_id;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)commentTappedOnGlobalReviewCollectionViewCell:(DAGlobalReviewCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    DAGlobalReview *review = [self.dishProfile.reviews objectAtIndex:indexPath.row - 2];
    
    if( review.review_id == self.presentingReviewID )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self performSegueWithIdentifier:@"reviewDetails" sender:review];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"reviewDetails"] )
    {
        DAGlobalReview *review = sender;
        DAReviewDetailsViewController *dest = segue.destinationViewController;
        
        dest.reviewID = review.review_id;
    }
}

- (IBAction)shareBarButtonTapped:(UIBarButtonItem *)sender
{
    DATabBarController *tabBarController = (DATabBarController *)self.tabBarController;
    [tabBarController showShareView];
}

@end