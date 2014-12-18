//
//  AutoComleteTableView.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishSuggestionsTableView.h"
#import "DAReviewFormViewController.h"
#import "DADishSuggestionTableViewCell.h"

static NSString *const kDishSuggestionCellIdentifier = @"suggestionCell";


@interface DADishSuggestionsTableView()

@property (strong, nonatomic) NSArray          *dishSearchResults;
@property (strong, nonatomic) NSURLSessionTask *searchTask;

@end


@implementation DADishSuggestionsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        _dishSearchResults = [NSArray array];
        self.delegate = self;
        self.dataSource	= self;
        
        UINib *broadcastCellNib = [UINib nibWithNibName:NSStringFromClass( [DADishSuggestionTableViewCell class] ) bundle:nil];
        [self registerNib:broadcastCellNib forCellReuseIdentifier:kDishSuggestionCellIdentifier];
        
        self.rowHeight = 44.0;
    }
    
    return self;
}

- (void)updateSuggestionsWithQuery:(NSString *)query
{
    if( self.searchTask )
    {
        [self.searchTask cancel];
    }
    
    NSDictionary *parameters = @{ kNameKey : query };
    
    self.searchTask = [[DAAPIManager sharedManager] GETRequest:kDishSearchURL withParameters:parameters
    success:^( id response )
    {
        self.dishSearchResults = [self dishesWithResponse:response];
        
        self.hidden = NO;
        
        [self reloadData];
    }
    failure:^( NSError *error, BOOL shouldRetry )
    {
        self.hidden = YES;
    }];
}

- (void)cancelSearchQuery
{
    if( self.searchTask )
    {
        [self.searchTask cancel];
    }
}

- (NSArray *)dishesWithResponse:(id)response
{
    NSArray *dishes = response[kDataKey];
    NSMutableArray *newDishes = [NSMutableArray array];
    
    for( NSDictionary *dishInfo in dishes )
    {
        NSMutableDictionary *newDish = [NSMutableDictionary dictionary];
        
        newDish[kIDKey]           = dishInfo[kIDKey];
        newDish[kNameKey]         = dishInfo[kNameKey];
        newDish[kTypeKey]         = dishInfo[kTypeKey];
        newDish[kPriceKey]        = dishInfo[kPriceKey];
        newDish[kLocationIDKey]   = dishInfo[kLocationIDKey];
        newDish[kLocationNameKey] = dishInfo[kLocationNameKey];
        
        [newDishes addObject:newDish];
    }
    
    return newDishes;
}

- (void)resetTable
{
    [self.searchTask cancel];
    self.dishSearchResults = [NSArray array];
    [self reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dishSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DADishSuggestionTableViewCell *cell = (DADishSuggestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kDishSuggestionCellIdentifier];
    
    cell.placeLabel.text = [[self.dishSearchResults objectAtIndex:indexPath.row] objectForKey:kLocationNameKey];
    cell.nameLabel.text  = [[self.dishSearchResults objectAtIndex:indexPath.row] objectForKey:kNameKey];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedDishInfo = self.dishSearchResults[indexPath.row];
    NSString *dishName     = selectedDishInfo[kNameKey];
    NSString *dishID       = selectedDishInfo[kIDKey];
    NSString *dishType     = selectedDishInfo[kTypeKey];
    NSString *dishPrice    = selectedDishInfo[kPriceKey];
    NSString *locationName = selectedDishInfo[kLocationNameKey];
    NSString *locationID   = selectedDishInfo[kLocationIDKey];
    
    if( [self.suggestionDelegate respondsToSelector:@selector(didSelectSuggestionWithDishName:dishType:dishID:dishPrice:locationName:locationID:)] )
    {
        [self.suggestionDelegate didSelectSuggestionWithDishName:dishName dishType:dishType dishID:[dishID integerValue] dishPrice:dishPrice locationName:locationName locationID:[locationID integerValue]];
    }
    
    self.hidden = YES;
}

@end
