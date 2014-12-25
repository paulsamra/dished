//
//  DAUserProfileViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserProfileViewController.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "DADishTableViewCell.h"
#import "DAUserListViewController.h"
#import "DAReviewDetailsViewController.h"
#import "DAGlobalDishDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DAUserProfile.h"
#import "DARestaurantProfile.h"
#import "DAEditProfileViewController.h"
#import "DADishesMapViewController.h"

static NSInteger kRowLimit = 20;
static NSString *const kDishSearchCellID = @"dishCell";


@interface DAUserProfileViewController() <UIActionSheetDelegate, UIAlertViewDelegate, DADishTableViewCellDelegate>

@property (weak,   nonatomic) NSArray                 *selectedDataSource;
@property (weak,   nonatomic) UITableView             *selectedTableView;
@property (strong, nonatomic) CLPlacemark             *directionsPlacemark;
@property (strong, nonatomic) NSURLSessionTask        *profileLoadTask;
@property (strong, nonatomic) NSURLSessionTask        *followTask;
@property (strong, nonatomic) NSURLSessionTask        *spamReportTask;
@property (strong, nonatomic) DAUserProfile           *userProfile;
@property (strong, nonatomic) DARestaurantProfile     *restaurantProfile;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL hasMoreFoodDishes;
@property (nonatomic) BOOL hasMoreCocktailDishes;
@property (nonatomic) BOOL hasMoreWineDishes;
@property (nonatomic) BOOL isLoadingMoreFoodDishes;
@property (nonatomic) BOOL isLoadingMoreCocktailDishes;
@property (nonatomic) BOOL isLoadingMoreWineDishes;

@end


@implementation DAUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hasMoreFoodDishes = YES;
    self.hasMoreCocktailDishes = YES;
    self.hasMoreWineDishes = YES;
    self.isLoadingMoreFoodDishes = NO;
    self.isLoadingMoreCocktailDishes = NO;
    self.isLoadingMoreWineDishes = NO;
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DADishTableViewCell" bundle:nil];
    [self.foodTableView     registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    [self.cocktailTableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    [self.wineTableView     registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    self.selectedTableView = self.foodTableView;
    self.cocktailTableView.hidden = YES;
    self.wineTableView.hidden = YES;
    
    self.userImageView.layer.masksToBounds = YES;
    self.privacyLabel.hidden = YES;
    
    [self setMainViewsHidden:YES animated:NO];
    
    if( self.username )
    {
        if( [self.username characterAtIndex:0] == '@' )
        {
            self.username = [self.username substringFromIndex:1];
        }
        
        self.navigationItem.title = self.isRestaurant ? self.username : [NSString stringWithFormat:@"@%@", self.username];
    }
    
    for( NSLayoutConstraint *constraint in self.seperatorConstraints )
    {
        constraint.constant = 0.5;
    }
    
    [self createFooterForTableView:self.foodTableView];
    [self createFooterForTableView:self.cocktailTableView];
    [self createFooterForTableView:self.wineTableView];
    [self loadData];
}

- (void)setMainViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if( animated )
    {
        [UIView transitionWithView:self.topView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.topView.hidden = hidden;
        
        [UIView transitionWithView:self.descriptionTextView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.descriptionTextView.hidden = hidden;
        
        [UIView transitionWithView:self.middleView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.middleView.hidden = hidden;
        
        if( !self.restaurantProfile.is_private && !self.userProfile.is_private )
        {
            [UIView transitionWithView:self.selectedTableView
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
            
            self.selectedTableView.hidden = hidden;
        }
        else
        {
            if( !self.isRestaurant )
            {
                self.dishesMapButton.hidden = YES;
                self.moreInfoButton.hidden = YES;
            }
            
            self.privacyLabel.hidden = NO;
        }
    }
    else
    {
        self.topView.hidden = hidden;
        self.descriptionTextView.hidden = hidden;
        self.middleView.hidden = hidden;
        self.foodTableView.hidden = hidden;
        self.cocktailTableView.hidden = hidden;
        self.wineTableView.hidden = hidden;
        
        self.privacyLabel.hidden = !self.restaurantProfile.is_private && !self.userProfile.is_private;
    }
}

- (void)createFooterForTableView:(UITableView *)tableView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0, 0, self.view.frame.size.width, 70 )];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = footerView.center;
    [spinner startAnimating];
    
    [footerView addSubview:spinner];
    
    tableView.tableFooterView = footerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.selectedTableView deselectRowAtIndexPath:[self.selectedTableView indexPathForSelectedRow] animated:YES];
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
    [self showSpinner];

    if( self.isRestaurant )
    {
        [self loadRestaurantProfile];
    }
    else
    {
        [self loadUserProfile];
    }
}

- (void)loadRestaurantProfile
{
    NSDictionary *parameters = self.loc_id == 0 ? @{ kIDKey : @(self.user_id) } : @{ kLocationIDKey : @(self.loc_id) };
    
    CLSLog( @"Loading restaurant profile with parameters: %@", parameters );
    
    self.profileLoadTask = [[DAAPIManager sharedManager] GETRequest:kRestaurantProfileURL withParameters:parameters
    success:^( id response )
    {
        self.restaurantProfile = [[DARestaurantProfile alloc] initWithData:nilOrJSONObjectForKey( response, kDataKey )];
        [self configureForRestaurantProfile];
        [self hideSpinner];
        [self setMainViewsHidden:NO animated:YES];
        [self loadPlacemark];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self loadRestaurantProfile];
        }
    }];
}

