//
//  DAEditProfileViewController.h
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"


@interface DAEditProfileViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel         *addPhotoLabel;
@property (weak, nonatomic) IBOutlet UILabel         *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel         *influencerLabel;
@property (weak, nonatomic) IBOutlet SZTextView      *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField     *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField     *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField     *emailField;
@property (weak, nonatomic) IBOutlet UITextField     *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField     *passwordField;
@property (weak, nonatomic) IBOutlet UITextField     *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIImageView     *placeholderUserImageView;
@property (weak, nonatomic) IBOutlet UIImageView     *userImageView;
@property (weak, nonatomic) IBOutlet UITableViewCell *dateOfBirthCell;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageSeperatorWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameSeperatorHeightConstraint;

@end