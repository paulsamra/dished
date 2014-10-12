//
//  DASocialCollectionViewController.m
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASocialCollectionViewController.h"
#import "DASocialCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>
#import "DAAppDelegate.h"
#import "DATwitterManager.h"
#import <Social/Social.h>

@interface DASocialCollectionViewController() <UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end


@implementation DASocialCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedSharing = [NSMutableDictionary dictionary];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.cellLabels count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView	
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( indexPath.row == (self.isReview ? 3 : 4) )
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"doneCell" forIndexPath:indexPath];
       
        if( !self.isReview )
        {
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, self.view.frame.size.width, cell.frame.size.height);
            
            if( cell.tag == 12 )
            {
                
            }
        }
        
        return cell;
    }
    
    DASocialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"socialCell" forIndexPath:indexPath];
    
    cell.socialLabel.text = [self.cellLabels objectAtIndex:indexPath.row];
    cell.socialImageView.image = [self.cellImages objectAtIndex:indexPath.row];
    
    if (self.isReview)
    {
        if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]])
        {
            cell.socialImageView.alpha = 1.0;
            cell.socialLabel.alpha = 1.0;
        }
        else
        {
            cell.socialImageView.alpha = 0.3;
            cell.socialLabel.alpha = 0.3;
        }
    }
    else
    {
        cell.socialImageView.alpha = 1.0;
        cell.socialLabel.alpha = 1.0;
    }

	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGSize defaultItemSize = flowLayout.itemSize;
    
    CGFloat width = collectionView.frame.size.width;
    CGFloat sectionInsetSpacing = flowLayout.sectionInset.right + flowLayout.sectionInset.left;
    CGFloat availableWidth = width - ( 2 * flowLayout.minimumInteritemSpacing ) - sectionInsetSpacing;
    CGFloat itemWidth = availableWidth / 2;
    
    CGSize itemSize = CGSizeMake( itemWidth, defaultItemSize.height );
    
    return itemSize;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( alertView == self.facebookLoginAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            [self openFacebookSession];
        }
        else
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[0]];
            [self.collectionView reloadData];
        }
    }
    
    if( alertView == self.twitterLoginAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            [self loginToTwitter];
        }
        else
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[1]];
            [self.collectionView reloadData];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch( indexPath.row )
    {
        case 0:
        {
            if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]] )
            {
                [self.selectedSharing removeObjectForKey:self.cellLabels[indexPath.row]];
                [self.collectionView reloadData];
            }
            else
            {
                if (self.isReview)
                {
                    [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
                    [self.collectionView reloadData];
                    
                    if( FBSession.activeSession.state == FBSessionStateOpen ||
                       FBSession.activeSession.state == FBSessionStateOpenTokenExtended )
                    {
                        [self requestFacebookPermissions];
                    }
                    else
                    {
                        [self.facebookLoginAlert show];
                    }

                }
                else
                {
                    if( [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] )
                    {
                        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                        
                        //[controller setInitialText:@"Post your favorite dish!"];
                       // [controller addImage:self.reviewImage];
                        
                        [self presentViewController:controller animated:YES completion:nil];
                    }
                }
            }
        }
        break;
            
        case 1:
        {
            
            if (self.isReview)
            {
                if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]] )
                {
                    [self.selectedSharing removeObjectForKey:self.cellLabels[indexPath.row]];
                    [self.collectionView reloadData];
                }
                else
                {
                    [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
                    [self.collectionView reloadData];
                    
                    if( ![[DATwitterManager sharedManager] isLoggedIn] )
                    {
                        [self.twitterLoginAlert show];
                    }
                }

            }
            else
            {
                if( [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter] )
                {
                    SLComposeViewController *tweetSheet = [SLComposeViewController
                                                           composeViewControllerForServiceType:SLServiceTypeTwitter];
                    //[tweetSheet setInitialText:@"Tweet your favorite dish!"];
                    //[tweetSheet addImage:self.reviewImage];
                    
                    [self presentViewController:tweetSheet animated:YES completion:nil];
                }
   
            }
            
        }
        break;
            
        case 2:
        {
            if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]] )
            {
                [self.selectedSharing removeObjectForKey:self.cellLabels[indexPath.row]];
                [self.collectionView reloadData];
            }
            else
            {                
                [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
                [self.collectionView reloadData];
                
                if( [MFMailComposeViewController canSendMail] )
                {
                    if (!self.isReview) {
                        if( [MFMailComposeViewController canSendMail] )
                        {
                            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                            [composeViewController setMailComposeDelegate:self];
                            [composeViewController setSubject:@"Wow this Dish is awesome!"];
                            //                        NSData *imageData = UIImagePNGRepresentation(self.reviewImage);
                            //                        [composeViewController addAttachmentData:imageData mimeType:nil fileName:@"image.png"];
                            [self.view.window.rootViewController presentViewController:composeViewController animated:YES completion:nil];
                        }

                    }
                    
                }
                else
                {
                    [self.emailFailAlert show];

                }
            }
        }
        break;
        case 3:
            if (self.isReview)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDoneSelecting object:nil];
            }
            else
            {
              	//do flag stuff here.
            }
            break;

        case 4:
            [[NSNotificationCenter defaultCenter] postNotificationName:kDoneSelecting object:nil];
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");

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
            [self.selectedSharing removeObjectForKey:self.cellLabels[0]];
            [self.collectionView reloadData];
        }
         
        DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sessionStateChanged:session state:status error:error];
    }];
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
                [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                defaultAudience:FBSessionDefaultAudienceNone completionHandler:^( FBSession *session, NSError *error )
                {
                    if( !error )
                    {
                        [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[0]];
                        [self.collectionView reloadData];
                    }
                    else
                    {
                        [self.selectedSharing removeObjectForKey:self.cellLabels[0]];
                        [self.collectionView reloadData];
                    }
                }];
            }
            else
            {
                [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[0]];
                [self.collectionView reloadData];
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

- (void)shareReviewOnFacebook:(DANewReview *)review imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion;
{
    NSString *message = [NSString stringWithFormat:@"I just left an %@ review for %@ at %@.", review.rating, review.title, review.locationName];
    
    NSDictionary *shareParams = @{ @"name" : review.title, @"caption" : message,
                                   @"description" : review.comment, @"link" : @"http://dishedapp.com",
                                   @"picture" : imageURL};
    
    [FBRequestConnection startWithGraphPath:@"/me/feed" parameters:shareParams HTTPMethod:@"POST"
    completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
    {
        if( !error )
        {
            completion( YES );
        }
        else
        {
            completion( NO );
        }
    }];
}

- (void)loginToTwitter
{
    [[DATwitterManager sharedManager] loginWithCompletion:^( BOOL success )
    {
        if( success )
        {
            [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[1]];
            [self.collectionView reloadData];
        }
        else
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[1]];
            [self.collectionView reloadData];
        }
    }];
}