- (void)loadUserProfile
{
    NSDictionary *parameters = @{ ( self.username ? kUsernameKey : kIDKey ) :
                                  ( self.username ? self.username : @(self.user_id) ) };
    
    CLSLog( @"Loading user profile with parameters: %@", parameters );
    
    self.profileLoadTask = [[DAAPIManager sharedManager] GETRequest:kUserProfileURL withParameters:parameters
    success:^( id response )
    {
        self.userProfile = [[DAUserProfile alloc] initWithData:nilOrJSONObjectForKey( response, kDataKey )];
        [self configureForUserProfile];
        
        [self hideSpinner];
        
        [self setMainViewsHidden:NO animated:YES];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self loadUserProfile];
        }
    }];
}

- (void)loadMoreDishesOfType:(NSString *)dishType
{
    if( self.isRestaurant )
    {
        [self loadMoreRestaurantDishesOfType:dishType];
    }
    else
    {
        [self loadMoreUserReviewsOfType:dishType];
    }
}

- (void)loadMoreRestaurantDishesOfType:(NSString *)dishType
{
    NSInteger offset = [dishType isEqualToString:kFood] ? self.restaurantProfile.foodDishes.count : [dishType isEqualToString:kCocktail] ? self.restaurantProfile.cocktailDishes.count : self.restaurantProfile.wineDishes.count;
    
    NSDictionary *parameters = @{ kIDKey : @(self.restaurantProfile.user_id), kDishTypeKey : dishType,
                                  kRowLimitKey : @(kRowLimit), kRowOffsetKey : @(offset) };
    
    [[DAAPIManager sharedManager] GETRequest:kRestaurantProfileDishesURL withParameters:parameters
    success:^( id response )
    {
        NSArray *newDishesData = nilOrJSONObjectForKey( response, kDataKey );
         
        if( [dishType isEqualToString:kFood] )
        {
            [self.restaurantProfile addFoodDishesWithData:newDishesData];
        }
        else if( [dishType isEqualToString:kCocktail] )
        {
            [self.restaurantProfile addCocktailDishesWithData:newDishesData];
        }
        else if( [dishType isEqualToString:kWine] )
        {
            [self.restaurantProfile addWineDishesWithData:newDishesData];
        }
         
        [self finishedLoadingMoreDishesOfType:dishType loadCount:newDishesData.count];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        shouldRetry ? [self loadMoreRestaurantDishesOfType:dishType] : [self loadMoreDishType:dishType failedWithError:error];
    }];
}

