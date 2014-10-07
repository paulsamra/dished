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
#define kLocationServicesDeniedKey     @"location_denied"


@interface DALocationManager : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D currentLocation;


+ (DALocationManager *)sharedManager;

- (void)getAddressWithCompletion:( void(^)( NSDictionary *addressDictionary ) )completion;
- (BOOL)locationServicesEnabled;
- (BOOL)hasDeterminedLocation;
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end