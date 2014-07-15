//
//  DALocationManager.h
//  Dished
//
//  Created by Ryan Khalili on 7/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define kLocationUpdateNotificationKey @"location_updated"


@interface DALocationManager : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D currentLocation;


+ (DALocationManager *)sharedManager;

- (BOOL)hasDeterminedLocation;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end