- (void)loadMoreUserReviewsOfType:(NSString *)dishType
{
    NSInteger offset = [dishType isEqualToString:kFood] ? self.userProfile.foodReviews.count : [dishType isEqualToString:kCocktail] ? self.userProfile.cocktailReviews.count : self.userProfile.wineReviews.count;
    
    NSDictionary *parameters = @{ ( self.username ? kUsernameKey : kIDKey ) :
                                  ( self.username ? self.username : @(self.user_id) ),
                                  kDishTypeKey : dishType,
                                  kRowLimitKey : @(kRowLimit), kRowOffsetKey : @(offset) };
    
    [[DAAPIManager sharedManager] GETRequest:kUserProfileReviewsURL withParameters:parameters
    success:^( id response )
    {
        NSArray *newReviewData = nilOrJSONObjectForKey( response, kDataKey );
        
        if( [dishType isEqualToString:kFood] )
        {
            [self.userProfile addFoodReviewsWithData:newReviewData];
        }
        else if( [dishType isEqualToString:kCocktail] )
        {
            [self.userProfile addCocktailReviewsWithData:newReviewData];
        }
        else if( [dishType isEqualToString:kWine] )
        {
            [self.userProfile addWineReviewsWithData:newReviewData];
        }
         
        [self finishedLoadingMoreDishesOfType:dishType loadCount:newReviewData.count];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        shouldRetry ? [self loadMoreUserReviewsOfType:dishType] : [self loadMoreDishType:dishType failedWithError:error];
    }];
}

- (void)finishedLoadingMoreDishesOfType:(NSString *)dishType loadCount:(NSInteger)count
{
    if( [dishType isEqualToString:kFood] )
    {
        if( self.selectedTableView == self.foodTableView )
        {
            self.selectedDataSource = self.userProfile.foodReviews;
        }
        
        [self.foodTableView reloadData];
        
        if( count < 20 )
        {
            self.hasMoreFoodDishes = NO;
            self.foodTableView.tableFooterView = [[UIView alloc] init];
        }
        
        self.isLoadingMoreFoodDishes = NO;
    }
    else if( [dishType isEqualToString:kCocktail] )
    {
        if( self.selectedTableView == self.cocktailTableView )
        {
            self.selectedDataSource = self.userProfile.cocktailReviews;
        }
        
        [self.cocktailTableView reloadData];
        
        if( count < 20 )
        {
            self.hasMoreCocktailDishes = NO;
            self.cocktailTableView.tableFooterView = [[UIView alloc] init];
        }
        
        self.isLoadingMoreCocktailDishes = NO;
    }
    else if( [dishType isEqualToString:kWine] )
    {
        if( self.selectedTableView == self.wineTableView )
        {
            self.selectedDataSource = self.userProfile.wineReviews;
        }
        
        [self.wineTableView reloadData];
        
        if( count < 20 )
        {
            self.hasMoreWineDishes = NO;
            self.wineTableView.tableFooterView = [[UIView alloc] init];
        }
        
        self.isLoadingMoreWineDishes = NO;
    }
}

- (void)loadMoreDishType:(NSString *)dishType failedWithError:(NSError *)error
{
    eErrorType errorType = [DAAPIManager errorTypeForError:error];
    BOOL noMoreData = errorType == eErrorTypeDataNonexists;
    
    if( [dishType isEqualToString:kFood] )
    {
        self.hasMoreFoodDishes = noMoreData ? NO : YES;
        self.isLoadingMoreFoodDishes = NO;
        
        if( noMoreData )
        {
            self.foodTableView.tableFooterView = [[UIView alloc] init];
        }
        
        [self.foodTableView reloadData];
    }
    else if( [dishType isEqualToString:kCocktail] )
    {
        self.hasMoreCocktailDishes = noMoreData ? NO : YES;
        self.isLoadingMoreCocktailDishes = NO;
        
        if( noMoreData )
        {
            self.cocktailTableView.tableFooterView = [[UIView alloc] init];
        }
        
        [self.cocktailTableView reloadData];
    }
    else if( [dishType isEqualToString:kWine] )
    {
        self.hasMoreWineDishes = noMoreData ? NO : YES;
        self.isLoadingMoreWineDishes = NO;
        
        if( noMoreData )
        {
            self.wineTableView.tableFooterView = [[UIView alloc] init];
        }
        
        [self.wineTableView reloadData];
    }
}

- (void)loadPlacemark
{
    double longitude = self.restaurantProfile.longitude;
    double latitude  = self.restaurantProfile.latitude;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^( NSArray *placemarks, NSError *error )
    {
        if( !error && placemarks && placemarks.count > 0 )
        {
            self.directionsPlacemark = placemarks[0];
        }
    }];
}

