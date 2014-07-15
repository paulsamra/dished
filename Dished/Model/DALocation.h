//
//  DALocation.h
//  Dished
//
//  Created by Ryan Khalili on 7/11/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DALocation : NSManagedObject

@property (nonatomic, retain) NSString * streetNum;
@property (nonatomic, retain) NSString * streetName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * streetType;
@property (nonatomic, retain) NSString * zip;
@property (nonatomic, retain) NSString * name;

@end