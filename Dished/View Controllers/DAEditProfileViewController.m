//
//  DAEditProfileViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAEditProfileViewController.h"
#import "DAUserManager.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "MRProgress.h"


@interface DAEditProfileViewController() <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

@property (copy,   nonatomic) NSDate          *dateOfBirth;
@property (strong, nonatomic) UIImage         *selectedImage;
@property (strong, nonatomic) NSIndexPath     *pickerIndexPath;
@property (strong, nonatomic) DAErrorView     *errorView;
@property (strong, nonatomic) UIAlertView     *deleteAccountAlert;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSURLSessionTask *saveProfileTask;
@property (strong, nonatomic) NSURLSessionTask *removeProfilePictureTask;

@property (nonatomic) BOOL errorVisible;

@end


@implementation DAEditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake( -35, 0, 0, 0 );
    self.tableView.rowHeight = 44.0;
    self.tableView.estimatedRowHeight = 44.0;
    
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    
    self.descriptionTextView.delegate = self;
    self.descriptionTextView.placeholder = @"Description";
    
    self.imageSeperatorWidthConstraint.constant = 0.5;
    self.nameSeperatorHeightConstraint.constant = 0.5;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    self.userImageView.userInteractionEnabled = YES;
    self.placeholderUserImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUserImage)];
    tapGesture1.numberOfTapsRequired = 1;
    [self.userImageView addGestureRecognizer:tapGesture1];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUserImage)];
    tapGesture2.numberOfTapsRequired = 1;
    [self.placeholderUserImageView addGestureRecognizer:tapGesture2];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self populateProfile];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.errorView = [[DAErrorView alloc] initWithFrame:[self invisibleErrorFrame]];
    [self.errorView.closeButton addTarget:self action:@selector(errorViewDidTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.errorView];
    self.errorVisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.errorView removeFromSuperview];
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [self.saveProfileTask cancel];
    [self.removeProfilePictureTask cancel];
}