- (void)configureForRestaurantProfile
{
    self.navigationItem.title = self.restaurantProfile.name;
    
    NSURL *url = [NSURL URLWithString:self.restaurantProfile.img_thumb];
    [self.userImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    self.restaurantProfile.is_profile_owner ? [self setFollowButtonToProfileOwner] : [self setFollowButtonState];
    
    if( self.restaurantProfile.is_profile_owner )
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActionSheet)];
        self.navigationItem.rightBarButtonItem = moreButton;
    }
    
    self.selectedDataSource = self.restaurantProfile.foodDishes;
    
    self.numDishesButton.hidden       = YES;
    self.numFollowersButton.hidden    = YES;
    self.numFollowingButton.hidden    = YES;
    self.descriptionSeperator.hidden  = YES;
    self.thirdButtonSeperator.hidden  = YES;
    self.secondButtonSeperator.hidden = YES;
    
    self.userImageView.layer.cornerRadius     = 10;
    self.descriptionHeightConstraint.constant = 0;
    
    NSString *phoneNumberString = @"No Phone\nNumber";
    
    if( self.restaurantProfile.phone && [self.restaurantProfile.phone integerValue] > 0 )
    {
        phoneNumberString = [NSString stringWithFormat:@"(%@) %@-%@", [self.restaurantProfile.phone substringWithRange:NSMakeRange( 0, 3 )], [self.restaurantProfile.phone substringWithRange:NSMakeRange( 3, 3 )], [self.restaurantProfile.phone substringFromIndex:6]];
    }
    else
    {
        [self.phoneNumberButton setImage:nil forState:UIControlStateNormal];
    }
    self.phoneNumberButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.phoneNumberButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.phoneNumberButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.phoneNumberButton setTitle:phoneNumberString forState:UIControlStateNormal];
    self.phoneNumberButton.enabled = [self.restaurantProfile.phone integerValue] > 0 ? YES : NO;
    
    [self.moreInfoButton setImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [self.moreInfoButton addTarget:self action:@selector(showGradeInfoAlert) forControlEvents:UIControlEventTouchUpInside];
    
    [self.dishesMapButton setImage:nil forState:UIControlStateNormal];
    self.dishesMapButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.dishesMapButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.dishesMapButton setTitle:self.restaurantProfile.avg_grade forState:UIControlStateNormal];
    self.dishesMapButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0];
    [self.dishesMapButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.dishesMapButton removeTarget:self action:@selector(goToDishesMap) forControlEvents:UIControlEventTouchUpInside];
    
    if( self.restaurantProfile.foodDishes.count < 20 )
    {
        self.foodTableView.tableFooterView = [[UIView alloc] init];
        self.hasMoreFoodDishes = NO;
    }
    
    if( self.restaurantProfile.cocktailDishes.count < 20 )
    {
        self.cocktailTableView.tableFooterView = [[UIView alloc] init];
        self.hasMoreCocktailDishes = NO;
    }
    
    if( self.restaurantProfile.wineDishes.count < 20 )
    {
        self.wineTableView.tableFooterView = [[UIView alloc] init];
        self.hasMoreWineDishes = NO;
    }
    
    [self.selectedTableView reloadData];
    
    if( self.restaurantProfile.is_private )
    {
        self.dishTypeChooser.enabled = NO;
    }
}

- (void)configureForUserProfile
{
    self.navigationItem.title = [NSString stringWithFormat:@"@%@", self.userProfile.username];
    
    NSURL *url = [NSURL URLWithString:self.userProfile.img_thumb];
    [self.userImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    self.userProfile.is_profile_owner ? [self setFollowButtonToProfileOwner] : [self setFollowButtonState];
    
    if( self.userProfile.is_profile_owner )
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActionSheet)];
        self.navigationItem.rightBarButtonItem = moreButton;
    }
    
    self.selectedDataSource = self.userProfile.foodReviews;
    
    self.directionsButton.hidden      = YES;
    self.phoneNumberButton.hidden     = YES;
    self.centerButtonSeperator.hidden = YES;
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    
    [self setTitle:@"Dishes"    withValue:self.userProfile.num_reviews   forButton:self.numDishesButton];
    [self setTitle:@"Following" withValue:self.userProfile.num_following forButton:self.numFollowingButton];
    [self setTitle:@"Followers" withValue:self.userProfile.num_followers forButton:self.numFollowersButton];
    
    self.moreInfoButton.userInteractionEnabled = NO;
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", self.userProfile.firstName, self.userProfile.lastName];
    [self setDescriptionTextWithName:name description:self.userProfile.desc];
    
    if( self.userProfile.foodReviews.count < 20 )
    {
        self.foodTableView.tableFooterView = [[UIView alloc] init];
        self.hasMoreFoodDishes = NO;
    }
    
    if( self.userProfile.cocktailReviews.count < 20 )
    {
        self.cocktailTableView.tableFooterView = [[UIView alloc] init];
        self.hasMoreCocktailDishes = NO;
    }
    
    if( self.userProfile.wineReviews.count < 20 )
    {
        self.wineTableView.tableFooterView = [[UIView alloc] init];
        self.hasMoreWineDishes = NO;
    }
    
    [self.selectedTableView reloadData];
    
    if( self.userProfile.is_private )
    {
        self.dishTypeChooser.enabled = NO;
    }
}

