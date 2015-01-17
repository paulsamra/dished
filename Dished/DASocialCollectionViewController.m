//
//  DASocialCollectionViewController.m
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASocialCollectionViewController.h"
#import "REComposeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MessageUI/MessageUI.h>
#import "DAAppDelegate.h"
#import "DATwitterManager.h"
#import <Social/Social.h>
#import "MRProgress.h"

static NSString *const kFacebookTitle = @"Facebook";
static NSString *const kTwitterTitle  = @"Twitter";
static NSString *const kEmailTitle    = @"Email";


@interface DASocialCollectionViewController() <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) NSArray             *cellLabels;
@property (strong, nonatomic) NSArray             *cellImages;
@property (strong, nonatomic) UIAlertView         *facebookLoginAlert;
@property (strong, nonatomic) UIAlertView         *twitterLoginAlert;
@property (strong, nonatomic) UIAlertView         *emailFailAlert;
@property (strong, nonatomic) UIAlertView         *deleteConfirmAlert;
@property (strong, nonatomic) NSMutableDictionary *selectedSharing;
@property (strong, nonatomic) NSMutableDictionary *cellWaiting;


@end


@implementation DASocialCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedSharing = [NSMutableDictionary dictionary];
    self.cellWaiting = [NSMutableDictionary dictionary];
}

- (BOOL)socialMediaTypeSelected:(eSocialMediaType)socialMediaType
{
    switch( socialMediaType )
    {
        case eSocialMediaTypeFacebook: return [[self.selectedSharing objectForKey:kFacebookTitle] boolValue]; break;
        case eSocialMediaTypeTwitter:  return [[self.selectedSharing objectForKey:kTwitterTitle] boolValue];  break;
        case eSocialMediaTypeEmail:    return [[self.selectedSharing objectForKey:kEmailTitle] boolValue];    break;
        default: return NO;
    }
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
    if( indexPath.row == self.cellLabels.count - 1 )
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"doneCell" forIndexPath:indexPath];
        
        return cell;
    }
    
    DASocialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"socialCell" forIndexPath:indexPath];
    
    cell.socialLabel.text = [self.cellLabels objectAtIndex:indexPath.row];
    cell.socialImageView.image = [self.cellImages objectAtIndex:indexPath.row];
    
    if( self.isReviewPost )
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
    
    if( [self.cellWaiting objectForKey:self.cellLabels[indexPath.row]] )
    {
        [cell.spinner startAnimating];
        cell.socialImageView.hidden = YES;
    }
    else
    {
        [cell.spinner stopAnimating];
        cell.socialImageView.hidden = NO;
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
    
    if( indexPath.row == self.cellLabels.count - 1 && self.cellLabels.count % 2 == 1 )
    {
        itemWidth = availableWidth;
    }
    
    CGSize itemSize = CGSizeMake( itemWidth, defaultItemSize.height );
    
    return itemSize;
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
            [self.cellWaiting removeObjectForKey:self.cellLabels[0]];
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
            [self.cellWaiting removeObjectForKey:self.cellLabels[1]];
            [self.selectedSharing removeObjectForKey:self.cellLabels[1]];
            [self.collectionView reloadData];
        }
    }
    
    if( alertView == self.deleteConfirmAlert )
    {
        if( buttonIndex != alertView.cancelButtonIndex )
        {
            [self deleteReview];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( [self.cellWaiting objectForKey:self.cellLabels[indexPath.row]] )
    {
        return;
    }
    
    switch( indexPath.row )
    {
        case 0: [self handleFacebookSelectionAtIndexPath:indexPath]; break;
        case 1: [self handleTwitterSelectionAtIndexPath:indexPath];  break;
        case 2:
        {
            if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]] )
            {
                [self.selectedSharing removeObjectForKey:self.cellLabels[indexPath.row]];
                [self.collectionView reloadData];
            }
            else
            {
                if( [MFMailComposeViewController canSendMail] )
                {
                    if( !self.isReviewPost )
                    {
                        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                        [composeViewController setMailComposeDelegate:self];
                        [composeViewController setSubject:@"Wow this Dish is awesome!"];
                        [self.parentViewController presentViewController:composeViewController animated:YES completion:nil];
                    }
                    else
                    {
                        [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
                        [self.collectionView reloadData];
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
            if( self.isReviewPost )
            {
                if( [self.delegate respondsToSelector:@selector(socialCollectionViewControllerDidFinish:)] )
                {
                    [self.delegate socialCollectionViewControllerDidFinish:self];
                }
            }
            else
            {
              	if( !self.isOwnReview )
                {
                    self.dishProfile ? [self reportDish] : [self reportReview];
                    [self dismissView];
                }
                else
                {
                    [self.deleteConfirmAlert show];
                }
            }
            break;

        case 4:
            [self dismissView];
            break;
    }
}

- (void)handleFacebookSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.isReviewPost )
    {
        if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]] )
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[indexPath.row]];
            [self.collectionView reloadData];
            return;
        }
        else
        {
            [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
        }
    }
    
    if( FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpenTokenExtended )
    {
        [self openFacebookSession];
    }
    else if( FBSession.activeSession.state != FBSessionStateOpen )
    {
        [self.cellWaiting setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
        [self.facebookLoginAlert show];
    }
    else
    {
        if( !self.isReviewPost )
        {
            [self presentComposeViewForSocialMediaType:eSocialMediaTypeFacebook];
        }
    }
    
    [self.collectionView reloadData];
}

