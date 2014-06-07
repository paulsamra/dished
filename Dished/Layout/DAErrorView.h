//
//  DAErrorView.h
//  Dished
//
//  Created by Ryan Khalili on 6/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DAErrorView;


@protocol DAErrorViewDelegate <NSObject>

@required
- (void)errorViewDidTapCloseButton:(DAErrorView *)errorView;

@end


@interface DAErrorView : UIView

@property (weak, nonatomic) id<DAErrorViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *errorTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end