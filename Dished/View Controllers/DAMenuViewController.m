//
//  DAMenuViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "DASettingsViewController.h"
#import "DAContainerViewController.h"
#import "DAUserProfileViewController.h"
#import "DAUserManager.h"
#import "DADocumentViewController.h"


@interface DAMenuViewController()

@property (nonatomic) BOOL initialViewAppear;

@end


@implementation DAMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.initialViewAppear = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUserInfo) name:kUserProfileUpdatedNotification object:nil];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    backgroundImage.image = [UIImage imageNamed:@"menu_background"];
    self.tableView.backgroundView = backgroundImage;
    
    self.userImageView.layer.borderColor   = [UIColor whiteColor].CGColor;
    self.userImageView.layer.borderWidth   = 2;
    self.userImageView.layer.cornerRadius  = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editProfile)];
    self.userImageView.userInteractionEnabled = YES;
    [self.userImageView addGestureRecognizer:tapGesture1];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editProfile)];
    self.usernameLabel.userInteractionEnabled = YES;
    [self.usernameLabel addGestureRecognizer:tapGesture2];
    
    [self setupUserInfo];
}

- (void)setupUserInfo
{
    NSURL *userImageURL = [NSURL URLWithString:[DAUserManager sharedManager].img_thumb];
    [self.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", [DAUserManager sharedManager].username];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if( !self.initialViewAppear && [self.containerViewController menuShowing] )
    {
        [self.containerViewController slideOutMenu];
    }
    
    self.initialViewAppear = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.containerViewController moveToMenu];
    
    switch( indexPath.row )
    {
        case 0:
            [self goToInviteFriends];
            break;
            
        case 1:
            [self goToSettings];
            break;
            
        case 2:
            break;
            
        case 3:
            [self showTermsOfUse];
            break;
        
        case 4:
            [self showPrivacyPolicy];
            break;
    }
}

- (void)showTermsOfUse
{
    [self goToDocumentViewWithName:@"Terms & Conditions"];
}

- (void)showPrivacyPolicy
{
    [self goToDocumentViewWithName:@"Privacy Policy"];
}

- (void)goToDocumentViewWithName:(NSString *)documentName
{
    DADocumentViewController *documentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"document"];
    documentViewController.documentName = documentName;
    [self.navigationController pushViewController:documentViewController animated:YES];
}

- (void)goToInviteFriends
{
    [self performSegueWithIdentifier:@"inviteFriends" sender:nil];
}

- (void)goToSettings
{
    DASettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)editProfile
{
    [self.containerViewController moveToMenu];
    
    DAUserProfileViewController *userProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfile"];
    userProfileViewController.user_id = [DAUserManager sharedManager].user_id;
    userProfileViewController.username = [DAUserManager sharedManager].username;
    [self.navigationController pushViewController:userProfileViewController animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end