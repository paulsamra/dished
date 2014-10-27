//
//  DATabBarController.m
//  Dished
//
//  Created by Ryan Khalili on 6/29/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DATabBarController.h"
#import "DAImagePickerController.h"
#import <MessageUI/MessageUI.h>
#import "DANewReview.h"
#import "MRProgressOverlayView.h"
#import "DAFeedViewController.h"
#import "DANewsManager.h"
#import "DANewsViewController.h"
#import "DAMenuViewController.h"
#import "DAContainerViewController.h"
#import "DASocialCollectionViewController.h"


@interface DATabBarController() <UITabBarControllerDelegate, MFMailComposeViewControllerDelegate, DASocialCollectionViewControllerDelegate>

@property (strong, nonatomic) UIButton *newsBadgeButton;
@property (strong, nonatomic) DAMenuViewController *menuViewController;
@property (strong, nonatomic) DASocialCollectionViewController *socialViewController;

@end


@implementation DATabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITabBarItem *addReviewTabItem = [self.tabBar.items objectAtIndex:2];
    
    UIImage *image = [UIImage imageNamed:@"add_review_tab"];
    addReviewTabItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [addReviewTabItem setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] } forState:UIControlStateNormal];
    
    self.delegate = self;
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.11 green:0.64 blue:0.99 alpha:1]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailView:) name:@"presentEmail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewsBadge) name:kNewsUpdatedNotificationKey object:nil];
    
    [self updateNewsBadge];
}

- (void)updateNewsBadge
{
    if( [self.selectedViewController isKindOfClass:[UINavigationController class]] )
    {
        UINavigationController *navigationController = (UINavigationController *)self.selectedViewController;
        UIViewController *rootViewController = navigationController.viewControllers[0];
        
        if( [rootViewController isMemberOfClass:[DANewsViewController class]] )
        {
            return;
        }
    }
    
    NSInteger yums    = [DANewsManager sharedManager].num_yums;
    NSInteger reviews = [DANewsManager sharedManager].num_reviews;
    
    if( yums == 0 && reviews == 0 )
    {
        return;
    }
    
    NSTextAttachment *yumAttachment = [[NSTextAttachment alloc] init];
    yumAttachment.image = [UIImage imageNamed:@"badge_yum"];
    NSAttributedString *yumAttachmentString = [NSAttributedString attributedStringWithAttachment:yumAttachment];
    
    NSTextAttachment *reviewAttachment = [[NSTextAttachment alloc] init];
    reviewAttachment.image = [UIImage imageNamed:@"badge_review"];
    NSAttributedString *reviewAttachmentString = [NSAttributedString attributedStringWithAttachment:reviewAttachment];
    
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:16],
                                  NSForegroundColorAttributeName : [UIColor whiteColor] };
    
    NSAttributedString *yumString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d  ", (int)yums] attributes:attributes];
    NSAttributedString *reviewString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %d", (int)reviews] attributes:attributes];
    
    NSMutableAttributedString *badgeString = [[NSMutableAttributedString alloc] init];
    [badgeString insertAttributedString:reviewString atIndex:0];
    [badgeString insertAttributedString:reviewAttachmentString atIndex:0];
    [badgeString insertAttributedString:yumString atIndex:0];
    [badgeString insertAttributedString:yumAttachmentString atIndex:0];

    UIImage *badgeImage = [UIImage imageNamed:@"badge_bubble"];
    UIButton *badgeButton = [[UIButton alloc] init];
    badgeButton.userInteractionEnabled = NO;
    badgeButton.contentEdgeInsets = UIEdgeInsetsMake( 0, 7, 4, 5 );
    [badgeButton setBackgroundImage:badgeImage forState:UIControlStateNormal];
    [badgeButton setAttributedTitle:badgeString forState:UIControlStateNormal];
    
    CGSize boundingSize = CGSizeMake( CGFLOAT_MAX, badgeImage.size.height );
    CGRect stringRect   = [badgeString boundingRectWithSize:boundingSize
                                                    options:0
                                                    context:nil];
    
    CGRect frame = CGRectZero;
    frame.size.height = badgeImage.size.height;
    frame.size.width = stringRect.size.width + 14;
    
    CGFloat itemWidth = self.tabBar.frame.size.width / 5;
    CGFloat newsTabCenterX = ( itemWidth * 3 ) + ( itemWidth / 2 );
    CGFloat newsTabY = self.tabBar.frame.origin.y;
    frame.origin.x = newsTabCenterX - frame.size.width / 2;
    frame.origin.y = newsTabY - frame.size.height;
    
    badgeButton.frame = frame;
    
    self.newsBadgeButton = badgeButton;
    [self.view addSubview:badgeButton];
}

