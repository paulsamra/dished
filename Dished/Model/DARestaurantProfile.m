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
        
        _name      = nilOrJSONObjectForKey( restaurant, @"name" );
        _phone     = nilOrJSONObjectForKey( restaurant, @"phone" );
        _username  = nilOrJSONObjectForKey( restaurant, @"username" );
        _img_thumb = nilOrJSONObjectForKey( restaurant, @"img_thumb" );
        _avg_grade = nilOrJSONObjectForKey( restaurant, @"avg_grade" );
        
        _loc_id  = [nilOrJSONObjectForKey( restaurant, @"loc_id" )  integerValue];
        _user_id = [nilOrJSONObjectForKey( restaurant, @"user_id" ) integerValue];
        
        NSDictionary *location = nilOrJSONObjectForKey( restaurant, @"location" );
        _latitude  = [nilOrJSONObjectForKey( location, @"latitude"  ) doubleValue];
        _longitude = [nilOrJSONObjectForKey( location, @"longitude" ) doubleValue];
        
        _caller_follows   = [nilOrJSONObjectForKey( data, @"caller_follows" )   boolValue];
        _is_profile_owner = [nilOrJSONObjectForKey( data, @"is_profile_owner" ) boolValue];
        
        NSDictionary *dishes = nilOrJSONObjectForKey( data, @"dishes" );
        _foodDishes     = [self dishesWithData:nilOrJSONObjectForKey( dishes, @"food" )];
        _wineDishes     = [self dishesWithData:nilOrJSONObjectForKey( dishes, @"wine" )];
        _cocktailDishes = [self dishesWithData:nilOrJSONObjectForKey( dishes, @"cocktail" )];
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