- (void)setTitle:(NSString *)title withValue:(NSInteger)value forButton:(UIButton *)button
{
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:[NSString stringWithFormat:@"%d\n%@", (int)value, title] forState:UIControlStateNormal];
}

- (void)setFollowButtonState
{
    BOOL isFollowed = self.isRestaurant ? self.restaurantProfile.caller_follows : self.userProfile.caller_follows;
    
    self.followButton.backgroundColor = isFollowed ? [UIColor clearColor] : [UIColor followButtonColor];
    
    NSString *buttonTitle = isFollowed ? @"Unfollow" : @"Follow";
    [self.followButton setTitle:buttonTitle forState:UIControlStateNormal];
    
    UIColor *titleColor = isFollowed ? [UIColor redColor] : [UIColor whiteColor];
    [self.followButton setTitleColor:titleColor forState:UIControlStateNormal];
}

- (void)setFollowButtonToProfileOwner
{
    self.followButton.backgroundColor = [UIColor clearColor];
    [self.followButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
    [self.followButton setTitle:@"Edit Your Profile" forState:UIControlStateNormal];
}

- (void)setDescriptionTextWithName:(NSString *)name description:(NSString *)description
{
    NSDictionary *nameAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14] };
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:name attributes:nameAttributes];
    
    if( [self.userProfile.type isEqualToString:kInfluencerUserType] )
    {
        [nameString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [nameString appendAttributedString:influencerIconString];
    }
    
    if( description.length > 0 )
    {
        NSDictionary *descriptionAttributes = @{ NSFontAttributeName : [UIFont fontWithName:kHelveticaNeueLightFont size:14] };
        
        NSMutableAttributedString *descriptionString = [[NSMutableAttributedString alloc] initWithString:description attributes:descriptionAttributes];
        
        [nameString appendAttributedString:[[NSAttributedString alloc] initWithString:@" - " attributes:descriptionAttributes]];
        [nameString appendAttributedString:descriptionString];
    }
    
    self.descriptionTextView.attributedText = nameString;
    
    CGFloat textViewWidth = self.view.frame.size.width;
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    CGSize stringSize = [self.descriptionTextView sizeThatFits:boundingSize];

    CGFloat heightConstraint = stringSize.height;
    
    self.descriptionHeightConstraint.constant = heightConstraint;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedDataSource.count == 0 ? 1 : self.selectedDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.selectedDataSource.count == 0 )
    {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        cell.textLabel.font = [UIFont fontWithName:kHelveticaNeueLightFont size:17];
        cell.textLabel.text = self.isRestaurant ? @"No Dishes" : @"No Reviews";
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    DADishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishSearchCellID];
    
    if( self.isRestaurant )
    {
        DADish *result = [self.selectedDataSource objectAtIndex:indexPath.row];
        
        cell.dishNameLabel.text = result.name;
        
        NSURL *url = [NSURL URLWithString:result.imageURL];
        [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        cell.isExplore = YES;
        cell.locationButton.hidden = YES;
        cell.locationIconImageView.hidden = YES;
        
        cell.leftNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.totalReviews];
        cell.middleNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.friendReviews];
        cell.rightNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.influencerReviews];
        
        cell.gradeLabel.text = result.avg_grade;
    }
    else
    {
        DAReview *review = [self.selectedDataSource objectAtIndex:indexPath.row];
        
        cell.dishNameLabel.text = review.name;
        
        NSURL *url = [NSURL URLWithString:review.img_thumb];
        [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        cell.isExplore = NO;
        cell.gradeLabel.text = review.grade;
        [cell.locationButton setTitle:review.loc_name forState:UIControlStateNormal];
        cell.rightNumberLabel.text = [NSString stringWithFormat:@"%d", (int)review.num_comments];
        cell.delegate = self;
    }
    
    return cell;
}

