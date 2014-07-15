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
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = 20.0f;
        _locationFound = NO;
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

- (void)getAddress
{
    if( self.locationFound )
    {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
        {
            if( error )
            {
                NSLog(@"Geocode failed with error: %@", error);
                return;
            }
            
            if( placemarks && placemarks.count > 0 )
            {
                CLPlacemark *placemark = placemarks[0];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kAddressReadyNotificationKey object:placemark.addressDictionary];
            }
        }];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    
    NSLog(@"%f, %f", self.currentLocation.longitude, self.currentLocation.latitude);
    
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