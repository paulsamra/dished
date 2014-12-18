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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row )
    {
        case 0: [self performSegueWithIdentifier:@"shareLink" sender:@(eSocialMediaTypeFacebook)]; break;
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