- (void)handleTwitterSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.isReviewPost )
    {
        if( [self.selectedSharing objectForKey:self.cellLabels[indexPath.row]] )
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[indexPath.row]];
        }
        else
        {
            [self.selectedSharing setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
            
            if( ![[DATwitterManager sharedManager] isLoggedIn] )
            {
                [self.cellWaiting setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
                [self.twitterLoginAlert show];
            }
        }
        
        [self.collectionView reloadData];
    }
    else
    {
        if( ![[DATwitterManager sharedManager] isLoggedIn] )
        {
            [self.cellWaiting setObject:@(YES) forKey:self.cellLabels[indexPath.row]];
            [self.collectionView reloadData];
            [self.twitterLoginAlert show];
        }
        else
        {
            [self.cellWaiting removeObjectForKey:self.cellLabels[indexPath.row]];
            [self presentComposeViewForSocialMediaType:eSocialMediaTypeTwitter];
        }
    }
}

- (void)presentComposeViewForSocialMediaType:(eSocialMediaType)socialMediaType
{
    if( socialMediaType == eSocialMediaTypeEmail )
    {
        [self presentEmailComposer];
    }
    else
    {
        REComposeViewController *composeViewController = [[REComposeViewController alloc] init];
        composeViewController.hasAttachment = YES;
        composeViewController.editableAttachmentImage = NO;
        
        UIImage *image = nil;
        
        switch( socialMediaType )
        {
            case eSocialMediaTypeFacebook: image = [UIImage imageNamed:@"facebook"]; break;
            case eSocialMediaTypeTwitter:  image = [UIImage imageNamed:@"twitter"];  break;
            default: break;
        }
        
        UIImageView *titleImageView = [[UIImageView alloc] initWithImage:image];
        titleImageView.contentMode = UIViewContentModeCenter;
        composeViewController.navigationItem.titleView = titleImageView;
        composeViewController.placeholderText = @"Enter a message.";
        
        NSString *imageURL = self.review ? self.review.img : self.dishProfile.images[0];
        imageURL = imageURL ? imageURL : @"";
        
        NSURL *image_URL = [NSURL URLWithString:imageURL];
        [[SDWebImageManager sharedManager] downloadImageWithURL:image_URL options:0 progress:nil
        completed:^( UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL )
        {
            composeViewController.attachmentImage = image;
        }];
        
        composeViewController.completionHandler = ^( REComposeViewController *composeVC, REComposeResult result )
        {
            [composeVC dismissViewControllerAnimated:YES completion:nil];
            
            if( result == REComposeResultPosted )
            {
                
                switch( socialMediaType )
                {
                    case eSocialMediaTypeTwitter:
                        [[DATwitterManager sharedManager] postDishTweetWithMessage:composeVC.text imageURL:self.review.img completion:nil];
                        break;
                        
                    case eSocialMediaTypeFacebook:
                        [self shareDishOnFacebookWithMessage:composeVC.text imageURL:imageURL];
                        break;
                        
                    default: break;
                }
                
                [self dismissView];
            }
        };
        
        [composeViewController presentFromRootViewController];
    }
}

