//
//  DAFormTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAReviewFormViewController.h"
#import "DAPositiveHashtagsViewController.h"
#import "DANewReview.h"
#import "DALocationManager.h"
#import "DAReviewLocationViewController.h"
#import "DARatingViewController.h"
#import "MRProgress.h"
#import "DAAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "DATwitterManager.h"
#import "DASocialCollectionViewController.h"
#import "DAImagePickerController.h"
#import "DAUserManager.h"

@interface DAReviewFormViewController() <UIAlertViewDelegate, DASocialCollectionViewControllerDelegate>

@property (strong, nonatomic) UIView                           *dimView;
@property (strong, nonatomic) NSArray                          *suggestedLocations;
@property (strong, nonatomic) UIAlertView                      *postFailAlert;
@property (strong, nonatomic) UIAlertView                      *twitterLoginFailAlert;
@property (strong, nonatomic) UIAlertView                      *googleLoginFailAlert;
@property (strong, nonatomic) NSMutableString                  *dishPrice;
@property (strong, nonatomic) DASocialCollectionViewController *socialViewController;

@property (nonatomic) BOOL   selectedDish;
@property (nonatomic) BOOL   searchedForSuggestions;
@property (nonatomic) CGRect keyboardFrame;

@end


@implementation DAReviewFormViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.selectedDish = NO;
    self.searchedForSuggestions = NO;
    
    self.facebookImage.alpha = 0.3;
    self.twitterImage.alpha  = 0.3;
    self.emailImage.alpha    = 0.3;
    
    self.dishPrice    = [[NSMutableString alloc] init];
    self.review.type  = kFood;

    self.titleTextField.delegate  = self;
    self.priceTextField.delegate  = self;
    self.commentTextView.delegate = self;

    [[SZTextView appearance] setPlaceholderTextColor:[UIColor lightGrayColor]];
    self.commentTextView.placeholder = @"Comment";
    self.commentTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.imAtButton.titleLabel.numberOfLines = 2;
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:attributes];
    self.priceTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Price (Optional)" attributes:attributes];
    
    [self checkForSelectedDish];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationServicesDenied) name:kLocationServicesDeniedKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocationSuggestions) name:kLocationUpdateNotificationKey object:nil];
    
    [[DALocationManager sharedManager] startUpdatingLocation];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if( !self.dishSuggestionsTable )
    {
        [self setupSuggestionTable];
    }
}

- (void)getLocationSuggestions
{
    if( !self.searchedForSuggestions )
    {
        self.searchedForSuggestions = YES;
        
        [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
        {
            CLLocationCoordinate2D currentLocation = [[DALocationManager sharedManager] currentLocation];
            
            NSDictionary *parameters = @{ kLatitudeKey : @(currentLocation.latitude),
                                          kLongitudeKey : @(currentLocation.longitude) };
            parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
            
            [[DAAPIManager sharedManager] GET:kExploreLocationsURL parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                self.suggestedLocations = [DAReviewLocationViewController locationsFromResponse:responseObject];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationUpdateNotificationKey object:nil];
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                self.searchedForSuggestions = NO;
            }];
        }];
    }
}

