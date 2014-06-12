//
//  DARegisterViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/5/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARegisterViewController.h"
#import "DATextFieldCell.h"
#import "DADatePickerCell.h"
#import "DAErrorView.h"
#import "DAAPIManager.h"
#import "MRProgress.h"

static NSString *kTextFieldCellID = @"textFieldCell";
static NSString *kDateCellID      = @"dateCell";
static NSString *kPickerCellID    = @"pickerCell";
static NSString *kRegisterCellID  = @"registerCell";


@interface DARegisterViewController() <DATextFieldCellDelegate, DAErrorViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIImage             *errorIconImage;
@property (strong, nonatomic) UIImage             *validIconImage;
@property (strong, nonatomic) DAErrorView         *errorView;
@property (strong, nonatomic) NSIndexPath         *pickerIndexPath;
@property (strong, nonatomic) UIAlertView         *emailExistsAlert;
@property (strong, nonatomic) UIAlertView         *loginFailAlert;
@property (strong, nonatomic) UIAlertView         *registerFailAlert;
@property (strong, nonatomic) UIAlertView         *registerSuccessAlert;
@property (strong, nonatomic) NSDictionary        *titleData;
@property (strong, nonatomic) NSDateFormatter     *birthDateFormatter;
@property (strong, nonatomic) NSMutableDictionary *signUpData;
@property (strong, nonatomic) NSMutableDictionary *errorData;

@property (nonatomic) BOOL errorVisible;
@property (nonatomic) BOOL usernameIsValid;
@property (nonatomic) BOOL shouldUpdateUsernameStatus;

@end


