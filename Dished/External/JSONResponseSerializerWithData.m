//
//  JSONResponseSerializerWithData.m
//  Titan
//
//  Created by Ryan Khalili on 6/13/14.
//  Copyright (c) 2014 Titan Health & Security Technologies, Inc. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error
{
	id JSONObject = [super responseObjectForResponse:response data:data error:error];
    
	if( *error != nil )
    {
		NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
                
		if( data == nil )
        {
            //userInfo[JSONResponseSerializerWithDataKey] = @"";
			//userInfo[JSONResponseSerializerWithDataKey] = [NSData data];
            userInfo[JSONResponseSerializerWithDataKey] = [NSDictionary dictionary];
		}
        else
        {
            //userInfo[JSONResponseSerializerWithDataKey] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			//userInfo[JSONResponseSerializerWithDataKey] = data;
                        
            NSError* err = nil;;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            if( err )
            {
                userInfo[JSONResponseSerializerWithDataKey] = [NSDictionary dictionary];
            }
            else
            {
                userInfo[JSONResponseSerializerWithDataKey] = json;
            }
		}
        
		NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
		(*error) = newError;
	}
    
	return (JSONObject);
}

@end