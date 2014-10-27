//
//  DASocialCollectionViewController.h
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DANewReview.h"

#define kDoneSelecting @"doneSelecting"

@class DASocialCollectionViewController;

@protocol DASocialCollectionViewControllerDelegate <NSObject>

@optional
- (void)socialCollectionViewControllerDidFinish:(DASocialCollectionViewController *)controller;

@end


@interface DASocialCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray             *cellLabels;
@property (strong, nonatomic) NSArray             *cellImages;
@property (strong, nonatomic) UIAlertView         *facebookLoginAlert;
@property (strong, nonatomic) UIAlertView         *twitterLoginAlert;
@property (strong, nonatomic) UIAlertView         *emailFailAlert;
@property (strong, nonatomic) NSMutableDictionary *selectedSharing;

@property (weak, nonatomic) id<DASocialCollectionViewControllerDelegate> delegate;

@property (nonatomic) BOOL isReview;
@property (nonatomic) BOOL isOwnReview;

- (void)shareReview:(DANewReview *)review imageURL:(NSString *)imageURL completion:( void(^)( BOOL success ) )completion;

@end