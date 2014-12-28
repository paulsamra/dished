//
//  DAContact.m
//  Dished
//
//  Created by Ryan Khalili on 12/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAContact.h"


@implementation DAContact

- (id)initWithName:(NSString *)name phone:(NSString *)phone email:(NSString *)email
{
    if( self = [super init] )
    {
        _name = name;
        _email = email;
        _phone = phone;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if( self.name )
    {
        dict[kNameKey] = self.name;
    }
    
    if( self.phone )
    {
        dict[kPhoneKey] = self.phone;
    }
    
    if( self.email )
    {
        dict[kEmailKey] = self.email;
    }
    
    return dict;
}

@end