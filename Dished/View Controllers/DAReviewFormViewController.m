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
#import <AddressBook/AddressBook.h>
#import "DALocationManager.h"
#import "DAReviewLocationViewController.h"
#import "DARatingViewController.h"
#import "MRProgress.h"
#import "DAAPIManager.h"
#import "DAAppDelegate.h"
#import <MessageUI/MessageUI.h>
#import "DATwitterManager.h"
#import "DASocialCollectionViewController.h"

@interface DAReviewFormViewController() <UIAlertViewDelegate>

@property (strong, nonatomic) UIView                           *dimView;
@property (strong, nonatomic) UIAlertView                      *postFailAlert;
@property (strong, nonatomic) UIAlertView                      *twitterLoginFailAlert;
@property (strong, nonatomic) UIAlertView                      *googleLoginFailAlert;
@property (strong, nonatomic) NSMutableString                  *dishPrice;
@property (strong, nonatomic) DASocialCollectionViewController *socialViewController;

@property (nonatomic) BOOL   addressFound;
@property (nonatomic) CGRect keyboardFrame;

@end


@implementation DAReviewFormViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    self.facebookImage.alpha = 0.3;
    self.twitterImage.alpha  = 0.3;
    self.emailImage.alpha    = 0.3;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressReady:) name:kAddressReadyNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissSocialView) name:kDoneSelecting object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];

    [self setupSuggestionTable];
    [self setupShareView];
    
    self.addressFound = NO;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
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
}

- (void)setupShareView
{
    self.dimView = [[UIView alloc] initWithFrame:self.view.frame];
    self.dimView.backgroundColor = [UIColor clearColor];
    
    self.socialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"social"];
    self.socialViewController.view.frame = CGRectMake( 0, 600, self.view.bounds.size.width, self.view.bounds.size.height );
}

- (void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    self.keyboardFrame = keyboardFrame;
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
        hiddenRect.origin.y = 600;
        self.socialViewController.view.frame = hiddenRect;
    }
    completion:nil];
    
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self.commentTextView resignFirstResponder];
    
    [super viewDidDisappear:animated];
}

- (void)showProgressView
{
    UIWindow *window = [UIApplication sharedApplication].windows.lastObject;
    
    [MRProgressOverlayView showOverlayAddedTo:window title:@"Posting..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
}

- (void)setupSuggestionTable
{
    CGFloat x = 0;
    CGFloat y = self.tableView.rowHeight;
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = self.commentTextView.frame.size.height + self.imAtButton.frame.size.height;
    
    self.dishSuggestionsTable = [[DADishSuggestionsTableView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.view addSubview:self.dishSuggestionsTable];
    self.dishSuggestionsTable.suggestionDelegate = self;
    self.dishSuggestionsTable.hidden = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( !IS_IPHONE5 )
    {
        if( indexPath.row == 1 )
        {
            return [super tableView:tableView heightForRowAtIndexPath:indexPath] - 68;
        }
        
        if( indexPath.row == 3 )
        {
            return [super tableView:tableView heightForRowAtIndexPath:indexPath] - 12;
        }
        
        return [super tableView:tableView heightForRowAtIndexPath:indexPath] - 4;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
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
            [textField setText:[NSString stringWithFormat:@"$%@",newAmount]];
        }
        else
        {
            if ( [self.dishPrice doubleValue] < 1000000.0 )
            {
                [self.dishPrice appendString:string];

                newAmount = [self formatCurrencyValue:( [self.dishPrice doubleValue] / 100 )];
                [textField setText:[NSString stringWithFormat:@"$%@", newAmount]];
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
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == self.titleTextField )
    {
        self.dishSuggestionsTable.hidden = YES;
        self.review.title = textField.text;
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
    
    if( self.review.dishID.length != 0 )
    {
        self.review.dishID = @"";
        self.review.price = @"";
        self.review.locationName = @"";
        self.review.locationID = @"";
        self.dishPrice = [[NSMutableString alloc] init];
    }
    
    [self updateFields];
}

- (void)selectedSuggestionWithDishName:(NSString *)dishName dishID:(NSString *)dishID dishPrice:dishPrice locationName:(NSString *)locationName locationID:(NSString *)locationID
{
    self.review.dishID = dishID;
    self.review.title = dishName;
    self.review.locationName = locationName;
    self.review.locationID = locationID;
    self.dishPrice = [[NSMutableString alloc] init];
    self.review.price = [NSString stringWithFormat:@"$%@", dishPrice];
    
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
    self.priceTextField.text  = self.review.price;
    
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
        self.tagsImageView.image = [UIImage imageNamed:@"valid_icon"];
    }
    else
    {
        self.tagsImageView.image = [UIImage imageNamed:@"add_dish_arrow"];
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
    
    if( self.review.dishID.length != 0 )
    {
        self.imAtButton.enabled = NO;
        self.priceTextField.enabled = NO;
        [self.imAtButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.priceTextField.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.imAtButton.enabled = YES;
        self.priceTextField.enabled = YES;
        self.priceTextField.textColor = [UIColor blackColor];

        if( self.review.locationName.length != 0 )
        {
            [self.imAtButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    [self setPostButtonStatus];
}

- (void)setPostButtonStatus
{
    DANewReview *review = self.review;
    
    if( review.comment.length > 0 && review.rating.length > 0 )
    {
        if( review.dishID.length > 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else if( review.title.length > 0 && review.locationID.length > 0 )
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
    [self.navigationController.view addSubview:self.dimView];
    [self.navigationController.view addSubview:self.socialViewController.view];
    
    [UIView animateWithDuration:0.3 animations:^
    {
        self.dimView.backgroundColor = [UIColor lightGrayColor];
        self.dimView.alpha = 0.7;
    }];

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        CGFloat keyboardY = self.view.window.frame.size.height - self.keyboardFrame.size.height;
        CGFloat socialViewHeight = self.socialViewController.collectionViewLayout.collectionViewContentSize.height;
        CGRect socialViewFrame = self.socialViewController.view.frame;
        socialViewFrame.origin.y = keyboardY - socialViewHeight;
        self.socialViewController.view.frame = socialViewFrame;
    }
    completion:nil];
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
    }
}

- (void)addressReady:(NSNotification *)notification;
{
    NSDictionary *addressDictionary = notification.object;
    NSLog(@"%@", addressDictionary);
    
    self.review.locationStreetNum  = addressDictionary[@"SubThoroughfare"];
    self.review.locationStreetName = addressDictionary[@"Thoroughfare"];
    self.review.locationCity       = addressDictionary[(NSString *)kABPersonAddressCityKey];
    self.review.locationState      = addressDictionary[(NSString *)kABPersonAddressStateKey];
    self.review.locationZip        = addressDictionary[(NSString *)kABPersonAddressZIPKey];
    
    self.addressFound = YES;
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
            postSuccess = YES;
            
            dispatch_group_enter( group );
            
            [self.socialViewController shareReview:self.review imageURL:imageURL completion:^( BOOL success )
            {
                dispatch_group_leave( group );
            }];
        }
        else
        {
            postSuccess = NO;
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