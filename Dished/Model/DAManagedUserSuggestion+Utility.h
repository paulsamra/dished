//
//  DAManagedUserSuggestion+DAManagedUserSuggestion_Utility.h
//  Dished
//
//  Created by Ryan Khalili on 4/15/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import "DAManagedUserSuggestion.h"

@interface DAManagedUserSuggestion (Utility)

- (void)configureWithDictionary:(NSDictionary *)dictionary;
+ (NSString *)entityName;

@end