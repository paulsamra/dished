//
//  DANewRegisterViewController.m
//  Dished
//
//  Created by Ryan Khalili on 7/13/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARegisterViewController.h"
#import "DAErrorView.h"
#import "DAAPIManager.h"
#import "MRProgress.h"
#import "DAAppDelegate.h"


@interface DARegisterViewController() <DAErrorViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSDate               *dateOfBirth;
@property (strong, nonatomic) UIImage              *errorIconImage;
@property (strong, nonatomic) UIImage              *validIconImage;
@property (strong, nonatomic) DAErrorView          *errorView;
@property (strong, nonatomic) NSIndexPath          *pickerIndexPath;
@property (strong, nonatomic) UIAlertView          *loginFailAlert;
@property (strong, nonatomic) UIAlertView          *registerFailAlert;
@property (strong, nonatomic) UIAlertView          *registerSuccessAlert;
@property (strong, nonatomic) NSDateFormatter      *birthDateFormatter;
@property (strong, nonatomic) NSMutableDictionary  *errorData;
@property (strong, nonatomic) NSURLSessionDataTask *usernameCheckTask;

@property (nonatomic) BOOL errorVisible;
@property (nonatomic) BOOL usernameIsValid;

@end


@implementation DARegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    self.errorData  = [[NSMutableDictionary alloc] init];
    self.usernameIsValid = NO;
    
    self.errorIconImage = [UIImage imageNamed:@"invalid_input"];
    self.validIconImage = [UIImage imageNamed:@"valid_input"];
}