- (void)locationServicesDenied
{
    [[[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Some features of Dished require your current location. To use these features, enable location services in your settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)checkForSelectedDish
{
    DAImagePickerController *imagePickerController = [self.navigationController.viewControllers objectAtIndex:0];
    DADishProfile *selectedDish = imagePickerController.selectedDish;
    
    if( selectedDish )
    {
        self.selectedDish = YES;
        self.review.title = selectedDish.name;
        self.review.locationName = selectedDish.loc_name;
        self.review.locationID = selectedDish.loc_id;
        self.review.dishID = selectedDish.dish_id;
        
        [self updateFields];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor] };
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    if( !self.titleTextField.text || self.titleTextField.text.length == 0 )
    {
        [self.titleTextField becomeFirstResponder];
    }
    else
    {
        [self.commentTextView becomeFirstResponder];
    }
    
    [self updateFields];
    
    CLSLog( @"Review form will appear..." );
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [self.view endEditing:YES];
    [self.socialViewController.view removeFromSuperview];
    [self.dimView removeFromSuperview];
    
    CLSLog( @"Review form will disappear..." );
}

- (void)setupShareView
{
    self.dimView = [[UIView alloc] initWithFrame:self.view.frame];
    self.dimView.backgroundColor = [UIColor clearColor];
    
    self.socialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"social"];
    self.socialViewController.isReviewPost = YES;
    self.socialViewController.view.hidden = YES;
    self.socialViewController.delegate = self;
    
    self.socialViewController.view.frame = CGRectMake( 0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height );
}

- (void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    if( keyboardFrame.origin.y > self.view.frame.size.height )
    {
        return;
    }
    
    self.keyboardFrame = keyboardFrame;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    CGFloat x = 0;
    UITableViewCell *commentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    CGFloat y = commentCell.frame.origin.y;
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = self.commentTextView.frame.size.height + self.imAtButton.frame.size.height;
    
    self.dishSuggestionsTable.frame = CGRectMake( x, y, width, height );
}

- (void)dismissSocialView
{
    [UIView animateWithDuration:0.3 animations:^
    {
        self.dimView.backgroundColor = [UIColor clearColor];
        self.dimView.alpha = 1.0;
    }
    completion:^( BOOL finished )
    {
        [self.dimView removeFromSuperview];
    }];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
    {
        CGRect hiddenRect = self.socialViewController.view.frame;
        hiddenRect.origin.y = self.view.frame.size.height;
        self.socialViewController.view.frame = hiddenRect;
    }
    completion:^( BOOL finished )
    {
        self.socialViewController.view.hidden = YES;
    }];
    
    self.facebookImage.alpha = 0.3;
    self.twitterImage.alpha  = 0.3;
    self.emailImage.alpha    = 0.3;
    
    if( [self.socialViewController.selectedSharing objectForKey:self.socialViewController.cellLabels[0]] )
    {
        self.facebookImage.alpha = 1.0;
    }
    
    if( [self.socialViewController.selectedSharing objectForKey:self.socialViewController.cellLabels[1]] )
    {
        self.twitterImage.alpha = 1.0;
    }
    
    if( [self.socialViewController.selectedSharing objectForKey:self.socialViewController.cellLabels[2]] )
    {
        self.emailImage.alpha = 1.0;
    }
}

