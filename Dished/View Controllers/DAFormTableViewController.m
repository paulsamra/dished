//
//  DAFormTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFormTableViewController.h"
#import "DAPositiveHashtagsViewController.h"
#import "DANewReview.h"
#import <AddressBook/AddressBook.h>
#import "DALocationManager.h"
#import "DALocationTableViewController.h"
#import "DARatingTableViewController.h"
#import "MRProgress.h"
#import "DAHashtag.h"
#import <Social/Social.h>
#import "DAAPIManager.h"
#import "DAAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>


@interface DAFormTableViewController() <UIAlertViewDelegate>

@property (strong, nonatomic) DANewReview     *foodReview;
@property (strong, nonatomic) DANewReview     *cocktailReview;
@property (strong, nonatomic) DANewReview     *wineReview;
@property (strong, nonatomic) DANewReview     *selectedReview;
@property (strong, nonatomic) UIAlertView     *facebookLoginAlert;
@property (strong, nonatomic) UIAlertView     *postFailAlert;
@property (strong, nonatomic) UIAlertView     *twitterLoginAlert;
@property (strong, nonatomic) NSMutableString *dishPrice;
@property (strong, nonatomic) ACAccountStore  *accountStore;
@property (strong, nonatomic) ACAccountType   *twitterType;

@property (nonatomic) BOOL shouldPostToFacebook;
@property (nonatomic) BOOL shouldPostToTwitter;
@property (nonatomic) BOOL shouldPostToGooglePlus;
@property (nonatomic) BOOL shouldEmailReview;
@property (nonatomic) BOOL addressFound;

@end


@implementation DAFormTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.accountStore = [[ACAccountStore alloc] init];

    self.facebookToggleButton.alpha   = 0.3;
    self.twitterToggleButton.alpha    = 0.3;
    self.googleplusToggleButton.alpha = 0.3;
    self.emailToggleButton.alpha      = 0.3;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressReady:) name:kAddressReadyNotificationKey object:nil];

    [self setupSuggestionTable];
    self.addressFound = NO;
    
    self.dishPrice = [[NSMutableString alloc] init];
    
    self.selectedReview = self.foodReview;

    self.titleTextField.delegate  = self;
    self.priceTextField.delegate  = self;
    self.commentTextView.delegate = self;

    [[SZTextView appearance] setPlaceholderTextColor:[UIColor lightGrayColor]];
    self.commentTextView.placeholder = @"Comment";
    self.commentTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.imAtButton.titleLabel.numberOfLines = 2;
    
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:attributes];
    self.priceTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Price" attributes:attributes];
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

- (void)viewDidDisappear:(BOOL)animated
{
    [self.commentTextView resignFirstResponder];
    
    [super viewDidDisappear:animated];
}

