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
    if( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && ![self locationServicesEnabled] )
    {
        [self requestAuthorization];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)requestAuthorization
{
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)stopUpdatingLocation
{
    [self.locationManager stopUpdatingLocation];
    self.currentLocation = CLLocationCoordinate2DMake( 0, 0 );
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesDeniedKey object:nil];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if( status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesDeniedKey object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesEnabledKey object:nil];
        [self.locationManager startUpdatingLocation];
    }
}

- (BOOL)locationServicesEnabled
{
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if( authStatus == kCLAuthorizationStatusNotDetermined )
    {
        return NO;
    }
    
    if( authStatus != kCLAuthorizationStatusDenied && authStatus != kCLAuthorizationStatusRestricted )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)hasDeterminedLocation
{
    return self.locationFound;
}

- (void)getAddressWithCompletion:( void(^)( NSDictionary *addressDictionary ) )completion
{
    if( self.locationFound )
    {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        [geocoder reverseGeocodeLocation:location completionHandler:^( NSArray *placemarks, NSError *error )
        {
            if( error )
            {
                NSString *log = [NSString stringWithFormat:@"Geocode failed with error: %@", error];
                [[LELog sharedInstance] log:log];
                
                if( completion )
                {
                    completion( nil );
                }
            }
            else if( placemarks && placemarks.count > 0 )
            {
                CLPlacemark *placemark = placemarks[0];
                
                if( completion )
                {
                    completion( placemark.addressDictionary );
                }
            }
        }];
    }
}

- (CLLocationCoordinate2D)lastKnownLocation
{
    if( self.locationFound )
    {
        return self.currentLocation;
    }
    
    NSNumber *longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastKnownLongitude"];
    NSNumber *latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastKnownLatitude"];
    
    if( !longitude || !latitude )
    {
        return CLLocationCoordinate2DMake(0.0, 0.0);
    }
    
    return CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    self.currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    
    [[NSUserDefaults standardUserDefaults] setValue:@(self.currentLocation.longitude) forKey:@"lastKnownLongitude"];
    [[NSUserDefaults standardUserDefaults] setValue:@(self.currentLocation.latitude) forKey:@"lastKnownLatitude"];
    
    if( location.coordinate.latitude != 0 && location.coordinate.longitude != 0 )
    {
        self.locationFound = YES;
    }
    else
    {
        self.locationFound = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdateNotificationKey object:nil];
}

@end