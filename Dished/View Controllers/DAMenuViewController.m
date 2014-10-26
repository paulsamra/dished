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
#import "DAEditProfileViewController.h"
#import "DAUserManager.h"


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
    
    if( !self.initialViewAppear )
    {
        [self.containerViewController slideOutMenu];
    }
    
    self.initialViewAppear = NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row )
    {
        case 1:
            [self.containerViewController moveToMenu];
            [self goToSettings];
            break;
    }
}

- (void)goToSettings
{
    DASettingsViewController *settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings"];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (IBAction)editProfile
{
    [self.containerViewController moveToMenu];
    
    DAEditProfileViewController *editProfileViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfile"];
    [self.navigationController pushViewController:editProfileViewController animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end