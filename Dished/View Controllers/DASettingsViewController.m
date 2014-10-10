//
//  DASettingsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASettingsViewController.h"


@interface DASettingsViewController() <UIActionSheetDelegate>

@end


@implementation DASettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 44.0;
    self.tableView.estimatedRowHeight = 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.section )
    {
        case 0:
            [self handleAccountSectionSelectionForRow:indexPath.row];
            break;
            
        case 1:
            [self performSegueWithIdentifier:@"notifications" sender:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            //[self handleNotificationSectionSelectionForRow:indexPath.row];
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
    
}

- (void)handleTermsSectionSelectionForRow:(NSInteger)row
{
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"notifications"] )
    {
        UIViewController *dest = segue.destinationViewController;
        dest.title = sender;
    }
}

- (IBAction)changedProfilePrivacySetting
{
    
}

- (IBAction)changedDishPhotosSetting
{
    
}

@end