- (void)postReviewToTwitter:(DANewReview *)review imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion
{
    NSString *twitterMessage = [NSString stringWithFormat:@"I just left an %@ review for %@ at %@.", review.rating, review.title, review.locationName];
    
    [[DATwitterManager sharedManager] postDishReviewTweetWithMessage:twitterMessage imageURL:imageURL
    completion:^( BOOL success )
    {
        completion( success );
    }];
}

- (void)shareReview:(DANewReview *)review imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion
{
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL success = YES;
    
    if( [self.selectedSharing objectForKey:self.cellLabels[0]] )
    {
        dispatch_group_enter( group );
        
        [self shareReviewOnFacebook:review imageURL:imageURL completion:^( BOOL successful )
        {
            success = successful;
            
            dispatch_group_leave( group );
        }];
    }
    
    if( [self.selectedSharing objectForKey:self.cellLabels[1]] )
    {
        dispatch_group_enter( group );
        
        [self postReviewToTwitter:review imageURL:imageURL completion:^( BOOL successful )
        {
            success = successful;
            
            dispatch_group_leave( group );
        }];
    }
    
    dispatch_group_enter( group );
    dispatch_group_leave( group );
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        completion( success );
    });
}

- (NSArray *)cellLabels
{
    if( !_cellLabels )
    {
        if (self.isReview)
        {
            _cellLabels = @[ @"Facebook", @"Twitter", @"Email", @"Done" ];

        }
        else
        {
            _cellLabels = @[ @"Facebook", @"Twitter", @"Email", @"Report", @"Done" ];

        }
    }
    
    return _cellLabels;
}

- (NSArray *)cellImages
{
    if( !_cellImages )
    {
        UIImage *facebookImage = [UIImage imageNamed:@"facebook"];
        UIImage *twitterImage = [UIImage imageNamed:@"twitter"];
        UIImage *emailImage = [UIImage imageNamed:@"email"];
        UIImage *flagImage = [UIImage imageNamed:@"flag"];

        _cellImages = @[ facebookImage, twitterImage, emailImage, flagImage];
        
        
        if (self.isReview)
        {
            _cellImages = @[ facebookImage, twitterImage, emailImage];
            
        }
        else
        {
            _cellImages = @[ facebookImage, twitterImage, emailImage, flagImage];
            
        }
        
        
    }
    
    return _cellImages;
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