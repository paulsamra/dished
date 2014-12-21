//
//  DAProgressView.m
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAProgressView.h"


@interface DAProgressView()

@property (strong, nonatomic) CALayer      *maskLayer;
@property (strong, nonatomic) CALayer      *blueDishLayer;
@property (strong, nonatomic) CALayer      *grayDishLayer;

@end


@implementation DAProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        [self setupImageLayer];
    }
    
    return self;
}

- (void)setupImageLayer
{
    self.grayDishLayer = [CALayer layer];
    self.grayDishLayer.masksToBounds = YES;
    UIImage *dishImage = [UIImage imageNamed:@"refresh_gray"];
    CGFloat x = ( self.frame.size.width  / 2 ) - ( dishImage.size.width  / 2 );
    CGFloat y = ( self.frame.size.height / 2 ) - ( dishImage.size.height / 2 );
    self.grayDishLayer.frame = CGRectMake( x, y, dishImage.size.width, dishImage.size.height );
    self.grayDishLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.grayDishLayer.contents = (id)dishImage.CGImage;
    [self.layer addSublayer:self.grayDishLayer];
    
    self.blueDishLayer = [CALayer layer];
    self.blueDishLayer.frame = self.grayDishLayer.frame;
    self.blueDishLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.blueDishLayer.contents = (id)[UIImage imageNamed:@"refresh_blue"].CGImage;
    [self.layer addSublayer:self.blueDishLayer];
    
    self.maskLayer = [CALayer layer];
    self.maskLayer.anchorPoint = CGPointZero;
    self.maskLayer.frame = CGRectMake( 0, 0, 0, self.blueDishLayer.frame.size.height );
    self.maskLayer.backgroundColor = [UIColor blackColor].CGColor;
    self.blueDishLayer.mask = self.maskLayer;
}

- (void)animateToPercentage:(CGFloat)percentage
{
    [self.maskLayer removeAllAnimations];
    
    if( percentage != percentage )
    {
        return;
    }
    
    CGFloat width = self.blueDishLayer.frame.size.width * percentage;
    CGRect maskFrame = self.maskLayer.frame;
    maskFrame.size.width = width;
    
    if( width != width )
    {
        return;
    }
    
    CABasicAnimation *progressAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size.width"];
    progressAnimation.fromValue = @(self.maskLayer.frame.size.width);
    progressAnimation.toValue   = @(width);
    progressAnimation.duration  = 0.1;
    self.maskLayer.frame = maskFrame;
    [self.maskLayer addAnimation:progressAnimation forKey:@"progress"];
}

@end