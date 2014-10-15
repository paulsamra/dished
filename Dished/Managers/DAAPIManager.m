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
#import "DAHashtag.h"
#import "SSKeychain.h"

#define kClientIDKey     @"client_id"
#define kClientSecretKey @"client_secret"
#define kAccessTokenKey  @"access_token"
#define kRefreshTokenKey @"refresh_token"
#define kLastRefreshKey  @"last_refresh"

static NSString *const kbaseAPIURL      = @"http://54.215.184.64/api/";
static NSString *const kKeychainService = @"com.dishedapp.Dished";


@interface DAAPIManager()

@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *clientSecret;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;

@property (nonatomic) BOOL                 isNetworkReachable;
@property (nonatomic) BOOL                 isAuthenticating;
@property (nonatomic) dispatch_queue_t     queue;
@property (nonatomic) dispatch_semaphore_t sem;

@end


@implementation DAAPIManager

+ (DAAPIManager *)sharedManager
{
    static DAAPIManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DAAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kbaseAPIURL]];
    });
    
    return manager;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if( self )
    {
        _isAuthenticating = NO;
        
        self.responseSerializer = [JSONResponseSerializerWithData serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
        
        _sem   = dispatch_semaphore_create( 0 );
        _queue = dispatch_queue_create( "com.dishedapp.Dished.api", 0 );
        
        if( ![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] )
        {
            [SSKeychain deletePasswordForService:kKeychainService account:kClientSecretKey];
            [SSKeychain deletePasswordForService:kKeychainService account:kAccessTokenKey];
            [SSKeychain deletePasswordForService:kKeychainService account:kRefreshTokenKey];
            
            [self createClientID];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"firstRun" forKey:@"firstRun"];
        }
        
        AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
        {
            [self networkReachabilityStatusChanged:( status != 0 ? YES : NO )];
        }];
        [reachabilityManager startMonitoring];
        
        NSLog(@"access: %@",  self.accessToken);
        NSLog(@"refresh: %@", self.refreshToken);
        NSLog(@"secret: %@",  self.clientSecret);
        NSLog(@"id: %@",      self.clientID);
    }
    
    return self;
}

- (void)networkReachabilityStatusChanged:(BOOL)reachable
{
    NSLog(@"%@", reachable ? @"network reachable" : @"network unreachable");
    self.isNetworkReachable = reachable;
    
    if( reachable )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkReachableKey object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkUnreachableKey object:nil];
    }
}

- (BOOL)networkIsReachable
{
    return self.isNetworkReachable;
}

+ (NSString *)errorResponseKey
{
    return JSONResponseSerializerWithDataKey;
}

+ (eErrorType)errorTypeForError:(NSError *)error
{
    if( error.code == NSURLErrorCancelled )
    {
        return eErrorTypeRequestCancelled;
    }
    
    if( error.code == NSURLErrorTimedOut )
    {
        return eErrorTypeTimeout;
    }
    
    eErrorType errorType = eErrorTypeUnknown;
    
    NSDictionary *errorResponse = [error.userInfo objectForKey:JSONResponseSerializerWithDataKey];
    
    if( [errorResponse isKindOfClass:[NSDictionary class]] )
    {
        id errorValue = errorResponse[kErrorKey];
        
        if( [errorValue isKindOfClass:[NSNumber class]] )
        {
            if( [errorValue integerValue] == 403 )
            {
                if( [errorResponse[@"error_description"] rangeOfString:@"Access token"].location != NSNotFound )
                {
                    errorType = eErrorTypeExpiredAccessToken;
                }
            }
        }
        else
        {
            if( [errorValue isEqualToString:kDataNonexistsError] )
            {
                errorType = eErrorTypeDataNonexists;
            }
            else if( [errorValue isEqualToString:kEmailExistsError] )
            {
                errorType = eErrorTypeEmailExists;
            }
            else if( [errorValue isEqualToString:kPhoneExistsError] )
            {
                errorType = eErrorTypePhoneExists;
            }
        }
    }
    
    return errorType;
}

- (BOOL)isAuthenticated
{
    NSDate *lastRefreshDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastRefreshKey];
    
    return !( [[NSDate date] timeIntervalSinceDate:lastRefreshDate] > 3600 );
}

