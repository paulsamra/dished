//
//  DASettingsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASettingsViewController.h"
#import "DAAPIManager.h"
#import "DAUserManager.h"
#import "DANotificationSettingsViewController.h"
#import "DAEditProfileViewController.h"
#import "DAAppDelegate.h"
#import "MRProgress.h"
#import "DADocumentViewController.h"


@interface DASettingsViewController() <UIActionSheetDelegate>

@property (strong, nonatomic) NSURLSessionTask *profilePrivacyURLTask;

@end


@implementation DASettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44.0;
    self.tableView.estimatedRowHeight = 44.0;
    
    [self populateSettings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)populateSettings
{
    self.privacySwitch.on    = ![DAUserManager sharedManager].publicProfile;
    self.dishPhotosSwitch.on = [DAUserManager sharedManager].savesDishPhoto;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.section )
    {
        case 0:
            [self handleAccountSectionSelectionForRow:indexPath.row];
            break;
            
        case 1:
            [self handleNotificationSectionSelectionForRow:indexPath.row];
            break;
            
        case 4:
            [self handleTermsSectionSelectionForRow:indexPath.row];
            break;
    }
}

- (void)handleAccountSectionSelectionForRow:(NSInteger)row
{
    switch( row )
    {
        case 0:
            [self goToEditProfile];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"shareSettings" sender:nil];
            break;
            
        case 2: 
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [self showLogoutVerification];
            break;
    }
}

- (void)goToEditProfile
{
    DAEditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfile"];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (void)showLogoutVerification
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to Log Out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:nil, nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.destructiveButtonIndex )
    {
        [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:@"Logging Out..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        
        [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
        {
            NSDictionary *parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:nil];
            
            [[DAAPIManager sharedManager] POST:kLogoutURL parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
                {
                    DAAppDelegate *appDelegate = (DAAppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate logout];
                }];
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES completion:^
                {
                    [[[UIAlertView alloc] initWithTitle:@"Failed to Log Out" message:@"There was a problem logging you out. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }];
            }];
        }];
    }
}

- (void)handleNotificationSectionSelectionForRow:(NSInteger)row
{
    NSString *notificationType = nil;
    
    switch( row )
    {
        case 0: notificationType = @"yum";     break;
        case 1: notificationType = @"comment"; break;
        case 2: notificationType = @"review";  break;
    }
    
    [self performSegueWithIdentifier:@"notifications" sender:notificationType];
}

- (void)handleTermsSectionSelectionForRow:(NSInteger)row
{
    switch( row )
    {
        case 0: [self goToDocumentViewWithName:@"Privacy Policy"]; break;
        case 1: [self goToDocumentViewWithName:@"Terms & Conditions"]; break;
    }
}

- (void)goToDocumentViewWithName:(NSString *)documentName
{
    DADocumentViewController *documentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"document"];
    documentViewController.documentName = documentName;
    [self.navigationController pushViewController:documentViewController animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"notifications"] )
    {
        DANotificationSettingsViewController *dest = segue.destinationViewController;
        dest.notificationType = sender;
    }
}

- (IBAction)changedProfilePrivacySetting
{
    [[DAUserManager sharedManager] savePrivacySetting:!self.privacySwitch.on completion:^( BOOL success )
    {
        [self populateSettings];
    }];
}

- (IBAction)changedDishPhotosSetting
{
    [[DAUserManager sharedManager] saveDishPhotoSetting:self.dishPhotosSwitch.on completion:^( BOOL success )
    {
        [self populateSettings];
    }];
}

@end