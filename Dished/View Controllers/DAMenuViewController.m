//
//  DAMenuViewController.m
//  Dished
//
//  Created by Ryan Khalili on 10/18/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "DAUserManager.h"


@interface DAMenuViewController()

@end


@implementation DAMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.tableView.frame];
    backgroundImage.image = [UIImage imageNamed:@"menu_background"];
    self.tableView.backgroundView = backgroundImage;
    
    self.userImageView.layer.borderColor   = [UIColor whiteColor].CGColor;
    self.userImageView.layer.borderWidth   = 2;
    self.userImageView.layer.cornerRadius  = self.userImageView.frame.size.width / 2;
    self.userImageView.layer.masksToBounds = YES;
    
    NSURL *userImageURL = [NSURL URLWithString:[DAUserManager sharedManager].img_thumb];
    [self.userImageView sd_setImageWithURL:userImageURL placeholderImage:[UIImage imageNamed:@"profile_image"]];
    
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", [DAUserManager sharedManager].username];
}

@end