- (void)authenticate
{
    [self authenticateWithCompletion:nil];
}

- (void)authenticateWithCompletion:( void (^)( BOOL success ) )completion
{
    if( ![self isLoggedIn] || !self.refreshToken || !self.clientSecret )
    {
        if( completion )
        {
            completion( NO );
        }
    }
    
    dispatch_async( self.queue, ^
    {
        dispatch_async( dispatch_get_main_queue(), ^
        {
            if( ![self isAuthenticated] )
            {
                self.isAuthenticating = YES;
                
                NSDictionary *parameters = @{ kClientIDKey : self.clientID, kClientSecretKey : self.clientSecret,
                                              kRefreshTokenKey : self.refreshToken };
                
                [self POST:@"auth/refresh" parameters:parameters
                success:^( NSURLSessionDataTask *task, id responseObject )
                {
                    self.isAuthenticating = NO;
                    
                    NSDictionary *auth = (NSDictionary *)responseObject;
                     
                    self.accessToken  = auth[kAccessTokenKey];
                    self.refreshToken = auth[kRefreshTokenKey];
                     
                    [SSKeychain setPassword:self.accessToken  forService:kKeychainService account:kAccessTokenKey];
                    [SSKeychain setPassword:self.refreshToken forService:kKeychainService account:kRefreshTokenKey];
                     
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastRefreshKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if( completion )
                    {
                        completion( YES );
                    }
                     
                    dispatch_semaphore_signal( self.sem );
                }
                failure:^( NSURLSessionDataTask *task, NSError *error )
                {
                    self.isAuthenticating = NO;
                    
                    NSLog(@"%@", error.localizedDescription);
                    
                    if( completion )
                    {
                        completion( NO );
                    }
                    
                    dispatch_semaphore_signal( self.sem );
                }];
            }
            else
            {
                if( completion )
                {
                    completion( YES );
                }
                
                dispatch_semaphore_signal( self.sem );
            }
        });
        
        dispatch_semaphore_wait( self.sem, DISPATCH_TIME_FOREVER );
    });
}

- (NSDictionary *)authenticatedParametersWithParameters:(NSDictionary *)parameters
{
    NSMutableDictionary *authParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    authParameters[kAccessTokenKey] = self.accessToken;
    
    return authParameters;
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
        clientSecret = responseObject[@"data"][kClientSecretKey];
        [SSKeychain setPassword:clientSecret forService:kKeychainService account:kClientSecretKey];
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error.userInfo[JSONResponseSerializerWithDataKey]);
        
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
                    NSDictionary *auth = (NSDictionary *)responseObject;
                    
                    self.accessToken  = auth[kAccessTokenKey];
                    self.refreshToken = auth[kRefreshTokenKey];
                    
                    [SSKeychain setPassword:self.accessToken  forService:kKeychainService account:kAccessTokenKey];
                    [SSKeychain setPassword:self.refreshToken forService:kKeychainService account:kRefreshTokenKey];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastRefreshKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    completion( YES, YES );
                }
                else
                {
                    completion( YES, NO );
                }
            }
            failure:^( NSURLSessionDataTask *task, NSError *error )
            {
                NSLog(@"%@", error.userInfo[JSONResponseSerializerWithDataKey]);
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
        NSDictionary *response = (NSDictionary *)responseObject;
        
        clientSecret = response[@"data"][kClientSecretKey];
        [SSKeychain setPassword:clientSecret forService:kKeychainService account:kClientSecretKey];
        
        userName = response[@"data"][@"username"];
        
        dispatch_group_leave( group );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error.localizedDescription);
        
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
                NSDictionary *auth = (NSDictionary *)responseObject;
                
                self.accessToken  = auth[kAccessTokenKey];
                self.refreshToken = auth[kRefreshTokenKey];
                
                [SSKeychain setPassword:self.accessToken  forService:kKeychainService account:kAccessTokenKey];
                [SSKeychain setPassword:self.refreshToken forService:kKeychainService account:kRefreshTokenKey];
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastRefreshKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                 
                completion( YES, badUser, badPass );
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

