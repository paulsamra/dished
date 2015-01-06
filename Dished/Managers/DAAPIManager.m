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
#define kExpirationDate  @"last_refresh"

#ifdef DEV
    static NSString *const kBaseAPIURL = @"http://54.67.63.46/v1/";
    static NSString *const kKeychainService = @"com.dishedapp.Dished-DEV";
#elif defined( STAGE )
    static NSString *const kBaseAPIURL = @"http://54.215.184.64/v1/";
    static NSString *const kKeychainService = @"com.dishedapp.Dished-STAGE";
#else
    static NSString *const kBaseAPIURL = @"https://api.dishedapp.com/v1/";
    static NSString *const kKeychainService = @"com.dishedapp.Dished";
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
            [self logout];
            
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
        
        NSString *errorDescription = nilOrJSONObjectForKey( errorResponse, @"error_description" );
        
        if( errorDescription && [errorDescription rangeOfString:@"refresh token"].location != NSNotFound )
        {
            errorType = eErrorTypeInvalidRefreshToken;
        }
        else if( [errorValue isKindOfClass:[NSNumber class]] )
        {
            if( [errorValue integerValue] == 403 )
            {
                if( [errorResponse[@"error_description"] rangeOfString:@"Access token"].location != NSNotFound )
                {
                    errorType = eErrorTypeExpiredAccessToken;
                }
            }
        }
        else if( [errorValue isKindOfClass:[NSString class]] )
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
            else if( [errorValue isEqualToString:kUsernameExistsError] )
            {
                errorType = eErrorTypeUsernameExists;
            }
            else if( [errorValue isEqualToString:kInvalidUsernameError] )
            {
                errorType = eErrorTypeInvalidUsername;
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
    
    return [expirationDate compare:[NSDate date]] == NSOrderedDescending;
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

- (NSURLSessionTask *)GETRequest:(NSString *)url
                  withParameters:(NSDictionary *)parameters
                         success:(RequestSuccessBlock)success
                         failure:(RequestFailureBlock)failure
{
    parameters = [self authenticatedParametersWithParameters:parameters];
    
    return [self GET:url parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        if( success )
        {
            success( responseObject );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [self.class errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [self refreshAuthenticationWithCompletion:^( BOOL success )
            {
                if( failure )
                {
                    failure( error, success );
                }
            }];
        }
        else
        {
            if( failure )
            {
                failure( error, NO );
            }
        }
    }];
}

- (NSURLSessionTask *)POSTRequest:(NSString *)url
                   withParameters:(NSDictionary *)parameters
                          success:( void(^)( id response ) )success
                          failure:( void(^)( NSError *error, BOOL shouldRetry ) )failure
{
    parameters = [self authenticatedParametersWithParameters:parameters];
    
    return [self POST:url parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        if( success )
        {
            success( responseObject );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [self.class errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [self refreshAuthenticationWithCompletion:^( BOOL success )
            {
                if( failure )
                {
                    failure( error, success );
                }
            }];
        }
        else
        {
            if( failure )
            {
                failure( error, NO );
            }
        }
    }];
}

- (NSURLSessionTask *)POSTRequest:(NSString *)url
                   withParameters:(NSDictionary *)parameters
        constructingBodyWithBlock:(void (^)( id <AFMultipartFormData> formData ) )block
                          success:(RequestSuccessBlock)success
                          failure:(RequestFailureBlock)failure
{
    parameters = [self authenticatedParametersWithParameters:parameters];
    
    return [self POST:url parameters:parameters constructingBodyWithBlock:block
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        if( success )
        {
            success( responseObject );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        if( [self.class errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [self refreshAuthenticationWithCompletion:^( BOOL success )
            {
                if( failure )
                {
                    failure( error, success );
                }
            }];
        }
        else
        {
            if( failure )
            {
                failure( error, NO );
            }
        }
    }];
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
        NSLog(@"Error registering: %@", error);
        
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
            if( completion )
            {
                completion( success, NO, NO );
            }
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

- (void)requestFacebookAccessTokenWithFacebookID:(NSString *)facebookID completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, kClientSecretKey : self.clientSecret,
                                  @"fb_user_id" : facebookID };
    
    [self POST:@"auth/token/facebook" parameters:parameters
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

- (void)loginWithFacebookUserID:(NSString *)facebookID completion:( void(^)( BOOL success, BOOL accountExists ) )completion
{
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, @"fb_user_id" : facebookID };
    
    [self POST:@"auth/login/facebook" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSString *clientSecret = responseObject[kDataKey][kClientSecretKey];
        [SSKeychain setPassword:clientSecret forService:kKeychainService account:kClientSecretKey];
        self.clientSecret = clientSecret;
        
        [self requestFacebookAccessTokenWithFacebookID:facebookID completion:^( BOOL success )
        {
            completion( success, YES );
        }];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( errorType == eErrorTypeDataNonexists )
        {
            completion( NO, NO );
        }
        else
        {
            NSLog(@"%@", error);
            completion( NO, YES );
        }
    }];
}

- (void)registerFacebookUserWithUserID:(NSString *)facebookID Username:(NSString *)username
                             firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email
                           phoneNumber:(NSString *)phoneNumber birthday:(NSDate *)birthday imageURL:(NSString *)imageURL
                            completion:( void(^)( BOOL registered, BOOL loggedIn ) )completion
{
    NSNumber *dobTimestamp = @( [birthday timeIntervalSince1970] );

    NSDictionary *parameters = @{ kClientIDKey : self.clientID, @"reg_type" : @"facebook", @"reg_id" : facebookID, @"reg_name" : username,
                                  kUsernameKey : username, kPhoneKey : phoneNumber, @"image_url" : imageURL,
                                  kPasswordKey : [self randomAlphanumericStringWithLength:8], @"fname" : firstName, @"lname" : lastName,
                                  kEmailKey : email, kDateOfBirthKey : dobTimestamp };
    
    [self POST:kUsersURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSString *clientSecret = responseObject[kDataKey][kClientSecretKey];
        [SSKeychain setPassword:clientSecret forService:kKeychainService account:kClientSecretKey];
        self.clientSecret = clientSecret;
        
        [self requestFacebookAccessTokenWithFacebookID:facebookID completion:^( BOOL success )
        {
            if( completion )
            {
                completion( YES, success );
            }
        }];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        NSLog(@"Error registering with Facebook: %@", error);
        
        completion( NO, NO );
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
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, kPhoneKey : phoneNumber };
    
    [self POST:kAuthPasswordURL parameters:parameters
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
    NSDictionary *parameters = @{ kClientIDKey : self.clientID, kPhoneKey : phoneNumber, @"pin" : pin };
    
    [self POST:kAuthPasswordURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        NSDictionary *nextParameters = @{ kClientIDKey : self.clientID, kPhoneKey : phoneNumber, @"pin" : pin, kPasswordKey : password };
        
        [self POST:kAuthPasswordURL parameters:nextParameters
        success:^( NSURLSessionDataTask *task, id responseObject )
        {
            completion( YES, YES );
        }
        failure:^( NSURLSessionDataTask *task, NSError *error )
        {
            NSLog(@"Error sending reset password pin: %@", error);
             
            completion( YES, NO );
        }];
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        completion( NO, NO );
    }];
}

- (NSURLSessionTask *)exploreDishAndLocationSuggestionsTaskWithQuery:(NSString *)query longitude:(double)longitude latitude:(double)latitude radius:(double)radius completion:( void(^)( id response, NSError *error ) )completion
{
    NSDictionary *parameters = @{ kAccessTokenKey : self.accessToken, kQueryKey : query,
                                  kLongitudeKey : @(longitude), kLatitudeKey : @(latitude),
                                  kRadiusKey : @(radius), @"auto_complete" : @(1) };
    
    return [self GET:@"explore/dishes_locations" parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        if( completion )
        {
            completion( responseObject, nil );
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

- (NSString *)randomAlphanumericStringWithLength:(NSUInteger)length
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    
    NSMutableString *string = [NSMutableString stringWithCapacity:length];
    
    for( NSUInteger i = 0U; i < length; i++ )
    {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [string appendFormat:@"%C", c];
    }
    
    return string;
}

@end