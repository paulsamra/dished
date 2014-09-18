//
//  DACommentsViewController.h
//  Dished
//
//  Created by Ryan Khalili on 8/27/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAFeedItem+Utility.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesToolbarContentView.h"
#import "JSQMessagesComposerTextView.h"
#import "JSQMessagesKeyboardController.h"


@interface DACommentsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet JSQMessagesInputToolbar *inputToolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;
@property (weak, nonatomic) DAFeedItem *feedItem;

@end