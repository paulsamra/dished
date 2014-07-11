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


@interface DAFormTableViewController ()

@property (strong, nonatomic) NSString *dishType;

@end


@implementation DAFormTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dishType = @"food";
    
    self.autocompleteTableView = [[DADishNamesTableView alloc] initWithFrame:CGRectMake(0, 44, 320, 189) withClass:self];
    [self.view addSubview:self.autocompleteTableView];
    self.autocompleteTableView.hidden = YES;

    self.titleTextField.delegate = self;
    self.priceTextField.delegate = self;

    [[SZTextView appearance] setPlaceholderTextColor:[UIColor lightGrayColor]];
    self.commentTextView.placeholder = @"Comment";
    self.commentTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.imAtButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] } ];
}

-(void)viewWillAppear:(BOOL)animated
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
    else if( self.commentTextView.text.length == 0 )
    {
        [self.titleTextField becomeFirstResponder];
    }
    else if( self.priceTextField.text.length == 0 )
    {
        [self.commentTextView becomeFirstResponder];
    }
    else
    {
        [self.priceTextField becomeFirstResponder];
    }
    
    if( _data )
    {
        [self.imAtButton setTitle:(NSString *)_data forState:UIControlStateNormal];
        self.imAtButton.titleLabel.textColor = [UIColor blackColor];
        [self.priceTextField becomeFirstResponder];
    }
    
    if( _label )
    {
        UILabel *labelWithRating = (UILabel *)_label;
        [self.ratingButton setTitle:labelWithRating.text forState:UIControlStateNormal];
        [self.ratingButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.priceTextField )
    {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
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
        self.autocompleteTableView.hidden = YES;
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
        self.autocompleteTableView.hidden = YES;
    }
    else
    {
        self.autocompleteTableView.hidden = NO;
        [self.autocompleteTableView searchAutocompleteEntriesWithSubstring:self.titleTextField.text];
    }
}

- (IBAction)changedDishType
{
    switch (self.dishTypeSegmentedControl.selectedSegmentIndex)
    {
        case 0: self.dishType = @"food";  break;
        case 1: self.dishType = @"drink"; break;
        case 2: self.dishType = @"wine";  break;
    }
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
        dest.dishType = self.dishType;
    }
}

- (IBAction)postDish:(UIBarButtonItem *)sender
{
    NSLog(@"Post: %@ %@ %@ %@ %@ %@", self.dishType,
                                      self.titleTextField.text,
    						 		  self.commentTextView.text,
                                      self.imAtButton.titleLabel.text,
                                      self.priceTextField.text,
    						 		  self.ratingButton.titleLabel.text);
}

@end