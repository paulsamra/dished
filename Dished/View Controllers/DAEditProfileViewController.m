//
//  DAEditProfileViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/12/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAEditProfileViewController.h"
#import "DAUserManager.h"
#import "UIImageView+WebCache.h"


@interface DAEditProfileViewController() <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (copy,   nonatomic) NSDate          *dateOfBirth;
@property (strong, nonatomic) NSIndexPath     *pickerIndexPath;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

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
    
    self.descriptionTextView.placeholder = @"Description";
    
    self.imageSeperatorWidthConstraint.constant = 0.5;
    self.nameSeperatorHeightConstraint.constant = 0.5;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    self.userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUserImage)];
    tapGesture.numberOfTapsRequired = 1;
    [self.userImageView addGestureRecognizer:tapGesture];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfile)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self populateProfile];
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
    self.phoneNumberField.text    = userManager.phoneNumber;
    self.descriptionTextView.text = userManager.desc;
    
    if( userManager.dateOfBirth )
    {
        self.dateOfBirth = userManager.dateOfBirth;
        self.dateOfBirthCell.detailTextLabel.text = [self.dateFormatter stringFromDate:userManager.dateOfBirth];
    }
    
    if( userManager.img_thumb )
    {
        self.addPhotoLabel.hidden = YES;
        self.placeholderUserImageView.hidden = YES;
        
        NSURL *userImageURL = [NSURL URLWithString:userManager.img_thumb];
        [self.userImageView sd_setImageWithURL:userImageURL];
    }
    else
    {
        self.userImageView.hidden = YES;
    }
}

- (void)tappedUserImage
{
    UIActionSheet *photoActionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Profile Picture" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Take Photo or Video", @"Remove Profile Picture", nil];
    photoActionSheet.destructiveButtonIndex = 2;
    
    [photoActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if( buttonIndex == actionSheet.cancelButtonIndex )
//    {
//        return;
//    }
//    
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    imagePickerController.delegate = self;
//    imagePickerController.allowsEditing = YES;
//    
//    if( buttonIndex == 0 )
//    {
//        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    else if( buttonIndex == 1 )
//    {
//        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    }
//    else if( buttonIndex == actionSheet.destructiveButtonIndex )
//    {
//        return;
//    }
//    
//    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    
//    [[DAUserManager sharedManager] setUserProfileImage:chosenImage completion:^( BOOL success )
//    {
//        if( success )
//        {
//            
//        }
//        else
//        {
//            
//        }
//    }];
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
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
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

- (void)saveProfile
{
    
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