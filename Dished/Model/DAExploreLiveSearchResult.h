//
//  DAExploreSearchResult.h
//  Dished
//
//  Created by Ryan Khalili on 8/4/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum eExploreSearchResultType
{
    eUsernameSearchResult,
    eHashtagSearchResult,
    eLocationSearchResult,
    eDishSearchResult
} eExploreSearchResultType;


@interface DAExploreLiveSearchResult : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *rating;
@property (copy, nonatomic) NSString *dishType;

@property (nonatomic) NSInteger                resultID;
@property (nonatomic) eExploreSearchResultType resultType;


+ (DAExploreLiveSearchResult *)liveSearchResultWithData:(id)data type:(eExploreSearchResultType)type;

@end