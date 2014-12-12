//
//  DASplashViewController.m
//  Dished
//
//  Created by Ryan Khalili on 6/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASplashViewController.h"
#import "DAPhoneNumberViewController.h"


@interface DASplashViewController() <UIScrollViewDelegate>

@property (strong, nonatomic) UIImageView  *welcomeDotsImageView;
@property (strong, nonatomic) UIScrollView *welcomeScrollView;

@property (nonatomic) BOOL welcomeScreenVisible;

@end


@implementation DASplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.welcomeScreenVisible = NO;
    
    if( IS_IPHONE4 )
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"launch_image_4"];
    }
    else if( IS_IPHONE5 )
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"launch_image_5"];
    }
    else if( IS_IPHONE6 )
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"launch_image_6"];
    }
    else if( IS_IPHONE6_PLUS )
    {
        self.backgroundImageView.image = [UIImage imageNamed:@"launch_image_6_plus"];
    }
    
    [self setupWelcomeScreens];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)setupWelcomeScreens
{
    if( ![[NSUserDefaults standardUserDefaults] objectForKey:kFirstLaunchKey] )
    {
        self.welcomeScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
        self.welcomeScrollView.pagingEnabled = YES;
        self.welcomeScrollView.delegate = self;
        self.welcomeScrollView.bounces = NO;
        self.welcomeScrollView.showsHorizontalScrollIndicator = NO;
        self.welcomeScrollView.delaysContentTouches = NO;
        
        for( int i = 0; i < 3; i++ )
        {
            CGRect frame = CGRectZero;
            frame.origin.x = self.view.frame.size.width * i;
            frame.origin.y = 0;
            frame.size.height = self.welcomeScrollView.frame.size.height;
            frame.size.width = self.welcomeScrollView.frame.size.width;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.masksToBounds = YES;
            
            NSString *imageName = [NSString stringWithFormat:kWelcomeScreenImageNameFormat, i + 1, (int)SCREEN_HEIGHT];
            imageView.image = [UIImage imageNamed:imageName];
            [self.welcomeScrollView addSubview:imageView];
            
            if( i == 2 )
            {
                UIButton *startButton = [UIButton buttonWithType:UIButtonTypeSystem];
                [startButton addTarget:self action:@selector(hideWelcomeScreens) forControlEvents:UIControlEventTouchUpInside];
                startButton.titleLabel.font = [UIFont fontWithName:kHelveticaNeueLightFont size:22.0];
                [startButton setTitleColor:[UIColor dishedColor] forState:UIControlStateNormal];
                [startButton setTitle:@"Start Using Dished" forState:UIControlStateNormal];
                [startButton sizeToFit];
                
                CGRect startFrame = startButton.frame;
                startFrame.origin.x = ( frame.origin.x + frame.size.width - ( self.welcomeScrollView.frame.size.width / 2 ) ) - ( startFrame.size.width / 2 );
                startFrame.origin.y = self.welcomeScrollView.frame.size.height - 75;
                
                if( IS_IPHONE4 )
                {
                    startFrame.origin.y -= 100;
                }
                
                startButton.frame = startFrame;
                
                [self.welcomeScrollView addSubview:startButton];
            }
        }
        
        [self.view addSubview:self.welcomeScrollView];
        
        self.welcomeScrollView.contentSize = CGSizeMake( self.view.frame.size.width * 3, self.view.frame.size.height );
        
        UIImage *firstPageDotsImage = [UIImage imageNamed:[NSString stringWithFormat:kWelcomeScreenDotsImageNameFormat, 1]];
        
        CGRect dotsFrame = CGRectZero;
        dotsFrame.size = firstPageDotsImage.size;
        dotsFrame.origin.x = ( self.view.frame.size.width / 2 ) - ( dotsFrame.size.width / 2 );
        dotsFrame.origin.y = self.view.frame.size.height - 25;
        
        self.welcomeDotsImageView = [[UIImageView alloc] initWithImage:firstPageDotsImage];
        self.welcomeDotsImageView.frame = dotsFrame;
        [self.view addSubview:self.welcomeDotsImageView];
        
        self.welcomeScreenVisible = YES;
        
        [self setNeedsStatusBarAppearanceUpdate];
        
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kFirstLaunchKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    NSString *dotsImageName = [NSString stringWithFormat:kWelcomeScreenDotsImageNameFormat, (int)page + 1];
    UIImage *pageDotsImage = [UIImage imageNamed:dotsImageName];
    self.welcomeDotsImageView.image = pageDotsImage;
}

- (void)hideWelcomeScreens
{
    [UIView transitionWithView:self.welcomeScrollView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:^( BOOL finished )
                    {
                        [self.welcomeScrollView removeFromSuperview];
                        self.welcomeScrollView = nil;
                    }];
    
    self.welcomeScrollView.hidden = YES;
    
    [UIView transitionWithView:self.welcomeDotsImageView
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:nil
                    completion:^( BOOL finished )
                    {
                        [self.welcomeDotsImageView removeFromSuperview];
                        self.welcomeDotsImageView = nil;
                    }];
    
    self.welcomeDotsImageView.hidden = YES;
    
    self.welcomeScreenVisible = NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if( self.welcomeScreenVisible )
    {
        return UIStatusBarStyleDefault;
    }
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)goToFacebookLogin
{
    [self performSegueWithIdentifier:@"facebookLogin" sender:nil];
}

- (IBAction)goToLogin
{
    [self performSegueWithIdentifier:@"loginSegue" sender:nil];
}

- (IBAction)goToRegister
{
    [self performSegueWithIdentifier:@"registerSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"registerSegue"] )
    {
        DAPhoneNumberViewController *dest = segue.destinationViewController;
        dest.registrationMode = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end