- (void)presentEmailComposer
{
    if( [MFMailComposeViewController canSendMail] )
    {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setSubject:@"Wow this Dish is awesome!"];
        [self.parentViewController presentViewController:composeViewController animated:YES completion:nil];
    }
    else
    {
        [self.emailFailAlert show];
    }
}

- (void)reportDish
{
    NSDictionary *parameters = @{ kIDKey : @(self.dishProfile.dish_id) };
    
    [[DAAPIManager sharedManager] POSTRequest:kReportDishURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self reportDish];
        }
    }];
}

- (void)reportReview
{
    NSDictionary *parameters = @{ kIDKey : @(self.review.review_id) };
    
    [[DAAPIManager sharedManager] POSTRequest:kReportReviewURL withParameters:parameters success:nil
    failure:^( NSError *error, BOOL shouldRetry )
    {
        if( shouldRetry )
        {
            [self reportReview];
        }
    }];
}

- (void)deleteReview
{
    if( [self.delegate respondsToSelector:@selector(socialCollectionViewControllerDidDeleteReview:)] )
    {
        [self.delegate socialCollectionViewControllerDidDeleteReview:self];
    }
}

- (void)dismissView
{
    if( [self.delegate respondsToSelector:@selector(socialCollectionViewControllerDidFinish:)] )
    {
        [self.delegate socialCollectionViewControllerDidFinish:self];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)openFacebookSession
{
    [FBSession openActiveSessionWithReadPermissions:@[ @"publish_actions" ] allowLoginUI:YES
    completionHandler:^( FBSession *session, FBSessionState status, NSError *error )
    {
        [self.cellWaiting removeObjectForKey:self.cellLabels[0]];
        
        if( status == FBSessionStateOpen )
        {            
            if( !self.isReviewPost )
            {
                [self presentComposeViewForSocialMediaType:eSocialMediaTypeFacebook];
            }
        }
        else
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[0]];
        }
        
        [self.collectionView reloadData];
        
        DAAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate sessionStateChanged:session state:status error:error];
    }];
}

- (void)shareReviewOnFacebook:(DANewReview *)review withReviewID:(NSInteger)reviewID imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion;
{
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];

    object.provisionedForPost = YES;
    
    object[@"title"] = [NSString stringWithFormat:@"I just left an %@ review for %@ at %@.", review.rating, review.title, review.locationName];
    object[@"type"] = @"dishedfb:dish";
    object[@"url"] = [NSString stringWithFormat:@"http://dishedapp.com/review/%ld", (long)reviewID];
    object[@"image"] = @[ @{ @"url": imageURL, @"user_generated" : @"true" } ];
    
    [FBRequestConnection startForPostOpenGraphObject:object
    completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
    {
        if( !error )
        {
            NSString *objectId = [result objectForKey:@"id"];
            
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:@"dish"];
            
            [FBRequestConnection startForPostWithGraphPath:@"/me/dishedfb:review" graphObject:action
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
        else
        {
            completion( NO );
        }
    }];
}

