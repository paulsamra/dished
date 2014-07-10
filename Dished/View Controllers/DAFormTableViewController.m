//
//  DAFormTableViewController.m
//  Dished
//
//  Created by Daryl Stimm on 7/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAFormTableViewController.h"
#import "SZTextView.h"


@interface DAFormTableViewController ()

@end


@implementation DAFormTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.autocompleteTableView = [[AutoComleteTableView alloc] initWithFrame:CGRectMake(0, 44, 320, 189) withClass:self];
    [self.view addSubview:self.autocompleteTableView];
    self.autocompleteTableView.hidden = YES;

    self.titleTextField.delegate = self;
    self.priceTextField.delegate = self;
    
    [[SZTextView appearance] setPlaceholderTextColor:[UIColor lightGrayColor]];
    
    self.commentTextView.placeholder = @"Comment";
    self.commentTextView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);

    self.ratingLabel.text = @"Rating";
    self.ratingLabel.textColor = [UIColor lightGrayColor];
    self.ratingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    self.titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{ NSForegroundColorAttributeName : [UIColor lightGrayColor] } ];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor blackColor] };
    
    if( _data )
    {
        self.imAtButton.titleLabel.text = (NSString *)_data;
        self.imAtButton.titleLabel.textColor = [UIColor blackColor];
    }
    
    [self.tableView reloadData];
    
    if( self.titleTextField.text.length == 0 )
    {
        [self.titleTextField becomeFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField == self.priceTextField )
    {
        if( textField.text.length == 0 )
        {
            textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
        }
    }
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if( textField == self.priceTextField )
    {
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if( ![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]] )
        {
            return NO;
        }
    }

    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setDetailItem:(id)newData
{
    if( _data != newData )
    {
        _data = newData;
    }
}

- (IBAction)goToHashtags
{
    [self performSegueWithIdentifier:@"posHashtags" sender:nil];
}

- (IBAction)titleTextChanged
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

- (IBAction)Post:(id)sender
{
    NSString *choice;
    
    switch( self.dishTypeSegementedControl.selectedSegmentIndex )
    {
        case 0: choice = @"food";  break;
        case 1: choice = @"drink"; break;
        case 2: choice = @"wine";  break;
    }
    
    NSLog(@"Post: %@ %@ %@ %@ %@ %@", choice,
                                      self.titleTextField.text,
    						 		  self.commentTextView.text,
                                      self.imAtButton.titleLabel.text,
                                      self.priceTextField.text,
    						 		  self.ratingLabel.text);
}
@end
