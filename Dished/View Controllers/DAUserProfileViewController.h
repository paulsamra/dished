//
//  DAUserProfileViewController.h
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView             *topView;
@property (weak, nonatomic) IBOutlet UIView             *middleView;
@property (weak, nonatomic) IBOutlet UIButton           *dishesMapButton;
@property (weak, nonatomic) IBOutlet UIButton           *numDishesButton;
@property (weak, nonatomic) IBOutlet UIButton           *numFollowingButton;
@property (weak, nonatomic) IBOutlet UIButton           *numFollowersButton;
@property (weak, nonatomic) IBOutlet UIButton           *followButton;
@property (weak, nonatomic) IBOutlet UITextView         *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView        *userImageView;
@property (weak, nonatomic) IBOutlet UITableView        *dishesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dishTypeChooser;

@property (strong, nonatomic) NSString *username;

@property (nonatomic) NSInteger user_id;

@end