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
#import "DAGradeGraphCollectionViewCell.h"
#import "DAGlobalReviewCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "DAReviewDetailsViewController.h"
#import "DAUserProfileViewController.h"
#import "DATabBarController.h"
#import "UIViewController+ShareView.h"
#import "DAFeedCollectionViewFlowLayout.h"
#import "DADishedViewController+Error.h"

#define kLoadLimit 20

static NSString *const kDishHeaderIdentifier = @"titleHeader";


@interface DAGlobalDishDetailViewController() <DAGlobalDishCollectionViewCellDelegate, DAGlobalReviewCollectionViewCellDelegate, DAGradesGraphCollectionViewCellDelegate, DADishHeaderCollectionReusableViewDelegate>

@property (strong, nonatomic) NSString                         *gradeMode;
@property (strong, nonatomic) DADishProfile                    *dishProfile;
@property (strong, nonatomic) NSURLSessionTask                 *profileLoadTask;
@property (strong, nonatomic) NSURLSessionTask                 *reviewsLoadTask;
@property (strong, nonatomic) UIActivityIndicatorView          *spinner;
@property (strong, nonatomic) DAGlobalDishCollectionViewCell   *referenceDishCell;
@property (strong, nonatomic) DAGlobalReviewCollectionViewCell *referenceReviewCell;

@property (nonatomic) BOOL graphAnimated;
@property (nonatomic) BOOL hasMoreReviews;
@property (nonatomic) BOOL isLoadingMore;

@end


@implementation DAGlobalDishDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gradeMode = kDAPGradeAll;
    self.graphAnimated = NO;
    self.hasMoreReviews = YES;
    self.isLoadingMore = NO;
    
    DAFeedCollectionViewFlowLayout *flowLayout = (DAFeedCollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.navigationBar  = self.navigationController.navigationBar;
    
    self.collectionView.hidden = YES;
    
    self.referenceDishCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"dishCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.referenceReviewCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"reviewCell" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    UINib *headerNib = [UINib nibWithNibName:@"DADishHeaderCollectionReusableView" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDishHeaderIdentifier];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self showSpinner];

    [self loadData];
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

- (void)loadData
{
    NSDictionary *parameters = @{ kIDKey : @(self.dishID), kRowLimitKey : @(kLoadLimit) };
    
    __weak typeof( self ) weakSelf = self;
    
    self.profileLoadTask = [[DAAPIManager sharedManager] GETRequest:kDishesProfileURL withParameters:parameters
    success:^( id response )
    {
        weakSelf.dishProfile = [DADishProfile profileWithData:nilOrJSONObjectForKey( response, kDataKey )];
        [weakSelf hideSpinner];
        
        NSArray *reviews = weakSelf.dishProfile.reviews[weakSelf.gradeMode];
        weakSelf.hasMoreReviews = reviews.count >= kLoadLimit;
        
        [weakSelf.collectionView reloadData];
        
        [UIView transitionWithView:weakSelf.collectionView
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        weakSelf.navigationItem.rightBarButtonItem.enabled = YES;
        weakSelf.collectionView.hidden = NO;
        
        [weakSelf dataLoaded];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadData];
        }
        else
        {
            [weakSelf hideSpinner];
            [weakSelf handleError:error];
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
    NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
    NSInteger limit = reviews.count ? reviews.count : kLoadLimit;
    NSDictionary *parameters = @{ kIDKey : @(self.dishID), kGradeKey : [self gradeKeyForGradeMode:self.gradeMode], kRowLimitKey : @(limit) };
    
    __weak typeof( self ) weakSelf = self;
    
    [[DAAPIManager sharedManager] GETRequest:kDishesProfileReviewsURL withParameters:parameters
    success:^( id response )
    {
        NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey );
        [weakSelf.dishProfile setReviewData:nilOrJSONObjectForKey( data, kReviewsKey ) forGradeKey:weakSelf.gradeMode];
        
        NSArray *reviews = weakSelf.dishProfile.reviews[weakSelf.gradeMode];
        weakSelf.hasMoreReviews = reviews.count >= kLoadLimit;
        
        completion();
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf reloadReviewsWithCompletion:completion];
        }
        else
        {
            completion();
        }
    }];
}

- (void)reloadCollectionViewReviewsSectionWithScroll:(BOOL)scroll
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    
    if( scroll )
    {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
}

