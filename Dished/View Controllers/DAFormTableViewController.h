//
//  DAFormTableViewController.h
//  Dished
//
//  Created by Daryl Stimm on 7/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "AutoComleteTableView.h"

@interface DAFormTableViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate> {
    AutoComleteTableView *autocompleteTableView;
}


@property (weak, nonatomic) IBOutlet UISegmentedControl *AddDishSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *PostButton;
@property (weak, nonatomic) IBOutlet UILabel *hashTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *imAtLabel;
@property (strong, nonatomic) id data;

@property (weak, nonatomic) IBOutlet SZTextView *titleTextView;
@property (weak, nonatomic) IBOutlet SZTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UITextField *priceTextView;
@property (nonatomic, retain) AutoComleteTableView *autocompleteTableView;

- (IBAction)Post:(id)sender;
- (void)setDetailItem:(id)newData;
@end
