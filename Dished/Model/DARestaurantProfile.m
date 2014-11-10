//
//  DARestaurantProfile.m
//  Dished
//
//  Created by Ryan Khalili on 10/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DARestaurantProfile.h"


@implementation DARestaurantProfile

- (id)initWithData:(id)data
{
    if( self = [super init] )
    {
        NSDictionary *restaurant = nilOrJSONObjectForKey( data, @"restaurant" );
        
        _name      = nilOrJSONObjectForKey( restaurant, kNameKey );
        _phone     = nilOrJSONObjectForKey( restaurant, kPhoneKey );
        _username  = nilOrJSONObjectForKey( restaurant, kUsernameKey );
        _img_thumb = nilOrJSONObjectForKey( restaurant, kImgThumbKey );
        _avg_grade = nilOrJSONObjectForKey( restaurant, @"avg_grade" );
        
        _loc_id  = [nilOrJSONObjectForKey( restaurant, kLocationIDKey )  integerValue];
        _user_id = [nilOrJSONObjectForKey( restaurant, @"user_id" ) integerValue];
        
        NSDictionary *location = nilOrJSONObjectForKey( restaurant, kLocationKey );
        if( location )
        {
            _latitude  = [nilOrJSONObjectForKey( location, kLatitudeKey  ) doubleValue];
            _longitude = [nilOrJSONObjectForKey( location, kLongitudeKey ) doubleValue];
        }
        
        _is_private       = [nilOrJSONObjectForKey( data, @"is_private" )       boolValue];
        _caller_follows   = [nilOrJSONObjectForKey( data, @"caller_follows" )   boolValue];
        _is_profile_owner = [nilOrJSONObjectForKey( data, @"is_profile_owner" ) boolValue];
        
        NSDictionary *dishes = nilOrJSONObjectForKey( data, @"dishes" );
        if( dishes )
        {
            _foodDishes     = [self dishesWithData:nilOrJSONObjectForKey( dishes, kFood )];
            _wineDishes     = [self dishesWithData:nilOrJSONObjectForKey( dishes, kWine )];
            _cocktailDishes = [self dishesWithData:nilOrJSONObjectForKey( dishes, kCocktail )];
        }
    }
    
    return self;
}

- (NSArray *)dishesWithData:(id)data
{
    NSMutableArray *dishes = [NSMutableArray array];
    
    for( NSDictionary *dish in data )
    {
        [dishes addObject:[DADish dishWithData:dish]];
    }
    
    return dishes;
}

@end