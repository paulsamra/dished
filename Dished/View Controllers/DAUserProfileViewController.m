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
#import "DADish.h"
#import "DADishTableViewCell.h"
#import "DAFollowListViewController.h"
#import "DAReviewDetailsViewController.h"
#import "DAGlobalDishDetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DAUserProfile.h"
#import "DARestaurantProfile.h"
#import "DAEditProfileViewController.h"


@interface DAUserProfileViewController() <UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak,   nonatomic) NSArray             *selectedDataSource;
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
    
    self.dishesTableView.tableFooterView = [[UIView alloc] init];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(showMoreActionSheet)];
    self.navigationItem.rightBarButtonItem = moreButton;
    
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
        
        [UIView transitionWithView:self.dishesTableView
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:nil
                        completion:nil];
        
        self.dishesTableView.hidden = hidden;
    }
    else
    {
        self.topView.hidden = hidden;
        self.descriptionTextView.hidden = hidden;
        self.middleView.hidden = hidden;
        self.dishesTableView.hidden = hidden;
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
    
    if( self.isRestaurant )
    {
        [[DAAPIManager sharedManager] getRestaurantProfileWithRestaurantID:self.user_id completion:^( id response, NSError *error )
        {
            if( !response || error )
            {
                
            }
            else
            {
                self.restaurantProfile = [[DARestaurantProfile alloc] initWithData:nilOrJSONObjectForKey( response, @"data" )];
                [self configureForRestaurantProfile];
                
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                [self setMainViewsHidden:NO animated:YES];
            }
        }];
    }
    else
    {
        [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
        {
            NSDictionary *parameters = @{ ( self.username ? kUsernameKey : kIDKey ) :
                                          ( self.username ? self.username : @(self.user_id) ) };
            parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
            
            [[DAAPIManager sharedManager] GET:kUserProfileURL parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                self.userProfile = [[DAUserProfile alloc] initWithData:nilOrJSONObjectForKey( responseObject, @"data" )];
                [self configureForUserProfile];
                
                [spinner stopAnimating];
                [spinner removeFromSuperview];
                
                [self setMainViewsHidden:NO animated:YES];
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                
            }];
        }];
    }
}

- (void)configureForRestaurantProfile
{
    self.navigationItem.title = self.restaurantProfile.name;
    
    NSURL *url = [NSURL URLWithString:self.restaurantProfile.img_thumb];
    [self.userImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    self.restaurantProfile.is_profile_owner ? [self setFollowButtonToProfileOwner] : [self setFollowButtonState:self.restaurantProfile.caller_follows];
    
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
    
    if( self.restaurantProfile.phone )
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
    
    self.userProfile.is_profile_owner ? [self setFollowButtonToProfileOwner] : [self setFollowButtonState:self.userProfile.caller_follows];
    
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

- (void)setFollowButtonState:(BOOL)isFollowed
{
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
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        cell.textLabel.text = self.isRestaurant ? @"No Dishes" : @"No Reviews";
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    DADishTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDishSearchCellID];
    
    DADish *result = [self.selectedDataSource objectAtIndex:indexPath.row];
    
    cell.dishNameLabel.text = result.name;
    
    NSURL *url = [NSURL URLWithString:result.imageURL];
    [cell.mainImageView setImageWithURL:url usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    if( self.isRestaurant )
    {
        cell.isExplore = YES;
        cell.locationButton.hidden = YES;
        
        cell.leftNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.totalReviews];
        cell.middleNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.friendReviews];
        cell.rightNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.influencerReviews];
        
        cell.gradeLabel.text = result.avg_grade;
    }
    else
    {
        cell.isExplore = NO;
        cell.gradeLabel.text = result.grade;
        [cell.locationButton setTitle:result.locationName forState:UIControlStateNormal];
        cell.rightNumberLabel.text = [NSString stringWithFormat:@"%d", (int)result.numComments];
    }
    
    return cell;
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
    DADish *result = [self.selectedDataSource objectAtIndex:indexPath.row];
    
    if( self.isRestaurant )
    {
        DAGlobalDishDetailViewController *globalDishViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"globalDish"];
        globalDishViewController.dishID = result.dishID;
        [self.navigationController pushViewController:globalDishViewController animated:YES];
    }
    else
    {
        DAReviewDetailsViewController *reviewDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"reviewDetails"];
        reviewDetailsViewController.reviewID = result.dishID;
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

- (IBAction)goToDishesMap
{
    
}

- (IBAction)showGradeInfoAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This grade is averaged from\nall the dish reviews at this\nrestaurant." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)followButtonPressed
{
    BOOL isOwnProfile = self.isRestaurant ? self.restaurantProfile.is_profile_owner : self.userProfile.is_profile_owner;
    BOOL isFollowed   = self.isRestaurant ? self.restaurantProfile.caller_follows : self.userProfile.caller_follows;
    
    if( !isOwnProfile )
    {
        isFollowed ? [self unfollowUserID:self.user_id] : [self followUserID:self.user_id];
        [self setFollowButtonState:!isFollowed];
    }
    else
    {
        DAEditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfile"];
        editProfileViewController.user_id = self.userProfile.user_id;
        [self.navigationController pushViewController:editProfileViewController animated:YES];
    }
}

- (IBAction)numFollowingPressed
{
    BOOL showFollowers = NO;
    
    [self performSegueWithIdentifier:@"followList" sender:@(showFollowers)];
}

- (IBAction)numFollowersPressed
{
    BOOL showFollowers = YES;
    
    [self performSegueWithIdentifier:@"followList" sender:@(showFollowers)];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"followList"] )
    {
        BOOL showFollowers = [sender boolValue];
        
        DAFollowListViewController *dest = segue.destinationViewController;
        dest.showFollowers = showFollowers;
        dest.user_id = self.user_id;
    }
}

- (void)followUserID:(NSInteger)userID
{
    [[DAAPIManager sharedManager] followUserWithUserID:userID completion:nil];
}

- (void)unfollowUserID:(NSInteger)userID
{
    [[DAAPIManager sharedManager] unfollowUserWithUserID:userID completion:nil];
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