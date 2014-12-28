//
//  DAContact.h
//  Dished
//
//  Created by Ryan Khalili on 12/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DAContact : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *email;

- (id)initWithName:(NSString *)name phone:(NSString *)phone email:(NSString *)email;
- (NSDictionary *)dictionaryRepresentation;

@end