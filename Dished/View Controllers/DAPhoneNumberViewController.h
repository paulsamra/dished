//
//  DAForgotPasswordViewController.h
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DAPhoneNumberViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *resetPasswordLabel;
@property (weak, nonatomic) IBOutlet UILabel *registerPhoneNumberLabel;

@property (strong, nonatomic) NSDictionary *facebookUserInfo;

@property (nonatomic) BOOL registrationMode;

@end