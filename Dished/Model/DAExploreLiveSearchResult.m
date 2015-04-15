//
//  DAExploreSearchResult.m
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAExploreLiveSearchResult.h"


@implementation DAExploreLiveSearchResult

+ (DAExploreLiveSearchResult *)liveSearchResultWithData:(id)data type:(eExploreSearchResultType)type
{
    DAExploreLiveSearchResult *searchResult = [[DAExploreLiveSearchResult alloc] init];
    
    if( type == eUsernameSearchResult )
    {
        searchResult.username = nilOrJSONObjectForKey( data, kUsernameKey );
        
        NSString *firstName = nilOrJSONObjectForKey( data, kFirstNameKey );
        NSString *lastName  = nilOrJSONObjectForKey( data, kLastNameKey  );
        searchResult.name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        
        searchResult.img_thumb  = nilOrJSONObjectForKey( data, kImgThumbKey );
    }
    else
    {
        searchResult.name = nilOrJSONObjectForKey( data, kNameKey );
    }
    
    searchResult.resultID   = [data[kIDKey] integerValue];
    searchResult.resultType = type;
    
    if( type == eDishSearchResult )
    {
        searchResult.dishType = data[kTypeKey];
    }
    
    return searchResult;
}

@end