- (void)loadMoreReviews
{
    NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
    NSUInteger offset = reviews.count;
    NSDictionary *parameters = @{ kIDKey : @(self.dishID), kGradeKey : [self gradeKeyForGradeMode:self.gradeMode],
                                  kRowLimitKey : @(kLoadLimit), kRowOffsetKey : @(offset) };
    
    self.isLoadingMore = YES;
    
    __weak typeof( self ) weakSelf = self;
    
    [[DAAPIManager sharedManager] GETRequest:kDishesProfileReviewsURL withParameters:parameters
    success:^( id response )
    {
        NSDictionary *data = nilOrJSONObjectForKey( response, kDataKey );
        NSArray *newReviews = nilOrJSONObjectForKey( data, kReviewsKey );
        [weakSelf.dishProfile addReviewData:nilOrJSONObjectForKey( data, kReviewsKey ) forGradeKey:weakSelf.gradeMode];
        
        weakSelf.hasMoreReviews = newReviews.count >= kLoadLimit;
        
        [weakSelf reloadCollectionViewReviewsSectionWithScroll:NO];
        
        weakSelf.isLoadingMore = NO;
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf loadMoreReviews];
        }
        else
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];

            if( errorType == eErrorTypeDataNonexists )
            {
                weakSelf.hasMoreReviews = NO;
                [weakSelf reloadCollectionViewReviewsSectionWithScroll:NO];
            }
            
            weakSelf.isLoadingMore = NO;
        }
    }];
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
            
            reviewCell.timeLabel.attributedText = [review.created attributedTimeStringWithAttributes:nil];
            
            reviewCell.delegate = self;
            
            cell = reviewCell;
        }
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;
    
    if( kind == UICollectionElementKindSectionHeader )
    {
        if( indexPath.section == 0 )
        {
            DADishHeaderCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kDishHeaderIdentifier forIndexPath:indexPath];
            
            [header.titleButton setTitle:self.dishProfile.name forState:UIControlStateNormal];
            
            if( self.dishProfile.price && [self.dishProfile.price integerValue] > 0 )
            {
                header.sideLabel.text = [NSString stringWithFormat:@"$%@", self.dishProfile.price];
            }
            
            view = header;
        }
        else
        {
            view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"dummyHeader" forIndexPath:indexPath];
        }
    }
    else if( kind == UICollectionElementKindSectionFooter && indexPath.section == 1 )
    {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"loadingFooter" forIndexPath:indexPath];
    }
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if( section == 0 )
    {
        return CGSizeMake( self.collectionView.frame.size.height, 40 );
    }
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if( section == 1 && self.hasMoreReviews )
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        
        return flowLayout.footerReferenceSize;
    }
    
    return CGSizeZero;
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
    else if( [grade isEqualToString:@"b"] )
    {
        return [UIColor yellowGradeColor];
    }
    else if( [grade isEqualToString:@"c"] )
    {
        return [UIColor orangeGradeColor];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if( self.hasMoreReviews && !self.isLoadingMore && bottomEdge >= scrollView.contentSize.height )
    {
        [self loadMoreReviews];
    }
}

- (void)dealloc
{
    [self.profileLoadTask cancel];
}

- (void)gradeGraphCollectionViewCell:(DAGradeGraphCollectionViewCell *)cell didSelectGradeGraphMode:(eGradeGraphMode)gradeGraphMode
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
        [self reloadCollectionViewReviewsSectionWithScroll:NO];
        [cell endLoading];
    }];
    
    [self reloadCollectionViewReviewsSectionWithScroll:YES];
}

- (void)moreButtonTappedInGradeGraphCollectionViewCell:(DAGradeGraphCollectionViewCell *)cell
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
    DAReview *review = [reviews objectAtIndex:indexPath.row];
    
    [self pushUserProfileWithUsername:review.creator_username];
}

- (void)commentTappedOnGlobalReviewCollectionViewCell:(DAGlobalReviewCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSArray *reviews = self.dishProfile.reviews[self.gradeMode];
    DAReview *review = [reviews objectAtIndex:indexPath.row];
    
    if( review.review_id == self.presentingReviewID )
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self pushReviewDetailsViewWithReviewID:review.review_id];
    }
}

- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller
{
    [self dismissShareView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (IBAction)shareBarButtonTapped:(UIBarButtonItem *)sender
{
    [self showShareViewWithDish:self.dishProfile];
    sender.enabled = NO;
}

@end