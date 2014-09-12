//
//  DADishLayer.m
//  Dished
//
//  Created by Ryan Khalili on 9/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishLayer.h"


@implementation DADishLayer

@dynamic blueDishWidthPercentage;
@dynamic blueDishOffsetPercentage;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if( [key isEqualToString:@"blueDishWidthPercentage"] || [key isEqualToString:@"blueDishOffsetPercentage"] )
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

+ (CGSize)dishSize
{
    return [UIImage imageNamed:@"refresh_gray"].size;
}

- (CABasicAnimation *)makeAnimationForKey:(NSString *)key
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
    anim.fromValue = [[self presentationLayer] valueForKey:key];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = [CATransaction animationDuration];
    
    return anim;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    if( [event isEqualToString:@"blueDishWidthPercentage"] || [event isEqualToString:@"blueDishOffsetPercentage"] )
    {
        return [self makeAnimationForKey:event];
    }
    else
    {
        return [super actionForKey:event];
    }
}

- (void)drawInContext:(CGContextRef)ctx
{
    [super drawInContext:ctx];
    
    UIImage *grayDishImage = [UIImage imageNamed:@"refresh_gray"];
    
    CGFloat x = ( self.frame.size.width  / 2 ) - ( grayDishImage.size.width  / 2 );
    CGFloat y = ( self.frame.size.height / 2 ) - ( grayDishImage.size.height / 2 );
    CGRect grayDishRect = CGRectMake( x, y, grayDishImage.size.width, grayDishImage.size.height );
    
    CGRect blueDishRect = grayDishRect;
    
    if( self.blueDishOffsetPercentage > 0 )
    {
        blueDishRect.origin.x = blueDishRect.origin.x * self.blueDishOffsetPercentage;
    }
    
    if( self.blueDishWidthPercentage > 0 )
    {
        blueDishRect.size.width = blueDishRect.size.width * self.blueDishWidthPercentage;
    }
    else
    {
        blueDishRect.size.width = 0;
    }
    
    CGContextTranslateCTM( ctx, 0, self.frame.size.height );
    CGContextScaleCTM( ctx, 1.0, -1.0 );
    CGContextDrawImage( ctx, grayDishRect, grayDishImage.CGImage );
    CGContextSetFillColorWithColor( ctx, [UIColor dishedColor].CGColor );
    CGContextClipToMask( ctx, grayDishRect, [grayDishImage CGImage] );
    CGContextFillRect( ctx, blueDishRect );
}

@end