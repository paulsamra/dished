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
#import "UserVoice.h"


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
    
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:selectedRowIndexPath animated:YES];
    
    [[self transitionCoordinator] notifyWhenInteractionEndsUsingBlock:^( id<UIViewControllerTransitionCoordinatorContext> context )
    {
        if( [context isCancelled] )
        {
            [self.tableView selectRowAtIndexPath:selectedRowIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.containerViewController moveToMenu];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.containerViewController moveToMenu];
    
    switch( indexPath.row )
    {
        case 0: [self goToInviteFriends]; break;
        case 1: [self goToSettings]; break;
        case 2: [self goToFAQ]; break;
        case 3: [self showTermsOfUse]; break;
        case 4: [self showPrivacyPolicy]; break;
        case 5: [UserVoice presentUserVoiceContactUsFormForParentViewController:self]; break;
    }
}
             
- (void)goToFAQ
{
    [self goToDocumentViewWithName:@"FAQ"];
}

- (void)showTermsOfUse
{
    [self goToDocumentViewWithName:kTermsAndConditions];
}

- (void)showPrivacyPolicy
{
    [self goToDocumentViewWithName:kPrivacyPolicy];
}

- (void)goToDocumentViewWithName:(NSString *)documentName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:documentName ofType:@"html"];
    DADocViewController *docVC = [[DADocViewController alloc] initWithFilePath:filePath title:documentName];
    [self.navigationController pushViewController:docVC animated:YES];
}

- (void)goToInviteFriends
{
    DAGetSocialViewController *getSocialVC = [[DAGetSocialViewController alloc] init];
    [self.navigationController pushViewController:getSocialVC animated:YES];
}

- (void)goToSettings
{
    [self pushSettingsView];
}

- (IBAction)editProfile
{
    [self.containerViewController moveToMenu];
    
    [self pushUserProfileWithUsername:[DAUserManager sharedManager].username];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end