- (void)errorViewDidTapCloseButton:(DAErrorView *)errorView
{
    [self dismissErrorView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if( self.facebookUserInfo )
    {
        self.firstNameField.text = self.facebookUserInfo[@"first_name"];
        self.lastNameField.text  = self.facebookUserInfo[@"last_name"];
        self.emailField.text     = self.facebookUserInfo[@"email"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM/dd/yyyy";
        self.dateOfBirth = [dateFormatter dateFromString:self.facebookUserInfo[@"birthday"]];
        self.dateOfBirthCell.detailTextLabel.text = [self.birthDateFormatter stringFromDate:self.dateOfBirth];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.errorView = [[DAErrorView alloc] initWithFrame:[self invisibleErrorFrame]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.errorView];
    self.errorView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.errorView removeFromSuperview];
    
    [super viewWillDisappear:animated];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (void)showErrorView
{
    if( self.errorVisible )
    {
        return;
    }
    
    self.errorVisible = YES;
    
    [UIView animateWithDuration:0.5 animations:^
    {
        [self.errorView setFrame:[self visibleErrorFrame]];
    }];
}

- (void)dismissErrorView
{
    self.errorVisible = NO;
    
    [UIView animateWithDuration:0.3 animations:^
    {
        [self.errorView setFrame:[self invisibleErrorFrame]];
    }];
}

- (CGRect)invisibleErrorFrame
{
    CGRect visibleFrame = [self visibleErrorFrame];
    visibleFrame.origin.y -= 100;
    return visibleFrame;
}

- (CGRect)visibleErrorFrame
{
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navBarRect    = self.navigationController.navigationBar.bounds;
    
    CGPoint location = statusBarRect.origin;
    CGFloat height = navBarRect.size.height + statusBarRect.size.height;
    CGSize  size = CGSizeMake( navBarRect.size.width, height );
    
    return CGRectMake( location.x, location.y, size.width, size.height );
}

- (IBAction)textFieldDidChange:(UITextField *)textField
{
    if( self.errorVisible )
    {
        [self dismissErrorView];
    }
    
    if( textField == self.firstNameField )
    {
        if( [textField.text length] > 0 )
        {
            self.firstNameCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
        }
        else
        {
            self.firstNameCell.accessoryView = nil;
        }
    }
    
    if( textField == self.lastNameField )
    {
        if( [textField.text length] > 0 )
        {
            self.lastNameCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
        }
        else
        {
            self.lastNameCell.accessoryView = nil;
        }
    }
    
    if( textField == self.usernameField )
    {
        if( [textField.text length] > 1 )
        {
            NSString *username = [textField.text substringFromIndex:1];
            
            if( self.usernameCheckTask )
            {
                [self.usernameCheckTask cancel];
            }
            
            self.usernameIsValid = YES;
            
            NSDictionary *parameters = @{ @"username" : username };
            
            self.usernameCheckTask = [[DAAPIManager sharedManager] GET:@"users/availability/username" parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                                          
                if( response.statusCode == 200 )
                {
                    self.usernameCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
                   
                    self.usernameIsValid = YES;
                    [self dismissErrorView];
                }
                else
                {
                    self.usernameIsValid = NO;
                    self.usernameCell.accessoryView = nil;
                }
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                if( error.code != -999 )
                {
                    NSDictionary *errorResponse = error.userInfo[[DAAPIManager errorResponseKey]];
              
                    if( [errorResponse[@"error"] isEqualToString:@"username_exists"] )
                    {
                        self.errorView.errorTextLabel.text = @"Username unavailable!";
                        self.errorView.errorTipLabel.text  = @"Please choose a different username.";
                  
                        [self showErrorView];
                        self.usernameIsValid = NO;
                  
                        self.usernameCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    }
                    else if( [errorResponse[@"error"] isEqualToString:@"username_invalid"] )
                    {
                        self.errorView.errorTextLabel.text = @"Invalid Username!";
                        self.errorView.errorTipLabel.text  = @"Your username must only contain letters and numbers.";
                  
                        [self showErrorView];
                        self.usernameIsValid = NO;
                  
                        self.usernameCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    }
                    else
                    {
                        self.usernameIsValid = NO;
                        self.usernameCell.accessoryView = nil;
                    }
                }
            }];
        }
        else
        {
            [self.usernameCheckTask cancel];
            self.usernameIsValid = NO;
            [self dismissErrorView];
            self.usernameCell.accessoryView = nil;
        }
    }
    
    if( textField == self.emailField )
    {
        if( [self.errorData objectForKey:@"Email"] )
        {
            [self dismissErrorView];
            [self.errorData removeObjectForKey:@"Email"];
            self.emailCell.accessoryView = nil;
        }
        
        if( [textField.text length] == 0 )
        {
            self.emailCell.accessoryView = nil;
        }
    }
    
    if( textField == self.phoneNumberField )
    {
        if( [self.errorData objectForKey:@"Phone Number"] )
        {
            [self dismissErrorView];
            [self.errorData removeObjectForKey:@"Phone Number"];
            self.phoneNumberCell.accessoryView = nil;
        }
        
        if( [self phoneNumberIsValid:textField.text] )
        {
            self.phoneNumberCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
        }
        else
        {
            self.phoneNumberCell.accessoryView = nil;
        }
    }
    
    if( textField == self.passwordField )
    {
        if( [textField.text length] >= 6 )
        {
            self.passwordCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
        }
        else
        {
            self.passwordCell.accessoryView = nil;
        }
        
        if( textField.text.length == 0 )
        {
            self.confirmPasswordCell.accessoryView = nil;
        }
    }
    
    if( textField == self.confirmPasswordField )
    {
        NSString *firstPassword = self.passwordField.text;
        
        if( textField.text.length == 0 )
        {
            self.confirmPasswordCell.accessoryView = nil;
        }
        else if( [textField.text isEqualToString:firstPassword] && textField.text.length >= 6 && firstPassword.length >= 6 )
        {
            self.confirmPasswordCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
        }
        else
        {
            self.confirmPasswordCell.accessoryView = nil;
        }
    }
}

- (BOOL)phoneNumberIsValid:(NSString *)phoneNumber
{
    if( !phoneNumber || phoneNumber.length < 10 )
    {
        return NO;
    }
    
    NSString *after1 = [phoneNumber substringFromIndex:3];
    NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [[components componentsJoinedByString:@""] mutableCopy];
    
    if( decimalString.length < 10 )
    {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 5 && indexPath.row == 0 )
    {
        [self toggleDatePicker];
        
        if( self.pickerIndexPath && !self.dateOfBirth )
        {
            DADatePickerTableViewCell *cell = (DADatePickerTableViewCell *)[tableView cellForRowAtIndexPath:self.pickerIndexPath];
            UIDatePicker *picker = cell.datePicker;
            self.dateOfBirth = picker.date;
            self.dateOfBirthCell.detailTextLabel.text = [self.birthDateFormatter stringFromDate:picker.date];
        }
    }
    
    if( indexPath.section == 6 )
    {
        [self checkInputsAndRegister];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 5 && indexPath.row == 1 )
    {
        DADatePickerTableViewCell *cell = [[DADatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"datePickerCell"];
        
        if( self.dateOfBirth )
        {
            cell.datePicker.date = self.dateOfBirth;
        }
        
        [cell.datePicker addTarget:self action:@selector(dateChosen:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 5 && self.pickerIndexPath )
    {
        return 2;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 5 && indexPath.row == 1 )
    {
        return 162;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 5  && indexPath.row == 1 )
    {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (void)toggleDatePicker
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:1 inSection:5] ];
    
    if ( self.pickerIndexPath )
    {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = nil;
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = [indexPaths objectAtIndex:0];
    }
    
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:self.pickerIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)checkInputsAndRegister
{
    int numOfInvalidInputs = 0;
    BOOL tooYoung = NO;
        
    if( !self.firstNameField.text || self.firstNameField.text.length == 0 )
    {
        numOfInvalidInputs++;
        self.firstNameCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( !self.lastNameField.text || self.lastNameField.text.length == 0 )
    {
        numOfInvalidInputs++;
        self.lastNameCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( !self.usernameField.text || self.usernameField.text.length <= 1 || !self.usernameIsValid )
    {
        numOfInvalidInputs++;
        self.usernameCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( !self.emailField.text || ![self stringIsValidEmail:self.emailField.text] )
    {
        numOfInvalidInputs++;
        self.emailCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( !self.phoneNumberField.text || ![self phoneNumberIsValid:self.phoneNumberField.text] )
    {
        numOfInvalidInputs++;
        self.phoneNumberCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( !self.passwordField.text || self.passwordField.text.length < 6 )
    {
        numOfInvalidInputs++;
        self.passwordCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    NSString *confirmPassword = self.confirmPasswordField.text;
    if( !confirmPassword || [confirmPassword length] < 6 || ( self.passwordField.text.length >= 6 && ![confirmPassword isEqualToString:self.passwordField.text] ) )
    {
        numOfInvalidInputs++;
        self.confirmPasswordCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( !self.dateOfBirth || [self ageWithDate:self.dateOfBirth] < 13 )
    {
        numOfInvalidInputs++;
        
        if( [self ageWithDate:self.dateOfBirth] < 13 )
        {
            tooYoung = YES;
        }
        
        self.dateOfBirthCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
    }
    
    if( numOfInvalidInputs == 1 && tooYoung )
    {
        self.errorView.errorTextLabel.text = @"You're too young!";
        self.errorView.errorTipLabel.text  = @"You must be 13 years or older to sign up for Dished.";
        
        [self showErrorView];
        
        return;
    }
    
    if( numOfInvalidInputs > 0 )
    {
        self.errorView.errorTextLabel.text = [NSString stringWithFormat:@"%d fields are invalid.", numOfInvalidInputs];
        self.errorView.errorTipLabel.text  = @"Please correct the fields marked red before registering.";
        
        [self showErrorView];
        
        return;
    }
    
    [self showProgressView];
    [self checkEmailAndPhoneNumber];
}

- (BOOL)stringIsValidEmail:(NSString *)checkString
{
    NSString *emailRegex = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (int)ageWithDate:(NSDate *)date
{
    if( !date )
    {
        return 0;
    }
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:date toDate:now options:0];
    NSInteger age = [ageComponents year];
    
    return (int)age;
}

- (void)showProgressView
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"Registering..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
}

- (void)checkEmailAndPhoneNumber
{
    __block BOOL emailSuccess = YES;
    __block BOOL phoneSuccess = YES;
    __block BOOL errorOccured = NO;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter( group );
    
    NSDictionary *emailParameters = @{ kEmailKey : self.emailField.text };

    [[DAAPIManager sharedManager] GET:kEmailAvailabilityURL parameters:emailParameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        errorOccured &= NO;
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( errorType == eErrorTypeEmailExists )
        {
            errorOccured &= NO;
            emailSuccess = NO;
        }
        else
        {
            errorOccured &= YES;
        }
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_enter( group );
    
    NSString *phoneNumber = self.phoneNumberField.text;
    NSString *after1 = [phoneNumber substringFromIndex:3];
    NSArray  *parts = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalStr = [[parts componentsJoinedByString:@""] mutableCopy];
    
    NSDictionary *phoneParameters = @{ kPhoneKey : decimalStr };
    
    [[DAAPIManager sharedManager] GET:kPhoneAvailabilityURL parameters:phoneParameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        errorOccured &= NO;
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( errorType == eErrorTypePhoneExists )
        {
            errorOccured &= NO;
            phoneSuccess = NO;
        }
        else
        {
            errorOccured &= YES;
        }
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        if( errorOccured )
        {
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
            {
                [self.registerFailAlert show];
            }];
        }
        else
        {
            if( !emailSuccess )
            {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
                {
                    [self showAlertMessageWithTitle:@"Account Exists" message:@"An account with the given email address already exists. Please sign in or submit a forgotten password request."];
                }];
            }
            else if( !phoneSuccess )
            {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
                {
                    [self showAlertMessageWithTitle:@"Phone Number Exists" message:@"An account with the given phone number already exists. Please sign in or enter a different phone number."];
                }];
            }
            else
            {
                [self registerUser];
            }
        }
    });
}

- (void)registerUser
{
    NSString *firstName = self.firstNameField.text;
    NSString *lastName  = self.lastNameField.text;
    NSString *username  = [self.usernameField.text substringFromIndex:1];
    NSString *email     = self.emailField.text;
    NSString *phone     = self.phoneNumberField.text;
    NSString *password  = self.passwordField.text;
    NSDate *dateOfBirth = self.dateOfBirth;
    
    NSString *after1 = [phone substringFromIndex:3];
    NSArray  *parts = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [[parts componentsJoinedByString:@""] mutableCopy];
    
    [[DAAPIManager sharedManager] registerUserWithUsername:username password:password firstName:firstName lastName:lastName email:email phoneNumber:decimalString birthday:dateOfBirth completion:^( BOOL registered, BOOL loggedIn )
    {
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
        {
            if( !registered )
            {
                [self.registerFailAlert show];
            }
            else if( registered && !loggedIn )
            {
                [self.loginFailAlert show];
            }
            else
            {
                [self.registerSuccessAlert show];
            }
        }];
    }];
}

- (void)dateChosen:(id)sender
{
    [self dismissErrorView];
    
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    self.dateOfBirth = datePicker.date;
    
    self.dateOfBirthCell.detailTextLabel.text = [self.birthDateFormatter stringFromDate:datePicker.date];
    self.dateOfBirthCell.accessoryView = nil;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( alertView == self.loginFailAlert || alertView == self.registerSuccessAlert )
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    if( alertView == self.registerSuccessAlert )
    {
        DAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate setRootView];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField == self.usernameField )
    {
        if( [textField.text length] == 0 )
        {
            textField.text = @"@";
        }
    }
    
    if( textField == self.phoneNumberField )
    {
        if( textField.text.length == 0 )
        {
            textField.text = @"+1 ";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == self.emailField )
    {
        if( ![self stringIsValidEmail:textField.text] )
        {
            if( !self.errorVisible && [textField.text length] > 0 )
            {
                self.errorView.errorTextLabel.text = @"Invalid Email Address!";
                self.errorView.errorTipLabel.text  = @"Please enter a valid email address.";
                
                [self.errorData setObject:@"error" forKey:@"Email"];
                [self showErrorView];
            }
            
            if( [textField.text length] > 0 )
            {
                self.emailCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
            }
        }
        else
        {
            self.emailCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
            [self dismissErrorView];
        }
    }
    
    if( textField == self.phoneNumberField )
    {
        if( textField.text.length == 3 )
        {
            textField.text = @"";
            return;
        }
        
        if( ![self phoneNumberIsValid:textField.text] )
        {
            if( !self.errorVisible && [textField.text length] > 0 )
            {
                self.errorView.errorTextLabel.text = @"Invalid Phone Number!";
                self.errorView.errorTipLabel.text  = @"Please enter a 7 digit phone number, with area code first.";
                
                [self.errorData setObject:@"error" forKey:@"Phone Number"];
                [self showErrorView];
            }
            
            if( [textField.text length] > 0 )
            {
                self.phoneNumberCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
            }
        }
        else
        {
            self.phoneNumberCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
            [self dismissErrorView];
        }
    }
    
    if( textField == self.passwordField || textField == self.confirmPasswordField )
    {
        if( textField == self.passwordField )
        {
            if( [textField.text length] < 6 )
            {
                if( !self.errorVisible && [textField.text length] > 0 )
                {
                    self.errorView.errorTextLabel.text = @"Invalid Password!";
                    self.errorView.errorTipLabel.text  = @"Your password must be at least 6 characters.";
                    
                    self.passwordCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    [self showErrorView];
                }
            }
            else
            {
                self.passwordCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
                [self dismissErrorView];
            }
        }
        
        if( textField == self.confirmPasswordField )
        {
            NSString *firstPassword = self.passwordField.text;
            
            if( ![textField.text isEqualToString:firstPassword] )
            {
                if( !self.errorVisible && [textField.text length] > 0 && [firstPassword length] > 0 )
                {
                    self.errorView.errorTextLabel.text = @"Invalid Password!";
                    self.errorView.errorTipLabel.text  = @"Your passwords must match.";
                    
                    self.confirmPasswordCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    [self showErrorView];
                }
            }
            else
            {
                if( [firstPassword length] > 0 && [textField.text length] > 0 )
                {
                    self.confirmPasswordCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
                    [self dismissErrorView];
                }
            }
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if( textField == self.usernameField )
    {
        if( [newString length] == 0 )
        {
            return NO;
        }
    }
    
    if( textField == self.phoneNumberField )
    {
        if( newString.length < 3 )
        {
            return NO;
        }
        
        NSString *after1 = [newString substringFromIndex:3];
        NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
        NSString *decimalString = [[components componentsJoinedByString:@""] mutableCopy];
        NSUInteger length = decimalString.length;
        
        if( length > 10 )
        {
            return NO;
        }
        
        NSUInteger index = 0;
        NSMutableString *formattedString = [[NSMutableString alloc] initWithString:@"+1 "];
        
        if( length - index > 3 )
        {
            NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
            [formattedString appendFormat:@"(%@) ",areaCode];
            index += 3;
        }
        
        if( length - index > 3 )
        {
            NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
            [formattedString appendFormat:@"%@-",prefix];
            index += 3;
        }
        
        NSString *remainder = [decimalString substringFromIndex:index];
        [formattedString appendString:remainder];
        
        textField.text = formattedString;
        [self textFieldDidChange:textField];
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.firstNameField)
    {
        [self.lastNameField becomeFirstResponder];
    }
    else if( textField == self.lastNameField )
    {
        [self.usernameField becomeFirstResponder];
    }
    else if( textField == self.usernameField )
    {
        [self.emailField becomeFirstResponder];
    }
    else if( textField == self.emailField )
    {
        [self.phoneNumberField becomeFirstResponder];
    }
    else if( textField == self.phoneNumberField )
    {
        [self.passwordField becomeFirstResponder];
    }
    else if( textField == self.passwordField )
    {
        [self.confirmPasswordField becomeFirstResponder];
    }
    else
    {
        [self.view endEditing:YES];
        return YES;
    }
    
    return NO;
}

- (IBAction)goToSignIn
{
    [self performSegueWithIdentifier:@"goToLogin" sender:nil];
}

- (void)showAlertMessageWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil
                      cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (NSDateFormatter *)birthDateFormatter
{
    if( !_birthDateFormatter )
    {
        _birthDateFormatter = [[NSDateFormatter alloc] init];
        _birthDateFormatter.dateFormat = @"dd MMMM yyyy";
    }
    
    return _birthDateFormatter;
}

- (UIAlertView *)registerFailAlert
{
    if( !_registerFailAlert )
    {
        _registerFailAlert = [[UIAlertView alloc] initWithTitle:@"Registration Error" message:@"There was an error registering your account. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _registerFailAlert;
}

- (UIAlertView *)loginFailAlert
{
    if( !_loginFailAlert )
    {
        _loginFailAlert = [[UIAlertView alloc] initWithTitle:@"Error Logging In" message:@"We were able to register your account, but there was a problem signing in. Please sign in with your username and password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _loginFailAlert;
}

- (UIAlertView *)registerSuccessAlert
{
    if( !_registerSuccessAlert )
    {
        _registerSuccessAlert = [[UIAlertView alloc] initWithTitle:@"Successful Registration" message:@"Account created successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _registerSuccessAlert;
}

@end