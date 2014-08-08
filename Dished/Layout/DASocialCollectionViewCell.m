//
//  DASocialCollectionViewCell.m
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASocialCollectionViewCell.h"
#import "DASocialCollectionViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DATwitterManager.h"
#import "DAAppDelegate.h"
#import <MessageUI/MessageUI.h>


@implementation DASocialCollectionViewCell

- (NSMutableDictionary*) myStaticDictionary
{
    static NSMutableDictionary *theDict = nil;
    
    if (theDict == nil)
    {
        theDict = [[NSMutableDictionary alloc] init];
    }
    
    return theDict;
}

- (IBAction)socialButtonPressed:(id)sender {
    
    if( [self.socialLabel.text isEqualToString:@"Facebook"] )
    {
        
        if (self.socialImageView.alpha == 1.0)
        {
            NSLog(@"should NOT Post to facebook");
            [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"facebook"];
            self.socialImageView.alpha = 0.3;
            self.socialLabel.alpha = 0.3;

        }
        else
        {
            self.socialImageView.alpha = 1.0;
            self.socialLabel.alpha = 1.0;
            if( FBSession.activeSession.state == FBSessionStateOpen || FBSession.activeSession.state == FBSessionStateOpenTokenExtended )
            {
                [self requestFacebookPermissions];
            } else {
                UIAlertView *facebookLoginAlert = [[UIAlertView alloc] initWithTitle:@"You are not logged into Facebook" message:@"You must login to Facebook to share reviews. Do you want to login now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                [facebookLoginAlert show];

            }

        }
        
    }
    else if([self.socialLabel.text isEqualToString:@"Twitter"])
    {
        if( self.socialImageView.alpha == 1.0 )
        {
            NSLog(@"should NOT Post to twitter");
            [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"twitter"];

            self.socialImageView.alpha = 0.3;
            self.socialLabel.alpha = 0.3;

        }
        else
        {
            if( [[DATwitterManager sharedManager] isLoggedIn] )
            {
                self.socialImageView.alpha = 1.0;
                self.socialLabel.alpha = 1.0;

                NSLog(@"should Post to twitter");
                [[self myStaticDictionary] setObject:[NSNumber numberWithBool:YES] forKey:@"twitter"];

            }
            else
            {
                [self.twitterLoginAlert show];
            }
        }

        
    }
    else if([self.socialLabel.text isEqualToString:@"Email"])
    {
        if( self.socialImageView.alpha == 1.0 )
        {
            self.socialImageView.alpha = 0.3;
            self.socialLabel.alpha = 0.3;

            NSLog(@"should NOT Post to Email");
            [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"email"];

        }
        else
        {
            if( [MFMailComposeViewController canSendMail] )
            {
                NSLog(@"should Post to Email");
                [[self myStaticDictionary] setObject:[NSNumber numberWithBool:YES] forKey:@"email"];

                self.socialImageView.alpha = 1.0;
                self.socialLabel.alpha = 1.0;

            }
            else
            {
                [self.emailFailAlert show];
            }
        }
    }
    else if([self.socialLabel.text isEqualToString:@"Done"])
    {
    	
        [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissView" object:[[self myStaticDictionary] mutableCopy]];

    	[[self myStaticDictionary] removeAllObjects];
    }

    
}

- (void)requestFacebookPermissions
{
    NSArray *requestPermissions = @[ @"publish_actions" ];
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
     {
         if( !error )
         {
             BOOL hasPermission = NO;
             
             for( NSDictionary *permission in (NSArray *)[result data] )
             {
                 if( [[permission objectForKey:@"permission"] isEqualToString:[requestPermissions objectAtIndex:0]] )
                 {
                     hasPermission = YES;

                 }
             }
             
             if( !hasPermission )
             {
                 [FBSession.activeSession requestNewPublishPermissions:requestPermissions defaultAudience:FBSessionDefaultAudienceNone completionHandler:^( FBSession *session, NSError *error )
                  {
                      if( !error )
                      {
                          NSLog(@"should Post to facebook");
                          [[self myStaticDictionary] setObject:[NSNumber numberWithBool:YES] forKey:@"facebook"];

                      }
                  }];
             }
             else
             {
                 NSLog(@"should Post to facebook");
                 [[self myStaticDictionary] setObject:[NSNumber numberWithBool:YES] forKey:@"facebook"];

             }
         }
         else
         {
             if( [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession )
             {
                 [self.facebookLoginAlert show];
             }
         }
     }];
}

- (void)openFacebookSession
{
    [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:YES
                                  completionHandler:^( FBSession *session, FBSessionState status, NSError *error )
     {
         if( status == FBSessionStateOpen || status == FBSessionStateOpenTokenExtended )
         {
             [self requestFacebookPermissions];
         }
         else
         {
             self.socialImageView.alpha = 0.3;
             self.socialLabel.alpha = 0.3;
             NSLog(@"should NOT Post to facebook");
             [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"facebook"];


         }
         
         DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
         [appDelegate sessionStateChanged:session state:status error:error];
     }];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( alertView == self.facebookLoginAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            [self openFacebookSession];

        }
        else
        {
            self.socialImageView.alpha = 0.3;
            self.socialLabel.alpha = 0.3;
            NSLog(@"should NOT Post to facebook");
            [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"facebook"];


        }
    }
    
    if( alertView == self.twitterLoginAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            self.socialImageView.alpha = 0.3;
            self.socialLabel.alpha = 0.3;

            NSLog(@"should NOT Post to twitter");
            [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"twitter"];


            [self loginToTwitter];
        }
        else
        {
            self.socialImageView.alpha = 0.3;
            self.socialLabel.alpha = 0.3;

            NSLog(@"should NOT Post to twitter");
            [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"twitter"];

        }
    }
}

- (void)loginToTwitter
{
    [[DATwitterManager sharedManager] loginWithCompletion:^( BOOL success )
     {
         if( success )
         {
             self.socialImageView.alpha = 1.0;
             self.socialLabel.alpha = 1.0;

             NSLog(@"should Post to twitter");
             [[self myStaticDictionary] setObject:[NSNumber numberWithBool:YES] forKey:@"twitter"];


         }
         else
         {
             self.socialImageView.alpha = 0.3;
             self.socialLabel.alpha = 0.3;

             NSLog(@"should NOT Post to twitter");
             [[self myStaticDictionary] setObject:[NSNumber numberWithBool:NO] forKey:@"twitter"];

         }
     }];
}


- (UIAlertView *)facebookLoginAlert
{
    if( !_facebookLoginAlert )
    {
        _facebookLoginAlert = [[UIAlertView alloc] initWithTitle:@"You are not logged into Facebook" message:@"You must login to Facebook to share reviews. Do you want to login now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    
    return _facebookLoginAlert;
}

- (UIAlertView *)twitterLoginAlert
{
    if( !_twitterLoginAlert )
    {
        _twitterLoginAlert = [[UIAlertView alloc] initWithTitle:@"You are not logged into Twitter" message:@"You must login to Twitter to share reviews. Do you want to login now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    
    return _twitterLoginAlert;
}
- (UIAlertView *)emailFailAlert
{
    if( !_emailFailAlert )
    {
        _emailFailAlert = [[UIAlertView alloc] initWithTitle:@"You can't send E-mails" message:@"You must add an email account in your device settings to be able to email a dish review." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    }
    
    return _emailFailAlert;
}

@end