- (void)logout
{
    [SSKeychain deletePasswordForService:kKeychainService account:kAccessTokenKey];
    [SSKeychain deletePasswordForService:kKeychainService account:kRefreshTokenKey];
    
    self.accessToken  = nil;
    self.refreshToken = nil;
}

- (void)requestPasswordResetCodeWithPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL success ))completion
{
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber };
    
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
        completion( NO );
    }];
}

- (void)submitPasswordResetWithPin:(NSString *)pin phoneNumber:(NSString *)phoneNumber newPassword:(NSString *)password completion:(void(^)( BOOL pinValid, BOOL success ))completion
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter( group );
    
    __block BOOL pinSuccess = YES;
    
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber, @"pin" : pin };
    
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
        NSDictionary *parameters2 = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber, @"pin" : pin, @"password" : password };
        
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

- (NSURLSessionTask *)exploreLocationSearchTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude completion:( void(^)( id response, NSError *error ) )completion;
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"query" : query, @"longitude" : @(longitude), @"latitude" : @(latitude) };
    
    return [self GET:@"explore/locations" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( responseObject, nil );
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
            completion( nil, error );
        }
    }];
}

- (void)postNewReview:(DANewReview *)review withImage:(UIImage *)image completion:( void(^)( BOOL success, NSString *imageURL ) )completion
{
    dispatch_async( self.queue, ^
    {
        NSString *hashtagString = @"";
        for( DAHashtag *hashtag in review.hashtags )
        {
            hashtagString = [hashtagString stringByAppendingFormat:@"%d,", (int)hashtag.hashtag_id];
        }
        
        NSDictionary *baseParams = @{ kAccessTokenKey : self.accessToken, @"comment" : review.comment,
                                      @"grade" : review.rating };
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:baseParams];
        
        if( review.price.length > 0 )
        {
            if( [review.price characterAtIndex:0] == '$' )
            {
                review.price = [review.price substringFromIndex:1];
            }
            
            [parameters setObject:review.price forKey:@"price"];
        }
        
        if( hashtagString.length > 0 )
        {
            hashtagString = [hashtagString substringToIndex:hashtagString.length - 1];
            [parameters setObject:hashtagString forKey:@"hashtags"];
        }
        
        if( review.dishID != 0 )
        {
            [parameters setObject:@(review.dishID) forKey:@"dish_id"];
        }
        else if( review.locationID != 0 || review.googleID != 0 )
        {
            if( review.locationID != 0 )
            {
                [parameters setObject:@(review.locationID) forKey:@"loc_id"];
            }
            else if( review.googleID != 0 )
            {
                [parameters setObject:@(review.googleID) forKey:@"loc_google_id"];
            }
            
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
            NSString *imageAddress = responseObject[@"data"][@"img"][@"url"];
            completion( YES, imageAddress );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"failure: %@", error );
            completion( NO, nil );
        }];
    });
}

- (void)getExploreTabContentWithCompletion:( void(^)( id response, NSError *error ) )completion
{
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken };
        
        [self GET:@"hashtags/explore" parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( [responseObject[@"status"] isEqualToString:@"success"] )
            {
                completion( responseObject, nil );
            }
            else
            {
                completion( nil, nil );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Error getting Explore content: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (NSURLSessionTask *)exploreUsernameSearchTaskWithQuery:(NSString *)query competion:( void(^)( id response, NSError *error ) )completion
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"username" : query };
    
    return [self GET:@"explore/usernames" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( responseObject, nil );
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
            NSLog(@"Username search error: %@", error);
            completion( nil, error );
        }
    }];
}

- (NSURLSessionTask *)exploreDishesWithHashtagSearchTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion;
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"hashtag" : query,
                                  @"longitude" : @(longitude), @"latitude" : @(latitude),
                                  @"radius" : @(radius) };
    
    return [self GET:@"explore/dishes/hashtag" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
                
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( responseObject, nil );
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
            NSLog(@"Username search error: %@", error.localizedDescription);
            completion( nil, error );
        }
    }];
}