- (void)showProgressView
{
    [MRProgressOverlayView showOverlayAddedTo:self.view.window title:@"Posting..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField == self.priceTextField )
    {
        if (textField.text.length  == 0)
        {
            textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
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
        self.selectedReview.comment = textView.text;
        [self updateFields];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.priceTextField )
    {
        NSString *newAmount;

        if ([string isEqualToString:@""] && [self.dishPrice length] > 0)
        {
            [self.dishPrice appendString:string];

            [self.dishPrice deleteCharactersInRange:NSMakeRange([self.dishPrice length]-1, 1)];
            
            newAmount = [self formatCurrencyValue:([self.dishPrice doubleValue]/100)];
            [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
        }
        else
        {
            if ( [self.dishPrice doubleValue] < 1000000.0 )
            {
                [self.dishPrice appendString:string];

                newAmount = [self formatCurrencyValue:([self.dishPrice doubleValue]/100)];
                [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
            }
        }
        
        NSString *price = textField.text;
        if( [price characterAtIndex:0] == '$' )
        {
            price = [price substringFromIndex:1];
        }
        
        self.selectedReview.price = price;
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
        self.selectedReview.title = textField.text;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if( textView == self.commentTextView )
    {
        self.selectedReview.comment = textView.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.titleTextField )
    {
        [self.commentTextView becomeFirstResponder];
    }
    
    return YES;
}

- (IBAction)titleFieldChanged
{
    if( self.titleTextField.text.length == 0 )
    {
        self.dishSuggestionsTable.hidden = YES;
    }
    else
    {
        self.dishSuggestionsTable.hidden = NO;
        [self.dishSuggestionsTable updateSuggestionsWithQuery:self.titleTextField.text dishType:self.selectedReview.type];
    }
    
    self.selectedReview.title = self.titleTextField.text;
    
    if( self.selectedReview.dishID.length != 0 )
    {
        self.selectedReview.dishID = @"";
        self.selectedReview.price = @"";
        self.selectedReview.locationName = @"";
        self.selectedReview.locationID = @"";
        self.dishPrice = [[NSMutableString alloc] init];
    }
    
    [self updateFields];
}

- (void)selectedSuggestionWithDishName:(NSString *)dishName dishID:(NSString *)dishID dishPrice:dishPrice locationName:(NSString *)locationName locationID:(NSString *)locationID
{
    self.selectedReview.dishID = dishID;
    self.selectedReview.title = dishName;
    self.selectedReview.locationName = locationName;
    self.selectedReview.locationID = locationID;
    self.dishPrice = [[NSMutableString alloc] init];
    self.selectedReview.price = [NSString stringWithFormat:@"$%@", dishPrice];
    
    [self updateFields];
}

- (IBAction)changedDishType
{
    switch (self.dishTypeSegmentedControl.selectedSegmentIndex)
    {
        case 0: self.selectedReview = self.foodReview;      break;
        case 1: self.selectedReview = self.cocktailReview;  break;
        case 2: self.selectedReview = self.wineReview;      break;
    }
    
    self.dishSuggestionsTable.hidden = YES;
    [self updateFields];
}

- (void)updateFields
{
    self.titleTextField.text  = self.selectedReview.title;
    self.commentTextView.text = self.selectedReview.comment;
    self.priceTextField.text  = self.selectedReview.price;
    
    if( self.selectedReview.locationName.length > 0 )
    {
        [self.imAtButton setTitle:self.selectedReview.locationName forState:UIControlStateNormal];
        [self.imAtButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.imAtButton setTitle:@"I'm at" forState:UIControlStateNormal];
        [self.imAtButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if( [self.selectedReview.hashtags count] > 0 )
    {
        self.tagsImageView.image = [UIImage imageNamed:@"valid_icon"];
    }
    else
    {
        self.tagsImageView.image = [UIImage imageNamed:@"add_dish_arrow"];
    }
    
    if( self.selectedReview.rating.length > 0 )
    {
        [self.ratingButton setTitle:self.selectedReview.rating forState:UIControlStateNormal];
        [self.ratingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.ratingButton setTitle:@"Rating" forState:UIControlStateNormal];
        [self.ratingButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    if( self.selectedReview.dishID.length != 0 )
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

        if( self.selectedReview.locationName.length != 0 )
        {
            [self.imAtButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    [self setPostButtonStatus];
}

- (void)setPostButtonStatus
{
    DANewReview *review = self.selectedReview;
    
    if( review.comment.length > 0 && review.rating.length > 0 )
    {
        if( review.dishID.length > 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else if( review.title.length > 0 && review.locationID.length > 0 && review.price.length > 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else if( review.title.length > 0 && review.locationName.length > 0 && review.price.length > 0 )
        {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
        else
        {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( alertView == self.facebookLoginAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            [self openFacebookSession];
        }
        else
        {
            self.facebookToggleButton.alpha = 0.5;
        }
    }
}

- (IBAction)share:(UIButton *)sender
{
    switch( sender.tag )
    {
        case 0:
            if( self.facebookToggleButton.alpha == 1.0 )
            {
                self.shouldPostToFacebook = NO;
                self.facebookToggleButton.alpha = 0.3;
            }
            else
            {
                self.facebookToggleButton.alpha = 1.0;
                
                if( FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended )
                {
                    [self requestFacebookPermissions];
                }
                else
                {
                    [self.facebookLoginAlert show];
                }
            }
            break;
        case 1:
            if( self.twitterToggleButton.alpha == 1.0 )
            {
                self.twitterToggleButton.alpha = 0.3;
            }
            else
            {
                self.twitterToggleButton.alpha = 1.0;
                [self requestTwitterAccountAccess];
            }
            break;
        case 2:
            if( self.googleplusToggleButton.alpha == 1.0 )
            {
                self.googleplusToggleButton.alpha = 0.3;
            }
            else
            {
                self.googleplusToggleButton.alpha = 1.0;
            }
            break;
        case 3:
            if( self.emailToggleButton.alpha == 1.0 )
            {
                self.emailToggleButton.alpha = 0.3;
                self.shouldEmailReview = NO;
            }
            else
            {
                if( [MFMailComposeViewController canSendMail] )
                {
                    self.shouldEmailReview = YES;
                    self.emailToggleButton.alpha = 1.0;
                }
                else
                {
                    //TODO maybe alert the user and let them know they can't send email
                }
            }
            break;
    }
}

- (void)requestTwitterAccountAccess
{
    self.twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:self.twitterType options:nil
    completion:^( BOOL granted, NSError *error )
    {
        if( granted )
        {
            NSArray *accounts = [self.accountStore accountsWithAccountType:self.twitterType];
            if( [accounts count] == 0 )
            {
                self.shouldPostToTwitter = NO;
                self.twitterToggleButton.alpha = 0.3;
                
                [self.twitterLoginAlert show];
            }
            else
            {
                self.shouldPostToTwitter = YES;
            }
        }
        else
        {
            self.shouldPostToTwitter = NO;
            self.twitterToggleButton.alpha = 0.3;
            
            [self.twitterLoginAlert show];
        }
    }];
}

- (void)requestFacebookPermissions
{
    NSArray *requestPermissions = @[ @"publish_actions" ];
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
    completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
    {
        if( !error )
        {
            BOOL hasPermission = NO;
            
            for( NSDictionary *permission in (NSArray *)[result data] )
            {
                if( [[permission objectForKey:@"permission"] isEqualToString:[requestPermissions objectAtIndex:0]] )
                {
                    hasPermission = YES;
                }
            }
            
            if( !hasPermission )
            {
                [FBSession.activeSession requestNewPublishPermissions:requestPermissions defaultAudience:FBSessionDefaultAudienceNone completionHandler:^( FBSession *session, NSError *error )
                {
                    if( !error )
                    {
                        self.shouldPostToFacebook = YES;
                    }
                }];
            }
            else
            {
                self.shouldPostToFacebook = YES;
            }
        }
        else
        {
            if( [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession )
            {
                [self.facebookLoginAlert show];
            }
        }
    }];
}

- (void)openFacebookSession
{
    [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES
    completionHandler:^( FBSession *session, FBSessionState status, NSError *error )
    {
        if( status == FBSessionStateOpen || status == FBSessionStateOpenTokenExtended )
        {
            [self requestFacebookPermissions];
        }
        else
        {
            self.facebookToggleButton.alpha = 0.5;
        }
        
        DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sessionStateChanged:session state:status error:error];
    }];
}

- (void)shareDishOnFacebookWithCompletion:( void(^)( BOOL success ) )completion;
{
    NSString *message = [NSString stringWithFormat:@"I just left an %@ review for %@ at %@.", self.ratingButton.titleLabel.text, self.titleTextField.text, self.imAtButton.titleLabel.text];
    
    NSDictionary *shareParams = @{ @"name" : self.selectedReview.title, @"caption" : message,
                                   @"description" : self.selectedReview.comment, @"link" : @"http://dishedapp.com" };
    
    [FBRequestConnection startWithGraphPath:@"/me/feed" parameters:shareParams HTTPMethod:@"POST"
    completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
    {
        if( !error )
        {
            completion( YES );
        }
        else
        {
            completion( NO );
        }
    }];
}

- (void)postToTwitterWithCompletion:( void(^)( BOOL success ) )completion
{
    NSString *twitterMessage = [NSString stringWithFormat:@"I just left an %@ review for %@ at %@.", self.ratingButton.titleLabel.text, self.titleTextField.text, self.imAtButton.titleLabel.text];
    
    SLRequestHandler requestHandler = ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error )
    {
        if( responseData )
        {
            NSInteger statusCode = urlResponse.statusCode;
            
            if( statusCode >= 200 && statusCode < 300 )
            {
                NSDictionary *postResponseData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
                completion( YES );
            }
            else
            {
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode, [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
                completion( NO );
            }
        }
        else
        {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
            completion( NO );
        }
    };
    
    NSArray *accounts = [self.accountStore accountsWithAccountType:self.twitterType];
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
    
    NSDictionary *params = @{ @"status" : twitterMessage };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodPOST
                                                      URL:url
                                               parameters:params];
    
    NSData *imageData = UIImageJPEGRepresentation( self.reviewImage, 1.0f );
    
    [request addMultipartData:imageData
                     withName:@"media[]"
                         type:@"image/jpeg"
                     filename:@"image.jpg"];
    
    [request setAccount:[accounts lastObject]];
    [request performRequestWithHandler:requestHandler];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //Add an alert in case of failure
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"posHashtags"] )
    {
        DAPositiveHashtagsViewController *dest = segue.destinationViewController;
        dest.review = self.selectedReview;
    }
    
    if( [segue.identifier isEqualToString:@"rating"] )
    {
        DARatingTableViewController *dest = segue.destinationViewController;
        dest.review = self.selectedReview;
    }
    
    if( [segue.identifier isEqualToString:@"imAt"] )
    {
        DALocationTableViewController *dest = segue.destinationViewController;
        dest.review = self.selectedReview;
    }
}

- (void)addressReady:(NSNotification *)notification;
{
    NSDictionary *addressDictionary = notification.object;
    NSLog(@"%@", addressDictionary);
    
    self.selectedReview.locationStreetNum  = addressDictionary[@"SubThoroughfare"];
    self.selectedReview.locationStreetName = addressDictionary[@"Thoroughfare"];
    self.selectedReview.locationCity       = addressDictionary[(NSString *)kABPersonAddressCityKey];
    self.selectedReview.locationState      = addressDictionary[(NSString *)kABPersonAddressStateKey];
    self.selectedReview.locationZip        = addressDictionary[(NSString *)kABPersonAddressZIPKey];
    
    self.addressFound = YES;
}

- (IBAction)postDish:(UIBarButtonItem *)sender
{
    [self showProgressView];
    
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL postSuccess = YES;
    
    dispatch_group_enter( group );

    [[DAAPIManager sharedManager] postNewReview:self.selectedReview withImage:self.reviewImage completion:^( BOOL success )
    {
        if( success )
        {
            postSuccess = YES;
        }
        else
        {
            postSuccess = NO;
        }
        
        dispatch_group_leave( group );
    }];
    
    if( self.shouldPostToFacebook )
    {
        dispatch_group_enter( group );
        
        [self shareDishOnFacebookWithCompletion:^( BOOL success )
        {
            dispatch_group_leave( group );
        }];
    }
    
    if( self.shouldPostToTwitter )
    {
        dispatch_group_enter( group );
        
        [self postToTwitterWithCompletion:^( BOOL success )
        {
            dispatch_group_leave( group );
        }];
    }
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        if( postSuccess )
        {
            [MRProgressOverlayView dismissOverlayForView:self.view.window animated:YES completion:^
            {
                if( postSuccess )
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                else
                {
                    [self.postFailAlert show];
                }
            }];
        }
    });
    
    if( self.shouldEmailReview )
    {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setSubject:@"Wow this Dish is awesome!"];
        NSData *imageData = UIImagePNGRepresentation(self.reviewImage);
        [composeViewController addAttachmentData:imageData mimeType:nil fileName:@"image.png"];
        [self presentViewController:composeViewController animated:YES completion:nil];
    }
}

- (DANewReview *)foodReview
{
    if( !_foodReview )
    {
        _foodReview = [[DANewReview alloc] init];
        _foodReview.type = kFood;
    }
    
    return _foodReview;
}

- (DANewReview *)cocktailReview
{
    if( !_cocktailReview )
    {
        _cocktailReview = [[DANewReview alloc] init];
        _cocktailReview.type = kCocktail;
    }
    
    return _cocktailReview;
}

- (DANewReview *)wineReview
{
    if( !_wineReview )
    {
        _wineReview = [[DANewReview alloc] init];
        _wineReview.type = kWine;
    }
    
    return _wineReview;
}

- (UIAlertView *)facebookLoginAlert
{
    if( !_facebookLoginAlert )
    {
        _facebookLoginAlert = [[UIAlertView alloc] initWithTitle:@"You are not logged into Facebook" message:@"You must login to Facebook to share reviews. Do you want to login now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    
    return _facebookLoginAlert;
}

- (UIAlertView *)postFailAlert
{
    if( !_postFailAlert )
    {
        _postFailAlert = [[UIAlertView alloc] initWithTitle:@"Failed to post Dish Review" message:@"There was a problem posting your review. Please try again." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    }
    
    return _postFailAlert;
}

- (UIAlertView *)twitterLoginAlert
{
    if( !_twitterLoginAlert )
    {
        _twitterLoginAlert = [[UIAlertView alloc] initWithTitle:@"You are not logged into Twitter" message:@"You must login to Twitter from your device settings to be able to post to Twitter." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    }
    
    return _twitterLoginAlert;
}

@end