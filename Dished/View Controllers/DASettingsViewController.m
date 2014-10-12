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
    self.privacySwitch.on    = [DAUserManager sharedManager].publicProfile;
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

- (void)showLogoutVerification
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to Log Out?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Log Out" otherButtonTitles:nil, nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == actionSheet.destructiveButtonIndex )
    {
        
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
    [self.profilePrivacyURLTask cancel];
    
    [[DAAPIManager sharedManager] authenticateWithCompletion:^( BOOL success )
    {
        NSDictionary *parameters = @{ kPublicKey : @(self.privacySwitch.on) };
        parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
        
        self.profilePrivacyURLTask = [[DAAPIManager sharedManager] POST:kUserSettingsURL parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType != eErrorTypeRequestCancelled )
            {
                [self populateSettings];
            }
        }];
    }];
}

- (IBAction)changedDishPhotosSetting
{
    
}

@end