@implementation DARegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);
    
    UINib *textCellNib = [UINib nibWithNibName:@"DATextFieldCell" bundle:nil];
    [self.tableView registerNib:textCellNib forCellReuseIdentifier:kTextFieldCellID];
    
    self.signUpData = [[NSMutableDictionary alloc] init];
    self.errorData  = [[NSMutableDictionary alloc] init];
    
    self.usernameIsValid = NO;
    
    self.shouldUpdateUsernameStatus = YES;
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
    [self.view endEditing:YES];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( section == 0 || section == 4 )
    {
        return 2;
    }
    
    if( section == 5 && self.pickerIndexPath )
    {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if( indexPath.section >= 0 && indexPath.section < 5 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kTextFieldCellID];
        DATextFieldCell *textFieldCell = (DATextFieldCell *)cell;
        
        NSString *placeholder = self.titleData[@(indexPath.section)][indexPath.row];
        textFieldCell.textField.placeholder = placeholder;
        textFieldCell.delegate = self;
        
        if( indexPath.section == 1 || indexPath.section == 2 )
        {
            textFieldCell.textField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        
        if( indexPath.section == 3 )
        {
            textFieldCell.textField.keyboardType = UIKeyboardTypePhonePad;
        }
        
        if( indexPath.section == 4 )
        {
            textFieldCell.textField.secureTextEntry = YES;
        }
        
        if( indexPath.section == 4 && indexPath.row == 1 )
        {
            textFieldCell.textField.returnKeyType = UIReturnKeyDone;
        }
        else
        {
            textFieldCell.textField.returnKeyType = UIReturnKeyNext;
        }
    }
    else if( indexPath.section == 5 )
    {
        if( indexPath.row == 0 )
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kDateCellID];
            
            cell.textLabel.text = self.titleData[@(indexPath.section)][indexPath.row];
        }
        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kPickerCellID];
            DADatePickerCell *datePickerCell = (DADatePickerCell *)cell;
            
            [datePickerCell.datePicker addTarget:self action:@selector(dateChosen:) forControlEvents:UIControlEventValueChanged];
        }
    }
    else if( indexPath.section == 6 )
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kRegisterCellID];
        
        cell.textLabel.text = self.titleData[@(indexPath.section)][indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 6 )
    {
        return 54;
    }
    
    if( indexPath.section == 5 && indexPath.row == 1 )
    {
        return 172;
    }
    
    return self.tableView.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( section > 0 )
    {
        return tableView.sectionHeaderHeight - 10;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.section == 5 && indexPath.row == 0 )
    {
        [self toggleDatePicker];
    }
    
    if( indexPath.section == 6 )
    {
        [self checkInputsAndRegister];
        NSLog(@"%@", self.signUpData);
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSString *firstName = [self.signUpData objectForKey:self.titleData[@0][0]];
    if( [firstName length] == 0 )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        self.errorView.errorTextLabel.text = @"Invalid Input!";
        self.errorView.errorTipLabel.text  = @"Please enter your first name.";
        
        [self.errorData setObject:@"error" forKey:self.titleData[@0][0]];
        
        [self showErrorView];
        
        return;
    }
    
    NSString *lastName = [self.signUpData objectForKey:self.titleData[@0][1]];
    if( [lastName length] == 0 )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        self.errorView.errorTextLabel.text = @"Invalid Input!";
        self.errorView.errorTipLabel.text  = @"Please enter your last name.";
        
        [self.errorData setObject:@"error" forKey:self.titleData[@0][1]];
        
        [self showErrorView];
        
        return;
    }
    
    NSString *username = [self.signUpData objectForKey:self.titleData[@1][0]];
    if( [username length] <= 1 || !self.usernameIsValid )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        if( !self.usernameIsValid )
        {
            self.errorView.errorTextLabel.text = @"Username unavailable!";
            self.errorView.errorTipLabel.text  = @"Please choose a different username.";
        }
        else
        {
            self.errorView.errorTextLabel.text = @"Invalid Input!";
            self.errorView.errorTipLabel.text  = @"Please enter a username.";
        }
        
        [self.errorData setObject:@"error" forKey:self.titleData[@1][0]];
        
        [self showErrorView];
        
        return;
    }
    
    NSString *email = [self.signUpData objectForKey:self.titleData[@2][0]];
    if( ![self stringIsValidEmail:email] )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        self.errorView.errorTextLabel.text = @"Invalid Email Address!";
        self.errorView.errorTipLabel.text  = @"Please enter a valid email address.";
        
        [self.errorData setObject:@"error" forKey:self.titleData[@2][0]];
        
        [self showErrorView];
        
        return;
    }
    
    NSString *firstPassword = [self.signUpData objectForKey:self.titleData[@4][0]];
    if( [firstPassword length] < 6 )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        self.errorView.errorTextLabel.text = @"Invalid Password!";
        self.errorView.errorTipLabel.text  = @"Your password must be at least 6 characters.";
        
        [self.errorData setObject:@"error" forKey:self.titleData[@4][0]];
        
        [self showErrorView];
        
        return;
    }
    
    NSString *confirmPassword = [self.signUpData objectForKey:self.titleData[@4][1]];
    if( ![confirmPassword isEqualToString:firstPassword] )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:4];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        self.errorView.errorTextLabel.text = @"Invalid Password!";
        self.errorView.errorTipLabel.text  = @"Your passwords must match.";
        
        [self.errorData setObject:@"error" forKey:self.titleData[@4][1]];
        
        [self showErrorView];
        
        return;
    }
    
    NSDate *dateOfBirth = [self.signUpData objectForKey:self.titleData[@5][0]];
    if( [self ageWithDate:dateOfBirth] < 13 )
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:5];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        cell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
        
        self.errorView.errorTextLabel.text = @"You're too young!";
        self.errorView.errorTipLabel.text  = @"You must be 13 years or older to sign up for Dished.";
        
        [self.errorData setObject:@"error" forKey:self.titleData[@5][0]];
        
        [self showErrorView];
        
        return;
    }
    
    [[DAAPIManager sharedManager] checkAvailabilityOfEmail:email completion:^( BOOL available, NSError *error )
    {
        if( available )
        {
            [self registerUser];
        }
        else
        {
            [self.emailExistsAlert show];
        }
    }];
}

- (void)registerUser
{
    NSString *firstName = [self.signUpData objectForKey:self.titleData[@0][0]];
    NSString *lastName  = [self.signUpData objectForKey:self.titleData[@0][1]];
    NSString *username  = [[self.signUpData objectForKey:self.titleData[@1][0]] substringFromIndex:1];
    NSString *email     = [self.signUpData objectForKey:self.titleData[@2][0]];
    NSString *password  = [self.signUpData objectForKey:self.titleData[@4][1]];
    NSDate *dateOfBirth = [self.signUpData objectForKey:self.titleData[@5][0]];

    [[DAAPIManager sharedManager] registerUserWithUsername:username password:password firstName:firstName lastName:lastName email:email birthday:dateOfBirth completion:^( BOOL registered, BOOL loggedIn )
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
}

- (void)dateChosen:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSString *key = self.titleData[@(self.pickerIndexPath.section)][self.pickerIndexPath.row - 1];
    [self.signUpData setObject:datePicker.date forKey:key];
    
    NSIndexPath *datePath = [NSIndexPath indexPathForRow:self.pickerIndexPath.row - 1 inSection:self.pickerIndexPath.section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:datePath];
    cell.detailTextLabel.text = [self.birthDateFormatter stringFromDate:datePicker.date];

    if( [self.errorData objectForKey:self.titleData[@(datePath.section)][datePath.row]] )
    {
        if( [self.errorData objectForKey:key] )
        {
            [self dismissErrorView];
            
            [self.errorData removeObjectForKey:key];
            
            cell.accessoryView = nil;
        }
    }
}

