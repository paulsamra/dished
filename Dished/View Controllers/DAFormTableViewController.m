//
//  DAFormTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFormTableViewController.h"
#import "DAPositiveHashtagsViewController.h"
#import "SZTextView.h"
#import "DANewReview.h"
#import <AddressBook/AddressBook.h>
#import "DALocationManager.h"


@interface DAFormTableViewController ()

@property (strong, nonatomic) DANewReview *review;
@property (nonatomic, retain) NSMutableString *dishPrice;

@end


@implementation DAFormTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressReady:) name:kAddressReadyNotificationKey object:nil];

    [self setupSuggestionTable];
    
    self.dishPrice   = [[NSMutableString alloc] init];
    self.review      = [[DANewReview alloc] init];
    self.review.type = kFood;

    self.titleTextField.delegate  = self;
    self.priceTextField.delegate  = self;
    self.commentTextView.delegate = self;

    [[SZTextView appearance] setPlaceholderTextColor:[UIColor lightGrayColor]];
    self.commentTextView.placeholder = @"Comment";
    self.commentTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.imAtButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] } ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor] };
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    if( self.titleTextField.text.length == 0 )
    {
        [self.titleTextField becomeFirstResponder];
    }
    else
    {
        [self.commentTextView becomeFirstResponder];
    }
    
    if( _data )
    {
        [self.imAtButton setTitle:(NSString *)_data forState:UIControlStateNormal];
        [self.imAtButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [self.priceTextField becomeFirstResponder];
    }
    
    if( _label )
    {
        UILabel *labelWithRating = (UILabel *)_label;
        [self.ratingButton setTitle:labelWithRating.text forState:UIControlStateNormal];
        [self.ratingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if( [self.review.hashtags count] > 0 )
    {
        self.tagsImageView.image = [UIImage imageNamed:@"valid_icon"];
    }
    else
    {
        self.tagsImageView.image = [UIImage imageNamed:@"add_dish_arrow"];
    }
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
        
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == self.titleTextField )
    {
        self.dishSuggestionsTable.hidden = YES;
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
        [self.dishSuggestionsTable updateSuggestionsWithQuery:self.titleTextField.text dishType:self.review.type];
    }
}

- (void)selectedSuggestionWithDishName:(NSString *)dishName dishID:(NSString *)dishID locationName:(NSString *)locationName locationID:(NSString *)locationID
{
    self.titleTextField.text = dishName;
    [self.imAtButton setTitle:locationName forState:UIControlStateNormal];
    [self.imAtButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.review.dishID = dishID;
    self.review.title = dishName;
    self.review.locationName = locationName;
    self.review.locationID = locationID;
}

- (IBAction)changedDishType
{
    switch (self.dishTypeSegmentedControl.selectedSegmentIndex)
    {
        case 0: self.review.type = kFood;     break;
        case 1: self.review.type = kCocktail; break;
        case 2: self.review.type = kWine;     break;
    }
    
    self.dishSuggestionsTable.hidden = YES;
}

- (void)setDetailItem:(id)newData
{
    if( [newData isKindOfClass:[UILabel class]] )
    {
        _label = newData;
    }
    else
    {
        if( _data != newData )
        {
            _data = newData;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"posHashtags"] )
    {
        DAPositiveHashtagsViewController *dest = segue.destinationViewController;
        dest.review = self.review;
    }
}

- (void)addressReady:(NSNotification *)notification;
{
    NSDictionary *addressDictionary = notification.object;
    
    NSString *address = [addressDictionary objectForKey:(NSString *)kABPersonAddressStreetKey];
    NSString *city =  	[addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
    NSString *state = 	[addressDictionary objectForKey:(NSString *)kABPersonAddressStateKey];
    NSString *zip =   	[addressDictionary objectForKey:(NSString *)kABPersonAddressZIPKey];
    
    NSLog(@"%@ %@ %@ %@", address, city, state, zip);
}


- (IBAction)postDish:(UIBarButtonItem *)sender
{
    NSLog(@"Post: %@ %@ %@ %@ %@ %@", self.review.type,
                                      self.titleTextField.text,
    						 		  self.commentTextView.text,
                                      self.imAtButton.titleLabel.text,
                                      self.priceTextField.text,
    						 		  self.ratingButton.titleLabel.text);
}

@end