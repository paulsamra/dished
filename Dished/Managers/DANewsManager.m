//
//  DANewsManager.m
//  Dished
//
//  Created by Ryan Khalili on 9/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsManager.h"


@interface DANewsManager()

@property (strong, nonatomic) NSMutableArray   *newsData;
@property (strong, nonatomic) NSMutableArray   *followingData;
@property (strong, nonatomic) NSURLSessionTask *userNewsUpdateTask;
@property (strong, nonatomic) NSURLSessionTask *followingNewsUpdateTask;

@property (nonatomic, readwrite) BOOL      newsFinishedLoading;
@property (nonatomic, readwrite) BOOL      followingFinishedLoading;
@property (nonatomic, readwrite) BOOL      hasMoreNewsNotifications;
@property (nonatomic, readwrite) BOOL      hasMoreFollowingNotifications;
@property (nonatomic, readwrite) NSInteger num_reviews;
@property (nonatomic, readwrite) NSInteger num_yums;

@end


@implementation DANewsManager

+ (DANewsManager *)sharedManager
{
    static DANewsManager *manager = nil;
    
    static dispatch_once_t singleton;
    
    dispatch_once(&singleton, ^{
        manager = [[DANewsManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    if( self = [super init] )
    {
        _newsData      = [NSMutableArray array];
        _followingData = [NSMutableArray array];
        
        _newsFinishedLoading = NO;
        _followingFinishedLoading = NO;
        
        _hasMoreNewsNotifications = YES;
        _hasMoreFollowingNotifications = YES;
        
        _num_yums = 0;
        _num_reviews = 0;
        
        _loadLimit = 25;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNews) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNews) name:UIApplicationDidFinishLaunchingNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateNews
{
    [self updateAllNews];
}

- (void)updateAllNews
{
    if( ![[DAAPIManager sharedManager] isLoggedIn] )
    {
        return;
    }
    
    [self.userNewsUpdateTask      cancel];
    [self.followingNewsUpdateTask cancel];
    
    NSInteger userLimit = self.newsData.count > 0 ? self.newsData.count : self.loadLimit;
    NSInteger followingLimit = self.followingData.count > 0 ? self.followingData.count : self.loadLimit;
    
    [self updateUserNewsWithLimit:userLimit offset:0 completion:nil];
    [self updateFollowingNewsWithLimit:followingLimit offset:0 completion:nil];
}

- (void)updateUserNewsWithLimit:(NSInteger)limit offset:(NSInteger)offset completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kTypeKey : kUserKey, kRowLimitKey : @(limit), kRowOffsetKey : @(offset) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    self.userNewsUpdateTask = [[DAAPIManager sharedManager] GET:kUsersNewsURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        self.newsFinishedLoading = YES;

        NSMutableArray *newData = [self newsDataWithData:responseObject];
        offset > 0 ? [self.newsData addObjectsFromArray:newData] : ( self.newsData = newData );
        
        [self setBadgeValuesWithData:responseObject];
        self.hasMoreNewsNotifications = !( self.newsData.count < self.loadLimit );
        [self notifyNewsObservers];
        
        if( completion )
        {
            completion( YES );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        self.newsFinishedLoading = YES;

        eErrorType errorType = [DAAPIManager errorTypeForError:error];
        
        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^( BOOL success )
            {
                if( success )
                {
                    [self updateUserNewsWithLimit:limit offset:offset completion:completion];
                }
                else
                {
                    if( completion )
                    {
                        completion( NO );
                    }
                }
            }];
        }
        else if( errorType == eErrorTypeDataNonexists )
        {
            self.hasMoreNewsNotifications = NO;
            
            if( completion )
            {
                completion( NO );
            }
        }
        else
        {
            if( completion )
            {
                completion( NO );
            }
        }
    }];
}

- (void)updateFollowingNewsWithLimit:(NSInteger)limit offset:(NSInteger)offset completion:( void(^)( BOOL success ) )completion
{
    NSDictionary *parameters = @{ kTypeKey : kFollowing, kRowLimitKey : @(limit), kRowOffsetKey : @(offset) };
    parameters = [[DAAPIManager sharedManager] authenticatedParametersWithParameters:parameters];
    
    self.followingNewsUpdateTask = [[DAAPIManager sharedManager] GET:kUsersNewsURL parameters:parameters
    success:^( NSURLSessionDataTask *task, id responseObject )
    {
        self.followingFinishedLoading = YES;
        
        NSMutableArray *newData = [self followingDataWithData:responseObject];
        offset > 0 ? [self.followingData addObjectsFromArray:newData] : ( self.followingData = newData );
        
        self.hasMoreFollowingNotifications = !( self.followingData.count < self.loadLimit );
        [self notifyFollowingObservers];
        
        if( completion )
        {
            completion( YES );
        }
    }
    failure:^( NSURLSessionDataTask *task, NSError *error )
    {
        self.followingFinishedLoading = YES;
        
        eErrorType errorType = [DAAPIManager errorTypeForError:error];

        if( [DAAPIManager errorTypeForError:error] == eErrorTypeExpiredAccessToken )
        {
            [[DAAPIManager sharedManager] refreshAuthenticationWithCompletion:^( BOOL success )
            {
                if( success )
                {
                    [self updateFollowingNewsWithLimit:limit offset:offset completion:completion];
                }
                else
                {
                    if( completion )
                    {
                        completion( NO );
                    }
                }
            }];
        }
        else if( errorType == eErrorTypeDataNonexists )
        {
            self.hasMoreFollowingNotifications = NO;
            
            if( completion )
            {
                completion( NO );
            }
        }
        else
        {
            if( completion )
            {
                completion( NO );
            }
        }
    }];
}

- (void)refreshNewsWithCompletion:(DANewsManagerCompletionBlock)completion
{
    NSInteger limit = self.newsData.count > 0 ? self.newsData.count : self.loadLimit;
    
    [self updateUserNewsWithLimit:limit offset:0 completion:completion];
}

- (void)refreshFollowingWithCompletion:(DANewsManagerCompletionBlock)completion
{
    NSInteger limit = self.followingData.count > 0 ? self.followingData.count : self.loadLimit;
    
    [self updateFollowingNewsWithLimit:limit offset:0 completion:completion];
}

- (void)loadMoreNewsWithCompletion:(DANewsManagerCompletionBlock)completion
{
    [self updateUserNewsWithLimit:self.loadLimit offset:self.newsData.count completion:completion];
}

- (void)loadMoreFollowingWithCompletion:(DANewsManagerCompletionBlock)completion
{
    [self updateFollowingNewsWithLimit:self.loadLimit offset:self.followingData.count completion:completion];
}

- (void)setBadgeValuesWithData:(id)data
{
    NSDictionary *response = nilOrJSONObjectForKey( data, kDataKey );
    
    if( response && [response isKindOfClass:[NSDictionary class]] )
    {
        self.num_yums    = [nilOrJSONObjectForKey( response, @"num_yum" ) integerValue];
        self.num_reviews = [nilOrJSONObjectForKey( response, @"num_review" ) integerValue];
    }
}

- (void)notifyNewsObservers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsUpdatedNotificationKey object:nil];
}

