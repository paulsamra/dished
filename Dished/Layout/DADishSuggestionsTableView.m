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
    }
    
    return self;
}

- (void)updateSuggestionsWithQuery:(NSString *)query;
{
    [self.dishSearchResults removeAllObjects];
    [self reloadData];
    
    if( self.searchTask )
    {
        [self.searchTask cancel];
    }
    
    self.searchTask = [[DAAPIManager sharedManager] dishTitleSuggestionTaskWithQuery:query dishType:kFood
    completion:^( id responseData, NSError *error )
    {
        if( responseData )
        {
            NSArray *searchResults = (NSArray *)responseData;
            
            for( NSDictionary *dishInfo in searchResults )
            {
                NSMutableDictionary *newDish = [NSMutableDictionary dictionary];
                newDish[@"dish_name"] = dishInfo[@"name"];
                newDish[@"dish_id"]   = dishInfo[@"id"];
                newDish[@"loc_name"]  = dishInfo[@"loc_name"];
                newDish[@"loc_id"]    = dishInfo[@"loc_id"];
                
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
    UITableViewCell *cell = nil;
    
    static NSString *AutoCompleteRowIdentifier = @"AutoCompleteRowIdentifier";
    
    cell = [tableView dequeueReusableCellWithIdentifier:AutoCompleteRowIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AutoCompleteRowIdentifier];
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    UIImageView *iconPlaceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_dish_location.png"]];
    UILabel *location = [[UILabel alloc] initWithFrame:CGRectMake(225, 44/2 - 7.5, 80, 30/2)];
    location.text = [[self.dishSearchResults objectAtIndex:indexPath.row] objectForKey:@"loc_name"];
    location.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
    location.textColor = [UIColor lightGrayColor];
    [backgroundView addSubview:iconPlaceImage];
    [backgroundView addSubview:location];
    iconPlaceImage.frame = CGRectMake(210, 44/2 - 7.5, 21/2, 30/2);
    cell.backgroundView = backgroundView;
    cell.textLabel.text = [[self.dishSearchResults objectAtIndex:indexPath.row] objectForKey:@"dish_name"];
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedDishInfo = self.dishSearchResults[indexPath.row];
    NSString *dishName = selectedDishInfo[@"dish_name"];
    NSString *dishID   = selectedDishInfo[@"dish_id"];
    NSString *locationName = selectedDishInfo[@"loc_name"];
    NSString *locationID   = selectedDishInfo[@"loc_id"];
    
    if( [self.suggestionDelegate respondsToSelector:@selector(selectedSuggestionWithDishName:dishID:locationName:locationID:)] )
    {
        [self.suggestionDelegate selectedSuggestionWithDishName:dishName dishID:dishID locationName:locationName locationID:locationID];
    }
    
    self.hidden = YES;
}

@end
