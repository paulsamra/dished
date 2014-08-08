//
//  DASocialCollectionViewCell.h
//  Dished
//
//  Created by POST on 8/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DASocialCollectionViewCell : UICollectionViewCell <UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel     *socialLabel;
@property (weak, nonatomic) IBOutlet UIButton 	 *button;
@property (weak, nonatomic) IBOutlet UIImageView *socialImageView;

@property (strong, nonatomic) UIAlertView *twitterLoginAlert;
@property (strong, nonatomic) UIAlertView *facebookLoginAlert;
@property (strong, nonatomic) UIAlertView *emailFailAlert;

- (IBAction)socialButtonPressed:(id)sender;
- (NSMutableDictionary *) myStaticDictionary;

@end