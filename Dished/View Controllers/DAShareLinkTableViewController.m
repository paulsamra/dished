//
//  DAShareLinkTableViewController.m
//  Dished
//
//  Created by Ryan Khalili on 12/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAShareLinkTableViewController.h"
#import "DATwitterManager.h"


@interface DAShareLinkTableViewController() <UIAlertViewDelegate>

@property (strong, nonatomic) UIAlertView *verifyUnlinkAlert;

@end


@implementation DAShareLinkTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    switch( self.socialMediaType )
    {
        case eSocialMediaTypeFacebook:
            self.navigationItem.title = @"Facebook";
            [self setupForFacebook];
            break;
            
        case eSocialMediaTypeTwitter:
            self.navigationItem.title = @"Twitter";
            [self setupForTwitter];
            break;
            
        default:
            break;
    }
}

- (void)setupForTwitter
{
    if( [[DATwitterManager sharedManager] isLoggedIn] )
    {
        self.linkCell.textLabel.text = @"Unlink";
        self.linkCell.textLabel.textColor = [UIColor redGradeColor];
    }
    else
    {
        self.linkCell.textLabel.text = @"Link";
        self.linkCell.textLabel.textColor = [UIColor dishedColor];
    }
}

- (void)setupForFacebook
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( self.socialMediaType )
    {
        case eSocialMediaTypeFacebook: break;
        case eSocialMediaTypeTwitter:  [self handleTwitterAction]; break;
        default: break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)handleTwitterAction
{
    if( [[DATwitterManager sharedManager] isLoggedIn] )
    {
        self.verifyUnlinkAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to unlink your Twitter account?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [self.verifyUnlinkAlert show];
    }
    else
    {
        [self loginToTwitter];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch( self.socialMediaType )
    {
        case eSocialMediaTypeFacebook: break;
        case eSocialMediaTypeTwitter: [self logoutOfTwitter]; break;
        default: break;
    }
}

- (void)loginToTwitter
{
    [[DATwitterManager sharedManager] loginWithCompletion:^( BOOL success )
    {
        if( success )
        {
            [self setupForTwitter];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"There was a problem logging in to Twitter. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }];
}

- (void)logoutOfTwitter
{
    [[DATwitterManager sharedManager] logout];
    [self setupForTwitter];
}

@end