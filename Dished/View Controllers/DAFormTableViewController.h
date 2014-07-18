//
//  DAFormTableViewController.h
//  Dished
//
//  Created by Daryl Stimm on 7/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "DADishSuggestionsTableView.h"


@interface DAFormTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, DADishSuggestionsTableDelegate>

@property (weak, nonatomic) IBOutlet UIButton            *ratingButton;
@property (weak, nonatomic) IBOutlet UIButton            *hashtagButton;
@property (weak, nonatomic) IBOutlet UIButton            *imAtButton;
@property (weak, nonatomic) IBOutlet SZTextView          *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView         *tagsImageView;
@property (weak, nonatomic) IBOutlet UITextField         *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField         *priceTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem     *postButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl  *dishTypeSegmentedControl;

@property (strong, nonatomic) DADishSuggestionsTableView *dishSuggestionsTable;

@end