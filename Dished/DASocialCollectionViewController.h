//
//  DASocialCollectionViewController.h
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DANewReview.h"
#import "DAReview.h"
#import "DADishProfile.h"

@class DASocialCollectionViewController;


@protocol DASocialCollectionViewControllerDelegate <NSObject>

@optional
- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller;
- (void)socialCollectionViewControllerDidDeleteReview:(DASocialCollectionViewController *)controller;

@end


@interface DASocialCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) id<DASocialCollectionViewControllerDelegate> delegate;

@property (weak, nonatomic) DAReview *review;
@property (weak, nonatomic) DADishProfile *dishProfile;

@property (nonatomic) BOOL isReviewPost;
@property (nonatomic) BOOL isOwnReview;

- (BOOL)socialMediaTypeSelected:(eSocialMediaType)socialMediaType;
- (void)shareReview:(DANewReview *)review imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion;

@end