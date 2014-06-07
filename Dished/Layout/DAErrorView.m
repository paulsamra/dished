//
//  DAErrorView.m
//  Dished
//
//  Created by Ryan Khalili on 6/6/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAErrorView.h"

@implementation DAErrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSArray *views = [mainBundle loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        [self addSubview:views[0]];
    }
    
    return self;
}

- (IBAction)closeButtonTapped
{
    if( [self.delegate respondsToSelector:@selector(errorViewDidTapCloseButton:)] )
    {
        [self.delegate errorViewDidTapCloseButton:self];
    }
}

@end