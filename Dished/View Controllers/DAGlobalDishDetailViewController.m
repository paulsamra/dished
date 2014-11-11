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
#import "UIViewController+ShareView.h"


@interface DAGlobalDishDetailViewController() <DAGlobalDishCollectionViewCellDelegate, DAGlobalReviewCollectionViewCellDelegate, DAGradeGraphCollectionViewCellDelegate>

@property (strong, nonatomic) DADishProfile                    *dishProfile;
@property (strong, nonatomic) UIActivityIndicatorView          *spinner;
@property (strong, nonatomic) DAGlobalDishCollectionViewCell   *referenceDishCell;
@property (strong, nonatomic) DAGlobalReviewCollectionViewCell *referenceReviewCell;

@property (nonatomic) BOOL graphAnimated;

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
            self.dishProfile = [DADishProfile profileWithData:nilOrJSONObjectForKey( response, kDataKey )];
            
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
    
        graphCell.gradeGraph.gradeValues = self.dishProfile.num_grades;
        [graphCell.gradeGraph showGraphData];
        graphCell.delegate = self;
        
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
        reviewCell.commentTextView.font = [UIFont fontWithName:kHelveticaNeueLightFont size:15];
        
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

- (void)dealloc
{
    [self.collectionView setDelegate:nil];
}

- (void)utilityButtonTappedOnGradeGraphCollectionViewCell:(DAGradeGraphCollectionViewCell *)cell
{
    [self shareBarButtonTapped:nil];
}

- (void)locationButtonTappedOnGlobalDishCollectionViewCell:(DAGlobalDishCollectionViewCell *)cell
{
    [self pushRestaurantProfileWithLocationID:self.dishProfile.loc_id username:self.dishProfile.loc_name];
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
    
    [self pushUserProfileWithUsername:review.creator_username];
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
        [self pushReviewDetailsWithReviewID:review.review_id];
    }
}

- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller
{
    [self dismissShareView];
}

- (IBAction)shareBarButtonTapped:(UIBarButtonItem *)sender
{
    [self showShareViewWithDish:self.dishProfile];
}

@end