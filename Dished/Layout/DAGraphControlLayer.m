//
//  DAGraphControlLayer.m
//  Dished
//
//  Created by Daryl Stimm on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAGraphControlLayer.h"

@implementation DAGraphControlLayer

@dynamic percentage;

+(BOOL)needsDisplayForKey:(NSString*) key
{
    
    if ([key isEqualToString:@"percentage"])
    {
        return YES;
    }
    else
    {
        return [super needsDisplayForKey:key];
    }
}

-(CABasicAnimation *)makeAnimationForKey:(NSString *) key
{
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = [CATransaction animationDuration];
    
	return anim;
}

-(id <CAAction> )actionForKey:(NSString *) event
{
	if ([event isEqualToString:@"percentage"])
    {
		return [self makeAnimationForKey:event];
	}
    else
    {
        return [super actionForKey:event];
    }
}

-(void)drawInContext:(CGContextRef)ctx
{
    [super drawInContext:ctx];
    
    UIGraphicsPushContext(ctx);
    
    //change this to set the grades totals
    NSArray *arrayOfGradeAmounts = @[@9 ,@23, @12, @33];
    
    float max = [[arrayOfGradeAmounts valueForKeyPath:@"@max.floatValue"] floatValue];
    
    float height = 20.0;
    float offset = 17.5;
    float x = 50;
	float min = 80;
    
    UIBezierPath* bezier2Path = UIBezierPath.bezierPath;
    [bezier2Path moveToPoint: CGPointMake(x-0.5, 37.5)];
    [bezier2Path addLineToPoint: CGPointMake(x-0.5, 190.0)];
    [UIColor.grayColor setStroke];
    bezier2Path.lineWidth = 0.5;
    [bezier2Path stroke];
    
    UIBezierPath* bezier3Path = UIBezierPath.bezierPath;
    [bezier3Path moveToPoint: CGPointMake(43.0, 183.5)];
    [bezier3Path addLineToPoint: CGPointMake(250.0, 183.5)];
    [UIColor.grayColor setStroke];
    bezier3Path.lineWidth = 0.5;
    [bezier3Path stroke];
    
    
    for (int i = 0; i < 4; i++)
    {
        float y = (height + offset)*i + 50;
        
        float length = ([[arrayOfGradeAmounts objectAtIndex:i] floatValue]*250)/max;
        length = length*self.percentage;
        
        if (length < min)
        {
            length = min;
        }
        UIBezierPath* bezierPath = UIBezierPath.bezierPath;
        [bezierPath moveToPoint: CGPointMake(x, y)];
        [bezierPath addLineToPoint: CGPointMake(length, y)];
        [bezierPath addLineToPoint: CGPointMake(length-12, y+height)];
        [bezierPath addLineToPoint: CGPointMake(x, y+height)];
        [bezierPath addLineToPoint: CGPointMake(x, y)];
        [[UIColor colorWithRed:24.0/255.0 green:171.0/255.0 blue:254.0/255.0 alpha:1.0] setStroke];
        [[UIColor colorWithRed:24.0/255.0 green:171.0/255.0 blue:254.0/255.0 alpha:1.0] setFill];
        
        bezierPath.lineWidth = 1;
        [bezierPath fill];
        [bezierPath stroke];
        
        CGRect textRect = CGRectMake(length-33, y+2, 30, 16);
        NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        textStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary* textFontAttributes = @{NSFontAttributeName: [UIFont fontWithName: @"HelveticaNeue-Light" size: 12], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: textStyle};
        
        [[NSString stringWithFormat:@"%@", [arrayOfGradeAmounts objectAtIndex:i]] drawInRect: textRect withAttributes: textFontAttributes];
        
    }
    
    
    
    UIGraphicsPopContext();
}


@end
