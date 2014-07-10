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


@interface DAFormTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel            *ratingLabel;
@property (weak, nonatomic) IBOutlet UIButton           *hashTagButton;
@property (weak, nonatomic) IBOutlet UIButton           *imAtButton;
@property (weak, nonatomic) IBOutlet UITextField        *titleTextField;
@property (weak, nonatomic) IBOutlet SZTextView         *commentTextView;
@property (weak, nonatomic) IBOutlet UITextField        *priceTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *PostButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dishTypeSegementedControl;

@property (strong, nonatomic) id data;
@property (nonatomic, retain) AutoComleteTableView *autocompleteTableView;

- (IBAction)Post:(id)sender;
- (void)setDetailItem:(id)newData;

@end
