 	//
//  main.m
//  Dished
//
//  Created by Ryan Khalili on 6/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lecore.h"
#import "DAAppDelegate.h"

int main( int argc, char * argv[] )
{
    @autoreleasepool
    {
        le_init();
        le_set_token( "f59b18d7-b3f2-416d-88fd-f0525dff6f0e" );
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([DAAppDelegate class]));
    }
}