- (UIImage *)resizeImage:(UIImage*)image toSize:(CGSize)size
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    
    UIGraphicsBeginImageContextWithOptions( size, NO, scale );
    [image drawInRect:CGRectMake( 0, 0, size.width, size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if( [viewController.title isEqualToString:@"dummy"] )
    {
        DAImagePickerController *reviewImagePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"addReview"];
        [self presentViewController:reviewImagePicker animated:YES completion:nil];
        
        return NO;
    }
    
    if( [viewController.title isEqualToString:@"menuDummy"] )
    {
        [self.containerViewController slideOutMenu];
        
        return NO;
    }
    
    if( viewController == self.selectedViewController )
    {
        if( [viewController isKindOfClass:[UINavigationController class]] )
        {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            UIViewController *rootViewController = navigationController.viewControllers[0];
            
            if( [rootViewController isMemberOfClass:[DAFeedViewController class]] )
            {
                DAFeedViewController *feedViewController = (DAFeedViewController *)rootViewController;
                [feedViewController scrollFeedToTop];
            }
        }
    }
    
    if( [viewController isKindOfClass:[UINavigationController class]] )
    {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        UIViewController *rootViewController = navigationController.viewControllers[0];
        
        if( [rootViewController isMemberOfClass:[DANewsViewController class]] )
        {
            [self.newsBadgeButton removeFromSuperview];
            self.newsBadgeButton = nil;
        }
    }
    
    return YES;
}

- (void) startAddReviewProcessWithDishProfile:(DADishProfile *)dishProfile
{
    UINavigationController *addReviewNavigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"addReview"];
    DAImagePickerController *imagePickerController = [addReviewNavigationController.viewControllers objectAtIndex:0];
    imagePickerController.selectedDish = dishProfile;
    [self presentViewController:addReviewNavigationController animated:YES completion:nil];
}

- (void)presentEmailView:(NSNotification *)notification
{
    [MRProgressOverlayView showOverlayAddedTo:self.view title:@"Loading Email..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    DANewReview *review = [(NSDictionary *)notification.object objectForKey:@"review"];
    NSData *imageData = [(NSDictionary *)notification.object objectForKey:@"imageData"];
    
    MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
    [composeViewController setMailComposeDelegate:self];
    [composeViewController setSubject:@"Check out my Dished Review"];
    
    BOOL an = [review.rating characterAtIndex:0] == 'A' || [review.rating characterAtIndex:0] == 'F';
    NSString *descriptor = an ? @"an" : @"a";
    
    NSString *emailBody = [NSString stringWithFormat:@"I just left %@ %@ at %@ for their %@ ", descriptor, review.rating, review.locationName, review.title];
    emailBody = [emailBody stringByAppendingString:@"and I thought you would love to see my review of this dish. Attached is a photo of the dish for you.<br><br>"];
    emailBody = [emailBody stringByAppendingString:@"Join me on <a href=""http://www.dishedapp.com"">Dished</a> and we can share more great dishes with each other.<br><br>Dished is now available on iPhone and coming soon to Android."];
    
    [composeViewController setMessageBody:emailBody isHTML:YES];
    [composeViewController addAttachmentData:imageData mimeType:@"image/jpeg" fileName:@"image.jpeg"];
    [self presentViewController:composeViewController animated:YES completion:^{
        [MRProgressOverlayView dismissOverlayForView:self.view animated:YES completion:nil];
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showShareView
{
    if( !self.socialViewController )
    {
        [self setupShareView];
    }
    
    [self.view insertSubview:self.socialViewController.view belowSubview:self.tabBar];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^
    {
        CGFloat socialViewHeight = self.socialViewController.collectionViewLayout.collectionViewContentSize.height;
        CGRect socialViewFrame = self.socialViewController.view.frame;
        socialViewFrame.origin.y = self.tabBar.frame.origin.y - socialViewHeight;
        self.socialViewController.view.frame = socialViewFrame;
    }
    completion:nil];
}

- (void)dismissSocialView
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^
    {
        CGRect hiddenRect = self.socialViewController.view.frame;
        hiddenRect.origin.y = self.view.frame.size.height;
        self.socialViewController.view.frame = hiddenRect;
    }
    completion:nil];
}

- (void)setupShareView
{
    self.socialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"social"];
    self.socialViewController.isReview = NO;
    self.socialViewController.view.frame = CGRectMake( 0, self.view.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height );
    self.socialViewController.delegate = self;
    [self addChildViewController:self.socialViewController];
}

- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller
{
    [self dismissSocialView];
}

@end