- (void)showProgressView
{
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    
    [MRProgressOverlayView showOverlayAddedTo:window title:@"Posting..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
}

- (void)setupSuggestionTable
{
    CGFloat x = 0;
    UITableViewCell *commentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    CGFloat y = commentCell.frame.origin.y;
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = self.commentTextView.frame.size.height + self.imAtButton.frame.size.height;
    
    self.dishSuggestionsTable = [[DADishSuggestionsTableView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.view addSubview:self.dishSuggestionsTable];
    self.dishSuggestionsTable.suggestionDelegate = self;
    self.dishSuggestionsTable.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.keyboardFrame.origin.y == 0 )
    {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    CGFloat availableSpace = self.keyboardFrame.origin.y;

    if( indexPath.row == 1 )
    {
        return availableSpace * 0.5;
    }
    if( indexPath.row == 3 )
    {
        return availableSpace * 0.2;
    }
    
    return availableSpace * 0.15;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField == self.priceTextField )
    {
        if (textField.text.length == 0 )
        {
            textField.text = [NSString stringWithFormat:@"%@0.00", [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]];
        }
    }
}

- (NSString *)formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

#define MAX_LENGTH 1000

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = ( textView.text.length - range.length ) + text.length;
    if( newLength <= MAX_LENGTH )
    {
        return YES;
    }
    else
    {
        NSUInteger emptySpace = MAX_LENGTH - ( textView.text.length - range.length );
        textView.text = [[[textView.text substringToIndex:range.location]
                          stringByAppendingString:[text substringToIndex:emptySpace]]
                         stringByAppendingString:[textView.text substringFromIndex:(range.location + range.length)]];
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if( textView == self.commentTextView )
    {
        self.review.comment = textView.text;
        [self updateFields];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.priceTextField )
    {
        NSString *newAmount;

        if( [string isEqualToString:@""] && [self.dishPrice length] > 0 )
        {
            [self.dishPrice appendString:string];

            [self.dishPrice deleteCharactersInRange:NSMakeRange( [self.dishPrice length] - 1, 1 )];
            
            newAmount = [self formatCurrencyValue:( [self.dishPrice doubleValue] / 100 )];
            [textField setText:[NSString stringWithFormat:@"%@", newAmount]];
        }
        else
        {
            if( [self.dishPrice doubleValue] < 1000000.0 )
            {
                [self.dishPrice appendString:string];

                newAmount = [self formatCurrencyValue:( [self.dishPrice doubleValue] / 100 )];
                [textField setText:[NSString stringWithFormat:@"%@", newAmount]];
            }
        }
        
        NSString *price = textField.text;
        if( [price characterAtIndex:0] == '$' )
        {
            price = [price substringFromIndex:1];
        }
        
        self.review.price = price;
        [self updateFields];
        
        return NO;
    }
    else if( textField == self.titleTextField )
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if( newString.length > 40 )
        {
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == self.titleTextField )
    {
        self.dishSuggestionsTable.hidden = YES;
        self.review.title = textField.text;
        [self.dishSuggestionsTable cancelSearchQuery];
    }
    
    if( textField == self.priceTextField )
    {
        if( [self.dishPrice doubleValue] == 0 )
        {
            self.priceTextField.text = @"";
            self.review.price = nil;
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if( textView == self.commentTextView )
    {
        self.review.comment = textView.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.titleTextField )
    {
        [textField resignFirstResponder];
        [self.commentTextView becomeFirstResponder];
        
        return NO;
    }
    
    return YES;
}

- (IBAction)titleFieldChanged
{
    if( self.titleTextField.text.length == 0 )
    {
        self.dishSuggestionsTable.hidden = YES;
        [self.dishSuggestionsTable resetTable];
    }
    else
    {
        [self.dishSuggestionsTable updateSuggestionsWithQuery:self.titleTextField.text dishType:self.review.type];
    }
    
    self.review.title = self.titleTextField.text;
    
    if( self.review.dishID != 0 )
    {
        self.review.dishID = 0;
    }
    
    [self updateFields];
}

- (void)didSelectSuggestionWithDishName:(NSString *)dishName dishID:(NSInteger)dishID dishPrice:(NSString *)dishPrice locationName:(NSString *)locationName locationID:(NSInteger)locationID
{
    self.review.dishID = dishID;
    self.review.title = dishName;
    self.review.locationName = locationName;
    self.review.locationID = locationID;
    self.dishPrice = [[dishPrice stringByReplacingOccurrencesOfString:@"." withString:@""] mutableCopy];
    
    if( [dishPrice doubleValue] > 0 )
    {
        self.review.price = dishPrice;
    }
    
    [self updateFields];
}

- (IBAction)changedDishType
{
    switch (self.dishTypeSegmentedControl.selectedSegmentIndex)
    {
        case 0: self.review.type = kFood;      break;
        case 1: self.review.type = kCocktail;  break;
        case 2: self.review.type = kWine;      break;
    }
    
    self.dishSuggestionsTable.hidden = YES;
    [self updateFields];
}

- (void)updateFields
{
    self.titleTextField.text  = self.review.title;
    self.commentTextView.text = self.review.comment;
    
    if( [self.review.price doubleValue] > 0 )
    {
        self.priceTextField.text  = [NSString stringWithFormat:@"$%@", self.review.price];
    }
    
    if( self.review.locationName.length > 0 )
    {
        [self.imAtButton setTitle:self.review.locationName forState:UIControlStateNormal];
        [self.imAtButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.imAtButton setTitle:@"I'm at" forState:UIControlStateNormal];
        [self.imAtButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if( [self.review.hashtags count] > 0 )
    {
        self.tagsImageView.image = [UIImage imageNamed:@"valid_input"];
    }
    else
    {
        self.tagsImageView.image = [UIImage imageNamed:@"disclosure_indicator"];
    }
    
    if( self.review.rating.length > 0 )
    {
        [self.ratingButton setTitle:self.review.rating forState:UIControlStateNormal];
        [self.ratingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.ratingButton setTitle:@"Rating" forState:UIControlStateNormal];
        [self.ratingButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    [self setPostButtonStatus];
}

- (void)setPostButtonStatus
{
    DANewReview *review = self.review;
    
    if( review.comment.length > 0 && review.rating.length > 0 )
    {
        if( review.dishID != 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else if( review.title.length > 0 && review.locationID != 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else if( review.title.length > 0 && review.locationName.length > 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (IBAction)goToHashtags
{
    [self performSegueWithIdentifier:@"posHashtags" sender:nil];
}

- (IBAction)goToPlaces
{
    [self performSegueWithIdentifier:@"imAt" sender:nil];
}

- (IBAction)goToRating
{
    [self performSegueWithIdentifier:@"rating" sender:nil];
}

- (IBAction)share:(UIButton *)sender
{
    if( !self.socialViewController )
    {
        [self setupShareView];
    }
    
    [self.navigationController.view addSubview:self.dimView];
    [self.navigationController.view addSubview:self.socialViewController.view];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        self.dimView.backgroundColor = [UIColor blackColor];
        self.dimView.alpha = 0.3;
    }];

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        CGFloat keyboardY = self.view.window.frame.size.height - self.keyboardFrame.size.height;
        CGFloat socialViewHeight = self.socialViewController.collectionViewLayout.collectionViewContentSize.height;
        CGRect socialViewFrame = self.socialViewController.view.frame;
        socialViewFrame.origin.y = keyboardY - socialViewHeight;
        self.socialViewController.view.frame = socialViewFrame;
        
        self.socialViewController.view.hidden = NO;
    }
    completion:nil];
}

- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller
{
    [self dismissSocialView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"posHashtags"] )
    {
        DAPositiveHashtagsViewController *dest = segue.destinationViewController;
        dest.review = self.review;
    }
    
    if( [segue.identifier isEqualToString:@"rating"] )
    {
        DARatingViewController *dest = segue.destinationViewController;
        dest.review = self.review;
    }
    
    if( [segue.identifier isEqualToString:@"imAt"] )
    {
        DAReviewLocationViewController *dest = segue.destinationViewController;
        dest.review = self.review;
        dest.suggestedLocations = self.suggestedLocations;
    }
}

- (IBAction)postDish:(UIBarButtonItem *)sender
{
    NSData *data = nil;
    
    [self showProgressView];
    
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL postSuccess = YES;
    
    dispatch_group_enter( group );

    [[DAAPIManager sharedManager] postNewReview:self.review withImage:self.reviewImage completion:^( BOOL success, NSString *imageURL )
    {
        if( success )
        {
            postSuccess &= YES;
            
            if( self.socialViewController )
            {
                dispatch_group_enter( group );
            
                [self.socialViewController shareReview:self.review imageURL:imageURL completion:^( BOOL success )
                {
                    dispatch_group_leave( group );
                }];
            }
        }
        else
        {
            postSuccess &= NO;
        }
        
        dispatch_group_leave( group );
    }];
    
    if( [self.socialViewController.selectedSharing objectForKey:self.socialViewController.cellLabels[2]] )
    {
        data = UIImageJPEGRepresentation( self.reviewImage, 0.5 );
    }
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        UIWindow *window = [UIApplication sharedApplication].windows.lastObject;

        [MRProgressOverlayView dismissOverlayForView:window animated:YES completion:^
        {
            if( postSuccess )
            {
                [self.view endEditing:YES];
                
                if( [DAUserManager sharedManager].savesDishPhoto )
                {
                    UIImageWriteToSavedPhotosAlbum( self.reviewImage, nil, nil, nil );
                }
                
                [self dismissViewControllerAnimated:YES completion:^
                {
                    if( data )
                    {
                        NSDictionary *info = @{ @"review" : self.review, @"imageData" : data };
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmail" object:info];
                    }
                }];
            }
            else
            {
                [self.postFailAlert show];
            }
        }];
    });
}

- (UIAlertView *)postFailAlert
{
    if( !_postFailAlert )
    {
        _postFailAlert = [[UIAlertView alloc] initWithTitle:@"Failed to post Dish Review" message:@"There was a problem posting your review. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    }
    
    return _postFailAlert;
}

@end