- (void)locationButtonTappedOnDishTableViewCell:(DADishTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.selectedTableView indexPathForCell:cell];
    DAReview *result = [self.selectedDataSource objectAtIndex:indexPath.row];
    
    [self pushRestaurantProfileWithLocationID:result.loc_id username:result.loc_name];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.selectedDataSource.count == 0 )
    {
        return tableView.rowHeight;
    }
    
    return 97;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.selectedDataSource.count == 0 )
    {
        return tableView.rowHeight;
    }
    
    return 97;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.isRestaurant )
    {
        DADish *dish = [self.selectedDataSource objectAtIndex:indexPath.row];
        
        [self pushGlobalDishViewWithDishID:dish.dishID];
    }
    else
    {
        DAReview *review = [self.selectedDataSource objectAtIndex:indexPath.row];
        
        [self pushReviewDetailsViewWithReviewID:review.review_id];
    }
}

- (IBAction)changeDishType
{
    self.selectedTableView.hidden = YES;

    switch( self.dishTypeChooser.selectedSegmentIndex )
    {
        case 0:
            self.selectedTableView = self.foodTableView;
            [self.view bringSubviewToFront:self.foodTableView];
            self.selectedDataSource = self.isRestaurant ? self.restaurantProfile.foodDishes : self.userProfile.foodReviews;
            break;
            
        case 1:
            self.selectedTableView = self.cocktailTableView;
            [self.view bringSubviewToFront:self.cocktailTableView];
            self.selectedDataSource = self.isRestaurant ? self.restaurantProfile.cocktailDishes : self.userProfile.cocktailReviews;
            break;
            
        case 2:
            self.selectedTableView = self.wineTableView;
            [self.view bringSubviewToFront:self.wineTableView];
            self.selectedDataSource = self.isRestaurant ? self.restaurantProfile.wineDishes : self.userProfile.wineReviews;
            break;
    }
    
    self.selectedTableView.hidden = NO;
    [self.selectedTableView reloadData];
}

- (void)showMoreActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Block User" otherButtonTitles:@"Report for Spam", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.cancelButtonIndex )
    {
        return;
    }
    
    if( buttonIndex == actionSheet.destructiveButtonIndex )
    {
        [self blockUser];
    }
    else
    {
        [self reportUserForSpam];
    }
}

- (void)blockUser
{
    
}

- (void)reportUserForSpam
{
    [self.spamReportTask cancel];
    
    NSDictionary *parameters = @{ kIDKey : @(self.userProfile.user_id) };
    
    self.spamReportTask = [[DAAPIManager sharedManager] POSTRequest:kReportUserURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self reportUserForSpam];
        }
    }];
}

- (IBAction)goToDishesMap
{
    DADishesMapViewController *dishesMapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"dishesMap"];
    
    NSArray *dishes = self.userProfile.foodReviews;
    dishes = [dishes arrayByAddingObjectsFromArray:self.userProfile.wineReviews];
    dishes = [dishes arrayByAddingObjectsFromArray:self.userProfile.cocktailReviews];
    
    dishesMapViewController.dishes = dishes;
    
    [self.navigationController pushViewController:dishesMapViewController animated:YES];
}

- (IBAction)showGradeInfoAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This grade is averaged from\nall the dish reviews at this\nrestaurant." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)followButtonPressed
{
    BOOL isOwnProfile = self.isRestaurant ? self.restaurantProfile.is_profile_owner : self.userProfile.is_profile_owner;
    
    if( !isOwnProfile )
    {
        [self.followTask cancel];
        
        BOOL isFollowed = self.isRestaurant ? self.restaurantProfile.caller_follows : self.userProfile.caller_follows;
        NSInteger user_id = self.isRestaurant ? self.restaurantProfile.user_id : self.userProfile.user_id;
        isFollowed ? [self unfollowUserID:user_id] : [self followUserID:user_id];
        
        self.restaurantProfile.caller_follows = !isFollowed;
        self.userProfile.caller_follows = !isFollowed;
        [self setFollowButtonState];
    }
    else
    {
        DAEditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfile"];
        [self.navigationController pushViewController:editProfileViewController animated:YES];
    }
}

