//
//  DAAPIManager.m
//  Dished
//
//  Created by Ryan Khalili on 6/7/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DAAPIManager.h"
#import "JSONResponseSerializerWithData.h"
#import "DALocationManager.h"

#define kClientIDKey     @"client_id"
#define kClientSecretKey @"client_secret"
#define kAccessTokenKey  @"access_token"
#define kRefreshTokenKey @"refresh_token"

static NSString *const baseAPIURL = @"http://54.215.184.64/api/";


@interface DAAPIManager()

@property (strong, nonatomic) NSString *clientID;

@end


@implementation DAAPIManager

+ (DAAPIManager *)sharedManager
{
    static DAAPIManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DAAPIManager alloc] initWithBaseURL:[NSURL URLWithString:baseAPIURL]];
    });
    
    return manager;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if( self )
    {
        self.responseSerializer = [JSONResponseSerializerWithData serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
    }
    
    return self;
}

- (NSString *)errorResponseKey
{
    return JSONResponseSerializerWithDataKey;
}

- (void)checkAvailabilityOfEmail:(NSString *)email completion:(void(^)( BOOL available, NSError *error ))completion
{
    NSDictionary *parameters = @{ @"email" : email };
    
    [self GET:@"users/availability/email" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
          
        if( response.statusCode == 200 )
        {
            completion( YES, nil );
        }
        else
        {
            completion( NO, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error);
        
        NSDictionary *errorResponse = error.userInfo[JSONResponseSerializerWithDataKey];
        
        if( [errorResponse[@"error"] isEqualToString:@"email_exists"] )
        {
            completion( NO, nil );
        }
        else
        {
            completion( NO, error );
        }
    }];
}

- (void)checkAvailabilityOfPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL available, NSError *error ))completion
{
    NSDictionary *parameters = @{ @"phone" : phoneNumber };
    
    [self GET:@"users/availability/phone" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        if( response.statusCode == 200 )
        {
            completion( YES, nil );
        }
        else
        {
            completion( NO, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error);
        
        NSDictionary *errorResponse = error.userInfo[JSONResponseSerializerWithDataKey];
        
        if( [errorResponse[@"error"] isEqualToString:@"phone_exists"] )
        {
            completion( NO, nil );
        }
        else
        {
            completion( NO, error );
        }
    }];
}

- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber birthday:(NSDate *)birthday completion:(void(^)( BOOL registered, BOOL loggedIn ))completion
{
    dispatch_group_t group = dispatch_group_create();
    
    __block NSString *clientSecret = nil;
    
    dispatch_group_enter( group );
    
    NSNumber *dobTimestamp = @( [birthday timeIntervalSince1970] );
    
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, @"username" : username, @"password" : password,
                                  @"phone" : phoneNumber, @"fname" : firstName, @"lname" : lastName, @"email" : email,
                                  @"dob" : dobTimestamp };
    
    [self POST:@"users" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSLog(@"%@", responseObject);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        if( response.statusCode == 200 )
        {
            NSDictionary *response = (NSDictionary *)responseObject;
            
            clientSecret = response[@"data"][kClientSecretKey];
            
            [[NSUserDefaults standardUserDefaults] setObject:clientSecret forKey:kClientSecretKey];
        }
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error);
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        if( clientSecret )
        {
            NSDictionary *authParameters = @{ kClientIDKey : self.clientID, kClientSecretKey : clientSecret,
                                              @"username" : username, @"password" : password };
            
            [self POST:@"auth/token" parameters:authParameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                
                if( response.statusCode == 200 )
                {
                    NSDictionary *response = (NSDictionary *)responseObject;
                    
                    [[NSUserDefaults standardUserDefaults] setObject:response[kAccessTokenKey] forKey:kAccessTokenKey];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:response[kRefreshTokenKey] forKey:kRefreshTokenKey];
                    
                    completion( YES, YES );
                }
                else
                {
                    completion( YES, NO );
                }
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                NSLog(@"%@", error);
                completion( YES, NO );
            }];
        }
        else
        {
            completion( NO, NO );
        }
    });
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void(^)( BOOL success, BOOL wrongUser, BOOL wrongPass ))completion
{
    dispatch_group_t group = dispatch_group_create();

    __block NSString *clientSecret = nil;
    __block NSString *userName = nil;
    __block BOOL badUser = NO;
    __block BOOL badPass = NO;
    
    dispatch_group_enter( group );
    
    NSString *userKey = @"username";
    
    if( [user rangeOfString:@"@"].location != NSNotFound )
    {
        userKey = @"email";
    }
    
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, userKey : user, @"password" : password };
    
    [self POST:@"auth/add" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        if( response.statusCode == 200 )
        {
            NSDictionary *response = (NSDictionary *)responseObject;
            
            clientSecret = response[@"data"][kClientSecretKey];
            userName = response[@"data"][@"username"];
            
            [[NSUserDefaults standardUserDefaults] setObject:clientSecret forKey:kClientSecretKey];
        }
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error);
        
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        
        if( response.statusCode == 400 )
        {
            NSDictionary *failResponse = error.userInfo[JSONResponseSerializerWithDataKey];
            
            if( [failResponse[@"error"] isEqualToString:@"data_nonexists"] )
            {
                badUser = YES;
            }
            else if( [failResponse[@"error"] isEqualToString:@"params_invalid"] )
            {
                badPass = YES;
            }
        }
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        if( clientSecret )
        {
            NSDictionary *authParameters = @{ kClientIDKey : self.clientID, kClientSecretKey : clientSecret,
                                              @"username" : userName, @"password" : password };
            
            [self POST:@"auth/token" parameters:authParameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                 
                if( response.statusCode == 200 )
                {
                    NSDictionary *response = (NSDictionary *)responseObject;
                     
                    [[NSUserDefaults standardUserDefaults] setObject:response[kAccessTokenKey] forKey:kAccessTokenKey];
                    [[NSUserDefaults standardUserDefaults] setObject:response[kRefreshTokenKey] forKey:kRefreshTokenKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                     
                    completion( YES, badUser, badPass );
                }
                else
                {
                    completion( NO, badUser, badPass );
                }
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                NSLog(@"%@", error);
                
                completion( NO, badUser, badPass );
            }];
        }
        else
        {
            completion( NO, badUser, badPass );
        }
    });
}

- (void)requestPasswordResetCodeWithPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL success ))completion
{
    NSDictionary *parameters = @{ @"phone" : phoneNumber };
    
    if( [self hasClientID] )
    {
        parameters = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber };
    }
    
    [self POST:@"auth/password" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( YES );
        }
        else
        {
            completion( NO );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error);
        completion( NO );
    }];
}

- (void)submitPasswordResetWithPin:(NSString *)pin phoneNumber:(NSString *)phoneNumber newPassword:(NSString *)password completion:(void(^)( BOOL pinValid, BOOL success ))completion
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter( group );
    
    __block BOOL pinSuccess = YES;
    
    NSDictionary *parameters = @{ @"phone" : phoneNumber, @"pin" : pin };
    
    if( [self hasClientID] )
    {
        parameters = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber, @"pin" : pin };
    }
    
    [self POST:@"auth/password" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            pinSuccess = YES;
        }
        else
        {
            pinSuccess = NO;
        }
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error);
        pinSuccess = NO;
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        NSDictionary *parameters2 = @{ @"phone" : phoneNumber, @"pin" : pin, @"password" : password };
        
        if( [self hasClientID] )
        {
            parameters2 = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber, @"pin" : pin, @"password" : password };
        }
        
        if( pinSuccess )
        {
            [self POST:@"auth/password" parameters:parameters2
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                NSDictionary *response = responseObject;
                
                if( [response[@"status"] isEqualToString:@"success"] )
                {
                    completion( YES, YES );
                }
                else
                {
                    completion( YES, NO );
                }
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                NSLog(@"%@", error);
                
                completion( YES, NO );
            }];
        }
        else
        {
            completion( NO, NO );
        }
    });
}

- (void)getPositiveHashtagsForDishType:(NSString *)dishType completion:( void(^)( NSArray *hashtags, NSError *error ) )completion
{
    if( ![self accessToken] )
    {
        completion( nil, nil );
        return;
    }
    
    NSDictionary *parameters = @{ kAccessTokenKey : [self accessToken], @"dish_type" : dishType, @"tag_type" : @"rev_p" };
    
    [self GET:@"hashtags" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            NSArray *hashtags = response[@"data"];
            
            NSMutableArray *newHashtags = [NSMutableArray array];
            
            for( NSDictionary *hashtag in hashtags )
            {
                DAHashtag *newHashtag = [[DAHashtag alloc] init];
                newHashtag.name = hashtag[@"name"];
                newHashtag.hashtagID = hashtag[@"id"];
                
                [newHashtags addObject:newHashtag];
            }
            
            completion( [newHashtags copy], nil );
        }
        else
        {
            completion( nil, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"Error getting positive hashtags: %@", error.localizedDescription);
        completion( nil, error );
    }];
}

- (void)getNegativeHashtagsForDishType:(NSString *)dishType completion:( void(^)( NSArray *hashtags, NSError *error ) )completion;
{
    if( ![self accessToken] )
    {
        completion( nil, nil );
        return;
    }
    
    NSDictionary *parameters = @{ kAccessTokenKey : [self accessToken], @"dish_type" : dishType, @"tag_type" : @"rev_n" };
    
    [self GET:@"hashtags" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            NSArray *hashtags = response[@"data"];
            
            NSMutableArray *newHashtags = [NSMutableArray array];
            
            for( NSDictionary *hashtag in hashtags )
            {
                DAHashtag *newHashtag = [[DAHashtag alloc] init];
                newHashtag.name = hashtag[@"name"];
                newHashtag.hashtagID = hashtag[@"id"];
                
                [newHashtags addObject:newHashtag];
            }
            
            completion( [newHashtags copy], nil );
        }
        else
        {
            completion( nil, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"Error getting negative hashtags: %@", error.localizedDescription);
        completion( nil, error );
    }];
}

