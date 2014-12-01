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
#import "AFOAuth2Manager.h"

#define kClientIDKey     @"client_id"
#define kClientSecretKey @"client_secret"
#define kAccessTokenKey  @"access_token"
#define kRefreshTokenKey @"refresh_token"
#define kExpirationDate  @"last_refresh"

static NSString *const kKeychainService = @"com.dishedapp.Dished";

#ifdef DEV
    static NSString *const kBaseAPIURL = @"http://54.67.63.46/v1/";
#elif defined( STAGE )
    static NSString *const kBaseAPIURL = @"http://54.215.184.64/v1/";
#else
    static NSString *const kBaseAPIURL = @"https://api.dishedapp.com/v1/";
#endif

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
        manager = [[DAAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseAPIURL]];
    });
    
    return manager;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if( self )
    {
        _isAuthenticating = NO;
        
        AFJSONResponseSerializer *responseSerializer = [JSONResponseSerializerWithData serializer];
        responseSerializer.readingOptions = NSJSONReadingAllowFragments;
        responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", nil];
        self.responseSerializer = responseSerializer;
        
        _sem   = dispatch_semaphore_create( 0 );
        _queue = dispatch_queue_create( "com.dishedapp.Dished.api", 0 );
        
        if( ![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] )
        {
            [SSKeychain deletePasswordForService:kKeychainService account:kClientSecretKey];
            [SSKeychain deletePasswordForService:kKeychainService account:kAccessTokenKey];
            [SSKeychain deletePasswordForService:kKeychainService account:kRefreshTokenKey];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"firstRun" forKey:@"firstRun"];
            [[NSUserDefaults standardUserDefaults] synchronize];
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
            NSString *errorDescription = nilOrJSONObjectForKey( errorResponse, @"error_description" );
            
            if( errorDescription && [errorDescription rangeOfString:@"refresh token"].location != NSNotFound )
            {
                errorType = eErrorTypeInvalidRefreshToken;
            }
            else if( [errorValue isEqualToString:kDataNonexistsError] )
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
            else if( [errorValue isEqualToString:kParamsInvalidError] )
            {
                errorType = eErrorTypeParamsInvalid;
            }
            else if( [errorValue isEqualToString:kContentPrivateError] )
            {
                errorType = eErrorTypeContentPrivate;
            }
        }
    }
    
    return errorType;
}

- (BOOL)isAuthenticated
{
    NSDate *expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:kExpirationDate];
    
    return [expirationDate compare:[NSDate date]] == NSOrderedAscending;
}

- (void)authenticate
{
    [self refreshAuthenticationWithCompletion:nil];
}

- (void)refreshAuthenticationWithCompletion:( void(^)( BOOL success ) )completion
{
    if( self.isAuthenticating )
    {
        dispatch_async( self.queue, ^
        {
            dispatch_async( dispatch_get_main_queue(), ^
            {
                if( completion )
                {
                    completion( [self isAuthenticated] );
                }
            });
        });
        
        return;
    }
    
    self.isAuthenticating = YES;
    
    dispatch_async( self.queue, ^
    {
        dispatch_async( dispatch_get_main_queue(), ^
        {
            NSDictionary *parameters = @{ kClientIDKey : self.clientID, kClientSecretKey : self.clientSecret,
                                          kRefreshTokenKey : self.refreshToken };
            
            [self POST:kAuthRefreshURL parameters:parameters
            success:^( NSURLSessionDataTask *task, id responseObject )
            {
                self.isAuthenticating = NO;
                
                self.accessToken  = responseObject[kAccessTokenKey];
                self.refreshToken = responseObject[kRefreshTokenKey];
                 
                [SSKeychain setPassword:self.accessToken  forService:kKeychainService account:kAccessTokenKey];
                [SSKeychain setPassword:self.refreshToken forService:kKeychainService account:kRefreshTokenKey];
                
                NSTimeInterval expiresTime = [responseObject[kExpiresKey] doubleValue];
                NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:expiresTime];
                
                [[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:kExpirationDate];
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
                 
                NSLog(@"%@", error);
                
                if( completion )
                {
                    completion( NO );
                }
                
                dispatch_semaphore_signal( self.sem );
            }];
        });
        
        dispatch_semaphore_wait( self.sem, DISPATCH_TIME_FOREVER );
    });
}

- (NSDictionary *)authenticatedParametersWithParameters:(NSDictionary *)parameters
{
    if( ![self isLoggedIn] )
    {
        return parameters;
    }
    
    NSMutableDictionary *authParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    authParameters[kAccessTokenKey] = self.accessToken;
    
    return authParameters;
}