- (int)ageWithDate:(NSDate *)date
{
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:date toDate:now options:0];
    NSInteger age = [ageComponents year];
    
    return (int)age;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( alertView == self.emailExistsAlert || alertView == self.loginFailAlert || alertView == self.registerSuccessAlert )
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)textField:(UITextField *)textField didBeginEditingInCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if( indexPath.section == 1 )
    {
        if( [textField.text length] == 0 )
        {
            textField.text = @"@";
        }
    }
}

- (void)textField:(UITextField *)textField didChangeInCell:(UITableViewCell *)cell toString:(NSString *)newString
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    DATextFieldCell *textCell = (DATextFieldCell *)cell;
    
    if( indexPath.section == 0 )
    {
        NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
        
        if( [self.errorData objectForKey:key] )
        {
            [self dismissErrorView];
            
            [self.errorData removeObjectForKey:key];
        }
        
        if( [newString length] > 0 )
        {
            textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
        }
        else
        {
            textCell.accessoryView = nil;
        }
    }
    
    if( indexPath.section == 1 )
    {
        NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
        
        if( [self.errorData objectForKey:key] )
        {
            [self dismissErrorView];
            
            [self.errorData removeObjectForKey:key];
        }
        
        if( [newString length] > 1 )
        {
            NSString *username = [newString substringFromIndex:1];
            
            [[DAAPIManager sharedManager] checkAvailabilityOfUsername:username completion:^( BOOL available, NSError *error )
            {
                if( self.shouldUpdateUsernameStatus )
                {
                    if( available )
                    {
                        textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
                        
                        self.usernameIsValid = YES;
                        
                        [self dismissErrorView];
                    }
                    else
                    {
                        self.errorView.errorTextLabel.text = @"Username unavailable!";
                        self.errorView.errorTipLabel.text  = @"Please choose a different username.";
                        
                        [self showErrorView];
                        
                        self.usernameIsValid = NO;
                        
                        textCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    }
                }
                else
                {
                    self.shouldUpdateUsernameStatus = YES;
                }
            }];
        }
        else
        {
            self.shouldUpdateUsernameStatus = NO;
            
            self.usernameIsValid = NO;
            
            [self dismissErrorView];
            
            textCell.accessoryView = nil;
        }
    }
    
    if( indexPath.section == 2 )
    {
        NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
        
        if( [self.errorData objectForKey:key] )
        {
            [self dismissErrorView];
            
            [self.errorData removeObjectForKey:key];
        }
        
        if( [newString length] == 0 )
        {
            textCell.accessoryView = nil;
        }
    }
    
    if( indexPath.section == 4 )
    {
        if( indexPath.row == 0 )
        {
            NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
            
            if( [self.errorData objectForKey:key] )
            {
                [self dismissErrorView];
                
                [self.errorData removeObjectForKey:key];
            }
            
            if( [newString length] >= 6 )
            {
                textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
            }
            else
            {
                textCell.accessoryView = nil;
            }
        }
        
        if( indexPath.row == 1 )
        {
            NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
            
            if( [self.errorData objectForKey:key] )
            {
                [self dismissErrorView];
                
                [self.errorData removeObjectForKey:key];
            }
            
            NSString *firstPasswordKey = self.titleData[@(indexPath.section)][indexPath.row - 1];
            NSString *firstPassword = [self.signUpData objectForKey:firstPasswordKey];
            
            if( [newString isEqualToString:firstPassword] )
            {
                textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
            }
            else
            {
                textCell.accessoryView = nil;
            }
        }
    }
}