- (void)shareDishOnFacebookWithMessage:(NSString *)message imageURL:(NSString *)imageURL;
{
    if( !self.dishProfile && !self.review )
    {
        return;
    }
    
    NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
    
    NSString *title = self.review ? self.review.name : self.dishProfile.name;
    NSString *place = self.review ? self.review.loc_name : self.dishProfile.loc_name;
    
    NSInteger itemId = self.review ? self.review.review_id : self.dishProfile.dish_id;
    NSString *deepLink = [NSString stringWithFormat:@"%@/%ld", self.review ? @"review" : @"dish", (long)itemId];
    
    object.provisionedForPost = YES;
    object[@"title"] = [NSString stringWithFormat:@"%@ from %@\n\n%@", title, place, message];
    object[@"type"] = @"dishedfb:dish";
    object[@"url"] = [NSString stringWithFormat:@"http://dishedapp.com/%@", deepLink];
    object[@"image"] = @[ @{ @"url": imageURL, @"user_generated" : @"true" } ];
    
    [FBRequestConnection startForPostOpenGraphObject:object
    completionHandler:^( FBRequestConnection *connection, id result, NSError *error )
    {
        if( !error )
        {
            NSString *objectId = [result objectForKey:@"id"];
             
            id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
            [action setObject:objectId forKey:@"dish"];
             
            [FBRequestConnection startForPostWithGraphPath:@"/me/dishedfb:share" graphObject:action completionHandler:nil];
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
            
            if( !self.isReviewPost )
            {
                [self presentComposeViewForSocialMediaType:eSocialMediaTypeTwitter];
            }
        }
        else
        {
            [self.selectedSharing removeObjectForKey:self.cellLabels[1]];
        }
        
        [self.cellWaiting removeObjectForKey:self.cellLabels[1]];
        [self.collectionView reloadData];
    }];
}

- (void)postReviewToTwitter:(DANewReview *)review imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion
{
    NSString *twitterMessage = [NSString stringWithFormat:@"I just left an %@ review for %@ at %@.", review.rating, review.title, review.locationName];
    
    [[DATwitterManager sharedManager] postDishTweetWithMessage:twitterMessage imageURL:imageURL
    completion:^( BOOL success )
    {
        completion( success );
    }];
}

- (void)shareReview:(DANewReview *)review withReviewID:(NSInteger)reviewID imageURL:(NSString *)imageURL
         completion:( void(^)( BOOL success ) )completion;
{
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL success = YES;
    
    if( [self.selectedSharing objectForKey:self.cellLabels[0]] )
    {
        dispatch_group_enter( group );
        
        [self shareReviewOnFacebook:review withReviewID:reviewID imageURL:imageURL completion:^( BOOL successful )
        {
            success &= successful;
            
            dispatch_group_leave( group );
        }];
    }
    
    if( [self.selectedSharing objectForKey:self.cellLabels[1]] )
    {
        dispatch_group_enter( group );
        
        [self postReviewToTwitter:review imageURL:imageURL completion:^( BOOL successful )
        {
            success &= successful;
            
            dispatch_group_leave( group );
        }];
    }
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        completion( success );
    });
}

- (void)setIsOwnReview:(BOOL)isOwnReview
{
    _isOwnReview = isOwnReview;
    
    self.cellLabels = nil;
    [self.collectionView reloadData];
}

- (void)setIsReviewPost:(BOOL)isReviewPost
{
    _isReviewPost = isReviewPost;
    
    self.cellLabels = nil;
    [self.collectionView reloadData];
}

- (NSArray *)cellLabels
{
    if( !_cellLabels )
    {
        if ( self.isReviewPost )
        {
            _cellLabels = @[ kFacebookTitle, kTwitterTitle, kEmailTitle, @"Done" ];
        }
        else
        {
            if( self.isOwnReview )
            {
                _cellLabels = @[ kFacebookTitle, kTwitterTitle, kEmailTitle, @"Delete", @"Done" ];
            }
            else
            {
                _cellLabels = @[ kFacebookTitle, kTwitterTitle, kEmailTitle, @"Report", @"Done" ];
            }
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
        UIImage *trashImage = [UIImage imageNamed:@"trash"];

        _cellImages = @[ facebookImage, twitterImage, emailImage, flagImage];
        
        if( self.isReviewPost )
        {
            _cellImages = @[ facebookImage, twitterImage, emailImage];
        }
        else
        {
            if( self.isOwnReview )
            {
                _cellImages = @[ facebookImage, twitterImage, emailImage, trashImage ];
            }
            else
            {
                _cellImages = @[ facebookImage, twitterImage, emailImage, flagImage ];
            }
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

- (UIAlertView *)deleteConfirmAlert
{
    if( !_deleteConfirmAlert )
    {
        _deleteConfirmAlert = [[UIAlertView alloc] initWithTitle:@"Confirm Deletion" message:@"Are you sure you want to delete your review?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    }
    
    return _deleteConfirmAlert;
}

@end