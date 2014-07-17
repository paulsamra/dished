//
//  AutoComleteTableView.m
//  Dished
//
//  Created by Daryl Stimm on 7/8/14.
//  Copyright (c) 2014 Dished. All rights reserved.
//

#import "DADishSuggestionsTableView.h"
#import "DAFormTableViewController.h"
#import "DAAPIManager.h"
#import "DADishSuggestionTableViewCell.h"

static NSString *kDishNameKey     = @"name";
static NSString *kDishIDKey       = @"id";
static NSString *kLocationNameKey = @"loc_name";
static NSString *kLocationIDKey   = @"loc_id";


@interface DADishSuggestionsTableView()

@property (strong, nonatomic) NSMutableArray   *dishSearchResults;
@property (strong, nonatomic) NSURLSessionTask *searchTask;

@end


@implementation DADishSuggestionsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if( self )
    {
        _dishSearchResults = [[NSMutableArray alloc] init];
        self.delegate = self;
        self.dataSource	= self;
        
        UINib *broadcastCellNib = [UINib nibWithNibName:@"DADishSuggestionTableViewCell" bundle:nil];
        [self registerNib:broadcastCellNib forCellReuseIdentifier:@"suggestionCell"];
    }
    
    return self;
}

- (void)updateSuggestionsWithQuery:(NSString *)query dishType:(NSString *)dishType;
{
    [self.dishSearchResults removeAllObjects];
    [self reloadData];
    
    if( self.searchTask )
    {
        [self.searchTask cancel];
    }
    
    self.searchTask = [[DAAPIManager sharedManager] dishTitleSuggestionTaskWithQuery:query dishType:dishType
    completion:^( id responseData, NSError *error )
    {
        if( responseData )
        {
            NSArray *searchResults = (NSArray *)responseData;
            
            for( NSDictionary *dishInfo in searchResults )
            {
                NSMutableDictionary *newDish = [NSMutableDictionary dictionary];
                newDish[kDishNameKey]      = dishInfo[kDishNameKey];
                newDish[kDishIDKey]        = dishInfo[kDishIDKey];
                newDish[kLocationNameKey]  = dishInfo[kLocationNameKey];
                newDish[kLocationIDKey]    = dishInfo[kLocationIDKey];
                
                [self.dishSearchResults addObject:newDish];
            }
            
            [self reloadData];
        }
    }];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dishSearchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DADishSuggestionTableViewCell *cell = (DADishSuggestionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"suggestionCell"];
    
    cell.placeLabel.text = [[self.dishSearchResults objectAtIndex:indexPath.row] objectForKey:kLocationNameKey];
    cell.nameLabel.text  = [[self.dishSearchResults objectAtIndex:indexPath.row] objectForKey:kDishNameKey];
    
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedDishInfo = self.dishSearchResults[indexPath.row];
    NSString *dishName = selectedDishInfo[kDishNameKey];
    NSString *dishID   = selectedDishInfo[kDishIDKey];
    NSString *locationName = selectedDishInfo[kLocationNameKey];
    NSString *locationID   = selectedDishInfo[kLocationIDKey];
    
    if( [self.suggestionDelegate respondsToSelector:@selector(selectedSuggestionWithDishName:dishID:locationName:locationID:)] )
    {
        [self.suggestionDelegate selectedSuggestionWithDishName:dishName dishID:dishID locationName:locationName locationID:locationID];
    }
    
    self.hidden = YES;
}

@end
