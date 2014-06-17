//
//  JSONResponseSerializerWithData.h
//  Titan
//
//  Created by Ryan Khalili on 6/13/14.
//  Copyright (c) 2014 Titan Health & Security Technologies, Inc. All rights reserved.
//

#import "AFURLResponseSerialization.h"


/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";


@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end