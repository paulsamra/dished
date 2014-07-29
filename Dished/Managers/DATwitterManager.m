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
#define kTwitterTokenAccount @"com.dishedapp.Dished"

#define kTwitterCallbackURL  @"dishedapp://twitterCallback"


typedef void ( ^DATwitterSuccessBlock )( BOOL );

@interface DATwitterManager()

@property (strong, nonatomic) STTwitterAPI *authTwitterAPI;
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
            self.oAuthToken       = token;
            self.oAuthTokenSecret = tokenSecret;
            
            _authTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey consumerSecret:kConsumerSecret oauthToken:self.oAuthToken oauthTokenSecret:self.oAuthTokenSecret];
            
            [self verifyStoredTokens];
        }
        else
        {
            _authTwitterAPI = [STTwitterAPI twitterAPIWithOAuthConsumerKey:kConsumerKey consumerSecret:kConsumerSecret];
        }
    }
    
    return self;
}

- (BOOL)isLoggedIn
{
    return self.loggedIn;
}

- (void)verifyStoredTokens
{
    [self.authTwitterAPI verifyCredentialsWithSuccessBlock:^( NSString *username )
    {
        self.loggedIn = YES;
    }
    errorBlock:^( NSError *error )
    {
        self.loggedIn = NO;
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
            completion( YES );
        }
        errorBlock:^( NSError *error )
        {
            self.loggedIn = NO;
            self.oAuthToken = nil;
            self.oAuthTokenSecret = nil;
            
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
    errorBlock:^(NSError *error)
    {
        completion( NO );
    }];
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
        }
    }
    
    [self.authTwitterAPI postAccessTokenRequestWithPIN:verifier
    successBlock:^( NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName )
    {
        self.oAuthToken       = oauthToken;
        self.oAuthTokenSecret = oauthTokenSecret;
        
        self.loggedIn = YES;
        
        [SSKeychain setPassword:oauthToken       forService:kTwitterToken       account:kTwitterTokenAccount];
        [SSKeychain setPassword:oauthTokenSecret forService:kTwitterTokenSecret account:kTwitterTokenAccount];
        
        if( self.currentCallbackBlock )
        {
            self.currentCallbackBlock( YES );
        }
    }
    errorBlock:^( NSError *error )
    {
        self.loggedIn = NO;
        
        if( self.currentCallbackBlock )
        {
            self.currentCallbackBlock( NO );
        }
    }];
}

- (void)postDishReviewTweetWithMessage:(NSString *)message imageURL:(NSString *)imageURL completion:(DATwitterSuccessBlock)completion
{
    if( !self.loggedIn )
    {
        completion( NO );
        return;
    }
    
    NSURL *url = [NSURL URLWithString:imageURL];
    
    [self.authTwitterAPI postStatusUpdate:message inReplyToStatusID:nil mediaURL:url placeID:nil latitude:nil longitude:nil
    uploadProgressBlock:nil successBlock:^( NSDictionary *status )
    {
        completion( YES );
    }
    errorBlock:^( NSError *error )
    {
        completion( NO );
    }];
}

@end