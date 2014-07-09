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
@synthesize autocompleteTableView, imAtLabel;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.priceTextView.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];

    if (textField.text.length  == 0)
    {
        textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Make sure that the currency symbol is always at the beginning of the string:
    if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
    {
        return NO;
    }
    
    // Default:
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    autocompleteTableView = [[AutoComleteTableView alloc] initWithFrame:CGRectMake(0, 44, 320, 189) withClass:self];
    [self.view addSubview:autocompleteTableView];
    autocompleteTableView.hidden = YES;

    self.titleTextView.delegate = self;
    [self.titleTextView becomeFirstResponder];
    self.priceTextView.delegate = self;
    self.priceTextView.textColor = [UIColor grayColor];

    
    [[SZTextView appearance] setPlaceholderTextColor:[UIColor lightGrayColor]];
    self.titleTextView.placeholder = @"Title";
    self.titleTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

    
    self.commentTextView.placeholder = @"Comment";
    self.commentTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    self.hashTagLabel.text = @"#Tags";
    self.hashTagLabel.textColor = [UIColor lightGrayColor];
    self.hashTagLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    self.imAtLabel.text = @"I'm at";
    self.imAtLabel.textColor = [UIColor lightGrayColor];
    self.imAtLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];

    self.ratingLabel.text = @"Rating";
    self.ratingLabel.textColor = [UIColor lightGrayColor];
    self.ratingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];


}

- (void)navigationController: (UINavigationController *)navigationController
       didShowViewController: (UIViewController *)viewController
                    animated: (BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setDetailItem:(id)newData {
    if (_data != newData) {
        _data = newData;
    }
    
}


-(void)viewWillAppear:(BOOL)animated {
    
    if (_data) {
        self.imAtLabel.text = (NSString *)_data;
        self.imAtLabel.textColor = [UIColor blackColor];

    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


#pragma mark UITextFieldDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    autocompleteTableView.hidden = NO;
    
    NSString *substring = [NSString stringWithString:textView.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:text];
    [autocompleteTableView searchAutocompleteEntriesWithSubstring:substring];
    return YES;
}

- (IBAction)Post:(id)sender {
    
    NSString *choise;
    
    switch (self.AddDishSegmentedControl.selectedSegmentIndex) {
        case 0:
            choise = @"food";
            break;
        case 1:
            choise = @"drink";
            break;
        case 2:
            choise = @"wine";
            break;
        default:
            break;
    }
    
    NSLog(@"Post: %@ %@ %@ %@ %@ %@", choise,
                                      self.titleTextView.text,
    						 		  self.commentTextView.text,
                                      self.imAtLabel.text,
                                      self.priceTextView.text,
    						 		  self.ratingLabel.text);
}
@end
