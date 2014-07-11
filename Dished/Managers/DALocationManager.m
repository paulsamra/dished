//
//  DALocationManager.m
//  Dished
//
//  Created by Ryan Khalili on 7/10/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DALocationManager.h"


@interface DALocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, readwrite) CLLocationCoordinate2D currentLocation;
@property (nonatomic) BOOL locationFound;

@end


@implementation DALocationManager

+ (DALocationManager *)sharedManager
{
    static DALocationManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DALocationManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    if( self )
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationFound = NO;
    }
    
    return self;
}

- (void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
}

- (BOOL)hasDeterminedLocation
{
    return self.locationFound;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    
    if( location.coordinate.latitude != 0 && location.coordinate.longitude != 0 )
    {
        self.locationFound = YES;
    }
    else
    {
        self.locationFound = NO;
    }
}

@end