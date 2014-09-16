//
//  DASampleGraphViewController.m
//  Dished
//
//  Created by POST on 8/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DASampleGraphViewController.h"
#import "DAGraphControl.h"

@interface DASampleGraphViewController ()

@property (weak, nonatomic) IBOutlet DAGraphControl *control;

@end

@implementation DASampleGraphViewController

- (void) viewDidAppear:(BOOL)animated
{
    NSDictionary *dictKeysObjectsNew = @{@"A" : @44,
                                       	 @"B" : @22,
                                       	 @"C" : @6,
                                         @"D/F" : @24};
    
    [self.control setGradeValues:dictKeysObjectsNew];
    [self.control sendActionsForControlEvents:UIControlEventTouchUpInside];
    
}


- (IBAction)touchedArrow:(DAGraphControl *)sender
{
    
    
    
    [CATransaction setAnimationDuration:1.0];
	if (sender.percentage == 1.0)
    {
        sender.percentage = 0.0;
    }
    else
    {
        sender.percentage = 1.0;
        
    }
    
}


@end
