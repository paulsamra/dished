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
    
    searchResult.name       = type == eUsernameSearchResult ? data[@"username"] : data[@"name"];
    searchResult.resultID   = [data[@"id"] integerValue];
    searchResult.resultType = type;
    
    if( type == eDishSearchResult )
    {
        searchResult.dishType = data[@"type"];
    }
    
    return searchResult;
}

@end