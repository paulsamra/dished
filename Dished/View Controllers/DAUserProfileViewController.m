//
//  DAUserProfileViewController.m
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAUserProfileViewController.h"
#import "DAAPIManager.h"
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

static NSString *const kDishSearchCellID = @"dishCell";


@interface DAUserProfileViewController() <UIActionSheetDelegate, UIAlertViewDelegate, DADishTableViewCellDelegate>

@property (weak,   nonatomic) NSArray             *selectedDataSource;
@property (strong, nonatomic) NSURLSessionTask    *profileLoadTask;
@property (strong, nonatomic) NSURLSessionTask    *followTask;
@property (strong, nonatomic) NSURLSessionTask    *spamReportTask;
@property (strong, nonatomic) DAUserProfile       *userProfile;
@property (strong, nonatomic) DARestaurantProfile *restaurantProfile;

@end


@implementation DAUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINib *searchCellNib = [UINib nibWithNibName:@"DADishTableViewCell" bundle:nil];
    [self.dishesTableView registerNib:searchCellNib forCellReuseIdentifier:kDishSearchCellID];
    
    self.userImageView.layer.masksToBounds = YES;
    
    self.privacyLabel.hidden = YES;
    
    self.dishesTableView.tableFooterView = [[UIView alloc] init];
    
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
            [UIView transitionWithView:self.dishesTableView
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:nil
                            completion:nil];
            
            self.dishesTableView.hidden = hidden;
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
        self.dishesTableView.hidden = hidden;
        
        self.privacyLabel.hidden = !self.restaurantProfile.is_private && !self.userProfile.is_private;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dishesTableView deselectRowAtIndexPath:[self.dishesTableView indexPathForSelectedRow] animated:YES];
}

- (void)loadData
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = self.view.center;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        if( self.isRestaurant )
        {
            NSDictionary *parameters = @{ @"loc_id" : @(self.user_id) };
            parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
            
            self.profileLoadTask = [[DAAPIManager sharedManager] GET:kRestaurantProfileURL parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                self.restaurantProfile = [[DARestaurantProfile alloc] initWithData:nilOrJSONObjectForKey( responseObject, kDataKey )];
                [self configureForRestaurantProfile];
                
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                [self setMainViewsHidden:NO animated:YES];
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                [self handleError:error];
            }];
        }
        else
        {
            NSDictionary *parameters = @{ ( self.username ? kUsernameKey : kIDKey ) :
                                          ( self.username ? self.username : @(self.user_id) ) };
            parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
            
            self.profileLoadTask = [[DAAPIManager sharedManager] GET:kUserProfileURL parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                self.userProfile = [[DAUserProfile alloc] initWithData:nilOrJSONObjectForKey( responseObject, kDataKey )];
                [self configureForUserProfile];
                
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                [self setMainViewsHidden:NO animated:YES];
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                [self handleError:error];
            }];
        }
    }];
}

