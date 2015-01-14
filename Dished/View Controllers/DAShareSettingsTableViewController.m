//
//  DAShareSettingsTableViewController.m
//  Dished
//
//  Created by Ryan Khalili on 12/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAShareSettingsTableViewController.h"
#import "DAShareLinkTableViewController.h"
#import "DATwitterManager.h"
#import "DAUserManager.h"


@interface DAShareSettingsTableViewController()

@end


@implementation DAShareSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupCells];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)setupCells
{
    if( [[DATwitterManager sharedManager] isLoggedIn] )
    {
        self.twitterCell.detailTextLabel.text = [NSString stringWithFormat:@"@%@", [[DATwitterManager sharedManager] currentUser]];
        self.twitterCell.detailTextLabel.textColor = [UIColor dishedColor];
    }
    else
    {
        self.twitterCell.detailTextLabel.text = @"Not Connected";
        self.twitterCell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    
    if( [DAUserManager sharedManager].isFacebookUser )
    {
        self.facebookCell.detailTextLabel.text = @"Connected";
        self.facebookCell.detailTextLabel.textColor = [UIColor dishedColor];
        self.facebookCell.userInteractionEnabled = NO;
    }
    if( FBSession.activeSession.state != FBSessionStateOpenTokenExtended && FBSession.activeSession.state != FBSessionStateOpen )
    {
        self.facebookCell.detailTextLabel.text = @"Not Connected";
        self.facebookCell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }
    else
    {
        self.facebookCell.detailTextLabel.text = @"Connected";
        self.facebookCell.detailTextLabel.textColor = [UIColor dishedColor];
        self.facebookCell.userInteractionEnabled = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row )
    {
        case 1: [self performSegueWithIdentifier:@"shareLink" sender:@(eSocialMediaTypeTwitter)]; break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    eSocialMediaType socialMediaType = [sender intValue];
    
    DAShareLinkTableViewController *dest = segue.destinationViewController;
    dest.socialMediaType = socialMediaType;
}

@end