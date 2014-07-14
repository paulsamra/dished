//
//  DANewRegisterViewController.h
//  Dished
//
//  Created by Ryan Khalili on 7/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DARegisterViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField        *firstNameField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *firstNameCell;
@property (weak, nonatomic) IBOutlet UITextField        *lastNameField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *lastNameCell;
@property (weak, nonatomic) IBOutlet UITextField        *usernameField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *usernameCell;
@property (weak, nonatomic) IBOutlet UITextField        *emailField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *emailCell;
@property (weak, nonatomic) IBOutlet UITextField        *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *phoneNumberCell;
@property (weak, nonatomic) IBOutlet UITextField        *passwordField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *passwordCell;
@property (weak, nonatomic) IBOutlet UITextField        *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UITableViewCell    *confirmPasswordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell    *dateOfBirthCell;
@property (weak, nonatomic) IBOutlet UIButton           *signInButton;


@end