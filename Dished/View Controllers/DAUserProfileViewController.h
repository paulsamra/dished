//
//  DAUserProfileViewController.h
//  Dished
//
//  Created by Ryan Khalili on 9/30/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAUserProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView             *firstButtonSeperator;
@property (weak, nonatomic) IBOutlet UIView             *secondButtonSeperator;
@property (weak, nonatomic) IBOutlet UIView             *thirdButtonSeperator;
@property (weak, nonatomic) IBOutlet UIView             *centerButtonSeperator;
@property (weak, nonatomic) IBOutlet UIView             *descriptionSeperator;
@property (weak, nonatomic) IBOutlet UIView             *topView;
@property (weak, nonatomic) IBOutlet UIView             *middleView;
@property (weak, nonatomic) IBOutlet UILabel            *privacyLabel;
@property (weak, nonatomic) IBOutlet UIButton           *directionsButton;
@property (weak, nonatomic) IBOutlet UIButton           *phoneNumberButton;
@property (weak, nonatomic) IBOutlet UIButton           *dishesMapButton;
@property (weak, nonatomic) IBOutlet UIButton           *moreInfoButton;
@property (weak, nonatomic) IBOutlet UIButton           *numDishesButton;
@property (weak, nonatomic) IBOutlet UIButton           *numFollowingButton;
@property (weak, nonatomic) IBOutlet UIButton           *numFollowersButton;
@property (weak, nonatomic) IBOutlet UIButton           *followButton;
@property (weak, nonatomic) IBOutlet UITextView         *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView        *userImageView;
@property (weak, nonatomic) IBOutlet UITableView        *wineTableView;
@property (weak, nonatomic) IBOutlet UITableView        *cocktailTableView;
@property (weak, nonatomic) IBOutlet UITableView        *foodTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dishTypeChooser;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *seperatorConstraints;


@property (strong, nonatomic) NSString *username;

@property (nonatomic) BOOL      isRestaurant;
@property (nonatomic) NSInteger user_id;
@property (nonatomic) NSInteger loc_id;

@end