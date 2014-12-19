//
//  DATwitterManager.m
//  Dished
//
//  Created by Ryan Khalili on 7/28/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DATwitterManager.h"
#import "STTwitter.h"
#import "SSKeychain.h"

#define kConsumerKey    @"JrQfO95zB60qOdn0Ou7iPNbJQ"
#define kConsumerSecret @"0eKZpwaEEwbRKzngvU5DUQ90EStLqsxCtBcltg0IrDeujeqmyX"

#define kTwitterToken        @"dishedTwitterToken"
#define kTwitterTokenSecret  @"dishedTwitterTokenSecret"
#define kTwitterCurrentUser  @"dishedTwitterUsername"
#define kTwitterTokenAccount @"com.dishedapp.Dished"


typedef void ( ^DATwitterSuccessBlock )( BOOL );

@interface DATwitterManager()

@property (strong, nonatomic) STTwitterAPI *authTwitterAPI;
@property (strong, nonatomic) NSString *currentUsername;
@property (strong, nonatomic) NSString *oAuthToken;
@property (strong, nonatomic) NSString *oAuthTokenSecret;

@property (nonatomic) BOOL loggedIn;

@property (copy, nonatomic) DATwitterSuccessBlock currentCallbackBlock;

@end


@implementation DATwitterManager

+ (DATwitterManager *)sharedManager
{
    static DATwitterManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DATwitterManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    
    if( self )
    {
        NSString *token       = [SSKeychain passwordForService:kTwitterToken       account:kTwitterTokenAccount];
        NSString *tokenSecret = [SSKeychain passwordForService:kTwitterTokenSecret account:kTwitterTokenAccount];
        
        if( token && tokenSecret )
        {
            _oAuthToken       = token;
            _oAuthTokenSecret = tokenSecret;
            
            _authTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey consumerSecret:kConsumerSecret oauthToken:self.oAuthToken oauthTokenSecret:self.oAuthTokenSecret];
            
            _currentUsername = [SSKeychain passwordForService:kTwitterCurrentUser account:kTwitterTokenAccount];
            
            [self verifyStoredTokens];
        }
        else
        {
            _loggedIn = NO;
            _authTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey consumerSecret:kConsumerSecret];
        }
    }
    
    return self;
}

- (BOOL)isLoggedIn
{
    return self.loggedIn;
}

- (NSString *)currentUser
{
    return self.currentUsername;
}

- (void)setCurrentUsername:(NSString *)currentUsername
{
    _currentUsername = currentUsername;
    
    if( currentUsername )
    {
        [SSKeychain setPassword:currentUsername forService:kTwitterCurrentUser account:kTwitterTokenAccount];
    }
    else
    {
        [SSKeychain deletePasswordForService:kTwitterCurrentUser account:kTwitterTokenAccount];
    }
}

- (void)verifyStoredTokens
{
    [self.authTwitterAPI verifyCredentialsWithSuccessBlock:^( NSString *username )
    {
        self.loggedIn = YES;
        self.currentUsername = username;
    }
    errorBlock:^( NSError *error )
    {
        self.loggedIn = NO;
        self.currentUsername = nil;
    }];
}

- (void)loginWithCompletion:( void(^)( BOOL success ) )completion
{
    if( self.loggedIn )
    {
        completion( YES );
        return;
    }
    
    if( self.oAuthToken && self.oAuthTokenSecret )
    {
        [self.authTwitterAPI verifyCredentialsWithSuccessBlock:^( NSString *username )
        {
            self.loggedIn = YES;
            self.currentUsername = username;
            completion( YES );
        }
        errorBlock:^( NSError *error )
        {
            self.loggedIn = NO;
            self.currentUsername = nil;
            
            completion( NO );
        }];
        
        return;
    }
    
    [self.authTwitterAPI postTokenRequest:^( NSURL *url, NSString *oauthToken )
    {
        [self setCurrentCallbackBlock:completion];
        [[UIApplication sharedApplication] openURL:url];
    }
    authenticateInsteadOfAuthorize:NO forceLogin:@(YES) screenName:nil oauthCallback:kTwitterCallbackURL
    errorBlock:^( NSError *error )
    {
        completion( NO );
    }];
}

- (void)logout
{
    self.authTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey consumerSecret:kConsumerSecret];

    [SSKeychain deletePasswordForService:kTwitterToken account:kTwitterTokenAccount];
    [SSKeychain deletePasswordForService:kTwitterTokenSecret account:kTwitterTokenAccount];
    
    self.oAuthToken = nil;
    self.oAuthTokenSecret = nil;
    self.currentUsername = nil;
    self.loggedIn = NO;
}

- (void)processURL:(NSURL *)url
{
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [[url query] componentsSeparatedByString:@"&"];
    
    for( NSString *queryComponent in queryComponents )
    {
        NSArray *pair = [queryComponent componentsSeparatedByString:@"="];
        
        if( [pair count] != 2 ) continue;
        
        NSString *key   = pair[0];
        NSString *value = pair[1];
        
        queryDict[key] = value;
    }
    
    NSString *verifier = queryDict[@"oauth_verifier"];
    
    if( !verifier )
    {
        if( self.currentCallbackBlock )
        {
            self.currentCallbackBlock( NO );
            self.currentCallbackBlock = nil;
        }
    }
    
    [self.authTwitterAPI postAccessTokenRequestWithPIN:verifier
    successBlock:^( NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName )
    {
        self.oAuthToken       = oauthToken;
        self.oAuthTokenSecret = oauthTokenSecret;
        
        self.loggedIn = YES;
        self.currentUsername = screenName;
        
        [SSKeychain setPassword:oauthToken       forService:kTwitterToken       account:kTwitterTokenAccount];
        [SSKeychain setPassword:oauthTokenSecret forService:kTwitterTokenSecret account:kTwitterTokenAccount];
        
        if( self.currentCallbackBlock )
        {
            self.currentCallbackBlock( YES );
            self.currentCallbackBlock = nil;
        }
    }
    errorBlock:^( NSError *error )
    {
        self.loggedIn = NO;
        self.currentUsername = nil;
        
        if( self.currentCallbackBlock )
        {
            self.currentCallbackBlock( NO );
            self.currentCallbackBlock = nil;
        }
    }];
}

- (void)postDishTweetWithMessage:(NSString *)message imageURL:(NSString *)imageURL completion:(DATwitterSuccessBlock)completion
{
    if( !self.loggedIn )
    {
        if( completion )
        {
            completion( NO );
        }
        
        return;
    }
    
    NSURL *url = [NSURL URLWithString:imageURL];
    
    [self.authTwitterAPI postStatusUpdate:message inReplyToStatusID:nil mediaURL:url placeID:nil latitude:nil longitude:nil
    uploadProgressBlock:nil successBlock:^( NSDictionary *status )
    {
        if( completion )
        {
            completion( YES );
        }
    }
    errorBlock:^( NSError *error )
    {
        if( completion )
        {
            completion( NO );
        }
    }];
}

@end