- (void)notifyFollowingObservers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kFollowingUpdatedNotificationKey object:nil];
}

- (NSMutableArray *)newsDataWithData:(id)data
{
    NSArray *response = data[@"data"][@"activity_user"];
    NSMutableArray *news = [NSMutableArray array];
    
    if( response && ![response isEqual:[NSNull null]] && [response isKindOfClass:[NSArray class]] )
    {
        for( NSDictionary *dataObject in response )
        {
            [news addObject:[DAUserNews userNewsWithData:dataObject]];
        }
    }
    
    return news;
}

- (NSMutableArray *)followingDataWithData:(id)data
{
    NSArray *response = data[@"data"][@"activity_following"];
    NSMutableArray *following = [NSMutableArray array];
    
    if( response && ![response isEqual:[NSNull null]] && [response isKindOfClass:[NSArray class]] )
    {
        for( NSDictionary *dataObject in response )
        {
            [following addObject:[DAFollowingNews followingNewsWithData:dataObject]];
        }
    }
    
    return following;
}

- (void)deleteAllNews
{
    self.newsData = [NSMutableArray array];
    self.followingData = [NSMutableArray array];
    
    self.newsFinishedLoading = NO;
    self.followingFinishedLoading = NO;
    
    self.hasMoreNewsNotifications = YES;
    self.hasMoreFollowingNotifications = YES;
    
    self.num_yums = 0;
    self.num_reviews = 0;
    
    self.loadLimit = 25;
}

- (NSArray *)newsNotifications
{
    return self.newsData;
}

- (NSArray *)followingNotifications
{
    return self.followingData;
}

@end