- (IBAction)numFollowingPressed
{
    DAUserListViewController *followListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userList"];
    followListViewController.listContent = eUserListContentFollowing;
    followListViewController.object_id = self.isRestaurant ? self.restaurantProfile.user_id : self.userProfile.user_id;
    
    [self.navigationController pushViewController:followListViewController animated:YES];
}

- (IBAction)numFollowersPressed
{
    DAUserListViewController *followListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userList"];
    followListViewController.listContent = eUserListContentFollowers;
    followListViewController.object_id = self.isRestaurant ? self.restaurantProfile.user_id : self.userProfile.user_id;
    
    [self.navigationController pushViewController:followListViewController animated:YES];
}

- (void)followUserID:(NSInteger)userID
{
    self.restaurantProfile.caller_follows = self.userProfile.caller_follows = YES;
    [self setFollowButtonState];
    
    NSDictionary *parameters = @{ kIDKey : @(userID) };
    
    self.followTask = [[DAAPIManager sharedManager] POSTRequest:kFollowUserURL withParameters:parameters
    success:nil failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self followUserID:userID];
        }
        else
        {
            self.restaurantProfile.caller_follows = self.userProfile.caller_follows = NO;
            [self setFollowButtonState];
        }
    }];
}

- (void)unfollowUserID:(NSInteger)userID
{
    self.restaurantProfile.caller_follows = self.userProfile.caller_follows = NO;
    [self setFollowButtonState];
    
    NSDictionary *parameters = @{ kIDKey : @(userID) };
    
    self.followTask = [[DAAPIManager sharedManager] POSTRequest:kUnfollowUserURL withParameters:parameters
    success:nil failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self unfollowUserID:userID];
        }
        else
        {
            self.restaurantProfile.caller_follows = self.userProfile.caller_follows = YES;
            [self setFollowButtonState];
        }
    }];
}

- (IBAction)phoneNumberButtonTapped
{
    if( self.restaurantProfile.phone.length > 0 )
    {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.restaurantProfile.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (IBAction)directionsButtonTapped
{
    NSString *title = [NSString stringWithFormat:@"Directions to %@", self.restaurantProfile.name];
    [[[UIAlertView alloc] initWithTitle:title message:@"Do you want to open the Maps app to view directions?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)openDirections
{
    if( self.directionsPlacemark )
    {
        [self openMapsDirectionsWithPlacemark:self.directionsPlacemark];
    }
    else
    {
        double longitude = self.restaurantProfile.longitude;
        double latitude  = self.restaurantProfile.latitude;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^( NSArray *placemarks, NSError *error )
        {
            if( !error && placemarks && placemarks.count > 0 )
            {
                CLPlacemark *placemark = placemarks[0];
                 
                [self openMapsDirectionsWithPlacemark:placemark];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Error Occured" message:@"There was a problem with opening maps directions. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        }];
    }
}

- (void)openMapsDirectionsWithPlacemark:(CLPlacemark *)placemark
{
    double longitude = self.restaurantProfile.longitude;
    double latitude  = self.restaurantProfile.latitude;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake( latitude, longitude );
    MKPlacemark *placemark2 = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:placemark.addressDictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark2];
    mapItem.name = self.restaurantProfile.name;
    
    NSDictionary *launchOptions = @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving };
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex != alertView.cancelButtonIndex )
    {
        [self openDirections];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    
    if( bottomEdge >= scrollView.contentSize.height )
    {
        if( scrollView == self.foodTableView && self.hasMoreFoodDishes && !self.isLoadingMoreFoodDishes )
        {
            self.isLoadingMoreFoodDishes = YES;
            [self loadMoreDishesOfType:kFood];
        }
        else if( scrollView == self.cocktailTableView && self.hasMoreCocktailDishes && !self.isLoadingMoreCocktailDishes )
        {
            self.isLoadingMoreCocktailDishes = YES;
            [self loadMoreDishesOfType:kCocktail];
        }
        else if( scrollView == self.wineTableView && self.hasMoreWineDishes && !self.isLoadingMoreWineDishes )
        {
            self.isLoadingMoreWineDishes = YES;
            [self loadMoreDishesOfType:kWine];
        }
    }
}

@end