- (void)handleError:(NSError *)error
{
    eErrorType errorType = [DAAPIManager errorTypeForError:error];
    
    if( errorType != eErrorTypeRequestCancelled )
    {
        
    }
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
    
    NSString *phoneNumberString = @"No Phone Number";
    
    if( self.restaurantProfile.phone && [self.restaurantProfile.phone integerValue] > 0 )
    {
        phoneNumberString = [NSString stringWithFormat:@"(%@) %@-%@", [self.restaurantProfile.phone substringWithRange:NSMakeRange( 0, 3 )], [self.restaurantProfile.phone substringWithRange:NSMakeRange( 3, 3 )], [self.restaurantProfile.phone substringFromIndex:6]];
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
    
    [self.dishesTableView reloadData];
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

    [self.dishesTableView reloadData];
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
    
    if( [self.userProfile.type isEqualToString:@"influencer"] )
    {
        [nameString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        NSTextAttachment *influencerIcon = [[NSTextAttachment alloc] init];
        influencerIcon.image = [UIImage imageNamed:@"influencer"];
        NSAttributedString *influencerIconString = [NSAttributedString attributedStringWithAttachment:influencerIcon];
        [nameString appendAttributedString:influencerIconString];
    }
    
    if( description.length > 0 )
    {
        NSDictionary *descriptionAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14] };
        
        NSMutableAttributedString *descriptionString = [[NSMutableAttributedString alloc] initWithString:description attributes:descriptionAttributes];
        
        [nameString appendAttributedString:[[NSAttributedString alloc] initWithString:@" - " attributes:descriptionAttributes]];
        [nameString appendAttributedString:descriptionString];
    }
    
    self.descriptionTextView.attributedText = nameString;
    
    CGFloat textViewWidth = self.descriptionTextView.frame.size.width;
    CGSize boundingSize = CGSizeMake( textViewWidth, CGFLOAT_MAX );
    CGRect stringRect = [nameString boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    UIEdgeInsets textViewInsets = self.descriptionTextView.textContainerInset;
    CGFloat heightConstraint = stringRect.size.height + textViewInsets.top + textViewInsets.bottom;
    
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
    NSIndexPath *indexPath = [self.dishesTableView indexPathForCell:cell];
    DADish *result = [self.selectedDataSource objectAtIndex:indexPath.row];
    
    DAUserProfileViewController *restaurantProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    
    restaurantProfileViewController.username = result.locationName;
    restaurantProfileViewController.user_id  = result.locationID;
    restaurantProfileViewController.isRestaurant = YES;
    [self.navigationController pushViewController:restaurantProfileViewController animated:YES];
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
        
        DAGlobalDishDetailViewController *globalDishViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"globalDish"];
        globalDishViewController.dishID = dish.dishID;
        [self.navigationController pushViewController:globalDishViewController animated:YES];
    }
    else
    {
        DAReview *review = [self.selectedDataSource objectAtIndex:indexPath.row];
        
        DAReviewDetailsViewController *reviewDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"reviewDetails"];
        reviewDetailsViewController.reviewID = review.review_id;
        [self.navigationController pushViewController:reviewDetailsViewController animated:YES];
    }
}

- (IBAction)changeDishType
{
    switch( self.dishTypeChooser.selectedSegmentIndex )
    {
        case 0:
            self.selectedDataSource = self.isRestaurant ? self.restaurantProfile.foodDishes : self.userProfile.foodReviews;
            break;
            
        case 1:
            self.selectedDataSource = self.isRestaurant ? self.restaurantProfile.cocktailDishes : self.userProfile.cocktailReviews;
            break;
            
        case 2:
            self.selectedDataSource = self.isRestaurant ? self.restaurantProfile.wineDishes : self.userProfile.wineReviews;
            break;
    }
    
    [self.dishesTableView reloadData];
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
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kIDKey : @(self.userProfile.user_id) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        self.spamReportTask = [[DAAPIManager sharedManager] POST:kReportUserURL parameters:parameters success:nil failure:nil];
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
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kIDKey : @(userID) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        self.followTask = [[DAAPIManager sharedManager] POST:kFollowUserURL parameters:parameters
        success:nil failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            self.restaurantProfile.caller_follows = self.userProfile.caller_follows = NO;
            [self setFollowButtonState];
        }];
    }];
}

- (void)unfollowUserID:(NSInteger)userID
{
    self.restaurantProfile.caller_follows = self.userProfile.caller_follows = NO;
    [self setFollowButtonState];
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kIDKey : @(userID) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        self.followTask = [[DAAPIManager sharedManager] POST:kUnfollowUserURL parameters:parameters
        success:nil failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            self.restaurantProfile.caller_follows = self.userProfile.caller_follows = YES;
            [self setFollowButtonState];
        }];
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
    double longitude = self.restaurantProfile.longitude;
    double latitude  = self.restaurantProfile.latitude;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake( longitude, latitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.restaurantProfile.name;
    
    NSDictionary *launchOptions = @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving };
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
}

@end