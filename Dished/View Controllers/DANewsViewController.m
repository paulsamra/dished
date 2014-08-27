//
//  DANewsViewController.m
//  Dished
//
//  Created by Ryan Khalili on 8/9/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsViewController.h"
#import "DAAppDelegate.h"
#import "DAAPIManager.h"


@interface DANewsViewController()

@property (weak, nonatomic) IBOutlet UIImageView *dishImage;
@property (nonatomic) BOOL isMaskMoved;
@property (strong, nonatomic) CAShapeLayer *maskLayer;

@end


@implementation DANewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.isMaskMoved = !self.isMaskMoved;
    CGFloat width = self.dishImage.layer.frame.size.width;
    CGFloat height = self.dishImage.layer.frame.size.height;
    
    //Create path that defines the edges of our masking layer
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, width, 0);
    CGPathAddLineToPoint(path, NULL, width, height);
    //    CGPathAddLineToPoint(path, NULL, (width / 2) + 30, height);
    //    if (self.isMaskMoved)
    //        CGPathAddLineToPoint(path, NULL, (width / 2), height - 30);
    //    else
    //        CGPathAddLineToPoint(path, NULL, (width / 2), height);
    //    CGPathAddLineToPoint(path, NULL, (width / 2) - 30, height);
    //    CGPathAddLineToPoint(path, NULL, 0, height);
    CGPathCloseSubpath(path);
    
    //if no mask, create it
    if (!self.maskLayer)
    {
        self.maskLayer = [[CAShapeLayer alloc] init];
        self.maskLayer.frame = self.dishImage.layer.bounds;
        self.maskLayer.fillColor = [[UIColor dishedColor] CGColor];
        self.maskLayer.path = path;
        self.dishImage.layer.mask = self.maskLayer;
    }
    //animate our mask to the new path
    else
    {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        [anim setFromValue:(id)self.maskLayer.path];
        [anim setToValue:(__bridge id)(path)];
        [anim setDelegate:self];
        [anim setDuration:0.25];
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        self.maskLayer.path = path;
        [self.maskLayer addAnimation:anim forKey:@"path"];
    }
    
    CGPathRelease(path);
}

- (IBAction)logout
{
    [[DAAPIManager sharedManager] logout];
    
    DAAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate setLoginView];
}

@end