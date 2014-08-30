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


@interface DATabBarController() <UITabBarControllerDelegate, MFMailComposeViewControllerDelegate>

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
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if( [viewController.title isEqualToString:@"dummy"] )
    {
        DAImagePickerController *reviewImagePicker = [self.storyboard instantiateViewControllerWithIdentifier:@"addReview"];
        [self presentViewController:reviewImagePicker animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
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

@end