- (void)requestAccessTokenWithUsername:(NSString *)username password:(NSString *)password completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *authParameters = @{ kClientIDKey : self.clientID, kClientSecretKey : self.clientSecret,
                                      kUsernameKey : username, kPasswordKey : password };
    
    [self POST:kAuthTokenURL parameters:authParameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        self.accessToken  = responseObject[kAccessTokenKey];
        self.refreshToken = responseObject[kRefreshTokenKey];
         
        [SSKeychain setPassword:self.accessToken  forService:kKeychainService account:kAccessTokenKey];
        [SSKeychain setPassword:self.refreshToken forService:kKeychainService account:kRefreshTokenKey];
         
        NSTimeInterval expiresTime = [responseObject[kExpiresKey] doubleValue];
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:expiresTime];
        
        [[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:kExpirationDate];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        completion( YES );
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        completion( NO );
    }];
}

- (void)registerUserWithUsername:(NSString *)username password:(NSString *)password firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email phoneNumber:(NSString *)phoneNumber birthday:(NSDate *)birthday completion:(void(^)( BOOL registered, BOOL loggedIn ))completion
{
    NSNumber *dobTimestamp = @( [birthday timeIntervalSince1970] );
    
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, kUsernameKey : username, kPasswordKey : password,
                                  kPhoneKey : phoneNumber, @"fname" : firstName, @"lname" : lastName, kEmailKey : email,
                                  kDateOfBirthKey : dobTimestamp };
    
    [self POST:kUsersURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        self.clientSecret = responseObject[kDataKey][kClientSecretKey];
        
        [SSKeychain setPassword:self.clientSecret forService:kKeychainService account:kClientSecretKey];
        
        [self requestAccessTokenWithUsername:username password:password completion:^( BOOL success )
        {
            if( completion )
            {
                completion( YES, success );
            }
        }];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"%@", error.userInfo[JSONResponseSerializerWithDataKey]);
        
        completion( NO, NO );
    }];
}

- (void)loginWithUser:(NSString *)user password:(NSString *)password completion:(void(^)( BOOL success, BOOL wrongUser, BOOL wrongPass ))completion
{
    NSString *userKey = kUsernameKey;
    
    if( [user rangeOfString:@"@"].location != NSNotFound )
    {
        userKey = kEmailKey;
    }
    
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, userKey : user, kPasswordKey : password };
    
    [self POST:kAuthAddURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSString *clientSecret = responseObject[kDataKey][kClientSecretKey];
        NSString *username = responseObject[kDataKey][kUsernameKey];
        [SSKeychain setPassword:clientSecret forService:kKeychainService account:kClientSecretKey];
        self.clientSecret = clientSecret;
        
        [self requestAccessTokenWithUsername:username password:password completion:^( BOOL success )
        {
            completion( success, NO, NO );
        }];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( errorType == eErrorTypeDataNonexists )
        {
            completion( NO, YES, NO );
        }
        else if( errorType == eErrorTypeParamsInvalid )
        {
            completion( NO, NO, YES );
        }
        else
        {
            completion( NO, NO, NO );
        }
    }];
}

- (void)logout
{
    [SSKeychain deletePasswordForService:kKeychainService account:kClientSecretKey];
    [SSKeychain deletePasswordForService:kKeychainService account:kAccessTokenKey];
    [SSKeychain deletePasswordForService:kKeychainService account:kRefreshTokenKey];
    
    self.accessToken  = nil;
    self.refreshToken = nil;
    self.clientSecret = nil;
}

- (void)requestPasswordResetCodeWithPhoneNumber:(NSString *)phoneNumber completion:(void(^)( BOOL success ))completion
{
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, @"phone" : phoneNumber };
    
    [self POST:@"auth/password" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        completion( YES );
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
                completion( YES, YES );
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

- (void)postNewReview:(DANewReview *)review withImage:(UIImage *)image completion:( void(^)( BOOL success, NSString *imageURL ) )completion
{
    dispatch_async( self.queue, ^
    {
        NSString *hashtagString = @"";
        for( DAHashtag *hashtag in review.hashtags )
        {
            hashtagString = [hashtagString stringByAppendingFormat:@"%d,", (int)hashtag.hashtag_id];
        }
        
        NSDictionary *baseParams = @{ kAccessTokenKey : self.accessToken, kCommentKey : review.comment,
                                      @"grade" : review.rating };
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:baseParams];
        
        if( review.price && review.price.length > 0 )
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
            else if( review.googleID )
            {
                [parameters setObject:review.googleID forKey:@"loc_google_id"];
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