//
//  DAResetPasswordViewController.h
//  Dished
//
//  Created by Ryan Khalili on 6/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DAResetPasswordViewController : UIViewController

@property (weak,   nonatomic) IBOutlet UITextField *codeField;
@property (weak,   nonatomic) IBOutlet UITextField *passwordField;
@property (weak,   nonatomic) IBOutlet UITextField *confirmField;
@property (weak,   nonatomic) IBOutlet UIButton    *submitButton;
@property (strong, nonatomic)          NSString    *phoneNumber;

@end