- (void)getEditorsPicksDishesWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion
{
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"longitude" : @(longitude),
                                      @"latitude" : @(latitude), @"radius" : @(radius) };
        
        [self GET:@"explore/dishes/editors_pick" parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            NSDictionary *response = (NSDictionary *)responseObject;
            
            if( [response[@"status"] isEqualToString:@"success"] )
            {
                completion( responseObject, nil );
            }
            else
            {
                completion( nil, nil );
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error)
        {
            NSLog(@"Editors Picks error: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getPopularDishesWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion
{
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"longitude" : @(longitude),
                                      @"latitude" : @(latitude), @"radius" : @(radius) };
        
        [self GET:@"explore/dishes/popular" parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            NSDictionary *response = (NSDictionary *)responseObject;
             
            if( [response[@"status"] isEqualToString:@"success"] )
            {
                completion( responseObject, nil );
            }
            else
            {
                completion( nil, nil );
            }
        }
        failure:^(NSURLSessionDataTask *task, NSError *error)
        {
            NSLog(@"Editors Picks error: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (NSURLSessionTask *)exploreDishAndLocationSuggestionsTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"query" : query,
                                  @"longitude" : @(longitude), @"latitude" : @(latitude),
                                  @"radius" : @(radius), @"auto_complete" : @(1) };
    
    return [self GET:@"explore/dishes_locations" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( responseObject, nil );
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
            NSLog(@"Error searching dishes and locations: %@", error.localizedDescription);
            completion( nil, error );
        }
    }];
}

- (NSURLSessionTask *)exploreHashtagSuggestionsTaskWithQuery:(NSString *)query completion:( void(^)( id response, NSError *error ) )completion
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"name" : query };
    
    return [self GET:@"hashtags" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *response = (NSDictionary *)responseObject;
        
        if( [response[@"status"] isEqualToString:@"success"] )
        {
            completion( responseObject, nil );
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
            NSLog(@"Error searching dishes and locations: %@", error.localizedDescription);
            completion( nil, error );
        }
    }];
}

- (void)exploreDishesWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"query" : query, @"longitude" : @(longitude),
                                      @"latitude" : @(latitude), @"radius" : @(radius), @"auto_complete" : @(0) };
        
        [self GET:@"explore/dishes" parameters:parameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( [responseObject[@"status"] isEqualToString:@"success"] )
            {
                completion( responseObject, nil );
            }
            else
            {
                completion( nil, nil );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Error searching dishes: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getFeedActivityWithLongitude:(double)longitude latitude:(double)latitude radius:(double)radius offset:(NSInteger)offset limit:(NSInteger)limit completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"longitude" : @(longitude),
                                      @"latitude" : @(latitude), @"radius" : @(radius), @"row_limit" : @(limit),
                                      @"row_offset" : @(offset) };
        
        [self GET:@"feed" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( [responseObject[@"status"] isEqualToString:@"success"] )
            {
                completion( responseObject, nil );
            }
            else
            {
                completion( nil, nil );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Error getting feed: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getCommentsForReviewID:(NSInteger)reviewID completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(reviewID) };
        
        [self GET:@"comments" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( [responseObject[@"status"] isEqualToString:@"success"] )
            {
                completion( responseObject, nil );
            }
            else
            {
                completion( nil, nil );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Error getting comments: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)deleteCommentWithID:(NSInteger)commentID completion:( void(^)( BOOL success ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(commentID) };
        
        [self POST:@"comments/delete" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to delete comment: %@", error.localizedDescription);
            completion( NO );
        }];
    });
}

- (void)flagCommentWithID:(NSInteger)commentID completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(commentID) };
    
    [self POST:@"comments/report" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
    {
        [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"Failed to flag comment: %@", error.localizedDescription);
        completion( NO );
    }];
}

- (void)createComment:(NSString *)comment forReviewID:(NSInteger)reviewID completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(reviewID), @"comment" : comment };
    
    [self POST:@"comments" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
    {
        [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"Failed to create comment: %@", error.localizedDescription);
        completion( NO );
    }];
}

- (void)yumReviewID:(NSInteger)reviewID completion:( void(^)( BOOL success ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(reviewID) };
        
        [self POST:@"reviews/yum" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( completion )
            {
                [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            if( completion )
            {
                NSLog(@"Failed to yum review: %@", error.localizedDescription);
                completion( NO );
            }
        }];
    });
}

