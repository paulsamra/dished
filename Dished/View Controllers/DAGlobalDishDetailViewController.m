//
//  DAGlobaelDishDetailViewController.m
//  Dished
//
//  Created by POST on 9/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGlobalDishDetailViewController.h"
#import "DADishProfile.h"
#import "DAGlobalDishCollectionViewCell.h"
#import "DAGradesGraphCollectionViewCell.h"
#import "DAGlobalReviewCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSAttributedString+Dished.h"
#import "DAReviewDetailsViewController.h"
#import "DAUserProfileViewController.h"
#import "DATabBarController.h"
#import "UIViewController+ShareView.h"

#define kLoadLimit 20


@interface DAGlobalDishDetailViewController() <DAGlobalDishCollectionViewCellDelegate, DAGlobalReviewCollectionViewCellDelegate, DAGradesGraphCollectionViewCellDelegate>

@property (strong, nonatomic) NSString                         *gradeMode;
@property (strong, nonatomic) DADishProfile                    *dishProfile;
@property (strong, nonatomic) NSURLSessionTask                 *profileLoadTask;
@property (strong, nonatomic) NSURLSessionTask                 *reviewsLoadTask;
@property (strong, nonatomic) UIActivityIndicatorView          *spinner;
@property (strong, nonatomic) DAGlobalDishCollectionViewCell   *referenceDishCell;
@property (strong, nonatomic) DAGlobalReviewCollectionViewCell *referenceReviewCell;

@property (nonatomic) BOOL graphAnimated;

@end


@implementation DAGlobalDishDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gradeMode = kDAPGradeAll;
    self.graphAnimated = NO;
    
    self.collectionView.hidden = YES;
    
    self.referenceDishCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"dishCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.referenceReviewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    [self showSpinner];

    [self loadDishDetails];
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

- (void)loadDishDetails
{
    NSDictionary *parameters = @{ kIDKey : @(self.dishID) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    __weak typeof( self ) weakSelf = self;
    
    self.profileLoadTask = [[DAAPIManager sharedManager] GETRequest:kDishesProfileURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.dishProfile = [DADishProfile profileWithData:nilOrJSONObjectForKey( response, kDataKey )];
        [weakSelf hideSpinner];
        [weakSelf.collectionView reloadData];
        
        [UIView transitionWithView:weakSelf.collectionView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        weakSelf.collectionView.hidden = NO;
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadDishDetails];
        }
    }];
}

- (NSString *)gradeKeyForGradeMode:(NSString *)gradeMode
{
    NSString *key = @"";
    
    if( gradeMode == kDAPGradeA )
    {
        key = @"a";
    }
    else if( gradeMode == kDAPGradeB )
    {
        key = @"b";
    }
    else if( gradeMode == kDAPGradeC )
    {
        key = @"c";
    }
    else if( gradeMode == kDAPGradeDF )
    {
        key = @"df";
    }
    
    return key;
}

- (void)reloadReviewsWithCompletion:( void(^)() )completion
{
    NSDictionary *parameters = @{ kIDKey : @(self.dishID), kGradeKey : [self gradeKeyForGradeMode:self.gradeMode], kRowLimitKey : @(kLoadLimit) };
    [[DAAPIManager sharedManager] GETRequest:kDishesProfileReviewsURL withParameters:parameters
    success:^( id response )
    {
        NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey );
        [self.dishProfile setReviewData:nilOrJSONObjectForKey( data, kReviewsKey ) forGradeKey:self.gradeMode];
        
        completion();
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self reloadReviewsWithCompletion:completion];
        }
        else
        {
            completion();
        }
    }];
}

