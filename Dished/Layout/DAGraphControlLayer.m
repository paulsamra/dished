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
@dynamic gradeValues;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"percentage"] ? YES : [super needsDisplayForKey:key];
}

- (CABasicAnimation *)makeAnimationForKey:(NSString *)key
{
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = 0.5f;
    
	return anim;
}

- (id<CAAction>)actionForKey:(NSString *)event
{
    return [event isEqualToString:@"percentage"] ? [self makeAnimationForKey:event] : [super actionForKey:event];
}

- (void)createLabelsWithFrame:(CGRect)textRect title:(NSString *)title withColor:(UIColor *)color withFont:(UIFont *)font
{
    NSMutableParagraphStyle* textStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary* textFontAttributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: color, NSParagraphStyleAttributeName: textStyle};
    
    [title drawInRect: textRect withAttributes: textFontAttributes];
}

- (void)drawInContext:(CGContextRef)ctx
{
    [super drawInContext:ctx];
    
    UIGraphicsPushContext(ctx);
    
    //change this to set the grades totals
    NSArray *arrayOfGradeAmounts = [self.gradeValues allValues];
    NSArray *arrayOfGrades = @[ @"A", @"B", @"C", @"DF" ];
    
    float max = [[arrayOfGradeAmounts valueForKeyPath:@"@max.floatValue"] floatValue];
    
    if( !arrayOfGradeAmounts )
    {
        max = 1;
    }
    
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
    [bezier3Path addLineToPoint: CGPointMake(self.frame.size.width - 50.0, 183.5)];
    [UIColor.grayColor setStroke];
    bezier3Path.lineWidth = 0.5;
    [bezier3Path stroke];
        
    [arrayOfGrades enumerateObjectsUsingBlock:^( id obj, NSUInteger idx, BOOL *stop )
    {
        float y = (height + offset)*idx + 50;
        
        float length = ( [[self.gradeValues objectForKey:obj] floatValue] * ( self.frame.size.width - 50.0 ) ) / max;
        
        length = length * self.percentage;
        
        if( length < min || length != length )
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
        
        [self createLabelsWithFrame:CGRectMake(length-33, y+2, 30, 16)
                              title:[NSString stringWithFormat:@"%@", [self.gradeValues objectForKey:obj]]
                          withColor:[UIColor whiteColor]
                           withFont:[UIFont fontWithName:kHelveticaNeueLightFont size: 12]];
        
        [self createLabelsWithFrame:CGRectMake(10, y+2, 30, 16)
                              title:[NSString stringWithFormat:@"%@", obj]
                          withColor:[UIColor grayColor]
                           withFont:[UIFont fontWithName:kHelveticaNeueLightFont size: 16]];
    }];
    
    UIGraphicsPopContext();
}

@end