- (void)unyumReviewID:(NSInteger)reviewID completion:( void(^)( BOOL success ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(reviewID) };
        
        [self POST:@"reviews/unyum" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( completion )
            {
                [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            if( completion )
            {
                NSLog(@"Failed to unyum review: %@", error.localizedDescription);
                completion( NO );
            }
        }];
    });
}

- (void)getProfileForReviewID:(NSInteger)reviewID completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(reviewID) };
        
        [self GET:@"reviews/profile" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get review profile: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getGlobalDishInfoForDishID:(NSInteger)dishID completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(dishID) };
        
        [self GET:@"dishes/profile" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get global dish profile: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getNewsNotificationsWithLimit:(NSInteger)limit offset:(NSInteger)offset completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"type" : @"user",
                                      @"row_limit" : @(limit), @"row_offset" : @(offset) };
        
        [self GET:@"users/news" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get news notifications: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getFollowingNotificationsWithLimit:(NSInteger)limit offset:(NSInteger)offset completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"type" : @"following",
                                      @"row_limit" : @(limit), @"row_offset" : @(offset) };
        
        [self GET:@"users/news" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get following notifications: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getUserProfileWithUserID:(NSInteger)userID completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(userID) };
        
        [self GET:@"users/profile" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get user profile info: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getUserFollowersWithUserID:(NSInteger)userID showRelations:(BOOL)showRelations completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(userID), @"relation" : @(showRelations) };
        
        [self POST:@"users/followers" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get user followers: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)getUserFollowingWithUserID:(NSInteger)userID showRelations:(BOOL)showRelations completion:( void(^)( id response, NSError *error ) )completion;
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(userID), @"relation" : @(showRelations) };
        
        [self POST:@"users/following" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get user following: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
}

- (void)followUserWithUserID:(NSInteger)userID completion:( void(^)( BOOL success ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(userID) };
        
        [self POST:@"users/follow" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( completion )
            {
                [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to follow user: %@", error.localizedDescription);
            
            if( completion )
            {
                completion( NO );
            }
        }];
    });
}

- (void)unfollowUserWithUserID:(NSInteger)userID completion:( void(^)( BOOL success ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"id" : @(userID) };
        
        [self POST:@"users/unfollow" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            if( completion )
            {
                [responseObject[@"status"] isEqualToString:@"success"] ? completion( YES ) : completion( NO );
            }
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to unfollow user: %@", error.localizedDescription);
            
            if( completion )
            {
                completion( NO );
            }
        }];
    });
}

- (void)getRestaurantProfileWithRestaurantID:(NSInteger)restaurantID completion:( void(^)( id response, NSError *error ) )completion
{
    [self authenticate];
    
    dispatch_async( self.queue, ^
    {
        NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, @"loc_id" : @(restaurantID) };
        
        [self GET:@"restaurants/profile" parameters:parameters success:^( NSURLSessionDataTask *task, id responseObject )
        {
            [responseObject[@"status"] isEqualToString:@"success"] ? completion( responseObject, nil ) : completion( nil, nil );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Failed to get restaurant profile: %@", error.localizedDescription);
            completion( nil, error );
        }];
    });
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

- (NSString *)refreshToken
{
    if( !_refreshToken )
    {
        _refreshToken = [SSKeychain passwordForService:kKeychainService account:kRefreshTokenKey];
    }
    
    return _refreshToken;
}

- (NSString *)accessToken
{
    if( !_accessToken )
    {
        _accessToken = [SSKeychain passwordForService:kKeychainService account:kAccessTokenKey];
    }
    
    return _accessToken;
}

- (NSString *)clientSecret
{
    if( !_clientSecret )
    {
        _clientSecret = [SSKeychain passwordForService:kKeychainService account:kClientSecretKey];
    }
    
    return _clientSecret;
}

- (void)createClientID
{
    NSString *newClientID = [[NSUUID UUID] UUIDString];
    [SSKeychain setPassword:newClientID forService:kKeychainService account:kClientIDKey];
    
    _clientID = newClientID;
}
    
- (NSString *)clientID
{
    if( _clientID )
    {
        return _clientID;
    }
    
    _clientID = [SSKeychain passwordForService:kKeychainService account:kClientIDKey];
    
    if( !_clientID )
    {
        [self createClientID];
    }
    
    return _clientID;
}

@end