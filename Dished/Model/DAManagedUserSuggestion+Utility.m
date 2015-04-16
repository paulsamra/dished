//
//  DAManagedUserSuggestion+DAManagedUserSuggestion_Utility.m
//  Dished
//
//  Created by Ryan Khalili on 4/15/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

#import "DAManagedUserSuggestion+Utility.h"

@implementation DAManagedUserSuggestion (Utility)

+ (NSString *)entityName
{
    return NSStringFromClass( [self class] );
}

- (void)configureWithDictionary:(NSDictionary *)dictionary
{
    self.desc        = nilOrJSONObjectForKey( dictionary, kDescriptionKey );
    self.username    = nilOrJSONObjectForKey( dictionary, kUsernameKey );
    self.img_thumb   = nilOrJSONObjectForKey( dictionary, kImgThumbKey );
    self.user_type   = nilOrJSONObjectForKey( dictionary, kTypeKey );
    self.last_name   = nilOrJSONObjectForKey( dictionary, kLastNameKey );
    self.first_name  = nilOrJSONObjectForKey( dictionary, kFirstNameKey );
    
    self.following   = @(NO);
    self.dismissed   = @(NO);
    
    id reviews = nilOrJSONObjectForKey( dictionary, kReviewsKey );
    
    if( [reviews isKindOfClass:[NSArray class]] )
    {
        if( [reviews count] > 0 )
        {
            self.reviews = reviews;
        }
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.user_id = [formatter numberFromString:nilOrJSONObjectForKey( dictionary, kIDKey )];
}

@end