- (void)errorViewDidTapCloseButton:(DAErrorView *)errorView
{
    [self dismissErrorView];
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
    CGRect navBarRect    = self.navigationController.navigationBar.frame;
    
    CGPoint location = statusBarRect.origin;
    CGFloat height = navBarRect.size.height + statusBarRect.size.height;
    CGSize  size = CGSizeMake( navBarRect.size.width, height );
    
    return CGRectMake( location.x, location.y, size.width, size.height );
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (void)populateProfile
{
    DAUserManager *userManager = [DAUserManager sharedManager];
    
    self.dateOfBirth = userManager.dateOfBirth;
    
    self.emailField.text          = userManager.email;
    self.usernameLabel.text       = [NSString stringWithFormat:@"@%@", userManager.username];
    self.lastNameField.text       = userManager.lastName;
    self.firstNameField.text      = userManager.firstName;
    self.descriptionTextView.text = userManager.desc;
    
    if( userManager.phoneNumber.length == 10 )
    {
        NSMutableString *phoneNumber = [[NSMutableString alloc] initWithString:@"+1 "];
        [phoneNumber appendFormat:@"(%@) ", [userManager.phoneNumber substringToIndex:3]];
        [phoneNumber appendFormat:@"%@-", [userManager.phoneNumber substringWithRange:NSMakeRange( 3, 3 )]];
        [phoneNumber appendString:[userManager.phoneNumber substringFromIndex:6]];
        self.phoneNumberField.text = phoneNumber;
    }

    if( userManager.dateOfBirth )
    {
        self.dateOfBirth = userManager.dateOfBirth;
        self.dateOfBirthCell.detailTextLabel.text = [self.dateFormatter stringFromDate:userManager.dateOfBirth];
    }
    
    if( userManager.img_thumb.length > 0 )
    {
        self.addPhotoLabel.hidden = YES;
        self.placeholderUserImageView.hidden = YES;
        
        NSURL *userImageURL = [NSURL URLWithString:userManager.img_thumb];
        [self.userImageView setImageWithURL:userImageURL usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else
    {
        self.userImageView.hidden = YES;
    }
}

- (void)checkInputs
{
    if( !self.firstNameField.text || self.firstNameField.text.length == 0 )
    {
        self.errorView.messageLabel.text = @"Invalid First Name";
        self.errorView.tipLabel.text  = @"Please enter your first name.";
        
        [self showErrorView];
        return;
    }
    
    if( !self.lastNameField.text || self.lastNameField.text.length == 0 )
    {
        self.errorView.messageLabel.text = @"Invalid Last Name";
        self.errorView.tipLabel.text  = @"Please enter your last name.";
        
        [self showErrorView];
        return;
    }
    
    if( !self.emailField.text || ![self stringIsValidEmail:self.emailField.text] )
    {
        self.errorView.messageLabel.text = @"Invalid Email Address";
        self.errorView.tipLabel.text  = @"Please enter a valid email address.";
        
        [self showErrorView];
        return;
    }
    
    if( !self.phoneNumberField.text || ![self phoneNumberIsValid:self.phoneNumberField.text] )
    {
        self.errorView.messageLabel.text = @"Invalid Phone Number";
        self.errorView.tipLabel.text  = @"Please enter a valid phone number.";
        
        [self showErrorView];
        return;
    }
    
    if( self.passwordField.text.length > 0 || self.confirmPasswordField.text.length > 0 )
    {
        if( !self.passwordField.text || self.passwordField.text.length < 6 )
        {
            self.errorView.messageLabel.text = @"Invalid Password";
            self.errorView.tipLabel.text  = @"Your password must be at least 6 characters.";
            
            [self showErrorView];
            return;
        }
        
        NSString *confirmPassword = self.confirmPasswordField.text;
        if( !confirmPassword || [confirmPassword length] < 6 || ( self.passwordField.text.length >= 6 && ![confirmPassword isEqualToString:self.passwordField.text] ) )
        {
            self.errorView.messageLabel.text = @"Invalid Password";
            self.errorView.tipLabel.text  = @"Your passwords must match.";
            
            [self showErrorView];
            return;
        }
    }

    if( !self.dateOfBirth || [self ageWithDate:self.dateOfBirth] < 13 )
    {
        self.errorView.messageLabel.text = @"You're too young!";
        self.errorView.tipLabel.text  = @"You must be 13 years or older to be signed up with Dished.";
        
        [self showErrorView];
        return;
    }
    
    [self checkForEqualInputs];
}

- (void)checkForEqualInputs
{
    DAUserManager *userManager = [DAUserManager sharedManager];
    
    BOOL sameFirstName   = [self.firstNameField.text isEqualToString:userManager.firstName];
    BOOL sameLastName    = [self.lastNameField.text isEqualToString:userManager.lastName];
    BOOL sameEmail       = [self.emailField.text isEqualToString:userManager.email];
    BOOL sameDescription = [self.descriptionTextView.text isEqualToString:userManager.desc];
    
    NSString *after1 = [self.phoneNumberField.text substringFromIndex:3];
    NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [[components componentsJoinedByString:@""] mutableCopy];
    BOOL samePhone = [decimalString isEqualToString:userManager.phoneNumber];
    
    BOOL newPassword = self.passwordField.text.length > 0 || self.confirmPasswordField.text.length > 0;
    
    BOOL sameDateOfBirth = [self.dateOfBirth isEqualToDate:userManager.dateOfBirth];
    
    BOOL sameProfile = sameFirstName && sameLastName && sameEmail && sameDescription && samePhone && !newPassword && sameDateOfBirth && !self.selectedImage;
    
    if( sameProfile )
    {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self showProgressViewWithTitle:@"Saving..."];
        [self checkEmailAndPhoneNumber];
    }
}

- (void)showProgressViewWithTitle:(NSString *)title
{
    MRProgressOverlayView *view = [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    view.titleLabelText = title;
}

- (BOOL)stringIsValidEmail:(NSString *)checkString
{
    NSString *emailRegex = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)phoneNumberIsValid:(NSString *)phoneNumber
{
    if( !phoneNumber || phoneNumber.length < 4 )
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

- (void)tappedUserImage
{
    UIActionSheet *photoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Take Photo or Video", [DAUserManager sharedManager].img_thumb.length > 0 ? @"Remove Profile Picture" : nil, nil];
    photoActionSheet.destructiveButtonIndex = 2;
    
    [photoActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.cancelButtonIndex )
    {
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if( buttonIndex == 0 )
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else if( buttonIndex == 1 )
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if( buttonIndex == actionSheet.destructiveButtonIndex )
    {
        [[[UIAlertView alloc] initWithTitle:@"Are you sure you want to remove your profile picture?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
        return;
    }
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( alertView == self.deleteAccountAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            [self deleteAccount];
        }
        
        return;
    }
    
    if( buttonIndex != alertView.cancelButtonIndex )
    {
        [self showProgressViewWithTitle:@"Removing..."];
        [self removeProfilePicture];
    }
}

- (void)deleteAccount
{
    [self showProgressViewWithTitle:@"Deactivating Your Account..."];
    
    [[DAAPIManager sharedManager] deactivateUserAccountWithCompletion:^( BOOL success )
    {
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES completion:^
        {
            if( success )
            {
                DAAppDelegate *appDelegate = (DAAppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate logout];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Failed to Deactivate Account" message:@"There was a problem deactivating your account. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
        }];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    self.userImageView.image = chosenImage;
    self.selectedImage = chosenImage;
    
    self.userImageView.hidden = NO;
    self.placeholderUserImageView.hidden = YES;
    self.addPhotoLabel.hidden = YES;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 6 && indexPath.row == 0 )
    {
        [self toggleDatePicker];
    }
    
    if( indexPath.section == 7 )
    {
        [[[UIAlertView alloc] initWithTitle:@"Coming Soon" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
    
    if( indexPath.section == 8 )
    {
        self.deleteAccountAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to deactivate your account?" message:@"This cannot be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [self.deleteAccountAlert show];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 6 && indexPath.row == 1 )
    {
        DADatePickerTableViewCell *cell = [[DADatePickerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"datePickerCell"];
        
        if( self.dateOfBirth )
        {
            cell.datePicker.date = self.dateOfBirth;
        }
        
        [cell.datePicker addTarget:self action:@selector(dateChosen:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if( [[DAUserManager sharedManager] isFacebookUser] && indexPath.section == 5 )
    {
        cell.hidden = YES;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 6 && self.pickerIndexPath )
    {
        return 2;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 6 && indexPath.row == 1 )
    {
        return 175;
    }
    
    if( [[DAUserManager sharedManager] isFacebookUser] && indexPath.section == 5 )
    {
        return 0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 6  && indexPath.row == 1 )
    {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
    
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

- (void)toggleDatePicker
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:1 inSection:6] ];
    
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

- (void)dateChosen:(UIDatePicker *)datePicker
{
    self.dateOfBirth = datePicker.date;
    
    self.dateOfBirthCell.detailTextLabel.text = [self.dateFormatter stringFromDate:datePicker.date];
}

- (void)checkEmailAndPhoneNumber
{
    __block BOOL emailSuccess = YES;
    __block BOOL phoneSuccess = YES;
    __block BOOL errorOccured = NO;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter( group );
    
    if( [self.emailField.text isEqualToString:[DAUserManager sharedManager].email] )
    {
        dispatch_group_leave( group );
    }
    else
    {
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
    }
    
    dispatch_group_enter( group );
    
    NSString *phoneNumber = self.phoneNumberField.text;
    NSString *after1 = [phoneNumber substringFromIndex:3];
    NSArray  *parts = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalStr = [[parts componentsJoinedByString:@""] mutableCopy];
    
    if( [decimalStr isEqualToString:[DAUserManager sharedManager].phoneNumber] )
    {
        dispatch_group_leave( group );
    }
    else
    {
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
    }
    
    __weak typeof( self ) weakSelf = self;
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        if( errorOccured )
        {
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
            
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
            {
                [weakSelf showAlertMessageWithTitle:@"Error" message:@"An error occured while saving your profile. Please try again."];
            }];
        }
        else
        {
            if( !emailSuccess )
            {
                weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
                
                [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
                {
                    [weakSelf showAlertMessageWithTitle:@"Email Exists" message:@"An account with the given email address already exists."];
                }];
            }
            else if( !phoneSuccess )
            {
                weakSelf.navigationItem.rightBarButtonItem.enabled = NO;

                [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
                {
                    [weakSelf showAlertMessageWithTitle:@"Phone Number Exists" message:@"An account with the given phone number already exists."];
                }];
            }
            else
            {
                [weakSelf saveProfile];
            }
        }
    });
}

- (void)saveProfile
{
    DAUserManager *userManager = [DAUserManager sharedManager];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if( ![self.firstNameField.text isEqualToString:userManager.firstName] )
    {
        [parameters setObject:self.firstNameField.text forKey:@"fname"];
    }
    
    if( ![self.lastNameField.text isEqualToString:userManager.lastName] )
    {
        [parameters setObject:self.lastNameField.text forKey:@"lname"];
    }
    
    if( ![self.emailField.text isEqualToString:userManager.email] )
    {
        [parameters setObject:self.emailField.text forKey:kEmailKey];
    }
    
    if( ![self.descriptionTextView.text isEqualToString:userManager.desc] )
    {
        [parameters setObject:self.descriptionTextView.text forKey:@"desc"];
    }
    
    NSString *after1 = [self.phoneNumberField.text substringFromIndex:3];
    NSArray  *components = [after1 componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [[components componentsJoinedByString:@""] mutableCopy];
    
    if( ![decimalString isEqualToString:userManager.phoneNumber] )
    {
        [parameters setObject:decimalString forKey:kPhoneKey];
    }
    
    if( ![self.dateOfBirth isEqualToDate:userManager.dateOfBirth] )
    {
        [parameters setObject:@([self.dateOfBirth timeIntervalSince1970]) forKey:kDateOfBirthKey];
    }
    
    if( self.passwordField.text.length > 0 || self.confirmPasswordField.text.length > 0 )
    {
        [parameters setObject:self.passwordField.text forKey:@"password"];
    }
    
    if( self.selectedImage )
    {
        [self saveProfileWithImage:self.selectedImage parameters:parameters];
    }
    else
    {
        [self saveProfileWithParameters:parameters];
    }
}

- (void)saveProfileWithParameters:(NSDictionary *)parameters
{
    __weak typeof( self ) weakSelf = self;
    
    weakSelf.saveProfileTask = [[DAAPIManager sharedManager] POSTRequest:kUserUpdateURL withParameters:parameters
    success:^( id response )
    {
        NSString *idName = [NSString stringWithFormat:@"%d", (int)[DAUserManager sharedManager].user_id];
        [[NSNotificationCenter defaultCenter] postNotificationName:idName object:nil];
        
        [[DAUserManager sharedManager] loadUserInfoWithCompletion:^( BOOL success )
        {
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
            {
                if( success )
                {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
                    [weakSelf showAlertMessageWithTitle:@"Error Occurred" message:@"There was a problem saving your profile. Please try again."];
                }
            }];
        }];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf saveProfileWithParameters:parameters];
        }
        else
        {
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
            
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
            {
                [weakSelf handleSaveError:error];
            }];
        }
    }];
}

- (void)saveProfileWithImage:(UIImage *)image parameters:(NSDictionary *)parameters
{
    __weak typeof( self ) weakSelf = self;
    
    weakSelf.saveProfileTask = [[DAAPIManager sharedManager] POSTRequest:kUserUpdateURL withParameters:parameters
    constructingBodyWithBlock:^( id<AFMultipartFormData> formData )
    {
        float compression = 0.6;
        NSData *imageData = UIImageJPEGRepresentation( image, compression );
        int maxFileSize = 500000;
        while( [imageData length] > maxFileSize )
        {
            compression -= 0.1;
            imageData = UIImageJPEGRepresentation( image, compression );
        }
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
    }
    success:^( id response )
    {
        [[DAUserManager sharedManager] loadUserInfoWithCompletion:^( BOOL success )
        {
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
            {
                if( success )
                {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
                    [weakSelf showAlertMessageWithTitle:@"Error Occurred" message:@"There was a problem saving your profile. Please try again."];
                }
            }];
        }];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf saveProfileWithImage:image parameters:parameters];
        }
        else
        {
            weakSelf.navigationItem.rightBarButtonItem.enabled = NO;
            
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
            {
                [weakSelf handleSaveError:error];
            }];
        }
    }];
}

- (void)handleSaveError:(NSError *)error
{
    eErrorType errorType = [DAAPIManager errorTypeForError:error];
    
    if( errorType != eErrorTypeRequestCancelled )
    {
        [self showAlertMessageWithTitle:@"Error Occurred" message:@"There was a problem saving your profile. Please try again."];
    }
}

- (void)removeProfilePicture
{
    UIImage *tempImage = self.userImageView.image;
    
    __weak typeof( self ) weakSelf = self;
        
    weakSelf.removeProfilePictureTask = [[DAAPIManager sharedManager] POSTRequest:kUserImageDeleteURL withParameters:nil
    success:^( id response )
    {
        weakSelf.userImageView.image = nil;
        weakSelf.userImageView.hidden = YES;
        weakSelf.placeholderUserImageView.hidden = NO;
        weakSelf.addPhotoLabel.hidden = NO;
        
        [[DAUserManager sharedManager] loadUserInfoWithCompletion:^( BOOL success )
        {
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:nil];
        }];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [weakSelf removeProfilePicture];
        }
        else
        {
            weakSelf.userImageView.image = tempImage;
            
            [MRProgressOverlayView dismissOverlayForView:weakSelf.view animated:YES completion:^
            {
                [self showAlertMessageWithTitle:@"Error Occurred" message:@"There was a problem removing your profile picture. Please try again."];
            }];
        }
    }];
}

- (void)showAlertMessageWithTitle:(NSString *)title message:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK"
                      otherButtonTitles:nil, nil] show];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if( textField == self.phoneNumberField && textField.text.length == 0 )
    {
        textField.text = @"+1 ";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if( textField == self.phoneNumberField && textField.text.length == 3 )
    {
        textField.text = @"";
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
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
        
        return NO;
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if( [text isEqualToString:@"\n"] )
    {
        return NO;
    }
    
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if( newString.length > 200 )
    {
        return NO;
    }
    
    return YES;
}

- (void)saveButtonTapped
{
    [self.view endEditing:YES];
    
    [self checkInputs];
}

- (NSDateFormatter *)dateFormatter
{
    if( !_dateFormatter )
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"dd MMMM yyyy";
    }
    
    return _dateFormatter;
}

@end