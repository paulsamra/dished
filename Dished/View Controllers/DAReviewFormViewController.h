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


@class DANewReview;

@interface DAReviewFormViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, DADishSuggestionsTableDelegate>


@property (weak, nonatomic) IBOutlet UIImageView         *facebookImage;
@property (weak, nonatomic) IBOutlet UIImageView         *twitterImage;
@property (weak, nonatomic) IBOutlet UIImageView         *emailImage;
@property (weak, nonatomic) IBOutlet UIButton            *ratingButton;
@property (weak, nonatomic) IBOutlet UIButton            *hashtagButton;
@property (weak, nonatomic) IBOutlet UIButton            *imAtButton;
@property (weak, nonatomic) IBOutlet SZTextView          *commentTextView;
@property (weak, nonatomic) IBOutlet UIImageView         *tagsImageView;
@property (weak, nonatomic) IBOutlet UITextField         *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField         *priceTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem     *postButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl  *dishTypeSegmentedControl;

@property (weak,   nonatomic) UIImage                    *reviewImage;
@property (strong, nonatomic) DANewReview                *review;
@property (strong, nonatomic) DADishSuggestionsTableView *dishSuggestionsTable;

@end