- (NSURLSessionTask *)dishTitleSuggestionTaskWithQuery:(NSString *)query dishType:(NSString *)dishType completion:( void(^)( id responseData, NSError *error ) )completion
{
    if( ![self accessToken] )
    {
        completion( nil, nil );
        return nil;
    }
    
    NSDictionary *parameters = @{ kAccessTokenKey : [self accessToken], @"name" : query, @"type" : dishType };
    
    return [self GET:@"dishes/search" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( response[@"data"], nil );
        }
        else
        {
            completion( nil, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( error.code != -999 )
        {
            NSLog(@"Error getting dish name suggestions: %@", error );
            completion( nil, error );
        }
    }];
}

- (NSURLSessionTask *)locationSearchTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude completion:( void(^)( id responseData, NSError *error ) )completion;
{
    if( ![self accessToken] )
    {
        completion( nil, nil );
        return nil;
    }
    
    NSDictionary *parameters = @{ kAccessTokenKey : [self accessToken], @"query" : query, @"longitude" : @(longitude), @"latitude" : @(latitude) };
    
    return [self GET:@"explore/locations" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( response[@"data"][@"locations"], nil );
        }
        else
        {
            completion( nil, nil );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( error.code != -999 )
        {
            NSLog(@"Error searching for locations: %@", error);
            completion( nil, error );
        }
    }];
}

- (void)postNewReview:(DANewReview *)review withImage:(UIImage *)image completion:( void(^)( BOOL success ) )completion
{
    NSString *hashtagString = @"";
    for( DAHashtag *hashtag in review.hashtags )
    {
        hashtagString = [hashtagString stringByAppendingFormat:@"%@,", hashtag.hashtagID];
    }
    
    if( [review.price characterAtIndex:0] == '$' )
    {
        review.price = [review.price substringFromIndex:1];
    }
    
    NSDictionary *baseParams = @{ kAccessTokenKey : [self accessToken], @"comment" : review.comment,
                                  @"price" : review.price, @"grade" : review.rating };
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:baseParams];
    
    if( hashtagString.length > 0 )
    {
        hashtagString = [hashtagString substringToIndex:hashtagString.length - 1];
        [parameters setObject:hashtagString forKey:@"hashtags"];
    }
    
    if( review.dishID.length > 0 )
    {
        [parameters setObject:review.dishID forKey:@"dish_id"];
    }
    else if( review.locationID.length > 0 )
    {
        [parameters setObject:review.locationID forKey:@"loc_id"];
        
        [parameters setObject:review.type forKey:@"type"];
        [parameters setObject:review.title forKey:@"title"];
    }
    else
    {
        [parameters setObject:review.locationName forKey:@"loc_name"];
        [parameters setObject:@(review.locationLongitude) forKey:@"loc_longitude"];
        [parameters setObject:@(review.locationLatitude) forKey:@"loc_latitude"];
        [parameters setObject:review.locationStreetNum forKey:@"loc_street_number"];
        [parameters setObject:review.locationStreetName forKey:@"loc_street"];
        [parameters setObject:review.locationCity forKey:@"loc_city"];
        [parameters setObject:review.locationState forKey:@"loc_state"];
        [parameters setObject:review.locationZip forKey:@"loc_zip"];
        
        [parameters setObject:review.type forKey:@"type"];
        [parameters setObject:review.title forKey:@"title"];
    }
    
    NSLog(@"%@", parameters);
    
    [self POST:@"reviews" parameters:parameters
    constructingBodyWithBlock:^( id<AFMultipartFormData> formData )
    {
        if( image )
        {
            float compression = 0.8;
            NSData *imageData = UIImageJPEGRepresentation( image, compression );
            int maxFileSize = 2000000;
            while( [imageData length] > maxFileSize )
            {
                compression -= 0.1;
                imageData = UIImageJPEGRepresentation( image, compression );
            }
            
            [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.jpeg" mimeType:@"image/jpeg"];
        }
    }
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSLog(@"success");
        NSLog(@"%@", responseObject);
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"failure: %@", error );
    }];
}

- (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenKey];
}

- (BOOL)isLoggedIn
{
    if( [self accessToken] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString *)clientSecret
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kClientSecretKey];
}
    
- (NSString *)clientID
{
    if( _clientID )
    {
        return _clientID;
    }
    
    _clientID = [[NSUserDefaults standardUserDefaults] objectForKey:kClientIDKey];
    
    if( !_clientID )
    {
        NSString *newClientID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:newClientID forKey:kClientIDKey];
        
        _clientID = newClientID;
    }
    
    return _clientID;
}
    
- (BOOL)hasClientID
{
    if( [[NSUserDefaults standardUserDefaults] objectForKey:kClientIDKey] )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end