- (void)reloadCollectionViewReviewsSection
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)loadMoreReviewsOfGrade:(NSString *)grade
{
    //NSUInteger offset = self.dishProfile.reviews.count;
    //NSDictionary *parameters = @{ kIDKey : @(self.dishID), kGradeKey : grade ? grade : @"", kRowLimitKey : 0 };
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if( section == 0 )
    {
        return 2;
    }
    else
    {
        NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
        return reviews.count ? reviews.count : 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if( indexPath.section == 0 )
    {
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
            DAGradesGraphCollectionViewCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"gradeGraph" forIndexPath:indexPath];
            
            DADishProfile *dp = self.dishProfile;
            [graphCell setGradeValuesWithAGrades:dp.aGrades BGrades:dp.bGrades CGrades:dp.cGrades DFGrades:dp.dfGrades];
            graphCell.delegate = self;
            
            cell = graphCell;
        }
    }
    else
    {
        NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
        
        if( reviews.count == 0 )
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"noReviewsCell" forIndexPath:indexPath];
        }
        else
        {
            DAGlobalReviewCollectionViewCell *reviewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:indexPath];
            DAReview *review = [reviews objectAtIndex:indexPath.row];
            
            NSString *usernameString = [NSString stringWithFormat:@"@%@", review.creator_username];
            if( [review.creator_type isEqualToString:kInfluencerUserType] )
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
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
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
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
        {
            DAGlobalDishCollectionViewCell *sizingCell = self.referenceDishCell;
            
            CGSize cellSize = flowLayout.itemSize;
            cellSize.width = collectionView.frame.size.width;
            cellSize.height -= sizingCell.descriptionTextView.frame.size.height;
            
            if( !self.dishProfile.desc )
            {
                return cellSize;
            }
            
            CGFloat textViewRightMargin = sizingCell.frame.size.width - ( sizingCell.descriptionTextView.frame.origin.x + sizingCell.descriptionTextView.frame.size.width );
            CGFloat textViewWidth = collectionView.frame.size.width - sizingCell.descriptionTextView.frame.origin.x - textViewRightMargin;
            CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
            
            NSAttributedString *descriptionString = [self attributedDishDescriptionTextWithDescription:self.dishProfile.desc];
            
            sizingCell.descriptionTextView.attributedText = descriptionString;
            
            CGSize stringSize = [sizingCell.descriptionTextView sizeThatFits:boundingSize];
            
            CGFloat textViewHeight = ceilf( stringSize.height );
            
            cellSize.height += textViewHeight;
            
            return cellSize;
        }
        else
        {
            return CGSizeMake( self.collectionView.frame.size.width, 209.0 );
        }
    }
    else
    {
        NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
        
        if( reviews.count == 0 )
        {
            return CGSizeMake( self.collectionView.frame.size.width, 100 );
        }
        else
        {
            DAReview *review = [reviews objectAtIndex:indexPath.row];
            
            DAGlobalReviewCollectionViewCell *sizingCell = self.referenceReviewCell;
            
            CGSize cellSize = sizingCell.frame.size;
            CGRect textViewRect = sizingCell.commentTextView.frame;
            cellSize.width = collectionView.frame.size.width;
            cellSize.height = textViewRect.origin.y + textViewRect.size.height;
            CGSize referenceSize = cellSize;
            
            if( !review.comment )
            {
                return cellSize;
            }
            
            cellSize.height -= textViewRect.size.height;
            
            NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:review.comment attributes:[DAGlobalReviewCollectionViewCell commentTextAttributes]];
            
            CGFloat textViewRightMargin = sizingCell.frame.size.width - ( sizingCell.commentTextView.frame.origin.x + sizingCell.commentTextView.frame.size.width );
            CGFloat textViewWidth = collectionView.frame.size.width - sizingCell.commentTextView.frame.origin.x - textViewRightMargin;
            CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
            
            sizingCell.commentTextView.attributedText = commentString;
            
            CGSize stringSize = [sizingCell.commentTextView sizeThatFits:boundingSize];
            
            CGFloat textViewHeight = ceilf( stringSize.height );
            
            cellSize.height += textViewHeight;
            
            cellSize.height = cellSize.height < referenceSize.height ? referenceSize.height : cellSize.height;
            
            return cellSize;
        }

    }
}

- (void)dealloc
{
    [self.profileLoadTask cancel];
    [self.collectionView setDelegate:nil];
}

- (void)gradeGraphCollectionViewCell:(DAGradesGraphCollectionViewCell *)cell didSelectGradeGraphMode:(eGradeGraphMode)gradeGraphMode
{
    [cell beginLoading];
    
    switch( gradeGraphMode )
    {
        case eGradeGraphModeA:    self.gradeMode = kDAPGradeA;   break;
        case eGradeGraphModeB:    self.gradeMode = kDAPGradeB;   break;
        case eGradeGraphModeC:    self.gradeMode = kDAPGradeC;   break;
        case eGradeGraphModeDF:   self.gradeMode = kDAPGradeDF;  break;
        case eGradeGraphModeNone: self.gradeMode = kDAPGradeAll; break;
    }
    
    [self reloadReviewsWithCompletion:^
    {
        [cell endLoading];
    }];
    
    [self reloadCollectionViewReviewsSection];
}

- (void)moreButtonTappedInGradeGraphCollectionViewCell:(DAGradesGraphCollectionViewCell *)cell
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
    NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
    DAReview *review = [reviews objectAtIndex:indexPath.row - 2];
    
    [self pushUserProfileWithUsername:review.creator_username];
}

- (void)commentTappedOnGlobalReviewCollectionViewCell:(DAGlobalReviewCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
    DAReview *review = [reviews objectAtIndex:indexPath.row - 2];
    
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