//
//  DANewsManager.m
//  Dished
//
//  Created by Ryan Khalili on 9/24/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DANewsManager.h"
#import "DAAPIManager.h"


@interface DANewsManager()

@property (strong, nonatomic) NSMutableArray *newsData;
@property (strong, nonatomic) NSMutableArray *followingData;

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
    [self updateAllNewsWithCompletion:nil];
}

- (void)updateAllNewsWithCompletion:( void (^)( BOOL success ) )completion
{
    if( ![[DAAPIManager sharedManager] isLoggedIn] )
    {
        return;
    }
    
    dispatch_group_t group = dispatch_group_create();
    
    __block BOOL successful = YES;
    
    dispatch_group_enter( group );
    NSInteger newsLimit = self.newsData.count > 0 ? self.newsData.count : self.loadLimit;
    [[DAAPIManager sharedManager] getNewsNotificationsWithLimit:newsLimit offset:0 completion:^( id response, NSError *error )
    {
        self.newsFinishedLoading = YES;
        
        if( !response || error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                self.hasMoreNewsNotifications = NO;
            }
            else
            {
                successful &= NO;
            }
        }
        else
        {
            self.newsData = [self newsDataWithData:response];
            [self setBadgeValuesWithData:response];
            self.hasMoreNewsNotifications = !( self.newsData.count < self.loadLimit );
            [self notifyNewsObservers];
        }
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_enter( group );
    NSInteger followingLimit = self.followingData.count > 0 ? self.followingData.count : self.loadLimit;
    [[DAAPIManager sharedManager] getFollowingNotificationsWithLimit:followingLimit offset:0 completion:^( id response, NSError *error )
    {
        self.followingFinishedLoading = YES;
        
        if( !response || error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                self.hasMoreFollowingNotifications = NO;
            }
            else
            {
                successful &= NO;
            }
        }
        else
        {
            self.followingData = [self followingDataWithData:response];
            self.hasMoreFollowingNotifications = !( self.followingData.count < self.loadLimit );
            [self notifyFollowingObservers];
        }
        
        dispatch_group_leave( group );
    }];
    
    dispatch_group_notify( group, dispatch_get_main_queue(), ^
    {
        if( completion )
        {
            completion( successful );
        }
    });
}

- (void)refreshNewsWithCompletion:(DANewsManagerCompletionBlock)completion
{
    NSInteger limit = self.newsData.count + self.loadLimit;
    
    [[DAAPIManager sharedManager] getNewsNotificationsWithLimit:limit offset:0 completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                self.hasMoreNewsNotifications = NO;
                completion( YES );
            }
            else
            {
                completion( NO );
            }
        }
        else
        {
            self.newsData = [self newsDataWithData:response];
            [self setBadgeValuesWithData:response];
            
            self.hasMoreNewsNotifications = !( self.newsData.count < limit );
            
            completion( YES );
        }
    }];
}

- (void)refreshFollowingWithCompletion:(DANewsManagerCompletionBlock)completion
{
    NSInteger limit = self.followingData.count + self.loadLimit;
    
    [[DAAPIManager sharedManager] getFollowingNotificationsWithLimit:limit offset:0 completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                self.hasMoreFollowingNotifications = NO;
                completion( YES );
            }
            else
            {
                completion( NO );
            }
        }
        else
        {
            self.followingData = [self followingDataWithData:response];
            self.hasMoreFollowingNotifications = !( self.followingData.count < limit );
            completion( YES );
        }
    }];
}

- (void)loadMoreNewsWithCompletion:(DANewsManagerCompletionBlock)completion
{
    NSInteger offset = self.newsData.count;
    
    [[DAAPIManager sharedManager] getNewsNotificationsWithLimit:self.loadLimit offset:offset completion:^( id response, NSError *error )
    {
        if( error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                self.hasMoreNewsNotifications = NO;
                completion( YES );
            }
            else
            {
                completion( NO );
            }
        }
        else
        {
            NSMutableArray *newData = [self newsDataWithData:response];
            [self.newsData addObjectsFromArray:newData];
            
            self.hasMoreNewsNotifications = !( newData.count < self.loadLimit );
            
            completion( YES );
        }
    }];
}

- (void)loadMoreFollowingWithCompletion:(DANewsManagerCompletionBlock)completion
{
    NSInteger offset = self.followingData.count;
    
    [[DAAPIManager sharedManager] getFollowingNotificationsWithLimit:self.loadLimit offset:offset completion:^( id response, NSError *error )
    {
        if( !response || error )
        {
            eErrorType errorType = [DAAPIManager errorTypeForError:error];
            
            if( errorType == eErrorTypeDataNonexists )
            {
                self.hasMoreFollowingNotifications = NO;
                completion( YES );
            }
            else
            {
                completion( NO );
            }
        }
        else
        {
            NSMutableArray *newData = [self followingDataWithData:response];
            [self.followingData addObjectsFromArray:newData];
            
            self.hasMoreFollowingNotifications = !( newData.count < self.loadLimit );
            
            completion( YES );
        }
    }];
}

- (void)setBadgeValuesWithData:(id)data
{
    NSDictionary *response = nilOrJSONObjectForKey( data, kDataKey );
    
    if( response && [response isKindOfClass:[NSDictionary class]] )
    {
        self.num_yums    = [response[@"num_yum"]    integerValue];
        self.num_reviews = [response[@"num_review"] integerValue];
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

- (NSArray *)newsNotifications
{
    return self.newsData;
}

- (NSArray *)followingNotifications
{
    return self.followingData;
}

@end