- (void)textField:(UITextField *)textField didEndEditingInCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    DATextFieldCell *textCell = (DATextFieldCell *)cell;
    
    if( indexPath.section == 2 )
    {
        if( ![self stringIsValidEmail:textCell.textField.text] )
        {
            if( !self.errorVisible && [textCell.textField.text length] > 0 )
            {
                self.errorView.errorTextLabel.text = @"Invalid Email Address!";
                self.errorView.errorTipLabel.text  = @"Please enter a valid email address.";
                
                [self showErrorView];
            }
            
            if( [textCell.textField.text length] > 0 )
            {
                textCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
            }
        }
        else
        {
            textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
            
            [self dismissErrorView];
        }
    }
    
    if( indexPath.section == 4 )
    {
        if( indexPath.row == 0 )
        {
            if( [textCell.textField.text length] < 6 )
            {
                if( !self.errorVisible && [textCell.textField.text length] > 0 )
                {
                    self.errorView.errorTextLabel.text = @"Invalid Password!";
                    self.errorView.errorTipLabel.text  = @"Your password must be at least 6 characters.";
                    
                    textCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    
                    [self showErrorView];
                }
            }
            else
            {
                textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
                
                [self dismissErrorView];
            }
        }
        
        if( indexPath.row == 1 )
        {
            NSString *firstPasswordKey = self.titleData[@(indexPath.section)][indexPath.row - 1];
            NSString *firstPassword = [self.signUpData objectForKey:firstPasswordKey];
            
            if( ![textCell.textField.text isEqualToString:firstPassword] )
            {
                if( !self.errorVisible && [textCell.textField.text length] > 0 )
                {
                    self.errorView.errorTextLabel.text = @"Invalid Password!";
                    self.errorView.errorTipLabel.text  = @"Your passwords must match.";
                    
                    textCell.accessoryView = [[UIImageView alloc] initWithImage:self.errorIconImage];
                    
                    [self showErrorView];
                }
            }
            else
            {
                if( [firstPassword length] > 0 && [textCell.textField.text length] > 0 )
                {
                    textCell.accessoryView = [[UIImageView alloc] initWithImage:self.validIconImage];
                    
                    [self dismissErrorView];
                }
            }
        }
    }
    
    NSString *key = self.titleData[@(indexPath.section)][indexPath.row];
    [self.signUpData setObject:textField.text forKey:key];
}

- (BOOL)stringIsValidEmail:(NSString *)checkString
{
    NSString *emailRegex = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string inCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if( indexPath.section == 1 )
    {
        if( [newString length] == 0 )
        {
            return NO;
        }
    }
    
    [self textField:textField didChangeInCell:cell toString:newString];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldReturnInCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if( indexPath.section == 0 )
    {
        if( indexPath.row == 0 )
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
        else
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section + 1];
            DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
    }
    else if( indexPath.section == 1 )
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
        [cell.textField becomeFirstResponder];
    }
    else if( indexPath.section == 2 )
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
        [cell.textField becomeFirstResponder];
    }
    else if( indexPath.section == 3 )
    {
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
        DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
        [cell.textField becomeFirstResponder];
    }
    else if( indexPath.section == 4 )
    {
        if( indexPath.row == 0 )
        {
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            DATextFieldCell *cell = (DATextFieldCell *)[self.tableView cellForRowAtIndexPath:nextIndexPath];
            [cell.textField becomeFirstResponder];
        }
        else
        {
            [self.view endEditing:YES];
            return YES;
        }
    }
    
    return NO;
}

- (IBAction)goToLogin
{
    [self performSegueWithIdentifier:@"goToLogin" sender:nil];
}

- (CGRect)visibleErrorFrame
{
    CGRect statusBarRect = [[UIApplication sharedApplication] statusBarFrame];
    CGRect navBarRect    = self.navigationController.navigationBar.bounds;
    
    CGPoint location = statusBarRect.origin;
    
    CGFloat width = navBarRect.size.width;
    CGFloat height = navBarRect.size.height + statusBarRect.size.height;
    CGSize  size = CGSizeMake( width, height );
    
    return CGRectMake( location.x, location.y, size.width, size.height );
}

- (CGRect)invisibleErrorFrame
{
    CGRect visibleFrame = [self visibleErrorFrame];
    visibleFrame.origin.y -= 100;
    return visibleFrame;
}

- (NSDictionary *)titleData
{
    if( !_titleData )
    {
        _titleData = @{ @0 : @[ @"First Name", @"Last Name" ], @1 : @[ @"Username" ], @2 : @[ @"Email" ], @3 : @[ @"Phone Number" ], @4 : @[ @"Password", @"Confirm Password" ], @5 : @[ @"Date of Birth" ], @6 : @[ @"Register" ] };
    }
    
    return _titleData;
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

- (UIImage *)errorIconImage
{
    if( !_errorIconImage )
    {
        _errorIconImage = [UIImage imageNamed:@"error_icon"];
    }
    
    return _errorIconImage;
}

- (UIImage *)validIconImage
{
    if( !_validIconImage )
    {
        _validIconImage = [UIImage imageNamed:@"valid_icon"];
    }
    
    return _validIconImage;
}

- (UIAlertView *)emailExistsAlert
{
    if( !_emailExistsAlert )
    {
        _emailExistsAlert = [[UIAlertView alloc] initWithTitle:@"Account Exists" message:@"An account with the given email address already exists. Please sign in or submit a forgotten password request." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    
    return _emailExistsAlert;
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