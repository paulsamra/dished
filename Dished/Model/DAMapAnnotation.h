//
//  DAMapAnnotation.h
//  Dished
//
//  Created by Ryan Khalili on 10/25/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface DAMapAnnotation : NSObject <MKAnnotation>

@property (copy,   nonatomic) NSString       *img_thumb;
@property (strong, nonatomic) NSMutableArray *reviews;

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end